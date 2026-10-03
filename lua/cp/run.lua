-- CP runner: build once, run every test against inputN.txt.
--
-- C / C++ / Rust / Go / Java are compiled ONCE per run and the
-- same binary is reused for every test.
--
-- The time limit applies to each test's execution only.
-- Compile time is never counted.
local config = require("cp.config")
local files = require("cp.files")
local report = require("cp.report")

local M = {}

local LANGS = config.LANGS
local INFO, WARN, ERROR =
    vim.log.levels.INFO, vim.log.levels.WARN, vim.log.levels.ERROR

-- ============================================================
-- Current file context (saves the file)
-- ============================================================

local function context()
    local buf = vim.api.nvim_get_current_buf()

    -- Called from a test pane: use the solution shown in another window
    if not LANGS[vim.bo[buf].filetype] then
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local b = vim.api.nvim_win_get_buf(win)

            if
                LANGS[vim.bo[b].filetype]
                and vim.api.nvim_buf_get_name(b) ~= ""
            then
                buf = b
                break
            end
        end
    end

    local file = vim.api.nvim_buf_get_name(buf)
    local ft = vim.bo[buf].filetype

    if file == "" then
        vim.notify("Please save the file first", WARN)
        return nil
    end

    local lang = LANGS[ft]

    if not lang then
        vim.notify("Unsupported filetype: " .. ft, WARN)
        return nil
    end

    vim.api.nvim_buf_call(buf, function()
        vim.cmd("write")
    end)

    return {
        file = file,
        dir = vim.fn.fnamemodify(file, ":h"),
        name = vim.fn.fnamemodify(file, ":t"),
        ft = ft,
        lang = lang,
    }
end

-- ============================================================
-- Run a process directly (no shell)
--
-- Time is measured from spawn to process exit inside the libuv
-- callback, so editor work (notifications, redraws) never leaks
-- into the measurement.
-- ============================================================

local function exec(argv, opts, on_done)
    local stdin = assert(vim.uv.new_pipe())
    local stdout = assert(vim.uv.new_pipe())
    local stderr = assert(vim.uv.new_pipe())
    local timer = assert(vim.uv.new_timer())

    local out, err = {}, {}
    local res = { code = 0, signal = 0, time = 0 }
    local pending = 3 -- process exit + stdout EOF + stderr EOF
    local handle, spawn_err

    local function finish()
        pending = pending - 1

        if pending > 0 then
            return
        end

        timer:stop()
        timer:close()
        handle:close()

        res.stdout = table.concat(out)
        res.stderr = table.concat(err)

        vim.schedule(function()
            on_done(res)
        end)
    end

    local start = vim.uv.hrtime()

    handle, spawn_err = vim.uv.spawn(argv[1], {
        args = vim.list_slice(argv, 2),
        stdio = { stdin, stdout, stderr },
        cwd = opts.cwd,
    }, function(code, signal)
        res.time = (vim.uv.hrtime() - start) / 1e6
        res.code = code
        res.signal = signal
        res.exited = true
        finish()
    end)

    if not handle then
        for _, h in ipairs({ stdin, stdout, stderr, timer }) do
            h:close()
        end

        vim.schedule(function()
            on_done({
                spawn_error = argv[1] .. ": " .. tostring(spawn_err),
                code = -1,
                signal = 0,
                time = 0,
                stdout = "",
                stderr = "",
            })
        end)

        return
    end

    local function kill()
        if not res.exited then
            handle:kill("sigkill")
        end
    end

    local function read(pipe, chunks)
        local bytes = 0

        pipe:read_start(function(_, data)
            if not data then
                pipe:close()
                finish()
                return
            end

            bytes = bytes + #data

            if bytes > config.OUTPUT_LIMIT then
                res.output_limit = true
                kill()
                return
            end

            table.insert(chunks, data)
        end)
    end

    read(stdout, out)
    read(stderr, err)

    if opts.timeout then
        timer:start(opts.timeout, 0, function()
            if not res.exited then
                res.timed_out = true
                kill()
            end
        end)
    end

    -- Send input, then close stdin so EOF-readers don't hang
    if opts.input and opts.input ~= "" then
        stdin:write(opts.input)
    end

    stdin:shutdown(function()
        stdin:close()
    end)
end

local function classify(res)
    if res.spawn_error then
        return "ERR"
    elseif res.timed_out then
        return "TLE"
    elseif res.output_limit then
        return "OLE"
    elseif res.code ~= 0 or res.signal ~= 0 then
        return "RE"
    end

    return "OK"
end

-- ============================================================
-- Build once, run every test, hand results to on_done
--
-- opts.need_expected  compare against outputN.txt
-- opts.stop_on_error  stop at the first crash / timeout
-- opts.on_test(r)     called after every test
-- ============================================================

local busy = false

local function run(opts, on_done)
    if busy then
        vim.notify("CP run already in progress", WARN)
        return
    end

    local ctx = context()

    if not ctx then
        return
    end

    -- Run against what's on screen, not stale files
    files.save_tests(ctx.dir)

    local tests, find_err = files.find_tests(ctx.dir, opts.need_expected)

    if not tests then
        vim.notify(find_err, WARN)
        return
    end

    report.close()
    busy = true

    local out = vim.fn.tempname()
    local run_argv = ctx.lang.run(ctx.file, out)

    local function cleanup()
        vim.fn.delete(out, "rf")
        busy = false
    end

    local function run_tests()
        local results = {}

        local function step(i)
            local last = results[#results]
            local stop = opts.stop_on_error and last and last.status ~= "AC"

            if i > #tests or stop then
                cleanup()
                on_done(ctx, results)
                return
            end

            local test = tests[i]
            local input = files.read(test.input)

            if input ~= "" and input:sub(-1) ~= "\n" then
                input = input .. "\n"
            end

            exec(run_argv, {
                cwd = ctx.dir,
                input = input,
                timeout = config.TIMEOUT * 1000,
            }, function(res)
                local r = {
                    test = test,
                    status = classify(res),
                    time = res.time,
                    code = res.code,
                    signal = res.signal,
                    spawn_error = res.spawn_error,
                    actual = files.normalize(res.stdout),
                    stderr = files.normalize(res.stderr),
                }

                if r.status == "TLE" then
                    r.time = config.TIMEOUT * 1000
                elseif r.status == "OK" then
                    r.status = "AC"

                    if opts.need_expected then
                        r.expected = files.normalize(files.read(test.output))

                        if not vim.deep_equal(r.expected, r.actual) then
                            r.status = "WA"
                        end
                    end
                end

                table.insert(results, r)

                if opts.on_test then
                    opts.on_test(r)
                end

                step(i + 1)
            end)
        end

        step(1)
    end

    if not ctx.lang.build then
        run_tests()
        return
    end

    vim.notify("Compiling " .. ctx.name .. "...", INFO)

    exec(ctx.lang.build(ctx.file, out), {
        cwd = ctx.dir,
        timeout = 120 * 1000,
    }, function(res)
        if classify(res) ~= "OK" then
            cleanup()
            report.compile_error(ctx, res)
            return
        end

        local _, warnings = res.stderr:gsub(": warning", "")
        local msg = string.format("Compiled in %.1f s", res.time / 1000)

        if warnings > 0 then
            msg = msg .. string.format(" (%d warnings)", warnings)
        end

        vim.notify(msg .. " · running " .. #tests .. " tests", INFO)

        if not ctx.lang.native then
            run_tests()
            return
        end

        -- macOS scans a brand-new executable the first time it runs
        -- (~0.5 s). One untimed warm-up run keeps that out of Test 1.
        exec(run_argv, { cwd = ctx.dir, timeout = 3000 }, run_tests)
    end)
end

-- ============================================================
-- Actions
-- ============================================================

-- Compile + run the current file in a bottom terminal
local run_term_win = nil
local quick_out = {}

function M.quick()
    local ctx = context()

    if not ctx then
        return
    end

    local ft = ctx.ft
    quick_out[ft] = quick_out[ft] or vim.fn.tempname()

    local function shell(argv)
        return table.concat(vim.tbl_map(vim.fn.shellescape, argv), " ")
    end

    local cmd = shell(ctx.lang.run(ctx.file, quick_out[ft]))

    if ctx.lang.build then
        cmd = shell(ctx.lang.build(ctx.file, quick_out[ft])) .. " && " .. cmd
    end

    -- Reuse existing terminal window if it's still open,
    -- otherwise create a new bottom split
    if run_term_win and vim.api.nvim_win_is_valid(run_term_win) then
        vim.api.nvim_set_current_win(run_term_win)
        local old_buf = vim.api.nvim_get_current_buf()
        vim.cmd("enew") -- fresh empty buffer in the same window
        if vim.api.nvim_buf_is_valid(old_buf) then
            pcall(vim.api.nvim_buf_delete, old_buf, { force = true })
        end
    else
        vim.cmd("botright new")
        vim.cmd("resize 15")
        run_term_win = vim.api.nvim_get_current_win()
    end

    vim.fn.jobstart({ "sh", "-c", cmd }, { term = true, cwd = ctx.dir })
    vim.cmd("startinsert")
end

-- Build once, write program output into outputN.txt.
-- Stops at the first crash / timeout.
function M.generate()
    run({
        stop_on_error = true,
        on_test = function(r)
            if r.status == "AC" then
                vim.fn.writefile(r.actual, r.test.output)
                files.reload(r.test.output)
            end
        end,
    }, function(_, results)
        local last = results[#results]

        if last.status ~= "AC" then
            local b = report.builder()
            report.failure(b, last)
            report.show(b)

            vim.notify(
                last.test.name .. ": " .. config.STATUS[last.status][2],
                ERROR
            )
            return
        end

        vim.notify(
            string.format(
                "Generated %d outputs · max %s",
                #results,
                report.ms(report.stats(results).max)
            ),
            INFO
        )
    end)
end

-- Run all tests, compare with outputN.txt, show diffs
function M.check()
    run({ need_expected = true }, function(ctx, results)
        local stats = report.stats(results)

        if stats.failed == 0 then
            vim.notify(
                string.format(
                    "✓ All %d tests passed · max %s",
                    #results,
                    report.ms(stats.max)
                ),
                INFO
            )
            return
        end

        local b = report.builder()
        report.summary(b, ctx, results, "CP Results")

        for _, r in ipairs(results) do
            if r.status ~= "AC" then
                report.failure(b, r)
            end
        end

        report.show(b)

        vim.notify(string.format("%d/%d passed", stats.passed, #results), ERROR)
    end)
end

-- Quick pass/fail + timing summary for all tests
function M.summary()
    run({ need_expected = true }, function(ctx, results)
        local stats = report.stats(results)
        local b = report.builder()

        report.summary(b, ctx, results, "CP Summary")
        report.show(b)

        vim.notify(
            string.format(
                "%d/%d passed · max %s",
                stats.passed,
                #results,
                report.ms(stats.max)
            ),
            stats.failed == 0 and INFO or ERROR
        )
    end)
end

return M
