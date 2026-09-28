-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
-- local o = vim.opt
local MiniFiles = require("mini.files")
local lazy = require("lazy")

map("o", "c", function()
    return "_"
end, {
    expr = true,
    desc = "Comment current line",
})

-- ============================================================
-- REMOVE LAZYVIM DEFAULT MAPPINGS
-- ============================================================
map("n", "<S-w>", "b", { desc = "Previous word" })
map("n", "<S-e>", "ge", { desc = "Previous word end" })
vim.keymap.del("n", "<leader>ul")
vim.keymap.del("n", "<leader>uL")

-- ============================================================
-- LINE NUMBER STATE
-- ============================================================

local line_number_mode = "relative"
local previous_line_number_mode = "relative"

-- ============================================================
-- CHECK IF WINDOW IS A NORMAL EDITOR WINDOW
-- ============================================================

local function is_normal_window(win)
    if not vim.api.nvim_win_is_valid(win) then
        return false
    end

    local bufnr = vim.api.nvim_win_get_buf(win)

    -- Only normal file buffers
    return vim.bo[bufnr].buftype == ""
end

-- ============================================================
-- APPLY LINE NUMBER MODE
-- ============================================================

local function apply_line_numbers(win)
    if not is_normal_window(win) then
        return
    end

    local number = line_number_mode ~= "off"
    local relative = line_number_mode == "relative"

    vim.api.nvim_set_option_value("number", number, {
        win = win,
    })

    vim.api.nvim_set_option_value("relativenumber", relative, {
        win = win,
    })
end

-- ============================================================
-- SET LINE NUMBER MODE
-- ============================================================

local function set_line_numbers(mode)
    line_number_mode = mode

    -- Apply ONLY to normal editor windows
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        apply_line_numbers(win)
    end
end

-- ============================================================
-- AUTOCMD
-- Keep ONLY normal windows synchronized
-- ============================================================

local line_number_group =
    vim.api.nvim_create_augroup("LineNumberSync", { clear = true })

vim.api.nvim_create_autocmd({
    "BufEnter",
    "BufWinEnter",
    "WinEnter",
}, {
    group = line_number_group,

    callback = function()
        apply_line_numbers(vim.api.nvim_get_current_win())
    end,
})

-- ============================================================
-- <leader>ul
-- TOGGLE LINE NUMBERS ON/OFF
-- ============================================================

map("n", "<leader>ul", function()
    if line_number_mode == "off" then
        set_line_numbers(previous_line_number_mode)
    else
        previous_line_number_mode = line_number_mode
        set_line_numbers("off")
    end
end, {
    desc = "Toggle line numbers",
})

-- ============================================================
-- <leader>uL
-- TOGGLE NORMAL ↔ RELATIVE
-- ============================================================

map("n", "<leader>uL", function()
    if line_number_mode == "off" then
        set_line_numbers(
            previous_line_number_mode == "relative" and "normal" or "relative"
        )
    elseif line_number_mode == "relative" then
        set_line_numbers("normal")
    else
        set_line_numbers("relative")
    end

    if line_number_mode ~= "off" then
        previous_line_number_mode = line_number_mode
    end
end, {
    desc = "Toggle relative line numbers",
})

-- Incremental Selection
map({ "n", "x", "o" }, "<A-o>", function()
    if vim.treesitter.get_parser(nil, nil, { error = false }) then
        require("vim.treesitter._select").select_parent(vim.v.count1)
    else
        vim.lsp.buf.selection_range(vim.v.count1)
    end
end, {
    desc = "Select parent treesitter node or outer incremental lsp selections",
})

map({ "n", "x", "o" }, "<A-i>", function()
    if vim.treesitter.get_parser(nil, nil, { error = false }) then
        require("vim.treesitter._select").select_child(vim.v.count1)
    else
        vim.lsp.buf.selection_range(-vim.v.count1)
    end
end, {
    desc = "Select child treesitter node or inner incremental lsp selections",
})

map("n", "<leader>ij", require("treesj").toggle)
-- Search current word
local searching_brave = function()
    vim.fn.system({
        "xdg-open",
        "https://search.brave.com/search?q=" .. vim.fn.expand("<cword>"),
    })
end
map("n", "<leader>?", searching_brave, {
    noremap = true,
    silent = true,
    desc = "Search Current Word on Brave Search",
})

local fyler = require("fyler")
map("n", "<leader>ie", function()
    fyler.open({ kind = "split_left_most" })
end, { desc = "Fyler.nvim - Open" })

map("n", "<leader>if", function()
    fyler.open()
end, { desc = "Fyler.nvim - Open" })

map("n", "<leader>iE", function()
    fyler.open({ kind = "split_right_most" })
end, { desc = "Fyler.nvim - Open" })

map(
    "n",
    "<leader>s1",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "s&r1" }
)
map(
    "n",
    "<leader>s2",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gi<Left><Left><Left>]],
    { desc = "s&r2" }
)
map(
    "n",
    "<leader>s3",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gIc<Left><Left><Left><Left>]],
    { desc = "s&r3" }
)

-- Add N blank lines above the current line (e.g. 2]<CR> gone here... wait, use [<CR>)
map("n", "[<CR>", function()
    local count = vim.v.count1
    local pos = vim.api.nvim_win_get_cursor(0)
    local lnum, col = pos[1], pos[2]

    local blanks = {}
    for _ = 1, count do
        table.insert(blanks, "")
    end

    vim.api.nvim_buf_set_lines(0, lnum - 1, lnum - 1, false, blanks)
    vim.api.nvim_win_set_cursor(0, { lnum + count, col })
end, { desc = "Add N blank lines above" })

-- Add N blank lines below the current line
map("n", "]<CR>", function()
    local count = vim.v.count1
    local pos = vim.api.nvim_win_get_cursor(0)
    local lnum, col = pos[1], pos[2]

    local blanks = {}
    for _ = 1, count do
        table.insert(blanks, "")
    end

    vim.api.nvim_buf_set_lines(0, lnum, lnum, false, blanks)
    vim.api.nvim_win_set_cursor(0, { lnum, col })
end, { desc = "Add N blank lines below" })

-- Lazy options
map("n", "<leader>l", "<Nop>")
map("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>ig", "<cmd>GuessIndent<cr>", { desc = "GuessBufferIndent" })
-- stylua: ignore start
map("n", "<leader>ld", function() vim.fn.system({ "xdg-open", "https://lazyvim.org" }) end, { desc = "LazyVim Docs" })
map("n", "<leader>lr", function() vim.fn.system({ "xdg-open", "https://github.com/LazyVim/LazyVim" }) end, { desc = "LazyVim Repo" })
map("n", "<leader>lx", "<cmd>LazyExtras<cr>", { desc = "Extras" })
map("n", "<leader>lc", function() LazyVim.news.changelog() end, { desc = "LazyVim Changelog" })

map("n", "\\\\", function() MiniFiles.open() end, { desc = "MiniFiles Open" })
map("n", "<leader>lu", function() lazy.update() end, { desc = "Lazy Update" })
map("n", "<leader>lC", function() lazy.check() end, { desc = "Lazy Check" })
map("n", "<leader>ls", function() lazy.sync() end, { desc = "Lazy Sync" })
-- stylua: ignore end

-- Neovim (init.lua)
map("i", "<C-e>", "<C-x><C-e>")
map("i", "<C-y>", "<C-x><C-y>")

-- Open current file's PWD in VSCode
map("n", "<leader>fV", function()
    local dir_path = vim.fn.getcwd()
    if dir_path ~= "" then
        local command = "code " .. vim.fn.shellescape(dir_path)
        vim.fn.system(command)
        print("Opened PWD in VSCode: " .. dir_path)
    else
        print("No file is currently open")
    end
end, { desc = "[C]Open current file's PWD in VSCode" })

-- Disable LazyVim bindings
map("n", "<leader>L", "<Nop>")
map("n", "<leader>fT", "<Nop>")

-- -- this is used to toggle the transparency of the kanagawa theme on the fly
-- local config = {
--     transparent = true,
-- }
-- map("n", "<leader>tb", function()
--     config.transparent = not config.transparent
--     require("kanagawa").setup(config)
--     vim.cmd.colorscheme("kanagawa-dragon")
-- end, { desc = "Toggle transparency" })

-- -- this is used to toggle the transparency of the catppuccin theme on the fly
local config1 = {
    transparent_background = true,
    float = {
        transparent = true, -- enables transparency on floating windows
        solid = true, -- use nvchad styling for floating windows
    },
}
map("n", "<leader>t1", function()
    config1.transparent_background = not config1.transparent_background
    require("catppuccin").setup(config1)
    vim.cmd.colorscheme("catppuccin-mocha")
end, { desc = "Toggle transparency" })

-- Identation
map("n", "<", "<<", { desc = "Deindent" })
map("n", ">", ">>", { desc = "Indent" })

-- keymaps
map("n", "<leader>sk", function()
    Snacks.picker.keymaps({ layout = "select" })
end, { desc = "show keymaps" })

----buffer switch keymaps
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "go to next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "go to next buffer" })

-- Save without formatting
map(
    { "n", "i" },
    "<A-s>",
    "<cmd>noautocmd w<CR>",
    { desc = "Save Without Formatting" }
)

-- map("n", "<leader>iu", require("undotree").open)
-- Increment/decrement
-- map("n", "+", "<C-a>")

-- -- toggle oil
-- map("n", "-", "<cmd>Oil<cr>", { desc = "toggle oil lua" })

--toggle code diff
map("n", "<leader>cd", "<cmd>CodeDiff<cr>", { desc = "Toggle codediff" })

-- Buffers
map("n", "<leader>bf", "<cmd>bfirst<cr>", { desc = "First Buffer" })
map("n", "<leader>ba", "<cmd>blast<cr>", { desc = "Last Buffer" })
map("n", "<M-CR>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Toggle statusline
map("n", "<leader>uX", function()
    if vim.o.laststatus == 0 then
        vim.o.laststatus = 3
    else
        vim.o.laststatus = 0
    end
end, { desc = "Toggle Statusline" })

-- Toggle colorcolumn: off -> 80 -> 100 -> off
map("n", "<leader>uu", function()
    local current = vim.wo.colorcolumn
    if current == "" or current == nil then
        vim.wo.colorcolumn = "80"
    elseif current == "80" then
        vim.wo.colorcolumn = "100"
    else
        vim.wo.colorcolumn = ""
    end
end, { desc = "Toggle Color Column (80/100/off)" })

-- keymap to exit terminal mode using esc
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { silent = true })

-- Plugin Info
map("n", "<leader>cif", "<cmd>LazyFormatInfo<cr>", { desc = "Formatting" })
map("n", "<leader>cic", "<cmd>ConformInfo<cr>", { desc = "Conform" })
local linters = function()
    local linters_attached = require("lint").linters_by_ft[vim.bo.filetype]
    local buf_linters = {}

    if not linters_attached then
        LazyVim.warn("No linters attached", { title = "Linter" })
        return
    end

    for _, linter in pairs(linters_attached) do
        table.insert(buf_linters, linter)
    end

    local unique_client_names = table.concat(buf_linters, ", ")
    local linters = string.format("%s", unique_client_names)

    LazyVim.notify(linters, { title = "Linter" })
end
map("n", "<leader>ciL", linters, { desc = "Lint" })
map("n", "<leader>cir", "<cmd>LazyRoot<cr>", { desc = "Root" })

-- Copy whole text to clipboard
-- map(
--     "n",
--     "<C-c>",
--     ":%y+<CR>",
--     { desc = "Copy Whole Text to Clipboard", silent = true }
-- )

-- Select all text
map(
    "n",
    "<C-e>",
    "gg<S-V>G",
    { desc = "Select all Text", silent = true, noremap = true }
)

-- Delete and change without yanking
map({ "n", "x" }, "<A-d>", '"_d', { desc = "Delete Without Yanking" })
map({ "n", "x" }, "<A-c>", '"_c', { desc = "Change Without Yanking" })

-- Dashboard
map("n", "<leader>fd", function()
    if LazyVim.has("snacks.nvim") then
        Snacks.dashboard()
    elseif LazyVim.has("alpha-nvim") then
        require("alpha").start(true)
    elseif LazyVim.has("dashboard-nvim") then
        vim.cmd("Dashboard")
    end
end, { desc = "Dashboard" })

-- Spelling
map("n", "<leader>!", "zg", { desc = "Add Word to Dictionary" })
map("n", "<leader>@", "zug", { desc = "Remove Word from Dictionary" })

-- Terminal Stuff
if not LazyVim.has("floaterm.nvim") or not LazyVim.has("toggleterm.nvim") then
    local lazyterm = function()
        Snacks.terminal(
            nil,
            { size = { width = 0.8, height = 0.8 }, cwd = LazyVim.root() }
        )
    end
    map("n", "<leader>ft", lazyterm, { desc = "Terminal (Root Dir)" })
    map("n", "<leader>fT", function()
        Snacks.terminal(
            nil,
            { size = { width = 0.8, height = 0.8 }, cwd = vim.fn.getcwd() }
        )
    end, { desc = "Terminal (cwd)" })
    map("n", [[<c-\>]], lazyterm, { desc = "Terminal (Root Dir)" })
    map("t", [[<c-\>]], "<cmd>close<cr>", { desc = "Hide Terminal" })
end

-- Tmux sessionizer doesnt work if tmux is not active
map("n", "<leader>tt", function()
    if vim.fn.executable("fish") == 0 then
        vim.notify("fish not found in PATH", vim.log.levels.ERROR)
        return
    end
    vim.cmd("silent !fish -lc tmux_sessionizer")
    vim.cmd("redraw!")
end, { desc = "Tmux Sessionizer" })

-- Windows Split
map("n", "<leader>_", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>\\", "<C-W>v", { desc = "Split Window Right", remap = true })

-- this option toggles the blink cmp can be useful when i want to not display any suggestions
map("n", "<leader>tb", function()
    vim.g.blink_auto_show = not vim.g.blink_auto_show

    -- Hide any currently visible completion menu
    require("blink.cmp").hide()

    vim.notify(
        "Blink auto completion "
            .. (vim.g.blink_auto_show and "Enabled" or "Disabled")
    )
end, { desc = "Toggle Blink auto completion" })

map({ "n", "i" }, "<C-q>", function()
    vim.g.blink_auto_show = not vim.g.blink_auto_show
    require("blink.cmp").hide()
end, { desc = "Toggle Blink auto completion" })

-- Center when scrolling
if Snacks.scroll.enabled then
    map("n", "<C-d>", function()
        vim.wo.scrolloff = 999
        vim.defer_fn(function()
            vim.wo.scrolloff = 8
        end, 500)
        return "<c-d>"
    end, { expr = true })

    map("n", "<C-u>", function()
        vim.wo.scrolloff = 999
        vim.defer_fn(function()
            vim.wo.scrolloff = 8
        end, 500)
        return "<c-u>"
    end, { expr = true })
end

-- Select first option for spelling
map("n", "<leader>S", "1z=", { desc = "Spelling (First Option)" })

-- exit insert mode using jk
map("i", "jj", "<Esc>", { noremap = true, silent = true })

if vim.g.neovide then
    vim.g.neovide_scale_factor = 1.0

    -- Ctrl + =
    map({ "n", "v", "i" }, "<C-=>", function()
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1
    end, { desc = "Zoom in" })

    -- Ctrl + Shift + =
    map({ "n", "v", "i" }, "<C-S-=>", function()
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1
    end, { desc = "Zoom in" })

    -- Ctrl + -
    map({ "n", "v", "i" }, "<C-->", function()
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1
    end, { desc = "Zoom out" })

    -- reset zoom
    map({ "n", "v", "i" }, "<C-0>", function()
        vim.g.neovide_scale_factor = 1.0
    end, { desc = "Reset zoom" })
end

----------------------clear multicursors------------------------------

vim.keymap.del("n", "<C-l>")

if vim.fn.has("nvim-0.13") == 1 then
    map("n", "<C-l>", function()
        local ns = vim.api.nvim_create_namespace("nvim.multicursor")
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    end, {
        desc = "Clear multicursors",
    })
end

if vim.fn.has("nvim-0.13") == 1 then
    local multicursor_ns = vim.api.nvim_create_namespace("nvim.multicursor")
    map("n", "<Esc>", function()
        vim.cmd.nohlsearch()
        vim.api.nvim_buf_clear_namespace(0, multicursor_ns, 0, -1)
    end, { desc = "Clear search highligts & multicursors" })
end

-- ============================================================
-- CP Runner
--
-- Test files live next to the solution:
--     input.txt  -> output.txt
--     input1.txt -> output1.txt
--     input2.txt -> output2.txt
--     ...
--
-- C / C++ / Rust / Go / Java are compiled ONCE per run and the
-- same binary is reused for every test.
--
-- The time limit applies to each test's execution only.
-- Compile time is never counted.
-- ============================================================

local CP_TIMEOUT = 10 -- seconds per test
local CP_OUTPUT_LIMIT = 64 * 1024 * 1024 -- bytes per stream per test

-- 256 MB stack so deep recursion doesn't segfault (macOS default is 8 MB)
local CP_STACK = "-Wl,-stack_size,0x10000000"

local CP_CPP_FLAGS = {
    "-std=c++20",
    "-O2",
    "-Wall",
    "-Wextra",
    "-Wshadow",
    "-DLOCAL",
    CP_STACK,
}

local CP_C_FLAGS = {
    "-std=c17",
    "-O2",
    "-Wall",
    "-Wextra",
    "-DLOCAL",
    CP_STACK,
}

local function cp_argv(...)
    return vim.iter({ ... }):flatten():totable()
end

local function cp_run_binary(_, out)
    return { out }
end

-- ============================================================
-- Languages
--
-- build(file, out) -> compile command (optional)
-- run(file, out)   -> program command
-- native = true    -> `out` is a freshly built executable
-- ============================================================

local CP_LANGS = {
    cpp = {
        native = true,
        build = function(file, out)
            return cp_argv("g++-16", CP_CPP_FLAGS, file, "-o", out)
        end,
        run = cp_run_binary,
    },
    c = {
        native = true,
        build = function(file, out)
            return cp_argv("gcc", CP_C_FLAGS, file, "-o", out)
        end,
        run = cp_run_binary,
    },
    rust = {
        native = true,
        build = function(file, out)
            return cp_argv(
                "rustc",
                "-O",
                "--edition",
                "2021",
                "-C",
                "link-arg=" .. CP_STACK,
                file,
                "-o",
                out
            )
        end,
        run = cp_run_binary,
    },
    go = {
        native = true,
        build = function(file, out)
            return { "go", "build", "-o", out, file }
        end,
        run = cp_run_binary,
    },
    java = {
        build = function(file, out)
            return { "javac", "-d", out, file }
        end,
        run = function(file, out)
            local class = vim.fn.fnamemodify(file, ":t:r")
            return { "java", "-Xss256m", "-cp", out, class }
        end,
    },
    python = {
        run = function(file)
            return { "python3", file }
        end,
    },
    javascript = {
        run = function(file)
            return { "node", file }
        end,
    },
    typescript = {
        run = function(file)
            return { "bun", "run", file }
        end,
    },
}

-- ============================================================
-- Current file context (saves the file)
-- ============================================================

local function cp_context()
    local buf = vim.api.nvim_get_current_buf()

    -- Called from a test pane: use the solution shown in another window
    if not CP_LANGS[vim.bo[buf].filetype] then
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local b = vim.api.nvim_win_get_buf(win)

            if
                CP_LANGS[vim.bo[b].filetype]
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
        vim.notify("Please save the file first", vim.log.levels.WARN)
        return nil
    end

    local lang = CP_LANGS[ft]

    if not lang then
        vim.notify("Unsupported filetype: " .. ft, vim.log.levels.WARN)
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
-- Test files
-- ============================================================

local function cp_test_files(dir, index)
    if index == 0 then
        return dir .. "/input.txt", dir .. "/output.txt"
    end

    return dir .. "/input" .. index .. ".txt",
        dir .. "/output" .. index .. ".txt"
end

-- Remove leading/trailing blank lines (pasted samples often have them)
local function cp_trim_lines(lines)
    while #lines > 0 and lines[1]:match("^%s*$") do
        table.remove(lines, 1)
    end

    while #lines > 0 and lines[#lines]:match("^%s*$") do
        table.remove(lines)
    end

    return lines
end

local function cp_save_buf(buf)
    if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].modified then
        return false
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, cp_trim_lines(lines))

    vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent noautocmd write")
    end)

    return true
end

-- Save every modified input/output buffer in dir
local function cp_save_tests(dir)
    local saved = 0

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        local is_test = name:match("/input%d*%.txt$")
            or name:match("/output%d*%.txt$")

        if is_test and vim.fs.dirname(name) == dir and cp_save_buf(buf) then
            saved = saved + 1
        end
    end

    return saved
end

local function cp_find_tests(dir, need_expected)
    local tests = {}
    local index = 0

    while true do
        local input, output = cp_test_files(dir, index)

        if vim.fn.filereadable(input) == 1 then
            if need_expected and vim.fn.filereadable(output) == 0 then
                return nil,
                    "Missing expected output: " .. vim.fn.fnamemodify(
                        output,
                        ":t"
                    )
            end

            table.insert(tests, {
                name = "Test " .. (index + 1),
                input = input,
                output = output,
            })
        elseif index > 0 then
            break
        end

        index = index + 1
    end

    if #tests == 0 then
        return nil, "No test cases found. Press <leader>ic first."
    end

    return tests
end

local function cp_read(path)
    local fd = io.open(path, "rb")

    if not fd then
        return ""
    end

    local data = fd:read("*a")
    fd:close()

    return data
end

-- Split into lines, strip trailing whitespace and trailing blank lines
local function cp_normalize(text)
    local lines = vim.split(text, "\n", { plain = true })

    for i, line in ipairs(lines) do
        lines[i] = line:gsub("%s+$", "")
    end

    while #lines > 0 and lines[#lines] == "" do
        table.remove(lines)
    end

    return lines
end

-- ============================================================
-- Run a process directly (no shell)
--
-- Time is measured from spawn to process exit inside the libuv
-- callback, so editor work (notifications, redraws) never leaks
-- into the measurement.
-- ============================================================

local function cp_exec(argv, opts, on_done)
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

            if bytes > CP_OUTPUT_LIMIT then
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

local function cp_classify(res)
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
-- Result window
-- ============================================================

local CP_STATUS = {
    AC = { "✓", "PASSED", "DiagnosticOk" },
    WA = { "✗", "WRONG ANSWER", "DiagnosticError" },
    RE = { "✗", "RUNTIME ERROR", "DiagnosticError" },
    TLE = { "✗", "TIME LIMIT EXCEEDED", "DiagnosticWarn" },
    OLE = { "✗", "OUTPUT LIMIT EXCEEDED", "DiagnosticWarn" },
    ERR = { "✗", "FAILED TO START", "DiagnosticError" },
}

local CP_SIGNALS = {
    [4] = "SIGILL (illegal instruction)",
    [5] = "SIGTRAP (trap / sanitizer)",
    [6] = "SIGABRT (failed assert, bad_alloc, sanitizer...)",
    [8] = "SIGFPE (division by zero?)",
    [10] = "SIGBUS (bad memory access)",
    [11] = "SIGSEGV (out of bounds or stack overflow?)",
}

local cp_ns = vim.api.nvim_create_namespace("cp_results")
local cp_result_buf = nil
local cp_result_win = nil

local function cp_close_results()
    if cp_result_win and vim.api.nvim_win_is_valid(cp_result_win) then
        vim.api.nvim_win_close(cp_result_win, true)
    end

    cp_result_win = nil
end

-- Collects lines made of { text, highlight } chunks
local function cp_builder()
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

local function cp_show(b)
    if not cp_result_buf or not vim.api.nvim_buf_is_valid(cp_result_buf) then
        cp_result_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[cp_result_buf].bufhidden = "wipe"
        pcall(vim.api.nvim_buf_set_name, cp_result_buf, "CP Results")

        map("n", "q", cp_close_results, {
            buffer = cp_result_buf,
            desc = "Close CP results",
        })
    end

    local buf = cp_result_buf

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, b.lines)
    vim.bo[buf].modifiable = false

    vim.api.nvim_buf_clear_namespace(buf, cp_ns, 0, -1)

    for _, m in ipairs(b.marks) do
        vim.api.nvim_buf_set_extmark(buf, cp_ns, m[1], m[2], {
            end_col = m[3],
            hl_group = m[4],
        })
    end

    local height =
        math.max(6, math.min(#b.lines, math.floor(vim.o.lines * 0.4)))

    if cp_result_win and vim.api.nvim_win_is_valid(cp_result_win) then
        vim.api.nvim_win_set_buf(cp_result_win, buf)
        vim.api.nvim_win_set_height(cp_result_win, height)
    else
        -- Bottom split, focus stays in the solution
        cp_result_win = vim.api.nvim_open_win(buf, false, {
            split = "below",
            win = -1,
            height = height,
        })
    end

    local wo = vim.wo[cp_result_win]
    wo.number = false
    wo.relativenumber = false
    wo.signcolumn = "no"
    wo.foldcolumn = "0"
    wo.wrap = false
    wo.list = false
    wo.spell = false

    vim.api.nvim_win_set_cursor(cp_result_win, { 1, 0 })
end

-- ============================================================
-- Rendering
-- ============================================================

local function cp_ms(time)
    if time < 10 then
        return string.format("%.1f ms", time)
    end

    return string.format("%d ms", math.floor(time + 0.5))
end

local function cp_format_time(r)
    if r.status == "TLE" then
        return "> " .. CP_TIMEOUT .. " s"
    end

    return cp_ms(r.time)
end

local function cp_stats(results)
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

local function cp_render_summary(b, ctx, results, title)
    local stats = cp_stats(results)
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
                cp_ms(stats.max),
                cp_ms(stats.total)
            ),
            "Comment",
        },
    })

    b.add()

    for _, r in ipairs(results) do
        local s = CP_STATUS[r.status]

        b.add({
            { "  " .. s[1] .. " ", s[3] },
            string.format("%-8s ", r.test.name),
            {
                string.format("%-12s", vim.fn.fnamemodify(r.test.input, ":t")),
                "Comment",
            },
            { string.format("%10s", cp_format_time(r)), "Number" },
            r.status ~= "AC" and { "   " .. s[2], s[3] } or "",
        })
    end
end

-- Chunks for one diff cell. The part after the first
-- differing character is highlighted.
local function cp_cell(text, other, hl)
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

local function cp_render_diff(b, expected, actual)
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
                cp_cell(expected[i], actual[i], bad and "DiagnosticOk" or nil)
            local right = cp_cell(
                actual[i],
                expected[i],
                bad and "DiagnosticError" or nil
            )

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
                local left = cp_cell(expected[i], actual[i], "DiagnosticOk")
                local right = cp_cell(actual[i], expected[i], "DiagnosticError")

                b.add({ { "   ✗ line " .. i, "DiagnosticError" } })
                b.add(
                    vim.list_extend(
                        { { "       expected │ ", "Comment" } },
                        left
                    )
                )
                b.add(
                    vim.list_extend(
                        { { "       yours    │ ", "Comment" } },
                        right
                    )
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

local function cp_render_failure(b, r)
    local s = CP_STATUS[r.status]
    local title = string.format(
        "── %s · %s · %s ",
        r.test.name,
        vim.fn.fnamemodify(r.test.input, ":t"),
        s[2]
    )

    if #b.lines > 0 then
        b.add()
    end

    b.add({
        { title, s[3] },
        {
            string.rep("─", math.max(4, 60 - vim.fn.strdisplaywidth(title))),
            s[3],
        },
    })

    if r.status == "WA" then
        cp_render_diff(b, r.expected, r.actual)
    elseif r.status == "TLE" then
        b.add({
            {
                "   Killed after "
                    .. CP_TIMEOUT
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
                CP_SIGNALS[r.signal] or ("signal " .. r.signal),
                "DiagnosticError",
            },
            { "  after " .. cp_format_time(r), "Comment" },
        })
    else
        b.add({
            { "   Exit code: ", "Comment" },
            { tostring(r.code), "DiagnosticError" },
            { "  after " .. cp_format_time(r), "Comment" },
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

local function cp_show_compile_error(ctx, res)
    local b = cp_builder()

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

    for _, line in ipairs(cp_normalize(res.stderr or "")) do
        line = line:gsub(vim.pesc(ctx.dir .. "/"), "")

        local hl = line:find(": error") and "DiagnosticError"
            or line:find(": warning") and "DiagnosticWarn"
            or nil

        b.add({ { line, hl } })
    end

    cp_show(b)
    vim.notify("Compilation failed", vim.log.levels.ERROR)
end

-- ============================================================
-- Build once, run every test, hand results to on_done
--
-- opts.need_expected  compare against outputN.txt
-- opts.stop_on_error  stop at the first crash / timeout
-- opts.on_test(r)     called after every test
-- ============================================================

local cp_busy = false

local function cp_run(opts, on_done)
    if cp_busy then
        vim.notify("CP run already in progress", vim.log.levels.WARN)
        return
    end

    local ctx = cp_context()

    if not ctx then
        return
    end

    -- Run against what's on screen, not stale files
    cp_save_tests(ctx.dir)

    local tests, find_err = cp_find_tests(ctx.dir, opts.need_expected)

    if not tests then
        vim.notify(find_err, vim.log.levels.WARN)
        return
    end

    cp_close_results()
    cp_busy = true

    local out = vim.fn.tempname()
    local run_argv = ctx.lang.run(ctx.file, out)

    local function cleanup()
        vim.fn.delete(out, "rf")
        cp_busy = false
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
            local input = cp_read(test.input)

            if input ~= "" and input:sub(-1) ~= "\n" then
                input = input .. "\n"
            end

            cp_exec(run_argv, {
                cwd = ctx.dir,
                input = input,
                timeout = CP_TIMEOUT * 1000,
            }, function(res)
                local r = {
                    test = test,
                    status = cp_classify(res),
                    time = res.time,
                    code = res.code,
                    signal = res.signal,
                    spawn_error = res.spawn_error,
                    actual = cp_normalize(res.stdout),
                    stderr = cp_normalize(res.stderr),
                }

                if r.status == "TLE" then
                    r.time = CP_TIMEOUT * 1000
                elseif r.status == "OK" then
                    r.status = "AC"

                    if opts.need_expected then
                        r.expected = cp_normalize(cp_read(test.output))

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

    vim.notify("Compiling " .. ctx.name .. "...", vim.log.levels.INFO)

    cp_exec(ctx.lang.build(ctx.file, out), {
        cwd = ctx.dir,
        timeout = 120 * 1000,
    }, function(res)
        if cp_classify(res) ~= "OK" then
            cleanup()
            cp_show_compile_error(ctx, res)
            return
        end

        local _, warnings = res.stderr:gsub(": warning", "")
        local msg = string.format("Compiled in %.1f s", res.time / 1000)

        if warnings > 0 then
            msg = msg .. string.format(" (%d warnings)", warnings)
        end

        vim.notify(
            msg .. " · running " .. #tests .. " tests",
            vim.log.levels.INFO
        )

        if not ctx.lang.native then
            run_tests()
            return
        end

        -- macOS scans a brand-new executable the first time it runs
        -- (~0.5 s). One untimed warm-up run keeps that out of Test 1.
        cp_exec(run_argv, { cwd = ctx.dir, timeout = 3000 }, run_tests)
    end)
end

-- ============================================================
-- <leader>iq
-- Compile + run the current file in a bottom terminal
-- ============================================================

local run_term_win = nil
local cp_quick_out = {}

map("n", "<leader>iq", function()
    local ctx = cp_context()

    if not ctx then
        return
    end

    local ft = ctx.ft
    cp_quick_out[ft] = cp_quick_out[ft] or vim.fn.tempname()

    local function shell(argv)
        return table.concat(vim.tbl_map(vim.fn.shellescape, argv), " ")
    end

    local cmd = shell(ctx.lang.run(ctx.file, cp_quick_out[ft]))

    if ctx.lang.build then
        cmd = shell(ctx.lang.build(ctx.file, cp_quick_out[ft])) .. " && " .. cmd
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
end, {
    desc = "Run current file",
})

-- Closes the test panel / editor (defined at the bottom of the file)
local cp_close_views

-- ============================================================
-- <leader>ir
-- Build once, write program output into outputN.txt.
-- Stops at the first crash / timeout.
-- ============================================================

map("n", "<leader>ir", function()
    cp_run({
        stop_on_error = true,
        on_test = function(r)
            if r.status ~= "AC" then
                return
            end

            vim.fn.writefile(r.actual, r.test.output)

            -- Refresh output buffer if open
            local buf = vim.fn.bufnr(r.test.output)

            if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd("edit!")
                end)
            end
        end,
    }, function(_, results)
        local last = results[#results]

        if last.status ~= "AC" then
            local b = cp_builder()
            cp_render_failure(b, last)
            cp_show(b)

            vim.notify(
                last.test.name .. ": " .. CP_STATUS[last.status][2],
                vim.log.levels.ERROR
            )
            return
        end

        vim.notify(
            string.format(
                "Generated %d outputs · max %s",
                #results,
                cp_ms(cp_stats(results).max)
            ),
            vim.log.levels.INFO
        )
    end)
end, {
    desc = "Build once and generate CP outputs",
})

-- ============================================================
-- <leader>iC
-- Delete all CP input/output files
-- ============================================================

map("n", "<leader>iC", function()
    local dir = vim.fn.expand("%:p:h")

    if dir == "" then
        vim.notify("Please save the file first", vim.log.levels.WARN)
        return
    end

    -- The panel / editor may show files that are about to go
    cp_close_views()

    local deleted = 0
    local index = 0

    while true do
        local found = false

        for _, file in ipairs({ cp_test_files(dir, index) }) do
            if vim.fn.filereadable(file) == 1 then
                vim.fn.delete(file)
                deleted = deleted + 1
                found = true
            end
        end

        -- input.txt may be missing while input1.txt exists
        if not found and index > 0 then
            break
        end

        index = index + 1
    end

    if deleted > 0 then
        vim.notify(
            "Deleted " .. deleted .. " CP input/output files",
            vim.log.levels.INFO
        )
    else
        vim.notify("No CP input/output files found", vim.log.levels.INFO)
    end
end, {
    desc = "Delete all CP input/output files",
})

-- ============================================================
-- <leader>iR
-- Run all tests, compare with outputN.txt, show diffs
-- ============================================================

map("n", "<leader>iR", function()
    cp_run({ need_expected = true }, function(ctx, results)
        local stats = cp_stats(results)

        if stats.failed == 0 then
            vim.notify(
                string.format(
                    "✓ All %d tests passed · max %s",
                    #results,
                    cp_ms(stats.max)
                ),
                vim.log.levels.INFO
            )
            return
        end

        local b = cp_builder()
        cp_render_summary(b, ctx, results, "CP Results")

        for _, r in ipairs(results) do
            if r.status ~= "AC" then
                cp_render_failure(b, r)
            end
        end

        cp_show(b)

        vim.notify(
            string.format("%d/%d passed", stats.passed, #results),
            vim.log.levels.ERROR
        )
    end)
end, {
    desc = "Compile once and run all CP tests",
})

-- ============================================================
-- <leader>ia
-- Quick pass/fail + timing summary for all tests
-- ============================================================

map("n", "<leader>ia", function()
    cp_run({ need_expected = true }, function(ctx, results)
        local stats = cp_stats(results)
        local b = cp_builder()

        cp_render_summary(b, ctx, results, "CP Summary")
        cp_show(b)

        vim.notify(
            string.format(
                "%d/%d passed · max %s",
                stats.passed,
                #results,
                cp_ms(stats.max)
            ),
            stats.failed == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
        )
    end)
end, {
    desc = "Quick CP test summary",
})

--------------create cp folders for C++ lnagueges-------------------

map("n", "<leader>im", function()
    vim.fn.jobstart({ "fish", "-c", "cppfolders" }, {
        cwd = vim.fn.getcwd(),
        detach = true,
    })
end, { desc = "Create C++ folders" })

-- ============================================================
-- CP Test Views: side panel + floating editor
--
-- <leader>ic        toggle the side panel (code stays visible)
-- <leader>il        open the floating editor
-- <leader>i1..i9    show Test N (in the panel if it's open,
--                   otherwise in the floating editor)
-- <leader>iw        save all CP test files
-- <leader>ib        receive a problem from Competitive Companion
--
-- Test 1 = input.txt / output.txt
-- Test 2 = input1.txt / output1.txt ...
--
-- Inside the panel / editor:
--     <Tab>     switch between input and expected output
--     ]t / [t   next / previous test
--     <C-n>     add a new test
--     <C-s>     save input + expected output
--     R         replace this pane with the clipboard
--     <C-x>     delete this test (later tests are renumbered)
--     q         save and close
-- ============================================================

local cp_panel = { wins = {}, bufs = {}, test = 1, busy = false }
local cp_editor = { wins = {}, bufs = {}, test = 1, busy = false, float = true }

-- Panel first so that after a delete the editor (if open) gets focus
local cp_views = { cp_panel, cp_editor }

local CP_VIEW_KEYS =
    { "q", "<Tab>", "]t", "[t", "<C-n>", "<C-s>", "R", "<C-x>" }

-- Buffers loaded by a view (wiped again once nothing shows them)
local cp_created = {}

local function cp_count_tests(dir)
    local n = 0

    while vim.fn.filereadable((cp_test_files(dir, n))) == 1 do
        n = n + 1
    end

    return n
end

local function cp_view_of(win)
    for _, view in ipairs(cp_views) do
        if vim.tbl_contains(view.wins, win) then
            return view
        end
    end

    return nil
end

local function cp_view_is_open(view)
    return #view.wins == 2
        and vim.api.nvim_win_is_valid(view.wins[1])
        and vim.api.nvim_win_is_valid(view.wins[2])
end

-- Test folder: the view's folder when inside one, else the current file's
local function cp_view_dir()
    local view = cp_view_of(vim.api.nvim_get_current_win())

    if view then
        return view.dir
    end

    local file = vim.fn.expand("%:p")

    if file == "" then
        vim.notify("Please save the file first", vim.log.levels.WARN)
        return nil
    end

    return vim.fn.fnamemodify(file, ":h")
end

local function cp_load(path)
    local existed = vim.fn.bufnr(path) ~= -1
    local buf = vim.fn.bufadd(path)

    vim.fn.bufload(buf)

    if not existed then
        vim.bo[buf].buflisted = false
        cp_created[buf] = true
    end

    return buf
end

-- Drop keymaps (and loaded buffers) that no view shows anymore
local function cp_release(bufs)
    for _, buf in ipairs(bufs) do
        local shown = vim.iter(cp_views):any(function(view)
            return vim.tbl_contains(view.bufs, buf)
        end)

        if vim.api.nvim_buf_is_valid(buf) and not shown then
            for _, lhs in ipairs(CP_VIEW_KEYS) do
                pcall(vim.keymap.del, "n", lhs, { buffer = buf })
            end

            pcall(vim.keymap.del, "i", "<C-s>", { buffer = buf })

            if cp_created[buf] and #vim.fn.win_findbuf(buf) == 0 then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
                cp_created[buf] = nil
            end
        end
    end
end

-- Clamp Test N so there are no gaps, create its files if missing
local function cp_prepare_test(dir, n)
    local count = cp_count_tests(dir)

    -- The runners stop at the first missing test, so no gaps
    if n > count + 1 then
        vim.notify(
            "Test " .. n .. " would leave a gap · opening Test " .. count + 1,
            vim.log.levels.WARN
        )
        n = count + 1
    end

    local input, output = cp_test_files(dir, n - 1)

    for _, path in ipairs({ input, output }) do
        if vim.fn.filereadable(path) == 0 then
            vim.fn.writefile({}, path)
        end
    end

    return n, math.max(count, n), input, output
end

local cp_view_show

local function cp_view_close(view)
    view.busy = true

    for _, buf in ipairs(view.bufs) do
        cp_save_buf(buf)
    end

    local bufs = view.bufs
    view.bufs = {}

    for _, win in ipairs(view.wins) do
        if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_close, win, true)
        end
    end

    view.wins = {}
    cp_release(bufs)
    view.busy = false
end

cp_close_views = function()
    for _, view in ipairs(cp_views) do
        cp_view_close(view)
    end
end

local function cp_view_delete(view)
    local dir, n = view.dir, view.test
    local count = cp_count_tests(dir)

    if vim.fn.confirm("Delete Test " .. n .. "?", "&Yes\n&No", 2) ~= 1 then
        return
    end

    -- Files from Test n onwards get renamed: close every view first
    local reopen = {}

    for _, v in ipairs(cp_views) do
        if cp_view_is_open(v) then
            table.insert(reopen, v)
        end

        cp_view_close(v)
    end

    for i = n - 1, count - 1 do
        for _, path in ipairs({ cp_test_files(dir, i) }) do
            local buf = vim.fn.bufnr(path)

            if buf ~= -1 then
                cp_save_buf(buf)
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
                cp_created[buf] = nil
            end
        end
    end

    for _, path in ipairs({ cp_test_files(dir, n - 1) }) do
        vim.fn.delete(path)
    end

    -- Shift later tests down so numbering stays consecutive
    for i = n, count - 1 do
        local from_in, from_out = cp_test_files(dir, i)
        local to_in, to_out = cp_test_files(dir, i - 1)

        vim.fn.rename(from_in, to_in)

        if vim.fn.filereadable(from_out) == 1 then
            vim.fn.rename(from_out, to_out)
        end
    end

    vim.notify("Deleted Test " .. n, vim.log.levels.INFO)

    if count > 1 then
        for _, v in ipairs(reopen) do
            cp_view_show(v, math.min(n, count - 1), 1, dir)
        end
    end
end

-- Buffer-local keys; they act on whichever view the cursor is in
local function cp_view_keymaps(buf)
    local function set(lhs, fn, desc, modes)
        map(modes or "n", lhs, function()
            local win = vim.api.nvim_get_current_win()
            local view = cp_view_of(win)

            if view then
                fn(view, win == view.wins[2] and 2 or 1)
            end
        end, { buffer = buf, nowait = true, desc = desc })
    end

    set("q", cp_view_close, "Save and close")

    set("<Tab>", function(view, pane)
        vim.api.nvim_set_current_win(view.wins[pane == 1 and 2 or 1])
    end, "Switch input / expected output")

    -- ]t / [t wrap around: last -> first, first -> last
    local function cycle(view, pane, step)
        local count = cp_count_tests(view.dir)

        if count <= 1 then
            vim.notify("Only one test · <C-n> adds a new one")
            return
        end

        cp_view_show(view, (view.test - 1 + step) % count + 1, pane)
    end

    set("]t", function(view, pane)
        cycle(view, pane, 1)
    end, "Next test (wraps)")

    set("[t", function(view, pane)
        cycle(view, pane, -1)
    end, "Previous test (wraps)")

    set("<C-n>", function(view)
        cp_view_show(view, cp_count_tests(view.dir) + 1, 1)
    end, "New test")

    set("<C-s>", function(view)
        for _, b in ipairs(view.bufs) do
            cp_save_buf(b)
        end

        vim.notify("Saved Test " .. view.test, vim.log.levels.INFO)
    end, "Save input + expected output", { "n", "i" })

    set("R", function()
        local text = vim.fn.getreg("+"):gsub("\r", "")
        local lines = cp_trim_lines(vim.split(text, "\n", { plain = true }))

        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end, "Replace with clipboard")

    set("<C-x>", cp_view_delete, "Delete test")
end

-- ============================================================
-- Panel: full-height column on the right
-- ============================================================

function cp_panel.create(view, bufs)
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

function cp_panel.decorate(view, count, input, output)
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

function cp_editor.create(view, bufs)
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

function cp_editor.decorate(view, count, _, output)
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

cp_view_show = function(view, n, pane, dir)
    dir = dir or view.dir

    local inside = cp_view_of(vim.api.nvim_get_current_win()) == view
    local count, input, output
    n, count, input, output = cp_prepare_test(dir, n)

    view.busy = true

    for _, buf in ipairs(view.bufs) do
        cp_save_buf(buf)
    end

    local old = view.bufs
    local bufs = { cp_load(input), cp_load(output) }

    if not cp_view_is_open(view) then
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
        cp_view_keymaps(bufs[i])
    end

    view.decorate(view, count, input, output)
    cp_release(old)

    -- Floats take focus; the panel only keeps it if you were in it
    if inside or view.float then
        vim.api.nvim_set_current_win(view.wins[pane or 1])
    end

    view.busy = false
end

-- Close a view when one of its windows is closed, and the
-- floating editor when focus leaves it
local cp_views_group = vim.api.nvim_create_augroup("cp_views", {
    clear = true,
})

vim.api.nvim_create_autocmd({ "WinEnter", "WinClosed" }, {
    group = cp_views_group,
    callback = function()
        vim.schedule(function()
            local current = cp_view_of(vim.api.nvim_get_current_win())

            for _, view in ipairs(cp_views) do
                if not view.busy and #view.wins > 0 then
                    local leave = view.float and current ~= view

                    if not cp_view_is_open(view) or leave then
                        cp_view_close(view)
                    end
                end
            end
        end)
    end,
})

-- ============================================================
-- Keymaps
-- ============================================================

map("n", "<leader>ic", function()
    if cp_view_is_open(cp_panel) then
        cp_view_close(cp_panel)
        return
    end

    local dir = cp_view_dir()

    if not dir then
        return
    end

    -- Floats can't be split: leave the editor first
    if cp_view_of(vim.api.nvim_get_current_win()) == cp_editor then
        cp_view_close(cp_editor)
    end

    local n = dir == cp_panel.dir and cp_panel.test or 1

    cp_view_show(
        cp_panel,
        math.min(n, math.max(1, cp_count_tests(dir))),
        1,
        dir
    )
end, {
    desc = "Toggle CP test panel",
})

map("n", "<leader>il", function()
    local dir = cp_view_dir()

    if not dir then
        return
    end

    -- Reopen the last edited test for the same problem
    local n = dir == cp_editor.dir and cp_editor.test or 1

    cp_view_show(
        cp_editor,
        math.min(n, math.max(1, cp_count_tests(dir))),
        1,
        dir
    )
end, {
    desc = "CP test editor",
})

for n = 1, 9 do
    map("n", "<leader>i" .. n, function()
        local view = cp_view_is_open(cp_panel) and cp_panel or cp_editor
        local dir = cp_view_dir()

        if dir then
            cp_view_show(view, n, 1, dir)
        end
    end, {
        desc = "CP test " .. n,
    })
end

map("n", "<leader>iw", function()
    local dir = cp_view_dir()

    if not dir then
        return
    end

    local saved = cp_save_tests(dir)

    vim.notify(
        saved > 0 and ("Saved " .. saved .. " CP test files")
            or "CP test files already saved",
        vim.log.levels.INFO
    )
end, {
    desc = "Save CP test files",
})

-- ============================================================
-- <leader>ib
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
-- ============================================================

local CP_COMPANION_PORT = 12345
local CP_COMPANION_WAIT = 60 -- seconds

-- { server, timer } while listening
local cp_companion = nil

local function cp_companion_stop()
    if not cp_companion then
        return
    end

    for _, handle in ipairs({ cp_companion.timer, cp_companion.server }) do
        if not handle:is_closing() then
            handle:close()
        end
    end

    cp_companion = nil
end

local function cp_companion_lines(text)
    local lines = vim.split((text or ""):gsub("\r", ""), "\n", { plain = true })

    return cp_trim_lines(lines)
end

local function cp_companion_receive(dir, body)
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
    cp_close_views()

    -- Write samples, reloading any buffer that already shows the file
    for i, test in ipairs(tests) do
        local input, output = cp_test_files(dir, i - 1)

        for _, file in ipairs({
            { input, test.input },
            { output, test.output },
        }) do
            vim.fn.writefile(cp_companion_lines(file[2]), file[1])

            local buf = vim.fn.bufnr(file[1])

            if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd("silent edit!")
                end)
            end
        end
    end

    -- Remove old tests beyond the new ones
    local index = #tests

    while true do
        local found = false

        for _, path in ipairs({ cp_test_files(dir, index) }) do
            local buf = vim.fn.bufnr(path)

            if buf ~= -1 then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
                cp_created[buf] = nil
            end

            if vim.fn.filereadable(path) == 1 then
                vim.fn.delete(path)
                found = true
            end
        end

        if not found then
            break
        end

        index = index + 1
    end

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

    cp_view_show(cp_panel, 1, 1, dir)
end

-- Minimal HTTP: read one POST request, reply 200, hand over the body
local function cp_companion_accept(server, dir)
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
            if not cp_companion then
                return
            end

            cp_companion_stop()
            cp_companion_receive(dir, body)
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

map("n", "<leader>ib", function()
    if cp_companion then
        cp_companion_stop()
        vim.notify("Stopped waiting for Competitive Companion")
        return
    end

    local dir = cp_view_dir()

    if not dir then
        return
    end

    local server = assert(vim.uv.new_tcp())
    local ok, err = server:bind("127.0.0.1", CP_COMPANION_PORT)

    if ok then
        ok, err = server:listen(16, function(listen_err)
            if not listen_err then
                cp_companion_accept(server, dir)
            end
        end)
    end

    if not ok then
        server:close()
        vim.notify(
            "Can't listen on port "
                .. CP_COMPANION_PORT
                .. " ("
                .. tostring(err)
                .. "). Is another Neovim waiting?",
            vim.log.levels.ERROR
        )
        return
    end

    local timer = assert(vim.uv.new_timer())

    timer:start(
        CP_COMPANION_WAIT * 1000,
        0,
        vim.schedule_wrap(function()
            if cp_companion and cp_companion.timer == timer then
                cp_companion_stop()
                vim.notify(
                    "No problem received in " .. CP_COMPANION_WAIT .. " s",
                    vim.log.levels.WARN
                )
            end
        end)
    )

    cp_companion = { server = server, timer = timer }

    vim.notify(
        "Waiting for Competitive Companion on port "
            .. CP_COMPANION_PORT
            .. " · click + in the browser"
    )
end, {
    desc = "Receive problem from Competitive Companion",
})
