-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

local map = vim.keymap.set
local o = vim.opt

local lazy = require("lazy")

vim.keymap.set("n", "<leader>ij", require("treesj").toggle)
-- Search current word
local searching_brave = function()
    vim.fn.system({ "xdg-open", "https://search.brave.com/search?q=" .. vim.fn.expand("<cword>") })
end
map("n", "<leader>?", searching_brave, { noremap = true, silent = true, desc = "Search Current Word on Brave Search" })

vim.keymap.set("n", "<leader>s1", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "s&r1" })
vim.keymap.set("n", "<leader>s2", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gi<Left><Left><Left>]], { desc = "s&r2" })
vim.keymap.set("n", "<leader>s3", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gIc<Left><Left><Left><Left>]], { desc = "s&r3" })

-- Lazy options
map("n", "<leader>l", "<Nop>")
map("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Lazy" })
-- stylua: ignore start
map("n", "<leader>ld", function() vim.fn.system({ "xdg-open", "https://lazyvim.org" }) end, { desc = "LazyVim Docs" })
map("n", "<leader>lr", function() vim.fn.system({ "xdg-open", "https://github.com/LazyVim/LazyVim" }) end, { desc = "LazyVim Repo" })
map("n", "<leader>lx", "<cmd>LazyExtras<cr>", { desc = "Extras" })
map("n", "<leader>lc", function() LazyVim.news.changelog() end, { desc = "LazyVim Changelog" })

map("n", "<leader>lu", function() lazy.update() end, { desc = "Lazy Update" })
map("n", "<leader>lC", function() lazy.check() end, { desc = "Lazy Check" })
map("n", "<leader>ls", function() lazy.sync() end, { desc = "Lazy Sync" })
-- stylua: ignore end

-- Open current file's PWD in VSCode
vim.keymap.set("n", "<leader>fV", function()
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

-- Identation
map("n", "<", "<<", { desc = "Deindent" })
map("n", ">", ">>", { desc = "Indent" })

-- Save without formatting
map({ "n", "i" }, "<A-s>", "<cmd>noautocmd w<CR>", { desc = "Save Without Formatting" })

-- Increment/decrement
-- map("n", "+", "<C-a>")

-- toggle oil
map("n", "-", "<cmd>Oil<cr>", { desc = "toggle oil lua" })

-- Buffers
map("n", "<leader>bf", "<cmd>bfirst<cr>", { desc = "First Buffer" })
map("n", "<leader>ba", "<cmd>blast<cr>", { desc = "Last Buffer" })
map("n", "<M-CR>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Toggle statusline
map("n", "<leader>uX", function()
    if o.laststatus:get() == 0 then
        o.laststatus = 3
    else
        o.laststatus = 0
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
map("n", "<C-c>", ":%y+<CR>", { desc = "Copy Whole Text to Clipboard", silent = true })

-- Select all text
map("n", "<C-e>", "gg<S-V>G", { desc = "Select all Text", silent = true, noremap = true })

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
        Snacks.terminal(nil, { size = { width = 0.8, height = 0.8 }, cwd = LazyVim.root() })
    end
    map("n", "<leader>ft", lazyterm, { desc = "Terminal (Root Dir)" })
    map("n", "<leader>fT", function()
        Snacks.terminal(nil, { size = { width = 0.8, height = 0.8 }, cwd = vim.fn.getcwd() })
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
