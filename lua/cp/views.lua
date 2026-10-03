-- CP test views: side panel + floating editor
--
-- Inside the panel / editor:
--     <Tab>     switch between input and expected output
--     ]t / [t   next / previous test
--     <C-n>     add a new test
--     <C-s>     save input + expected output
--     R         replace this pane with the clipboard
--     <C-x>     delete this test (later tests are renumbered)
--     q         save and close
local files = require("cp.files")
local report = require("cp.report")

local M = {}

local INFO, WARN = vim.log.levels.INFO, vim.log.levels.WARN

local panel = { wins = {}, bufs = {}, test = 1, busy = false }
local editor = { wins = {}, bufs = {}, test = 1, busy = false, float = true }
M.panel = panel

-- Panel first so that after a delete the editor (if open) gets focus
local views = { panel, editor }

local VIEW_KEYS = { "q", "<Tab>", "]t", "[t", "<C-n>", "<C-s>", "R", "<C-x>" }

-- Buffers loaded by a view (wiped again once nothing shows them)
local created = {}

local function view_of(win)
    for _, view in ipairs(views) do
        if vim.tbl_contains(view.wins, win) then
            return view
        end
    end

    return nil
end

local function is_open(view)
    return #view.wins == 2
        and vim.api.nvim_win_is_valid(view.wins[1])
        and vim.api.nvim_win_is_valid(view.wins[2])
end

-- Test folder: the view's folder when inside one, else the current file's
function M.dir()
    local view = view_of(vim.api.nvim_get_current_win())

    if view then
        return view.dir
    end

    local file = vim.fn.expand("%:p")

    if file == "" then
        vim.notify("Please save the file first", WARN)
        return nil
    end

    return vim.fn.fnamemodify(file, ":h")
end

local function load(path)
    local existed = vim.fn.bufnr(path) ~= -1
    local buf = vim.fn.bufadd(path)

    vim.fn.bufload(buf)

    if not existed then
        vim.bo[buf].buflisted = false
        created[buf] = true
    end

    return buf
end

-- Drop keymaps (and loaded buffers) that no view shows anymore
local function release(bufs)
    for _, buf in ipairs(bufs) do
        local shown = vim.iter(views):any(function(view)
            return vim.tbl_contains(view.bufs, buf)
        end)

        if vim.api.nvim_buf_is_valid(buf) and not shown then
            for _, lhs in ipairs(VIEW_KEYS) do
                pcall(vim.keymap.del, "n", lhs, { buffer = buf })
            end

            pcall(vim.keymap.del, "i", "<C-s>", { buffer = buf })

            if created[buf] and #vim.fn.win_findbuf(buf) == 0 then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
                created[buf] = nil
            end
        end
    end
end

-- Clamp Test N so there are no gaps, create its files if missing
local function prepare_test(dir, n)
    local count = files.count_tests(dir)

    -- The runners stop at the first missing test, so no gaps
    if n > count + 1 then
        vim.notify(
            "Test " .. n .. " would leave a gap · opening Test " .. count + 1,
            WARN
        )
        n = count + 1
    end

    local input, output = files.test_files(dir, n - 1)

    for _, path in ipairs({ input, output }) do
        if vim.fn.filereadable(path) == 0 then
            vim.fn.writefile({}, path)
        end
    end

    return n, math.max(count, n), input, output
end

local function save(view)
    for _, buf in ipairs(view.bufs) do
        files.save_buf(buf)
    end
end

local function close(view)
    view.busy = true
    save(view)

    local bufs = view.bufs
    view.bufs = {}

    for _, win in ipairs(view.wins) do
        if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_close, win, true)
        end
    end

    view.wins = {}
    release(bufs)
    view.busy = false
end

function M.close_all()
    for _, view in ipairs(views) do
        close(view)
    end
end

-- Floats can't be split: leave the editor first
local function leave_editor()
    if view_of(vim.api.nvim_get_current_win()) == editor then
        close(editor)
    end
end

local show

local function delete(view)
    local dir, n = view.dir, view.test
    local count = files.count_tests(dir)

    if vim.fn.confirm("Delete Test " .. n .. "?", "&Yes\n&No", 2) ~= 1 then
        return
    end

    -- Files from Test n onwards get renamed: close every view first
    local reopen = {}

    for _, v in ipairs(views) do
        if is_open(v) then
            table.insert(reopen, v)
        end

        close(v)
    end

    for i = n - 1, count - 1 do
        for _, path in ipairs({ files.test_files(dir, i) }) do
            local buf = vim.fn.bufnr(path)

            if buf ~= -1 then
                files.save_buf(buf)
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
                created[buf] = nil
            end
        end
    end

    for _, path in ipairs({ files.test_files(dir, n - 1) }) do
        vim.fn.delete(path)
    end

    -- Shift later tests down so numbering stays consecutive
    for i = n, count - 1 do
        local from_in, from_out = files.test_files(dir, i)
        local to_in, to_out = files.test_files(dir, i - 1)

        vim.fn.rename(from_in, to_in)

        if vim.fn.filereadable(from_out) == 1 then
            vim.fn.rename(from_out, to_out)
        end
    end

    vim.notify("Deleted Test " .. n, INFO)

    if count > 1 then
        for _, v in ipairs(reopen) do
            show(v, math.min(n, count - 1), 1, dir)
        end
    end
end

-- Buffer-local keys; they act on whichever view the cursor is in
local function keymaps(buf)
    local function set(lhs, fn, desc, modes)
        vim.keymap.set(modes or "n", lhs, function()
            local win = vim.api.nvim_get_current_win()
            local view = view_of(win)

            if view then
                fn(view, win == view.wins[2] and 2 or 1)
            end
        end, { buffer = buf, nowait = true, desc = desc })
    end

    set("q", close, "Save and close")

    set("<Tab>", function(view, pane)
        vim.api.nvim_set_current_win(view.wins[pane == 1 and 2 or 1])
    end, "Switch input / expected output")

    -- ]t / [t wrap around: last -> first, first -> last
    local function cycle(view, pane, step)
        local count = files.count_tests(view.dir)

        if count <= 1 then
            vim.notify("Only one test · <C-n> adds a new one")
            return
        end

        show(view, (view.test - 1 + step) % count + 1, pane)
    end

    set("]t", function(view, pane)
        cycle(view, pane, 1)
    end, "Next test (wraps)")

    set("[t", function(view, pane)
        cycle(view, pane, -1)
    end, "Previous test (wraps)")

    set("<C-n>", function(view)
        show(view, files.count_tests(view.dir) + 1, 1)
    end, "New test")

    set("<C-s>", function(view)
        save(view)
        vim.notify("Saved Test " .. view.test, INFO)
    end, "Save input + expected output", { "n", "i" })

    set("R", function()
        local lines = files.split_lines(vim.fn.getreg("+"))

        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end, "Replace with clipboard")

    set("<C-x>", delete, "Delete test")
end

-- ============================================================
-- Panel: full-height column on the right
-- ============================================================

function panel.create(view, bufs)
    local top = vim.api.nvim_open_win(bufs[1], false, {
        split = "right",
        win = -1,
        width = math.floor(vim.o.columns * 0.4),
    })
    local bottom = vim.api.nvim_open_win(bufs[2], false, {
        split = "below",
        win = top,
    })

    for _, win in ipairs({ top, bottom }) do
        vim.wo[win].winfixwidth = true
        vim.wo[win].wrap = false
    end

    view.wins = { top, bottom }
end

function panel.decorate(view, count, input, output)
    vim.wo[view.wins[1]].winbar = string.format(
        "%%#Title# Test %d/%d %%*· Input  %%#Comment#%s",
        view.test,
        count,
        vim.fn.fnamemodify(input, ":t")
    )
    vim.wo[view.wins[2]].winbar = string.format(
        "%%#Title# Expected output %%#Comment#%s%%=]t [t · <C-n> new · <C-s> save ",
        vim.fn.fnamemodify(output, ":t")
    )
end

-- ============================================================
-- Editor: two large floats side by side
-- ============================================================

function editor.create(view, bufs)
    local total = math.min(
        vim.o.columns - 4,
        math.max(60, math.floor(vim.o.columns * 0.94))
    )
    local height = math.max(8, math.floor(vim.o.lines * 0.82))
    local left_width = math.floor(total / 2) - 2
    local row = math.floor((vim.o.lines - height) / 2) - 1
    local col = math.floor((vim.o.columns - total) / 2)

    local geometry = {
        { col = col, width = left_width },
        { col = col + left_width + 2, width = total - left_width - 4 },
    }

    view.wins = {}

    for i, g in ipairs(geometry) do
        local win = vim.api.nvim_open_win(bufs[i], false, {
            relative = "editor",
            row = row,
            col = g.col,
            width = g.width,
            height = height,
            border = "single",
            title = " ",
            style = "minimal",
        })

        vim.wo[win].number = true
        vim.wo[win].wrap = false

        view.wins[i] = win
    end
end

function editor.decorate(view, count, _, output)
    vim.api.nvim_win_set_config(view.wins[1], {
        title = string.format(" Test %d/%d · Input ", view.test, count),
        title_pos = "center",
        footer = " <Tab> switch · ]t [t · <C-n> new · <C-s> save · R paste · <C-x> delete · q close ",
        footer_pos = "center",
    })
    vim.api.nvim_win_set_config(view.wins[2], {
        title = " Expected output ",
        title_pos = "center",
        footer = " " .. vim.fn.fnamemodify(output, ":t") .. " ",
        footer_pos = "center",
    })
end

-- ============================================================
-- Show Test N in a view (reusing its windows when open)
-- ============================================================

show = function(view, n, pane, dir)
    dir = dir or view.dir

    local inside = view_of(vim.api.nvim_get_current_win()) == view
    local count, input, output
    n, count, input, output = prepare_test(dir, n)

    view.busy = true
    save(view)

    local old = view.bufs
    local bufs = { load(input), load(output) }

    if not is_open(view) then
        for _, win in ipairs(view.wins) do
            pcall(vim.api.nvim_win_close, win, true)
        end

        view.create(view, bufs)
    end

    view.dir = dir
    view.test = n
    view.bufs = bufs

    for i, win in ipairs(view.wins) do
        vim.api.nvim_win_set_buf(win, bufs[i])
        keymaps(bufs[i])
    end

    view.decorate(view, count, input, output)
    release(old)

    -- Floats take focus; the panel only keeps it if you were in it
    if inside or view.float then
        vim.api.nvim_set_current_win(view.wins[pane or 1])
    end

    view.busy = false
end

M.show = show

-- Close a view when one of its windows is closed, and the
-- floating editor when focus leaves it
vim.api.nvim_create_autocmd({ "WinEnter", "WinClosed" }, {
    group = vim.api.nvim_create_augroup("cp_views", { clear = true }),
    callback = function()
        vim.schedule(function()
            local current = view_of(vim.api.nvim_get_current_win())

            for _, view in ipairs(views) do
                if not view.busy and #view.wins > 0 then
                    local leave = view.float and current ~= view

                    if not is_open(view) or leave then
                        close(view)
                    end
                end
            end
        end)
    end,
})

-- ============================================================
-- Actions
-- ============================================================

-- Open `view` on the last test shown for the same problem, else Test 1
local function open(view, dir)
    local n = dir == view.dir and view.test or 1

    show(view, math.min(n, math.max(1, files.count_tests(dir))), 1, dir)
end

function M.toggle_panel()
    if is_open(panel) then
        close(panel)
        return
    end

    local dir = M.dir()

    if dir then
        leave_editor()
        open(panel, dir)
    end
end

function M.open_editor()
    local dir = M.dir()

    if dir then
        open(editor, dir)
    end
end

-- Test N in the panel if it's open, otherwise in the floating editor
function M.show_test(n)
    local view = is_open(panel) and panel or editor
    local dir = M.dir()

    if dir then
        show(view, n, 1, dir)
    end
end

function M.save_all()
    local dir = M.dir()

    if not dir then
        return
    end

    local saved = files.save_tests(dir)

    vim.notify(
        saved > 0 and ("Saved " .. saved .. " CP test files")
            or "CP test files already saved",
        INFO
    )
end

-- Delete all CP input/output files
function M.clean()
    local dir = M.dir()

    if not dir then
        return
    end

    -- The panel / editor may show files that are about to go
    M.close_all()

    local deleted = files.delete_tests(dir, 0)

    vim.notify(
        deleted > 0 and ("Deleted " .. deleted .. " CP input/output files")
            or "No CP input/output files found",
        INFO
    )
end

-- Preview text with highlighted section headers
local function test_preview(input, output)
    local lines, extmarks = {}, {}

    local function section(title, path)
        local header = report.rule(
            string.format("── %s · %s ", title, vim.fn.fnamemodify(path, ":t")),
            50
        )

        table.insert(lines, header)
        table.insert(extmarks, {
            row = #lines,
            col = 0,
            end_col = #header,
            hl_group = "Title",
        })

        local content = vim.fn.readfile(path)

        if #content == 0 then
            table.insert(lines, "(empty)")
            table.insert(extmarks, {
                row = #lines,
                col = 0,
                end_col = 7,
                hl_group = "Comment",
            })
        else
            vim.list_extend(lines, content)
        end
    end

    section("Input", input)
    table.insert(lines, "")
    section("Expected output", output)

    return { text = table.concat(lines, "\n"), extmarks = extmarks, loc = false }
end

-- Pick a test with Snacks: preview shows input + expected
-- output, <CR> opens it in the side panel (like <leader>ic)
function M.pick()
    local dir = M.dir()

    if not dir then
        return
    end

    -- Preview what's on screen, not stale files
    files.save_tests(dir)

    local items = {}

    for n = 1, files.count_tests(dir) do
        local input, output = files.test_files(dir, n - 1)
        local input_lines = vim.fn.readfile(input)
        local output_lines = vim.fn.readfile(output)
        local searchable = table.concat(input_lines, " ")
            .. " "
            .. table.concat(output_lines, " ")

        table.insert(items, {
            test = n,
            text = "Test " .. n .. " " .. searchable:sub(1, 500),
            input = input,
            input_count = #input_lines,
            output_count = #output_lines,
            first_line = input_lines[1] or "",
            preview = test_preview(input, output),
        })
    end

    if #items == 0 then
        vim.notify(
            "No test cases found. Press <leader>ic or <leader>ib first.",
            WARN
        )
        return
    end

    Snacks.picker({
        title = "CP Tests · " .. vim.fn.fnamemodify(dir, ":t"),
        items = items,
        preview = "preview",
        format = function(item)
            return {
                { string.format("Test %-3d", item.test), "Title" },
                {
                    string.format(
                        "%-12s",
                        vim.fn.fnamemodify(item.input, ":t")
                    ),
                    "Comment",
                },
                {
                    string.format(
                        "%3d in · %3d out   ",
                        item.input_count,
                        item.output_count
                    ),
                    "Number",
                },
                { item.first_line:sub(1, 60), "Normal" },
            }
        end,
        confirm = function(picker, item)
            picker:close()

            if not item then
                return
            end

            leave_editor()
            show(panel, item.test, 1, dir)
        end,
    })
end

return M
