-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

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

-- Gutter values used when line numbers are off, and the original
-- values (captured at startup) to restore when they come back on
local gutter_off = { signcolumn = "no", foldcolumn = "0", statuscolumn = "" }
local gutter_on = {}
for opt in pairs(gutter_off) do
    gutter_on[opt] = vim.go[opt]
end

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

    -- When off, also hide the sign column (gitsigns, diagnostics),
    -- fold column and statuscolumn so code starts at the left edge.
    for opt, off_value in pairs(gutter_off) do
        vim.api.nvim_set_option_value(
            opt,
            number and gutter_on[opt] or off_value,
            { win = win }
        )
    end
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

-- Incremental Selection: treesitter nodes, or LSP selection ranges
-- when there's no parser. `step` is 1 for outer, -1 for inner.
local function select_node(step)
    return function()
        if vim.treesitter.get_parser(nil, nil, { error = false }) then
            local select = require("vim.treesitter._select")
            local fn = step > 0 and select.select_parent or select.select_child
            fn(vim.v.count1)
        else
            vim.lsp.buf.selection_range(step * vim.v.count1)
        end
    end
end

map({ "n", "x", "o" }, "<A-o>", select_node(1), {
    desc = "Select parent treesitter node or outer incremental lsp selections",
})

map({ "n", "x", "o" }, "<A-i>", select_node(-1), {
    desc = "Select child treesitter node or inner incremental lsp selections",
})

-- Search current word
map("n", "<leader>?", function()
    vim.ui.open(
        "https://search.brave.com/search?q=" .. vim.fn.expand("<cword>")
    )
end, { silent = true, desc = "Search Current Word on Brave Search" })

local function fyler_open(opts)
    return function()
        require("fyler").open(opts)
    end
end

map("n", "<leader>ie", fyler_open({ kind = "split_left_most" }), {
    desc = "Fyler.nvim - Open (left)",
})
map("n", "<leader>iE", fyler_open({ kind = "split_right_most" }), {
    desc = "Fyler.nvim - Open (right)",
})

-- nvim-tree float look: rounded popup at the top-left, 30 lines tall
map(
    "n",
    "<leader>if",
    fyler_open({
        kind = "floating",
        border = "rounded",
        row = 3, -- fyler shifts floats up by 2, so this lands on row 1
        col = 1,
        width = "35%",
        height = 32, -- 30 lines + the border
        win_opts = { cursorline = true },
    }),
    { desc = "Fyler.nvim - Open (tree float)" }
)

-- Substitute the word under the cursor, with these flags
for i, flags in ipairs({ "gI", "gi", "gIc" }) do
    map(
        "n",
        "<leader>s" .. i,
        [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/]]
            .. flags
            .. string.rep("<Left>", #flags + 1),
        { desc = "s&r" .. i .. " (" .. flags .. ")" }
    )
end

-- Add N blank lines above / below (Neovim's built-in [<Space> / ]<Space>)
map(
    "n",
    "[<CR>",
    "[<Space>",
    { remap = true, desc = "Add N blank lines above" }
)
map(
    "n",
    "]<CR>",
    "]<Space>",
    { remap = true, desc = "Add N blank lines below" }
)

-- Lazy options
map("n", "<leader>l", "<Nop>")
map("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Lazy" })
-- stylua: ignore start
map("n", "<leader>ld", function() vim.ui.open("https://lazyvim.org") end, { desc = "LazyVim Docs" })
map("n", "<leader>lr", function() vim.ui.open("https://github.com/LazyVim/LazyVim") end, { desc = "LazyVim Repo" })
map("n", "<leader>lx", "<cmd>LazyExtras<cr>", { desc = "Extras" })
map("n", "<leader>lc", function() LazyVim.news.changelog() end, { desc = "LazyVim Changelog" })

map("n", "\\\\", function() require("mini.files").open() end, { desc = "MiniFiles Open" })
map("n", "<leader>lu", function() require("lazy").update() end, { desc = "Lazy Update" })
map("n", "<leader>lC", function() require("lazy").check() end, { desc = "Lazy Check" })
map("n", "<leader>ls", function() require("lazy").sync() end, { desc = "Lazy Sync" })
-- stylua: ignore end

-- Neovim (init.lua)
map("i", "<C-e>", "<C-x><C-e>")
map("i", "<C-y>", "<C-x><C-y>")

-- Open the current working directory in VSCode
map("n", "<leader>fV", function()
    local dir = vim.fn.getcwd()
    vim.fn.system({ "code", dir })
    print("Opened PWD in VSCode: " .. dir)
end, { desc = "[C]Open current file's PWD in VSCode" })

-- Disable LazyVim bindings
map("n", "<leader>L", "<Nop>")

-- Transparency for whatever colorscheme is active (config/transparency.lua),
-- the terminal background turns #000000 while it's on (config/termsync.lua)
local transparency = require("config.transparency")
Snacks.toggle({
    name = "Transparency (black bg)",
    get = function()
        return transparency.enabled
    end,
    set = transparency.set,
}):map("<leader>t1")

-- Classic command line: reserve a line at the bottom for commands like
-- stock nvim. Off by default (cmdheight = 0 in config/options.lua).
-- While it's on, only Noice's cmdline is handed back to the native line
-- (along with its message area, which Neovim ties to the cmdline), so it
-- doesn't draw over lualine. Noice notifications, LSP docs and the
-- popupmenu keep working.
local noice_cmdline_defaults

local function set_noice_cmdline(enabled)
    local ok, config = pcall(require, "noice.config")
    if not ok or not config.is_running() then
        return
    end
    noice_cmdline_defaults = noice_cmdline_defaults
        or {
            cmdline = config.options.cmdline.enabled,
            messages = config.options.messages.enabled,
        }
    config.options.cmdline.enabled = enabled and noice_cmdline_defaults.cmdline
    config.options.messages.enabled = enabled
        and noice_cmdline_defaults.messages
    -- re-attach the UI so the new cmdline/messages settings apply
    local noice = require("noice")
    noice.disable()
    noice.enable()
end

Snacks.toggle({
    name = "Command Line Space",
    get = function()
        return vim.o.cmdheight > 0
    end,
    set = function(state)
        if state then
            set_noice_cmdline(false)
            vim.o.cmdheight = 1
        else
            vim.o.cmdheight = 0
            set_noice_cmdline(true)
        end
    end,
}):map("<leader>tx")

-- Hiding stops lualine's refresh timer/autocmds (otherwise it keeps
-- redrawing). laststatus=0 still draws a statusline above horizontal
-- splits, so those are drawn as a plain separator line instead.
local statusline_sep = "%#WinSeparator#%{repeat('─', winwidth(0))}"

Snacks.toggle({
    name = "Statusline",
    get = function()
        return vim.o.laststatus ~= 0
    end,
    set = function(state)
        local lualine = package.loaded["lualine"]
        if lualine then
            lualine.hide({ place = { "statusline" }, unhide = state })
        end
        if state then
            vim.o.laststatus = 3
            if not lualine then
                vim.o.statusline = ""
            end
        else
            vim.o.laststatus = 0
            vim.go.statusline = statusline_sep
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                vim.wo[win].statusline = statusline_sep
            end
        end
    end,
}):map("<leader>uX")

-- Toggle colorcolumn: off -> 80 -> 100 -> off
map("n", "<leader>uu", function()
    local next_column = { [""] = "80", ["80"] = "100" }
    vim.wo.colorcolumn = next_column[vim.wo.colorcolumn] or ""
end, { desc = "Toggle Color Column (80/100/off)" })

-- Cursorline: full line, or only the line number in the gutter.
-- Applied to normal editor windows so pickers/explorers keep theirs.
-- The choice is remembered and restored in config/options.lua.
local cursorline_full =
    vim.api.nvim_get_option_info2("cursorlineopt", {}).default

local function apply_cursorline(win)
    if is_normal_window(win) then
        vim.wo[win].cursorlineopt = vim.go.cursorlineopt
    end
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
    group = vim.api.nvim_create_augroup("CursorlineSync", { clear = true }),
    callback = function()
        apply_cursorline(vim.api.nvim_get_current_win())
    end,
})

Snacks.toggle({
    name = "Cursorline",
    get = function()
        return vim.go.cursorlineopt ~= "number"
    end,
    set = function(state)
        vim.go.cursorlineopt = state and cursorline_full or "number"
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            apply_cursorline(win)
        end
        require("config.util").write_state("cursorline_full", state and 1 or 0)
    end,
}):map("<leader>tL")

-- Cursor shape: Neovim's default (bar in insert, etc.) or a block in
-- every mode (guicursor = ""). Remembered like the cursorline above.
local guicursor_default = vim.api.nvim_get_option_info2("guicursor", {}).default

Snacks.toggle({
    name = "Block Cursor",
    get = function()
        return vim.go.guicursor == ""
    end,
    set = function(state)
        vim.go.guicursor = state and "" or guicursor_default
        require("config.util").write_state("block_cursor", state and 1 or 0)
    end,
}):map("<leader>tB")

-- Identation
map("n", "<", "<<", { desc = "Deindent" })
map("n", ">", ">>", { desc = "Indent" })

-- keymaps
map("n", "<leader>sk", function()
    Snacks.picker.keymaps({ layout = "select" })
end, { desc = "show keymaps" })

----buffer switch keymaps
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "go to next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "go to previous buffer" })

-- Save without formatting
map(
    { "n", "i" },
    "<A-s>",
    "<cmd>noautocmd w<CR>",
    { desc = "Save Without Formatting" }
)

--toggle code diff
map("n", "<leader>cd", "<cmd>CodeDiff<cr>", { desc = "Toggle codediff" })

-- Buffers
map("n", "<leader>bf", "<cmd>bfirst<cr>", { desc = "First Buffer" })
map("n", "<leader>ba", "<cmd>blast<cr>", { desc = "Last Buffer" })
map("n", "<M-CR>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- keymap to exit terminal mode using esc
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { silent = true })

-- Plugin Info
map("n", "<leader>cif", "<cmd>LazyFormatInfo<cr>", { desc = "Formatting" })
map("n", "<leader>cic", "<cmd>ConformInfo<cr>", { desc = "Conform" })
map("n", "<leader>ciL", function()
    local linters = require("lint").linters_by_ft[vim.bo.filetype]

    if not linters or #linters == 0 then
        LazyVim.warn("No linters attached", { title = "Linter" })
        return
    end

    LazyVim.notify(table.concat(linters, ", "), { title = "Linter" })
end, { desc = "Lint" })
map("n", "<leader>cir", "<cmd>LazyRoot<cr>", { desc = "Root" })

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

-- Terminal Stuff: a floating Snacks terminal, unless a terminal plugin is installed
if not LazyVim.has("floaterm.nvim") and not LazyVim.has("toggleterm.nvim") then
    local function float_term(cwd)
        return function()
            Snacks.terminal(
                nil,
                { size = { width = 0.8, height = 0.8 }, cwd = cwd() }
            )
        end
    end
    local root_term = float_term(LazyVim.root)

    map("n", "<leader>ft", root_term, { desc = "Terminal (Root Dir)" })
    map(
        "n",
        "<leader>fT",
        float_term(vim.fn.getcwd),
        { desc = "Terminal (cwd)" }
    )
    map("n", [[<c-\>]], root_term, { desc = "Terminal (Root Dir)" })
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

-- Center when scrolling
if Snacks.scroll.enabled then
    for _, key in ipairs({ "<C-d>", "<C-u>" }) do
        map("n", key, function()
            vim.wo.scrolloff = 999
            vim.defer_fn(function()
                vim.wo.scrolloff = 8
            end, 500)
            return key
        end, { expr = true })
    end
end

-- Select first option for spelling
map("n", "<leader>S", "1z=", { desc = "Spelling (First Option)" })

-- exit insert mode using jj
map("i", "jj", "<Esc>", { noremap = true, silent = true })

if vim.g.neovide then
    vim.g.neovide_scale_factor = 1.0

    local function zoom(delta)
        return function()
            vim.g.neovide_scale_factor = delta == 0 and 1.0
                or vim.g.neovide_scale_factor + delta
        end
    end

    -- Ctrl + = / Ctrl + Shift + = / Ctrl + - / Ctrl + 0
    for lhs, delta in pairs({
        ["<C-=>"] = 0.1,
        ["<C-S-=>"] = 0.1,
        ["<C-->"] = -0.1,
        ["<C-0>"] = 0,
    }) do
        local desc = delta > 0 and "Zoom in"
            or delta < 0 and "Zoom out"
            or "Reset zoom"
        map({ "n", "v", "i" }, lhs, zoom(delta), { desc = desc })
    end
end

----------------------clear multicursors------------------------------

vim.keymap.del("n", "<C-l>")

if vim.fn.has("nvim-0.13") == 1 then
    local multicursor_ns = vim.api.nvim_create_namespace("nvim.multicursor")

    map("n", "<C-l>", function()
        vim.api.nvim_buf_clear_namespace(0, multicursor_ns, 0, -1)
    end, { desc = "Clear multicursors" })

    map("n", "<Esc>", function()
        vim.cmd.nohlsearch()
        vim.api.nvim_buf_clear_namespace(0, multicursor_ns, 0, -1)
    end, { desc = "Clear search highligts & multicursors" })
end

-- CP Runner: compile, run and check test cases (see lua/cp)
require("cp").setup()
