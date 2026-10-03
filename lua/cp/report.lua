-- CP result window: test summaries, diffs and compile errors
local config = require("cp.config")
local files = require("cp.files")

local M = {}

local STATUS = config.STATUS

local ns = vim.api.nvim_create_namespace("cp_results")
local result_buf = nil
local result_win = nil

function M.close()
    if result_win and vim.api.nvim_win_is_valid(result_win) then
        vim.api.nvim_win_close(result_win, true)
    end

    result_win = nil
end

-- `title` followed by a ─ rule, `width` cells wide in total
function M.rule(title, width)
    return title
        .. string.rep("─", math.max(4, width - vim.fn.strdisplaywidth(title)))
end

-- Collects lines made of { text, highlight } chunks
function M.builder()
    local b = { lines = {}, marks = {} }

    function b.add(chunks)
        local text, col = {}, 0

        for _, chunk in ipairs(chunks or {}) do
            if type(chunk) == "string" then
                chunk = { chunk }
            end

            table.insert(text, chunk[1])

            if chunk[2] then
                table.insert(b.marks, {
                    #b.lines,
                    col,
                    col + #chunk[1],
                    chunk[2],
                })
            end

            col = col + #chunk[1]
        end

        table.insert(b.lines, table.concat(text))
    end

    return b
end

function M.show(b)
    if not result_buf or not vim.api.nvim_buf_is_valid(result_buf) then
        result_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[result_buf].bufhidden = "wipe"
        pcall(vim.api.nvim_buf_set_name, result_buf, "CP Results")

        vim.keymap.set("n", "q", M.close, {
            buffer = result_buf,
            desc = "Close CP results",
        })
    end

    local buf = result_buf

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, b.lines)
    vim.bo[buf].modifiable = false

    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    for _, m in ipairs(b.marks) do
        vim.api.nvim_buf_set_extmark(buf, ns, m[1], m[2], {
            end_col = m[3],
            hl_group = m[4],
        })
    end

    local height =
        math.max(6, math.min(#b.lines, math.floor(vim.o.lines * 0.4)))

    if result_win and vim.api.nvim_win_is_valid(result_win) then
        vim.api.nvim_win_set_buf(result_win, buf)
        vim.api.nvim_win_set_height(result_win, height)
    else
        -- Bottom split, focus stays in the solution
        result_win = vim.api.nvim_open_win(buf, false, {
            split = "below",
            win = -1,
            height = height,
        })
    end

    local wo = vim.wo[result_win]
    wo.number = false
    wo.relativenumber = false
    wo.signcolumn = "no"
    wo.foldcolumn = "0"
    wo.wrap = false
    wo.list = false
    wo.spell = false

    vim.api.nvim_win_set_cursor(result_win, { 1, 0 })
end

-- ============================================================
-- Rendering
-- ============================================================

function M.ms(time)
    if time < 10 then
        return string.format("%.1f ms", time)
    end

    return string.format("%d ms", math.floor(time + 0.5))
end

local function format_time(r)
    if r.status == "TLE" then
        return "> " .. config.TIMEOUT .. " s"
    end

    return M.ms(r.time)
end

function M.stats(results)
    local stats = { passed = 0, failed = 0, max = 0, total = 0 }

    for _, r in ipairs(results) do
        if r.status == "AC" then
            stats.passed = stats.passed + 1
        else
            stats.failed = stats.failed + 1
        end

        stats.max = math.max(stats.max, r.time)
        stats.total = stats.total + r.time
    end

    return stats
end

function M.summary(b, ctx, results, title)
    local stats = M.stats(results)
    local ok = stats.failed == 0

    b.add({
        { " " .. title .. " ", "Title" },
        { " " .. ctx.name, "Comment" },
    })

    b.add({
        {
            string.format("  %d/%d passed", stats.passed, #results),
            ok and "DiagnosticOk" or "DiagnosticError",
        },
        {
            string.format(
                "  ·  max %s  ·  total %s",
                M.ms(stats.max),
                M.ms(stats.total)
            ),
            "Comment",
        },
    })

    b.add()

    for _, r in ipairs(results) do
        local s = STATUS[r.status]

        b.add({
            { "  " .. s[1] .. " ", s[3] },
            string.format("%-8s ", r.test.name),
            {
                string.format("%-12s", vim.fn.fnamemodify(r.test.input, ":t")),
                "Comment",
            },
            { string.format("%10s", format_time(r)), "Number" },
            r.status ~= "AC" and { "   " .. s[2], s[3] } or "",
        })
    end
end

-- Chunks for one diff cell. The part after the first
-- differing character is highlighted.
local function cell(text, other, hl)
    if text == nil then
        return { { "(missing)", "Comment" } }, 9
    elseif text == "" then
        return { { "(empty line)", "Comment" } }, 12
    end

    local width = vim.fn.strdisplaywidth(text)

    if not hl then
        return { text }, width
    end

    local p = 0
    other = other or ""

    while p < #text and p < #other and text:byte(p + 1) == other:byte(p + 1) do
        p = p + 1
    end

    return { text:sub(1, p), { text:sub(p + 1), hl } }, width
end

local function render_diff(b, expected, actual)
    local total = math.max(#expected, #actual)
    local mismatched = {}

    for i = 1, total do
        if expected[i] ~= actual[i] then
            table.insert(mismatched, i)
        end
    end

    if #expected == 0 then
        b.add({ { "   Expected output file is empty", "DiagnosticWarn" } })
    end

    b.add({
        {
            string.format(
                "   %d of %d lines differ · first at line %d",
                #mismatched,
                total,
                mismatched[1]
            ),
            "Comment",
        },
    })

    b.add()

    -- Short outputs: every line.
    -- Long outputs: differing lines with 2 lines of context.
    local rows = {}
    local shown = {}

    for _, i in ipairs(mismatched) do
        local from = total <= 30 and 1 or math.max(1, i - 2)
        local to = total <= 30 and total or math.min(total, i + 2)

        for j = from, to do
            shown[j] = true
        end
    end

    for i = 1, total do
        if shown[i] and #rows < 40 then
            table.insert(rows, i)
        end
    end

    local numw = math.max(4, #tostring(total))
    local colw = 12

    for _, i in ipairs(rows) do
        colw = math.max(colw, vim.fn.strdisplaywidth(expected[i] or ""))
    end

    local side_by_side = colw <= math.floor((vim.o.columns - numw - 12) / 2)

    if side_by_side then
        b.add({
            {
                string.format("     %" .. numw .. "s  ", "line")
                    .. "expected"
                    .. string.rep(" ", colw - 8)
                    .. " │ yours",
                "Comment",
            },
        })

        local prev = nil

        for _, i in ipairs(rows) do
            if prev and i ~= prev + 1 then
                b.add({
                    { "     " .. string.rep(" ", numw) .. "  ⋮", "Comment" },
                })
            end

            prev = i

            local bad = expected[i] ~= actual[i]
            local chunks = {
                bad and { "   ✗ ", "DiagnosticError" } or "     ",
                { string.format("%" .. numw .. "d  ", i), "LineNr" },
            }

            local left, width =
                cell(expected[i], actual[i], bad and "DiagnosticOk" or nil)
            local right =
                cell(actual[i], expected[i], bad and "DiagnosticError" or nil)

            vim.list_extend(chunks, left)
            table.insert(chunks, string.rep(" ", colw - width))
            table.insert(chunks, { " │ ", "Comment" })
            vim.list_extend(chunks, right)

            b.add(chunks)
        end
    else
        -- Lines too long for two columns: stack them
        for _, i in ipairs(rows) do
            if expected[i] ~= actual[i] then
                local left = cell(expected[i], actual[i], "DiagnosticOk")
                local right = cell(actual[i], expected[i], "DiagnosticError")

                b.add({ { "   ✗ line " .. i, "DiagnosticError" } })
                b.add(
                    vim.list_extend({ { "       expected │ ", "Comment" } }, left)
                )
                b.add(
                    vim.list_extend({ { "       yours    │ ", "Comment" } }, right)
                )
            end
        end
    end

    local hidden = 0

    for _, i in ipairs(mismatched) do
        if i > (rows[#rows] or 0) then
            hidden = hidden + 1
        end
    end

    if hidden > 0 then
        b.add({
            {
                string.format("   ... %d more differing lines", hidden),
                "Comment",
            },
        })
    end
end

function M.failure(b, r)
    local s = STATUS[r.status]
    local title = string.format(
        "── %s · %s · %s ",
        r.test.name,
        vim.fn.fnamemodify(r.test.input, ":t"),
        s[2]
    )

    if #b.lines > 0 then
        b.add()
    end

    b.add({ { M.rule(title, 60), s[3] } })

    if r.status == "WA" then
        render_diff(b, r.expected, r.actual)
    elseif r.status == "TLE" then
        b.add({
            {
                "   Killed after "
                    .. config.TIMEOUT
                    .. " s (compile time not included)",
                "Comment",
            },
        })
    elseif r.status == "OLE" then
        b.add({ { "   Program printed more than 64 MB", "Comment" } })
    elseif r.status == "ERR" then
        b.add({ { "   " .. r.spawn_error, "DiagnosticError" } })
    elseif r.signal ~= 0 then
        b.add({
            { "   Signal: ", "Comment" },
            {
                config.SIGNALS[r.signal] or ("signal " .. r.signal),
                "DiagnosticError",
            },
            { "  after " .. format_time(r), "Comment" },
        })
    else
        b.add({
            { "   Exit code: ", "Comment" },
            { tostring(r.code), "DiagnosticError" },
            { "  after " .. format_time(r), "Comment" },
        })
    end

    if #r.stderr > 0 then
        b.add()
        b.add({ { "   stderr:", "Comment" } })

        for i, line in ipairs(r.stderr) do
            if i > 30 then
                b.add({
                    {
                        string.format(
                            "   │ ... %d more lines",
                            #r.stderr - 30
                        ),
                        "Comment",
                    },
                })
                break
            end

            b.add({ { "   │ ", "Comment" }, line })
        end
    end
end

function M.compile_error(ctx, res)
    local b = M.builder()

    b.add({
        { " COMPILATION FAILED ", "DiagnosticError" },
        { " " .. ctx.name, "Comment" },
    })
    b.add()

    if res.spawn_error then
        b.add({ { "  " .. res.spawn_error, "DiagnosticError" } })
    elseif res.timed_out then
        b.add({ { "  Compiler timed out", "DiagnosticError" } })
    end

    for _, line in ipairs(files.normalize(res.stderr or "")) do
        line = line:gsub(vim.pesc(ctx.dir .. "/"), "")

        local hl = line:find(": error") and "DiagnosticError"
            or line:find(": warning") and "DiagnosticWarn"
            or nil

        b.add({ { line, hl } })
    end

    M.show(b)
    vim.notify("Compilation failed", vim.log.levels.ERROR)
end

return M
