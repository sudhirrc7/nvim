-- Receive ONE problem from Competitive Companion.
--
-- Browser extension settings -> Custom ports -> 12345
--
-- Press <leader>ib in the solution, then click the green "+"
-- on the problem page. The samples replace every existing test
-- in the solution's folder:
--     input.txt  / output.txt   <- sample 1
--     input1.txt / output1.txt  <- sample 2 ...
-- Press <leader>ib again while waiting to cancel.
local config = require("cp.config")
local files = require("cp.files")
local views = require("cp.views")

local M = {}

local PORT, WAIT = config.COMPANION_PORT, config.COMPANION_WAIT

-- { server, timer } while listening
local listening = nil

local function stop()
    if not listening then
        return
    end

    for _, handle in ipairs({ listening.timer, listening.server }) do
        if not handle:is_closing() then
            handle:close()
        end
    end

    listening = nil
end

local function receive(dir, body)
    local ok, problem = pcall(vim.json.decode, body)

    if not ok or type(problem) ~= "table" or type(problem.tests) ~= "table" then
        vim.notify(
            "Competitive Companion sent something unexpected",
            vim.log.levels.ERROR
        )
        return
    end

    local tests = problem.tests

    if #tests == 0 then
        vim.notify(
            (problem.name or "Problem") .. " has no samples · tests unchanged",
            vim.log.levels.WARN
        )
        return
    end

    -- The panel / editor may show files that are about to change
    views.close_all()

    -- Write samples, reloading any buffer that already shows the file
    for i, test in ipairs(tests) do
        local input, output = files.test_files(dir, i - 1)

        for _, file in ipairs({
            { input, test.input },
            { output, test.output },
        }) do
            vim.fn.writefile(files.split_lines(file[2]), file[1])
            files.reload(file[1])
        end
    end

    -- Remove old tests beyond the new ones
    files.delete_tests(dir, #tests, true)

    local details = { problem.name or "Problem", #tests .. " tests" }

    if problem.timeLimit then
        table.insert(
            details,
            string.format("TL %g s", problem.timeLimit / 1000)
        )
    end

    if problem.memoryLimit then
        table.insert(details, "ML " .. problem.memoryLimit .. " MB")
    end

    vim.notify(table.concat(details, " · "), vim.log.levels.INFO)

    if problem.interactive then
        vim.notify(
            "Interactive problem: the samples can't be checked automatically",
            vim.log.levels.WARN
        )
    end

    views.show(views.panel, 1, 1, dir)
end

-- Minimal HTTP: read one POST request, reply 200, hand over the body
local function accept(server, dir)
    local client = vim.uv.new_tcp()

    if not client or server:accept(client) ~= 0 then
        return
    end

    local data = ""
    local done = false

    local function finish(body)
        done = true
        client:read_stop()
        client:write(
            "HTTP/1.1 200 OK\r\nContent-Length: 0\r\nConnection: close\r\n\r\n",
            function()
                client:close()
            end
        )

        vim.schedule(function()
            -- Already handled or cancelled
            if not listening then
                return
            end

            stop()
            receive(dir, body)
        end)
    end

    client:read_start(function(err, chunk)
        if done then
            return
        end

        if err or not chunk then
            -- Connection ended before a full request
            client:close()
            return
        end

        data = data .. chunk

        local head_end = data:find("\r\n\r\n", 1, true)

        if not head_end then
            return
        end

        local headers = data:sub(1, head_end):lower()
        local length = tonumber(headers:match("content%-length:%s*(%d+)")) or 0
        local body = data:sub(head_end + 4)

        if #body >= length then
            finish(body)
        end
    end)
end

-- Start listening, or stop when already waiting
function M.toggle()
    if listening then
        stop()
        vim.notify("Stopped waiting for Competitive Companion")
        return
    end

    local dir = views.dir()

    if not dir then
        return
    end

    local server = assert(vim.uv.new_tcp())
    local ok, err = server:bind("127.0.0.1", PORT)

    if ok then
        ok, err = server:listen(16, function(listen_err)
            if not listen_err then
                accept(server, dir)
            end
        end)
    end

    if not ok then
        server:close()
        vim.notify(
            "Can't listen on port "
                .. PORT
                .. " ("
                .. tostring(err)
                .. "). Is another Neovim waiting?",
            vim.log.levels.ERROR
        )
        return
    end

    local timer = assert(vim.uv.new_timer())

    timer:start(
        WAIT * 1000,
        0,
        vim.schedule_wrap(function()
            if listening and listening.timer == timer then
                stop()
                vim.notify(
                    "No problem received in " .. WAIT .. " s",
                    vim.log.levels.WARN
                )
            end
        end)
    )

    listening = { server = server, timer = timer }

    vim.notify(
        "Waiting for Competitive Companion on port "
            .. PORT
            .. " · click + in the browser"
    )
end

return M
