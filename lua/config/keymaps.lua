-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local o = vim.opt
local MiniFiles = require("mini.files")
local lazy = require("lazy")

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
-- local config1 = {
--     transparent_background = true,
-- }
-- map("n", "<leader>tc", function()
--     config1.transparent_background = not config.transparent_background
--     require("catppuccin").setup(config1)
--     vim.cmd.colorscheme("catppuccin-mocha")
-- end, { desc = "Toggle transparency" })

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

-- toggle oil
map("n", "-", "<cmd>Oil<cr>", { desc = "toggle oil lua" })

--toggle code diff
map("n", "<leader>cd", "<cmd>CodeDiff<cr>", { desc = "Toggle codediff" })

-- Buffers
map("n", "<leader>bf", "<cmd>bfirst<cr>", { desc = "First Buffer" })
map("n", "<leader>ba", "<cmd>blast<cr>", { desc = "Last Buffer" })
map("n", "<M-CR>", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Toggle statusline
map("n", "<leader>uX", function()
    if o.laststatus == 0 then
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
map("n", "<leader>tc", function()
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

-------- this is used for the Competitive Programming work----------------------

----------------- this keymap just runs the code and shows the output in the bottom terminal --------------------

local run_term_win = nil

map("n", "<leader>iq", function()
    local file = vim.fn.expand("%:p")
    local ft = vim.bo.filetype
    if file == "" then
        vim.notify("Please save the file first")
        return
    end
    local cmd
    if ft == "cpp" then
        cmd = "g++-16 "
            .. vim.fn.shellescape(file)
            .. " -o /tmp/nvim_run && /tmp/nvim_run"
    elseif ft == "c" then
        cmd = "gcc "
            .. vim.fn.shellescape(file)
            .. " -o /tmp/nvim_run && /tmp/nvim_run"
    elseif ft == "python" then
        cmd = "python3 " .. vim.fn.shellescape(file)
    elseif ft == "javascript" then
        cmd = "node " .. vim.fn.shellescape(file)
    elseif ft == "go" then
        cmd = "go run " .. vim.fn.shellescape(file)
    elseif ft == "rust" then
        cmd = "rustc "
            .. vim.fn.shellescape(file)
            .. " -o /tmp/nvim_run && /tmp/nvim_run"
    elseif ft == "typescript" then
        cmd = "bun run " .. vim.fn.shellescape(file)
    elseif ft == "java" then
        cmd = "java " .. vim.fn.shellescape(file)
    else
        vim.notify("Unsupported filetype: " .. ft)
        return
    end
    -- Save current file
    vim.cmd("write")

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

    -- Run command through shell
    vim.fn.jobstart({ "sh", "-c", cmd }, { term = true })
    -- Enter terminal mode
    vim.cmd("startinsert")
end, {
    desc = "Run current file",
})

------- this is tried and tested keymap but it shows the terminal at the bottom ------

-- map("n", "<leader>ir", function()
--     local file = vim.fn.expand("%:p")
--     local dir = vim.fn.expand("%:p:h")
--     local ft = vim.bo.filetype
--     if file == "" then
--         vim.notify("Please save the file first")
--         return
--     end
--
--     local input_file = dir .. "/input.txt"
--     local output_file = dir .. "/output.txt"
--
--     -- Create input.txt if it doesn't exist yet
--     if vim.fn.filereadable(input_file) == 0 then
--         vim.fn.writefile({}, input_file)
--     end
--
--     local redirect = " < "
--         .. vim.fn.shellescape(input_file)
--         .. " > "
--         .. vim.fn.shellescape(output_file)
--
--     local cmd
--     if ft == "cpp" then
--         cmd = "g++-16 "
--             .. vim.fn.shellescape(file)
--             .. " -o /tmp/nvim_run && /tmp/nvim_run"
--             .. redirect
--     elseif ft == "c" then
--         cmd = "gcc "
--             .. vim.fn.shellescape(file)
--             .. " -o /tmp/nvim_run && /tmp/nvim_run"
--             .. redirect
--     elseif ft == "python" then
--         cmd = "python3 " .. vim.fn.shellescape(file) .. redirect
--     elseif ft == "javascript" then
--         cmd = "node " .. vim.fn.shellescape(file) .. redirect
--     elseif ft == "go" then
--         cmd = "go run " .. vim.fn.shellescape(file) .. redirect
--     elseif ft == "rust" then
--         cmd = "rustc "
--             .. vim.fn.shellescape(file)
--             .. " -o /tmp/nvim_run && /tmp/nvim_run"
--             .. redirect
--     elseif ft == "typescript" then
--         cmd = "bun run " .. vim.fn.shellescape(file) .. redirect
--     elseif ft == "java" then
--         cmd = "java " .. vim.fn.shellescape(file) .. redirect
--     else
--         vim.notify("Unsupported filetype: " .. ft)
--         return
--     end
--
--     -- Save current file
--     vim.cmd("write")
--
--     -- Reuse existing terminal window if it's still open,
--     -- otherwise create a new bottom split
--     if run_term_win and vim.api.nvim_win_is_valid(run_term_win) then
--         vim.api.nvim_set_current_win(run_term_win)
--         local old_buf = vim.api.nvim_get_current_buf()
--         vim.cmd("enew") -- fresh empty buffer in the same window
--         if vim.api.nvim_buf_is_valid(old_buf) then
--             pcall(vim.api.nvim_buf_delete, old_buf, { force = true })
--         end
--     else
--         vim.cmd("botright new")
--         vim.cmd("resize 15")
--         run_term_win = vim.api.nvim_get_current_win()
--     end
--
--     -- Run command through shell
--     vim.fn.jobstart({ "sh", "-c", cmd }, { term = true })
--
--     -- Enter terminal mode
--     vim.cmd("startinsert")
-- end, {
--     desc = "Run current file (CP mode: input.txt -> output.txt)",
-- })

----- this is new approach shows bottom buffer only if there are any issues in the code ----

------------ new approach enable this if chatgpt one fails -----------------------------------------
-- local run_error_win = nil
-- local run_error_buf = nil
--
-- map("n", "<leader>ir", function()
--     local file = vim.fn.expand("%:p")
--     local dir = vim.fn.expand("%:p:h")
--     local ft = vim.bo.filetype
--
--     if file == "" then
--         vim.notify("Please save the file first", vim.log.levels.WARN)
--         return
--     end
--
--     local input_file = dir .. "/input.txt"
--     local output_file = dir .. "/output.txt"
--
--     -- Create input.txt if it doesn't exist
--     if vim.fn.filereadable(input_file) == 0 then
--         vim.fn.writefile({}, input_file)
--     end
--
--     -- Save current file
--     vim.cmd("write")
--
--     local redirect = " < "
--         .. vim.fn.shellescape(input_file)
--         .. " > "
--         .. vim.fn.shellescape(output_file)
--
--     local cmd
--
--     if ft == "cpp" then
--         cmd = "g++-16 "
--             .. vim.fn.shellescape(file)
--             .. " -o /tmp/nvim_run && /tmp/nvim_run"
--             .. redirect
--     elseif ft == "c" then
--         cmd = "gcc "
--             .. vim.fn.shellescape(file)
--             .. " -o /tmp/nvim_run && /tmp/nvim_run"
--             .. redirect
--     elseif ft == "python" then
--         cmd = "python3 " .. vim.fn.shellescape(file) .. redirect
--     elseif ft == "javascript" then
--         cmd = "node " .. vim.fn.shellescape(file) .. redirect
--     elseif ft == "go" then
--         cmd = "go run " .. vim.fn.shellescape(file) .. redirect
--     elseif ft == "rust" then
--         cmd = "rustc "
--             .. vim.fn.shellescape(file)
--             .. " -o /tmp/nvim_run && /tmp/nvim_run"
--             .. redirect
--     elseif ft == "typescript" then
--         cmd = "bun run " .. vim.fn.shellescape(file) .. redirect
--     elseif ft == "java" then
--         cmd = "java " .. vim.fn.shellescape(file) .. redirect
--     else
--         vim.notify("Unsupported filetype: " .. ft, vim.log.levels.WARN)
--         return
--     end
--
--     local stderr = {}
--
--     -- Run the command once
--     vim.fn.jobstart({ "sh", "-c", cmd }, {
--         stdout_buffered = true,
--         stderr_buffered = true,
--
--         on_stderr = function(_, data)
--             if data then
--                 for _, line in ipairs(data) do
--                     if line ~= "" then
--                         table.insert(stderr, line)
--                     end
--                 end
--             end
--         end,
--
--         on_exit = function(_, exit_code)
--             vim.schedule(function()
--                 -- =========================
--                 -- SUCCESS
--                 -- =========================
--                 if exit_code == 0 then
--                     -- vim.notify("success", vim.log.levels.INFO)
--
--                     -- Refresh output.txt if already open
--                     local output_buf = vim.fn.bufnr(output_file)
--
--                     if
--                         output_buf ~= -1
--                         and vim.api.nvim_buf_is_valid(output_buf)
--                     then
--                         vim.api.nvim_buf_call(output_buf, function()
--                             vim.cmd("edit!")
--                         end)
--                     end
--
--                     return
--                 end
--
--                 -- =========================
--                 -- ERROR
--                 -- =========================
--
--                 -- Create/reuse error buffer
--                 if
--                     not run_error_buf
--                     or not vim.api.nvim_buf_is_valid(run_error_buf)
--                 then
--                     run_error_buf = vim.api.nvim_create_buf(false, true)
--
--                     vim.bo[run_error_buf].bufhidden = "hide"
--                     vim.bo[run_error_buf].filetype = "text"
--                     vim.api.nvim_buf_set_name(run_error_buf, "Run Errors")
--                 end
--
--                 -- Put captured errors into buffer
--                 vim.bo[run_error_buf].modifiable = true
--
--                 vim.api.nvim_buf_set_lines(run_error_buf, 0, -1, false, stderr)
--
--                 vim.bo[run_error_buf].modifiable = false
--
--                 -- Reuse existing error window
--                 if
--                     run_error_win
--                     and vim.api.nvim_win_is_valid(run_error_win)
--                 then
--                     vim.api.nvim_win_set_buf(run_error_win, run_error_buf)
--                 else
--                     -- Open bottom split only on error
--                     vim.cmd("botright new")
--                     vim.cmd("resize 15")
--
--                     run_error_win = vim.api.nvim_get_current_win()
--
--                     vim.api.nvim_win_set_buf(run_error_win, run_error_buf)
--                 end
--             end)
--         end,
--     })
-- end, {
--     desc = "Run current file (input.txt -> output.txt)",
-- })
--
-- ------------------- end of the new approach ----------------------------------------------------------
--
-- ------------------------- this is a keymap to create out and input txt files and if they exist already then use them --------------------
--
-- map("n", "<leader>ic", function()
--     local dir = vim.fn.expand("%:p:h")
--     if dir == "" then
--         vim.notify("Please save the file first")
--         return
--     end
--
--     local input_file = dir .. "/input.txt"
--     local output_file = dir .. "/output.txt"
--
--     -- Create input.txt / output.txt if they don't exist
--     if vim.fn.filereadable(input_file) == 0 then
--         vim.fn.writefile({}, input_file)
--     end
--     if vim.fn.filereadable(output_file) == 0 then
--         vim.fn.writefile({}, output_file)
--     end
--
--     -- Remember the current (solution) buffer/window
--     local sol_win = vim.api.nvim_get_current_win()
--
--     -- Open a vertical split to the right for input.txt
--     vim.cmd("rightbelow vsplit " .. vim.fn.fnameescape(input_file))
--     local input_win = vim.api.nvim_get_current_win()
--
--     -- Below input.txt, open output.txt (horizontal split)
--     vim.cmd("belowright split " .. vim.fn.fnameescape(output_file))
--     -- local output_win = vim.api.nvim_get_current_win()
--
--     -- Make the right column roughly half the screen width
--     vim.api.nvim_set_current_win(input_win)
--     vim.cmd("vertical resize " .. math.floor(vim.o.columns / 2))
--
--     -- Balance the two right windows (input/output) vertically
--     vim.cmd("wincmd =")
--
--     -- Return focus to the solution window
--     vim.api.nvim_set_current_win(sol_win)
-- end, {
--     desc = "Open CP layout: solution | input.txt / output.txt",
-- })
--
----------------------clear multicursors------------------------------

vim.keymap.del("n", "<C-l>")

if vim.fn.has("nvim-0.13") == 1 then
    vim.keymap.set("n", "<C-l>", function()
        local ns = vim.api.nvim_create_namespace("nvim.multicursor")
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    end, {
        desc = "Clear multicursors",
    })
end

if vim.fn.has("nvim-0.13") == 1 then
    local multicursor_ns = vim.api.nvim_create_namespace("nvim.multicursor")
    vim.keymap.set("n", "<Esc>", function()
        vim.cmd.nohlsearch()
        vim.api.nvim_buf_clear_namespace(0, multicursor_ns, 0, -1)
    end, { desc = "Clear search highligts & multicursors" })
end

-- ============================================================
-- CP Runner
-- input.txt  -> output.txt
-- input1.txt -> output1.txt
-- input2.txt -> output2.txt
-- ...
-- ============================================================

local run_error_win = nil
local run_error_buf = nil

-- ============================================================
-- CP test case index
-- ============================================================

local cp_test_index = 0
local cp_layout_active = false

local function get_test_files(dir, index)
    if index == 0 then
        return dir .. "/input.txt", dir .. "/output.txt"
    end

    return dir .. "/input" .. index .. ".txt",
        dir .. "/output" .. index .. ".txt"
end

-- ============================================================
-- <leader>ic
-- Open/create next input/output pair
-- ============================================================

map("n", "<leader>ic", function()
    local dir = vim.fn.expand("%:p:h")

    if dir == "" then
        vim.notify("Please save the file first", vim.log.levels.WARN)
        return
    end

    -- If the CP layout is no longer active,
    -- start again from input.txt
    if not cp_layout_active then
        cp_test_index = 0
    end

    local input_file, output_file = get_test_files(dir, cp_test_index)

    -- Create input file if it doesn't exist
    if vim.fn.filereadable(input_file) == 0 then
        vim.fn.writefile({}, input_file)
    end

    -- Create output file if it doesn't exist
    if vim.fn.filereadable(output_file) == 0 then
        vim.fn.writefile({}, output_file)
    end

    -- Remember solution window
    local sol_win = vim.api.nvim_get_current_win()

    -- Open input on the right
    vim.cmd("rightbelow vsplit " .. vim.fn.fnameescape(input_file))
    local input_win = vim.api.nvim_get_current_win()

    -- Open output below input
    vim.cmd("belowright split " .. vim.fn.fnameescape(output_file))

    -- Resize right column
    vim.api.nvim_set_current_win(input_win)
    vim.cmd("vertical resize " .. math.floor(vim.o.columns / 2))

    -- Balance input/output
    vim.cmd("wincmd =")

    -- Return to solution
    vim.api.nvim_set_current_win(sol_win)

    -- Mark layout as active
    cp_layout_active = true

    -- Notify
    if cp_test_index == 0 then
        vim.notify("Opened input.txt + output.txt")
    else
        vim.notify(
            "Opened input"
                .. cp_test_index
                .. ".txt + output"
                .. cp_test_index
                .. ".txt"
        )
    end

    -- Next test case
    cp_test_index = cp_test_index + 1
end, {
    desc = "Open next CP input/output pair",
})

-- ============================================================
-- Reset CP test case counter when input/output windows are closed
-- ============================================================

vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
        local name = vim.api.nvim_buf_get_name(0)

        if name:match("/input%d*%.txt$") or name:match("/output%d*%.txt$") then
            cp_layout_active = true
        end
    end,
})

vim.api.nvim_create_autocmd("BufWinLeave", {
    callback = function()
        vim.schedule(function()
            local input_open = false
            local output_open = false

            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                local name = vim.api.nvim_buf_get_name(buf)

                if name:match("/input%d*%.txt$") then
                    input_open = true
                end

                if name:match("/output%d*%.txt$") then
                    output_open = true
                end
            end

            -- Neither input nor output is open anymore
            if not input_open and not output_open then
                cp_layout_active = false
                cp_test_index = 0
            end
        end)
    end,
})

-- ============================================================
-- <leader>ir
--
-- BUILD ONCE, THEN GENERATE OUTPUT FOR ALL TEST CASES
--
-- C++ / C / Rust / Go:
--     Build once
--     Reuse executable for every test
--
-- Python / JavaScript / TypeScript / Java:
--     Run directly for every test
--
-- Every test has a 4 second timeout.
--
-- If a test times out or crashes:
--     - Stop the current program
--     - Stop the entire <leader>ir run
-- ============================================================

map("n", "<leader>ir", function()
    local file = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local ft = vim.bo.filetype

    if file == "" then
        vim.notify("Please save the file first", vim.log.levels.WARN)
        return
    end

    vim.cmd("write")

    -- ========================================================
    -- Configuration
    -- ========================================================

    local CP_TIMEOUT = 10

    -- ========================================================
    -- Temporary executable
    -- ========================================================

    local executable = vim.fn.tempname()

    -- ========================================================
    -- Compiled languages
    -- ========================================================

    local compiled_language = ft == "cpp"
        or ft == "c"
        or ft == "rust"
        or ft == "go"

    -- ========================================================
    -- Supported languages
    -- ========================================================

    local supported = ft == "cpp"
        or ft == "c"
        or ft == "rust"
        or ft == "go"
        or ft == "python"
        or ft == "javascript"
        or ft == "typescript"
        or ft == "java"

    if not supported then
        vim.notify("Unsupported filetype: " .. ft, vim.log.levels.WARN)
        return
    end

    -- ========================================================
    -- Get compile/build command
    -- ========================================================

    local function get_compile_command()
        if ft == "cpp" then
            return "g++-16 "
                .. vim.fn.shellescape(file)
                .. " -o "
                .. vim.fn.shellescape(executable)
        elseif ft == "c" then
            return "gcc "
                .. vim.fn.shellescape(file)
                .. " -o "
                .. vim.fn.shellescape(executable)
        elseif ft == "rust" then
            return "rustc "
                .. vim.fn.shellescape(file)
                .. " -o "
                .. vim.fn.shellescape(executable)
        elseif ft == "go" then
            return "go build -o "
                .. vim.fn.shellescape(executable)
                .. " "
                .. vim.fn.shellescape(file)
        end

        return nil
    end

    -- ========================================================
    -- Get direct program command
    --
    -- IMPORTANT:
    -- No "sh -c" here.
    -- ========================================================

    local function get_program_command()
        if compiled_language then
            return {
                executable,
            }
        elseif ft == "python" then
            return {
                "python3",
                file,
            }
        elseif ft == "javascript" then
            return {
                "node",
                file,
            }
        elseif ft == "typescript" then
            return {
                "bun",
                "run",
                file,
            }
        elseif ft == "java" then
            return {
                "java",
                file,
            }
        end

        return nil
    end

    -- ========================================================
    -- Find input files
    -- ========================================================

    local test_cases = {}

    -- ========================================================
    -- input.txt
    -- ========================================================

    local input_file = dir .. "/input.txt"

    if vim.fn.filereadable(input_file) == 1 then
        table.insert(test_cases, {
            index = 0,
            input = input_file,
            output = dir .. "/output.txt",
        })
    end

    -- ========================================================
    -- input1.txt, input2.txt, ...
    -- ========================================================

    local index = 1

    while true do
        local input = dir .. "/input" .. index .. ".txt"

        if vim.fn.filereadable(input) == 0 then
            break
        end

        table.insert(test_cases, {
            index = index,
            input = input,
            output = dir .. "/output" .. index .. ".txt",
        })

        index = index + 1
    end

    -- ========================================================
    -- No input files
    -- ========================================================

    if #test_cases == 0 then
        vim.notify(
            "No input files found. Press <leader>ic first.",
            vim.log.levels.WARN
        )

        return
    end

    -- ========================================================
    -- Current test
    -- ========================================================

    local current_test = 1

    -- ========================================================
    -- Run next test
    -- ========================================================

    local function run_next_test()
        -- ====================================================
        -- ALL TESTS COMPLETE
        -- ====================================================

        if current_test > #test_cases then
            if compiled_language then
                vim.fn.delete(executable)
            end

            vim.notify(
                "All " .. #test_cases .. " test cases completed",
                vim.log.levels.INFO
            )

            return
        end

        local test = test_cases[current_test]

        local test_number = test.index == 0 and "0" or tostring(test.index)

        -- ====================================================
        -- Create output file if it doesn't exist
        -- ====================================================

        if vim.fn.filereadable(test.output) == 0 then
            vim.fn.writefile({}, test.output)
        end

        -- ====================================================
        -- Read input
        -- ====================================================

        local input_lines = vim.fn.readfile(test.input)

        local input_data = table.concat(input_lines, "\n")

        -- Make sure input ends with newline
        if input_data ~= "" then
            input_data = input_data .. "\n"
        end

        -- ====================================================
        -- Program command
        -- ====================================================

        local command = get_program_command()

        if not command then
            vim.notify(
                "Unable to determine program command",
                vim.log.levels.ERROR
            )

            if compiled_language then
                vim.fn.delete(executable)
            end

            return
        end

        -- ====================================================
        -- Capture stdout / stderr
        -- ====================================================

        local stdout = {}
        local stderr = {}

        local finished = false
        local job_id = nil

        -- ====================================================
        -- Start timing
        -- ====================================================

        local start_time = vim.uv.hrtime()

        -- ====================================================
        -- Create timeout timer
        -- ====================================================

        local timer = vim.uv.new_timer()

        if not timer then
            vim.notify("Failed to create timeout timer", vim.log.levels.ERROR)

            if compiled_language then
                vim.fn.delete(executable)
            end

            return
        end

        -- ====================================================
        -- 4 SECOND TIMEOUT
        -- ====================================================

        timer:start(
            CP_TIMEOUT * 1000,
            0,

            vim.schedule_wrap(function()
                if finished then
                    return
                end

                finished = true

                timer:stop()
                timer:close()

                -- --------------------------------------------
                -- Kill program
                -- --------------------------------------------

                if job_id then
                    vim.fn.jobstop(job_id)
                end

                -- --------------------------------------------
                -- Cleanup executable
                -- --------------------------------------------

                if compiled_language then
                    vim.fn.delete(executable)
                end

                -- --------------------------------------------
                -- Show timeout
                -- --------------------------------------------

                local lines = {
                    "========================================",
                    "TIMEOUT - Test Case " .. test_number,
                    "========================================",
                    "",
                    "Input:  " .. vim.fn.fnamemodify(test.input, ":t"),
                    "Output: " .. vim.fn.fnamemodify(test.output, ":t"),
                    "",
                    "Time limit: " .. CP_TIMEOUT .. " seconds",
                    "",
                    "The program was stopped because it",
                    "exceeded the time limit.",
                    "",
                    "========================================",
                }

                -- --------------------------------------------
                -- Reuse result/error buffer
                -- --------------------------------------------

                if
                    not run_error_buf
                    or not vim.api.nvim_buf_is_valid(run_error_buf)
                then
                    run_error_buf = vim.api.nvim_create_buf(false, true)

                    vim.bo[run_error_buf].bufhidden = "hide"

                    vim.bo[run_error_buf].filetype = "text"

                    vim.api.nvim_buf_set_name(run_error_buf, "Run Errors")
                end

                vim.bo[run_error_buf].modifiable = true

                vim.api.nvim_buf_set_lines(run_error_buf, 0, -1, false, lines)

                vim.bo[run_error_buf].modifiable = false

                -- --------------------------------------------
                -- Show bottom window
                -- --------------------------------------------

                if
                    run_error_win
                    and vim.api.nvim_win_is_valid(run_error_win)
                then
                    vim.api.nvim_win_set_buf(run_error_win, run_error_buf)
                else
                    vim.cmd("botright new")
                    vim.cmd("resize 15")

                    run_error_win = vim.api.nvim_get_current_win()

                    vim.api.nvim_win_set_buf(run_error_win, run_error_buf)
                end

                vim.notify(
                    "Test case "
                        .. test_number
                        .. " timed out after "
                        .. CP_TIMEOUT
                        .. " seconds",
                    vim.log.levels.ERROR
                )
            end)
        )

        -- ====================================================
        -- Start program DIRECTLY
        -- ====================================================

        job_id = vim.fn.jobstart(command, {
            stdin = "pipe",

            stdout_buffered = false,
            stderr_buffered = false,

            -- ========================================
            -- STDOUT
            -- ========================================

            on_stdout = function(_, data)
                if not data then
                    return
                end

                for _, line in ipairs(data) do
                    table.insert(stdout, line)
                end
            end,

            -- ========================================
            -- STDERR
            -- ========================================

            on_stderr = function(_, data)
                if not data then
                    return
                end

                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(stderr, line)
                    end
                end
            end,

            -- ========================================
            -- PROCESS EXIT
            -- ========================================

            on_exit = function(_, exit_code)
                vim.schedule(function()
                    -- =================================
                    -- Timeout already handled
                    -- =================================

                    if finished then
                        return
                    end

                    finished = true

                    timer:stop()
                    timer:close()

                    -- =================================
                    -- Execution time
                    -- =================================

                    local elapsed = (vim.uv.hrtime() - start_time) / 1000000

                    local elapsed_ms = math.floor(elapsed + 0.5)

                    -- =================================
                    -- Runtime error
                    -- =================================

                    if exit_code ~= 0 then
                        -- -----------------------------
                        -- Cleanup
                        -- -----------------------------

                        if compiled_language then
                            vim.fn.delete(executable)
                        end

                        -- -----------------------------
                        -- Error buffer
                        -- -----------------------------

                        local error_lines = {

                            "========================================",

                            "ERROR - Test Case " .. test_number,

                            "========================================",

                            "",

                            "Input:  " .. vim.fn.fnamemodify(test.input, ":t"),

                            "Output: " .. vim.fn.fnamemodify(test.output, ":t"),

                            "",

                            "Exit code: " .. exit_code,

                            "Execution time: " .. elapsed_ms .. " ms",

                            "",
                        }

                        if #stderr > 0 then
                            table.insert(error_lines, "Program Error:")

                            table.insert(
                                error_lines,
                                "----------------------------------------"
                            )

                            vim.list_extend(error_lines, stderr)
                        else
                            table.insert(
                                error_lines,
                                "Program exited unexpectedly."
                            )
                        end

                        table.insert(error_lines, "")

                        table.insert(
                            error_lines,
                            "========================================"
                        )

                        -- -----------------------------
                        -- Create/reuse error buffer
                        -- -----------------------------

                        if
                            not run_error_buf
                            or not vim.api.nvim_buf_is_valid(run_error_buf)
                        then
                            run_error_buf = vim.api.nvim_create_buf(false, true)

                            vim.bo[run_error_buf].bufhidden = "hide"

                            vim.bo[run_error_buf].filetype = "text"

                            vim.api.nvim_buf_set_name(
                                run_error_buf,
                                "Run Errors"
                            )
                        end

                        vim.bo[run_error_buf].modifiable = true

                        vim.api.nvim_buf_set_lines(
                            run_error_buf,
                            0,
                            -1,
                            false,
                            error_lines
                        )

                        vim.bo[run_error_buf].modifiable = false

                        -- -----------------------------
                        -- Show bottom window
                        -- -----------------------------

                        if
                            run_error_win
                            and vim.api.nvim_win_is_valid(run_error_win)
                        then
                            vim.api.nvim_win_set_buf(
                                run_error_win,
                                run_error_buf
                            )
                        else
                            vim.cmd("botright new")

                            vim.cmd("resize 15")

                            run_error_win = vim.api.nvim_get_current_win()

                            vim.api.nvim_win_set_buf(
                                run_error_win,
                                run_error_buf
                            )
                        end

                        vim.notify(
                            "Test case " .. test_number .. " failed",
                            vim.log.levels.ERROR
                        )

                        -- --------------------------------
                        -- STOP ENTIRE RUN
                        -- --------------------------------

                        return
                    end

                    -- =================================
                    -- SUCCESS
                    -- =================================

                    -- ---------------------------------
                    -- Write program output
                    -- ---------------------------------

                    local output_lines = {}

                    for _, line in ipairs(stdout) do
                        table.insert(output_lines, line)
                    end

                    -- Remove final empty lines that
                    -- can be produced by stdout capture.
                    while
                        #output_lines > 0
                        and output_lines[#output_lines] == ""
                    do
                        table.remove(output_lines)
                    end

                    vim.fn.writefile(output_lines, test.output)

                    -- ---------------------------------
                    -- Refresh output buffer if open
                    -- ---------------------------------

                    local output_buf = vim.fn.bufnr(test.output)

                    if
                        output_buf ~= -1
                        and vim.api.nvim_buf_is_valid(output_buf)
                    then
                        vim.api.nvim_buf_call(output_buf, function()
                            vim.cmd("edit!")
                        end)
                    end

                    -- ---------------------------------
                    -- Next test
                    -- ---------------------------------

                    current_test = current_test + 1

                    run_next_test()
                end)
            end,
        })

        -- ====================================================
        -- Job failed to start
        -- ====================================================

        if job_id <= 0 then
            timer:stop()
            timer:close()

            if compiled_language then
                vim.fn.delete(executable)
            end

            vim.notify("Failed to start program", vim.log.levels.ERROR)

            return
        end

        -- ====================================================
        -- Send input
        -- ====================================================

        if input_data ~= "" then
            vim.fn.chansend(job_id, input_data)
        end

        -- ====================================================
        -- IMPORTANT:
        -- Close stdin so programs waiting for EOF don't hang.
        -- ====================================================

        vim.fn.chanclose(job_id, "stdin")
    end

    -- ========================================================
    -- BUILD ONCE
    -- ========================================================

    if compiled_language then
        local compile_command = get_compile_command()

        local compile_stderr = {}

        vim.notify(
            "Building " .. vim.fn.fnamemodify(file, ":t") .. "...",
            vim.log.levels.INFO
        )

        -- ====================================================
        -- Compile/build
        -- ====================================================

        local compile_job = vim.fn.jobstart({
            "sh",
            "-c",
            compile_command,
        }, {
            stdout_buffered = true,
            stderr_buffered = true,

            -- ========================================
            -- Compiler stderr
            -- ========================================

            on_stderr = function(_, data)
                if data then
                    for _, line in ipairs(data) do
                        if line ~= "" then
                            table.insert(compile_stderr, line)
                        end
                    end
                end
            end,

            -- ========================================
            -- Compile finished
            -- ========================================

            on_exit = function(_, exit_code)
                vim.schedule(function()
                    -- =================================
                    -- Compilation failed
                    -- =================================

                    if exit_code ~= 0 then
                        local lines = {
                            "========================================",
                            "COMPILATION / BUILD FAILED",
                            "========================================",
                            "",
                            "File: " .. vim.fn.fnamemodify(file, ":t"),
                            "",
                        }

                        if #compile_stderr > 0 then
                            vim.list_extend(lines, compile_stderr)
                        else
                            table.insert(
                                lines,
                                "Compiler exited with code " .. exit_code
                            )
                        end

                        table.insert(lines, "")

                        table.insert(
                            lines,
                            "========================================"
                        )

                        -- --------------------------------
                        -- Create/reuse error buffer
                        -- --------------------------------

                        if
                            not run_error_buf
                            or not vim.api.nvim_buf_is_valid(run_error_buf)
                        then
                            run_error_buf = vim.api.nvim_create_buf(false, true)

                            vim.bo[run_error_buf].bufhidden = "hide"

                            vim.bo[run_error_buf].filetype = "text"

                            vim.api.nvim_buf_set_name(
                                run_error_buf,
                                "Run Errors"
                            )
                        end

                        vim.bo[run_error_buf].modifiable = true

                        vim.api.nvim_buf_set_lines(
                            run_error_buf,
                            0,
                            -1,
                            false,
                            lines
                        )

                        vim.bo[run_error_buf].modifiable = false

                        -- --------------------------------
                        -- Show bottom window
                        -- --------------------------------

                        if
                            run_error_win
                            and vim.api.nvim_win_is_valid(run_error_win)
                        then
                            vim.api.nvim_win_set_buf(
                                run_error_win,
                                run_error_buf
                            )
                        else
                            vim.cmd("botright new")
                            vim.cmd("resize 15")

                            run_error_win = vim.api.nvim_get_current_win()

                            vim.api.nvim_win_set_buf(
                                run_error_win,
                                run_error_buf
                            )
                        end

                        vim.notify("Compilation failed", vim.log.levels.ERROR)

                        vim.fn.delete(executable)

                        return
                    end

                    -- =================================
                    -- Build successful
                    -- =================================

                    vim.notify(
                        "Build successful. Running "
                            .. #test_cases
                            .. " test cases...",
                        vim.log.levels.INFO
                    )

                    -- =================================
                    -- Run tests
                    -- =================================

                    run_next_test()
                end)
            end,
        })

        if compile_job <= 0 then
            vim.notify("Failed to start compiler", vim.log.levels.ERROR)

            vim.fn.delete(executable)

            return
        end
    else
        -- ====================================================
        -- Interpreted language
        -- ====================================================

        run_next_test()
    end
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

    local deleted = 0

    -- Delete input.txt / output.txt
    local base_files = {
        dir .. "/input.txt",
        dir .. "/output.txt",
    }

    for _, file in ipairs(base_files) do
        if vim.fn.filereadable(file) == 1 then
            vim.fn.delete(file)
            deleted = deleted + 1
        end
    end

    -- Delete input1.txt/output1.txt, input2.txt/output2.txt, ...
    local index = 1

    while true do
        local input_file = dir .. "/input" .. index .. ".txt"

        local output_file = dir .. "/output" .. index .. ".txt"

        local found = false

        if vim.fn.filereadable(input_file) == 1 then
            vim.fn.delete(input_file)
            deleted = deleted + 1
            found = true
        end

        if vim.fn.filereadable(output_file) == 1 then
            vim.fn.delete(output_file)
            deleted = deleted + 1
            found = true
        end

        -- Stop when neither file exists
        if not found then
            break
        end

        index = index + 1
    end

    -- Reset test-case state
    cp_test_index = 0
    cp_layout_active = false

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
-- CP Helpers
-- ============================================================

local CP_TIMEOUT = 10

local run_error_win = nil
local run_error_buf = nil

-- ============================================================
-- Get input/output files
--
-- Test 1:
-- input.txt  -> output.txt
--
-- Test 2:
-- input1.txt -> output1.txt
--
-- Test 3:
-- input2.txt -> output2.txt
-- ============================================================

local function get_test_files(dir, index)
    if index == 0 then
        return dir .. "/input.txt", dir .. "/output.txt"
    end

    return dir .. "/input" .. index .. ".txt",
        dir .. "/output" .. index .. ".txt"
end

-- ============================================================
-- Read file
-- ============================================================

local function read_file(path)
    if vim.fn.filereadable(path) == 0 then
        return {}
    end

    return vim.fn.readfile(path)
end

-- ============================================================
-- Normalize output
--
-- Removes trailing whitespace and trailing blank lines.
-- ============================================================

local function normalize_output(lines)
    local result = {}

    for _, line in ipairs(lines) do
        line = line:gsub("%s+$", "")
        table.insert(result, line)
    end

    while #result > 0 and result[#result] == "" do
        table.remove(result)
    end

    return result
end

-- ============================================================
-- Compare expected output with actual output
-- ============================================================

local function compare_output(expected_file, actual_file)
    local expected = normalize_output(read_file(expected_file))

    local actual = normalize_output(read_file(actual_file))

    if #expected ~= #actual then
        return false, expected, actual
    end

    for i = 1, #expected do
        if expected[i] ~= actual[i] then
            return false, expected, actual
        end
    end

    return true, expected, actual
end

-- ============================================================
-- Create side-by-side diff
-- ============================================================

local function create_side_by_side_diff(expected, actual)
    local lines = {}

    local max_lines = math.max(#expected, #actual)

    local width = 40

    table.insert(
        lines,
        string.format("%-" .. width .. "s | %s", "EXPECTED", "YOUR OUTPUT")
    )

    table.insert(
        lines,
        string.rep("-", width) .. "-+-" .. string.rep("-", width)
    )

    for i = 1, max_lines do
        local expected_line = expected[i] or ""

        local actual_line = actual[i] or ""

        local marker = " "

        if expected_line ~= actual_line then
            marker = "<"
        end

        table.insert(
            lines,
            string.format(
                "%-" .. width .. "s | %s %s",
                expected_line,
                marker,
                actual_line
            )
        )
    end

    return lines
end

-- ============================================================
-- Close existing CP result window
-- ============================================================

local function close_cp_result_window()
    if run_error_win and vim.api.nvim_win_is_valid(run_error_win) then
        vim.api.nvim_win_close(run_error_win, true)

        run_error_win = nil
    end
end

-- ============================================================
-- Show lines in CP result window
-- ============================================================

local function show_cp_result(lines, height)
    if not run_error_buf or not vim.api.nvim_buf_is_valid(run_error_buf) then
        run_error_buf = vim.api.nvim_create_buf(false, true)

        vim.bo[run_error_buf].bufhidden = "hide"
        vim.bo[run_error_buf].filetype = "text"

        vim.api.nvim_buf_set_name(run_error_buf, "CP Test Results")
    end

    vim.bo[run_error_buf].modifiable = true

    vim.api.nvim_buf_set_lines(run_error_buf, 0, -1, false, lines)

    vim.bo[run_error_buf].modifiable = false

    if not run_error_win or not vim.api.nvim_win_is_valid(run_error_win) then
        vim.cmd("botright new")
        vim.cmd("resize " .. height)

        run_error_win = vim.api.nvim_get_current_win()
    end

    vim.api.nvim_win_set_buf(run_error_win, run_error_buf)
end

-- ============================================================
-- Get compiler / runner command
-- ============================================================

local function get_cp_run_command(file, ft, input_file, actual_file)
    local redirect = " < "
        .. vim.fn.shellescape(input_file)
        .. " > "
        .. vim.fn.shellescape(actual_file)

    if ft == "cpp" then
        return "g++-16 "
            .. vim.fn.shellescape(file)
            .. " -o /tmp/nvim_run && /tmp/nvim_run"
            .. redirect
    elseif ft == "c" then
        return "gcc "
            .. vim.fn.shellescape(file)
            .. " -o /tmp/nvim_run && /tmp/nvim_run"
            .. redirect
    elseif ft == "python" then
        return "python3 " .. vim.fn.shellescape(file) .. redirect
    elseif ft == "javascript" then
        return "node " .. vim.fn.shellescape(file) .. redirect
    elseif ft == "go" then
        return "go run " .. vim.fn.shellescape(file) .. redirect
    elseif ft == "rust" then
        return "rustc "
            .. vim.fn.shellescape(file)
            .. " -o /tmp/nvim_run && /tmp/nvim_run"
            .. redirect
    elseif ft == "typescript" then
        return "bun run " .. vim.fn.shellescape(file) .. redirect
    elseif ft == "java" then
        return "java " .. vim.fn.shellescape(file) .. redirect
    end

    return nil
end

-- ============================================================
-- Find all test cases
-- ============================================================

local function find_cp_tests(dir)
    local test_cases = {}

    local index = 0

    while true do
        local input_file, expected_file = get_test_files(dir, index)

        -- Stop when input file doesn't exist
        if vim.fn.filereadable(input_file) == 0 then
            break
        end

        -- Expected output must exist
        if vim.fn.filereadable(expected_file) == 0 then
            return nil,
                "Missing expected output: " .. vim.fn.fnamemodify(
                    expected_file,
                    ":t"
                )
        end

        table.insert(test_cases, {
            index = index,
            input = input_file,
            expected = expected_file,
        })

        index = index + 1
    end

    return test_cases
end

-- ============================================================
-- <leader>iR
--
-- Run ALL tests and compare against expected output.
--
-- IMPORTANT:
-- Compiled languages are compiled ONLY ONCE.
--
-- C++:
--     g++-16 solution.cpp -o /tmp/nvim_cp_run
--              ↓
--     Test 1 -> /tmp/nvim_cp_run
--     Test 2 -> /tmp/nvim_cp_run
--     Test 3 -> /tmp/nvim_cp_run
--
-- C / Rust work the same way.
--
-- Python / JS / Go / TypeScript / Java are executed
-- separately for every test.
--
-- Every individual test has a 4 second timeout.
-- ============================================================

map("n", "<leader>iR", function()
    local file = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local ft = vim.bo.filetype

    if file == "" then
        vim.notify("Please save the file first", vim.log.levels.WARN)
        return
    end

    vim.cmd("write")

    -- ========================================================
    -- Find tests
    -- ========================================================

    local test_cases, error_message = find_cp_tests(dir)

    if not test_cases then
        vim.notify(error_message, vim.log.levels.WARN)
        return
    end

    if #test_cases == 0 then
        vim.notify(
            "No test cases found. Press <leader>ic first.",
            vim.log.levels.WARN
        )
        return
    end

    -- ========================================================
    -- Close previous results
    -- ========================================================

    close_cp_result_window()

    -- ========================================================
    -- Results
    -- ========================================================

    local results = {}

    local current_test = 1

    -- ========================================================
    -- Executable path for compiled languages
    -- ========================================================

    local executable = "/tmp/nvim_cp_run"

    -- ========================================================
    -- Determine whether language needs compilation
    -- ========================================================

    local compiled_language = ft == "cpp" or ft == "c" or ft == "rust"

    -- ========================================================
    -- Build compile command
    -- ========================================================

    local function get_compile_command()
        if ft == "cpp" then
            return "g++-16 "
                .. vim.fn.shellescape(file)
                .. " -o "
                .. vim.fn.shellescape(executable)
        elseif ft == "c" then
            return "gcc "
                .. vim.fn.shellescape(file)
                .. " -o "
                .. vim.fn.shellescape(executable)
        elseif ft == "rust" then
            return "rustc "
                .. vim.fn.shellescape(file)
                .. " -o "
                .. vim.fn.shellescape(executable)
        end

        return nil
    end

    -- ========================================================
    -- Build execution command
    --
    -- This ONLY runs the program.
    -- It does NOT compile.
    -- ========================================================

    local function get_run_command(input_file, actual_file)
        local redirect = " < "
            .. vim.fn.shellescape(input_file)
            .. " > "
            .. vim.fn.shellescape(actual_file)

        if compiled_language then
            return vim.fn.shellescape(executable) .. redirect
        elseif ft == "python" then
            return "python3 " .. vim.fn.shellescape(file) .. redirect
        elseif ft == "javascript" then
            return "node " .. vim.fn.shellescape(file) .. redirect
        elseif ft == "go" then
            return "go run " .. vim.fn.shellescape(file) .. redirect
        elseif ft == "typescript" then
            return "bun run " .. vim.fn.shellescape(file) .. redirect
        elseif ft == "java" then
            return "java " .. vim.fn.shellescape(file) .. redirect
        end

        return nil
    end

    -- ========================================================
    -- Check supported language
    -- ========================================================

    if
        not compiled_language
        and ft ~= "python"
        and ft ~= "javascript"
        and ft ~= "go"
        and ft ~= "typescript"
        and ft ~= "java"
    then
        vim.notify("Unsupported filetype: " .. ft, vim.log.levels.WARN)

        return
    end

    -- ========================================================
    -- Show final results
    -- ========================================================

    local function show_results()
        local passed_count = 0
        local failed_count = 0

        local total_time = 0
        local max_time = 0

        for _, result in ipairs(results) do
            if result.passed then
                passed_count = passed_count + 1
            else
                failed_count = failed_count + 1
            end

            total_time = total_time + result.time

            max_time = math.max(max_time, result.time)
        end

        -- ====================================================
        -- Everything passed
        -- ====================================================

        if failed_count == 0 then
            vim.notify(
                "✓ All "
                    .. #results
                    .. " tests passed | "
                    .. total_time
                    .. " ms",
                vim.log.levels.INFO
            )

            return
        end

        -- ====================================================
        -- Build detailed result
        -- ====================================================

        local lines = {}

        table.insert(lines, "========================================")

        table.insert(lines, "CP TEST RESULTS")

        table.insert(lines, "========================================")

        table.insert(lines, "")

        table.insert(
            lines,
            string.format("Passed: %d/%d", passed_count, #results)
        )

        table.insert(
            lines,
            string.format("Failed: %d/%d", failed_count, #results)
        )

        table.insert(lines, string.format("Total time: %d ms", total_time))

        table.insert(lines, string.format("Max test:   %d ms", max_time))

        table.insert(lines, "")

        -- ====================================================
        -- Individual test results
        -- ====================================================

        for _, result in ipairs(results) do
            table.insert(lines, "----------------------------------------")

            -- ================================================
            -- PASSED
            -- ================================================

            if result.passed then
                table.insert(
                    lines,
                    string.format("✓ %-10s %d ms", result.name, result.time)
                )

            -- ================================================
            -- TIMEOUT
            -- ================================================
            elseif result.timeout then
                table.insert(
                    lines,
                    string.format("✗ %-10s TIME LIMIT EXCEEDED", result.name)
                )

                table.insert(lines, "Time limit: " .. CP_TIMEOUT .. " seconds")

            -- ================================================
            -- PROGRAM ERROR
            -- ================================================
            elseif result.error and #result.error > 0 then
                table.insert(
                    lines,
                    string.format(
                        "✗ %-10s ERROR (%d ms)",
                        result.name,
                        result.time
                    )
                )

                table.insert(lines, "")

                table.insert(lines, "Program Error:")

                table.insert(lines, "----------------------------------------")

                vim.list_extend(lines, result.error)

            -- ================================================
            -- WRONG ANSWER
            -- ================================================
            else
                table.insert(
                    lines,
                    string.format(
                        "✗ %-10s FAILED (%d ms)",
                        result.name,
                        result.time
                    )
                )

                table.insert(lines, "")

                local diff =
                    create_side_by_side_diff(result.expected, result.actual)

                vim.list_extend(lines, diff)
            end

            table.insert(lines, "")
        end

        table.insert(lines, "========================================")

        -- ====================================================
        -- Show result window
        -- ====================================================

        show_cp_result(lines, 20)

        vim.notify(
            string.format(
                "%d/%d passed | %d failed | %d ms",
                passed_count,
                #results,
                failed_count,
                total_time
            ),
            vim.log.levels.ERROR
        )
    end

    -- ========================================================
    -- Run next test
    -- ========================================================

    local function run_next_test()
        -- ====================================================
        -- ALL TESTS COMPLETE
        -- ====================================================

        if current_test > #test_cases then
            show_results()

            return
        end

        local test = test_cases[current_test]

        local test_name = "Test " .. (test.index + 1)

        -- ====================================================
        -- Temporary actual output
        -- ====================================================

        local actual_file = "/tmp/nvim_cp_actual_" .. test.index .. ".txt"

        vim.fn.delete(actual_file)

        -- ====================================================
        -- Build run command
        -- ====================================================

        local cmd = get_run_command(test.input, actual_file)

        if not cmd then
            vim.notify("Unsupported filetype: " .. ft, vim.log.levels.WARN)

            return
        end

        local stderr = {}

        local finished = false
        local job_id = nil

        -- ====================================================
        -- Start execution timer
        --
        -- This measures ONLY this test execution.
        -- Compilation time is NOT included here.
        -- ====================================================

        local start_time = vim.uv.hrtime()

        -- ====================================================
        -- Create timeout timer
        -- ====================================================

        local timer = vim.uv.new_timer()

        if not timer then
            vim.notify("Failed to create timeout timer", vim.log.levels.ERROR)

            return
        end

        -- ====================================================
        -- 4 SECOND TEST TIMEOUT
        -- ====================================================

        timer:start(
            CP_TIMEOUT * 1000,
            0,

            vim.schedule_wrap(function()
                if finished then
                    return
                end

                finished = true

                timer:stop()
                timer:close()

                -- Stop current program
                if job_id then
                    vim.fn.jobstop(job_id)
                end

                -- Record timeout
                table.insert(results, {
                    name = test_name,

                    passed = false,

                    expected = normalize_output(read_file(test.expected)),

                    actual = {},

                    error = {
                        "TIME LIMIT EXCEEDED",
                    },

                    time = CP_TIMEOUT * 1000,

                    timeout = true,
                })

                vim.fn.delete(actual_file)

                -- IMPORTANT:
                -- Continue to next test
                current_test = current_test + 1

                run_next_test()
            end)
        )

        -- ====================================================
        -- RUN TEST
        -- ====================================================

        job_id = vim.fn.jobstart({
            "sh",
            "-c",
            cmd,
        }, {
            stdout_buffered = true,
            stderr_buffered = true,

            -- ========================================
            -- STDERR
            -- ========================================

            on_stderr = function(_, data)
                if data then
                    for _, line in ipairs(data) do
                        if line ~= "" then
                            table.insert(stderr, line)
                        end
                    end
                end
            end,

            -- ========================================
            -- PROCESS EXIT
            -- ========================================

            on_exit = function(_, exit_code)
                vim.schedule(function()
                    -- Timer already handled it
                    if finished then
                        return
                    end

                    finished = true

                    timer:stop()
                    timer:close()

                    -- =================================
                    -- Execution time
                    -- =================================

                    local elapsed = (vim.uv.hrtime() - start_time) / 1000000

                    local elapsed_ms = math.floor(elapsed + 0.5)

                    -- =================================
                    -- Program error
                    -- =================================

                    if exit_code ~= 0 then
                        table.insert(results, {
                            name = test_name,

                            passed = false,

                            expected = normalize_output(
                                read_file(test.expected)
                            ),

                            actual = {},

                            error = stderr,

                            time = elapsed_ms,
                        })

                        -- =================================
                        -- Normal execution
                        -- =================================
                    else
                        local passed, expected, actual =
                            compare_output(test.expected, actual_file)

                        table.insert(results, {
                            name = test_name,

                            passed = passed,

                            expected = expected,

                            actual = actual,

                            error = {},

                            time = elapsed_ms,
                        })
                    end

                    -- =================================
                    -- Remove temporary output
                    -- =================================

                    vim.fn.delete(actual_file)

                    -- =================================
                    -- Continue to next test
                    -- =================================

                    current_test = current_test + 1

                    run_next_test()
                end)
            end,
        })
    end

    -- ========================================================
    -- COMPILE ONCE
    --
    -- Only C / C++ / Rust come here.
    -- ========================================================

    if compiled_language then
        local compile_command = get_compile_command()

        local compile_stderr = {}

        local compile_finished = false

        vim.notify(
            "Compiling " .. vim.fn.fnamemodify(file, ":t") .. "...",
            vim.log.levels.INFO
        )

        local compile_job = vim.fn.jobstart({
            "sh",
            "-c",
            compile_command,
        }, {
            stdout_buffered = true,
            stderr_buffered = true,

            on_stderr = function(_, data)
                if data then
                    for _, line in ipairs(data) do
                        if line ~= "" then
                            table.insert(compile_stderr, line)
                        end
                    end
                end
            end,

            on_exit = function(_, exit_code)
                vim.schedule(function()
                    if compile_finished then
                        return
                    end

                    compile_finished = true

                    -- =================================
                    -- Compilation failed
                    -- =================================

                    if exit_code ~= 0 then
                        local lines = {
                            "========================================",
                            "COMPILATION FAILED",
                            "========================================",
                            "",
                            "File: " .. vim.fn.fnamemodify(file, ":t"),
                            "",
                        }

                        if #compile_stderr > 0 then
                            vim.list_extend(lines, compile_stderr)
                        else
                            table.insert(
                                lines,
                                "Compiler exited with code " .. exit_code
                            )
                        end

                        table.insert(lines, "")

                        table.insert(
                            lines,
                            "========================================"
                        )

                        show_cp_result(lines, 20)

                        vim.notify("Compilation failed", vim.log.levels.ERROR)

                        return
                    end

                    -- =================================
                    -- Compilation successful
                    -- =================================

                    vim.notify(
                        "Compilation successful. Running "
                            .. #test_cases
                            .. " tests...",
                        vim.log.levels.INFO
                    )

                    -- =================================
                    -- NOW run all tests
                    -- =================================

                    run_next_test()
                end)
            end,
        })

        if compile_job <= 0 then
            vim.notify("Failed to start compiler", vim.log.levels.ERROR)

            return
        end
    else
        -- ====================================================
        -- Interpreted languages
        --
        -- No compilation step.
        -- ====================================================

        run_next_test()
    end
end, {
    desc = "Compile once and run all CP tests",
})

-- ============================================================
-- <leader>ia
--
-- QUICK CP TEST SUMMARY
--
-- Improvements:
--
-- 1. C / C++ / Rust / Go are compiled ONCE.
-- 2. Executable is reused for every test.
-- 3. No "sh -c" wrapper for program execution.
-- 4. Input is sent directly through stdin.
-- 5. Output is captured directly from stdout.
-- 6. Each test has its own 4 second timeout.
-- 7. Tests continue even when one fails.
-- 8. Execution time is measured using vim.uv.hrtime().
-- ============================================================

map("n", "<leader>ia", function()
    local file = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local ft = vim.bo.filetype

    if file == "" then
        vim.notify("Please save the file first", vim.log.levels.WARN)
        return
    end

    vim.cmd("write")

    -- ========================================================
    -- Find tests
    -- ========================================================

    local test_cases, error_message = find_cp_tests(dir)

    if not test_cases then
        vim.notify(error_message, vim.log.levels.WARN)
        return
    end

    if #test_cases == 0 then
        vim.notify(
            "No test cases found. Press <leader>ic first.",
            vim.log.levels.WARN
        )
        return
    end

    -- ========================================================
    -- Close previous result window
    -- ========================================================

    close_cp_result_window()

    -- ========================================================
    -- Results
    -- ========================================================

    local results = {}

    local current_test = 1

    -- ========================================================
    -- Temporary executable
    -- ========================================================

    local executable = vim.fn.tempname()

    -- ========================================================
    -- Compiled languages
    -- ========================================================

    local compiled_language = ft == "cpp"
        or ft == "c"
        or ft == "rust"
        or ft == "go"

    -- ========================================================
    -- Build command
    -- ========================================================

    local function get_compile_command()
        if ft == "cpp" then
            return "g++-16 "
                .. vim.fn.shellescape(file)
                .. " -o "
                .. vim.fn.shellescape(executable)
        elseif ft == "c" then
            return "gcc "
                .. vim.fn.shellescape(file)
                .. " -o "
                .. vim.fn.shellescape(executable)
        elseif ft == "rust" then
            return "rustc "
                .. vim.fn.shellescape(file)
                .. " -o "
                .. vim.fn.shellescape(executable)
        elseif ft == "go" then
            return "go build -o "
                .. vim.fn.shellescape(executable)
                .. " "
                .. vim.fn.shellescape(file)
        end

        return nil
    end

    -- ========================================================
    -- Get program command
    --
    -- IMPORTANT:
    -- These are direct executable commands.
    -- There is NO sh -c here.
    -- ========================================================

    local function get_program_command()
        if compiled_language then
            return {
                executable,
            }
        elseif ft == "python" then
            return {
                "python3",
                file,
            }
        elseif ft == "javascript" then
            return {
                "node",
                file,
            }
        elseif ft == "typescript" then
            return {
                "bun",
                "run",
                file,
            }
        elseif ft == "java" then
            return {
                "java",
                file,
            }
        end

        return nil
    end

    -- ========================================================
    -- Supported languages
    -- ========================================================

    local supported = ft == "cpp"
        or ft == "c"
        or ft == "rust"
        or ft == "go"
        or ft == "python"
        or ft == "javascript"
        or ft == "typescript"
        or ft == "java"

    if not supported then
        vim.notify("Unsupported filetype: " .. ft, vim.log.levels.WARN)

        return
    end

    -- ========================================================
    -- Run next test
    -- ========================================================

    local function run_next()
        -- ====================================================
        -- ALL TESTS COMPLETE
        -- ====================================================

        if current_test > #test_cases then
            local passed = 0
            local failed = 0

            local total_time = 0
            local max_time = 0

            -- =================================================
            -- Statistics
            -- =================================================

            for _, result in ipairs(results) do
                if result.passed then
                    passed = passed + 1
                else
                    failed = failed + 1
                end

                total_time = total_time + result.time

                max_time = math.max(max_time, result.time)
            end

            -- =================================================
            -- Summary
            -- =================================================

            local lines = {
                "========================================",
                "CP TEST SUMMARY",
                "========================================",
                "",
            }

            -- =================================================
            -- Individual results
            -- =================================================

            for _, result in ipairs(results) do
                local symbol = result.passed and "✓" or "✗"

                local status = ""

                if result.timeout then
                    status = "  TIMEOUT"
                elseif result.error and #result.error > 0 then
                    status = "  ERROR"
                end

                table.insert(
                    lines,
                    string.format(
                        "%s %-10s %8d ms%s",
                        symbol,
                        result.name,
                        result.time,
                        status
                    )
                )
            end

            -- =================================================
            -- Statistics
            -- =================================================

            table.insert(lines, "")

            table.insert(lines, "========================================")

            table.insert(
                lines,
                string.format("Passed:     %d/%d", passed, #results)
            )

            table.insert(
                lines,
                string.format("Failed:     %d/%d", failed, #results)
            )

            table.insert(lines, string.format("Total time: %d ms", total_time))

            table.insert(lines, string.format("Max test:   %d ms", max_time))

            table.insert(lines, "========================================")

            -- =================================================
            -- Show result buffer
            -- =================================================

            show_cp_result(lines, 12)

            -- =================================================
            -- Notification
            -- =================================================

            if failed == 0 then
                vim.notify(
                    string.format(
                        "✓ All %d tests passed | %d ms",
                        #results,
                        total_time
                    ),
                    vim.log.levels.INFO
                )
            else
                vim.notify(
                    string.format(
                        "%d/%d passed | %d failed | %d ms",
                        passed,
                        #results,
                        failed,
                        total_time
                    ),
                    vim.log.levels.ERROR
                )
            end

            -- =================================================
            -- Cleanup
            -- =================================================

            if compiled_language then
                vim.fn.delete(executable)
            end

            return
        end

        -- ====================================================
        -- Current test
        -- ====================================================

        local test = test_cases[current_test]

        local test_name = "Test " .. (test.index + 1)

        -- ====================================================
        -- Read input
        -- ====================================================

        local input_lines = read_file(test.input)

        local input_data = table.concat(input_lines, "\n")

        -- Make sure stdin ends with newline
        if input_data ~= "" then
            input_data = input_data .. "\n"
        end

        -- ====================================================
        -- Expected output
        -- ====================================================

        local expected = normalize_output(read_file(test.expected))

        -- ====================================================
        -- Program command
        -- ====================================================

        local command = get_program_command()

        if not command then
            vim.notify("Unsupported filetype: " .. ft, vim.log.levels.WARN)

            return
        end

        -- ====================================================
        -- Captured stdout/stderr
        -- ====================================================

        local stdout = {}
        local stderr = {}

        local finished = false
        local job_id = nil

        -- ====================================================
        -- Start timing
        --
        -- This starts immediately before the actual program
        -- process is launched.
        -- ====================================================

        local start_time = vim.uv.hrtime()

        -- ====================================================
        -- Timeout timer
        -- ====================================================

        local timer = vim.uv.new_timer()

        if not timer then
            vim.notify("Failed to create timeout timer", vim.log.levels.ERROR)

            return
        end

        -- ====================================================
        -- 4 SECOND TIMEOUT
        -- ====================================================

        timer:start(
            CP_TIMEOUT * 1000,
            0,

            vim.schedule_wrap(function()
                if finished then
                    return
                end

                finished = true

                timer:stop()
                timer:close()

                -- ----------------------------------------------
                -- Stop program
                -- ----------------------------------------------

                if job_id then
                    vim.fn.jobstop(job_id)
                end

                -- ----------------------------------------------
                -- Record timeout
                -- ----------------------------------------------

                table.insert(results, {
                    name = test_name,

                    passed = false,

                    expected = expected,

                    actual = {},

                    error = {
                        "TIME LIMIT EXCEEDED",
                    },

                    time = CP_TIMEOUT * 1000,

                    timeout = true,
                })

                -- ----------------------------------------------
                -- Continue
                -- ----------------------------------------------

                current_test = current_test + 1

                run_next()
            end)
        )

        -- ====================================================
        -- Start program DIRECTLY
        --
        -- No shell.
        -- ====================================================

        job_id = vim.fn.jobstart(command, {
            stdin = "pipe",

            stdout_buffered = false,
            stderr_buffered = false,

            -- ========================================
            -- STDOUT
            -- ========================================

            on_stdout = function(_, data)
                if not data then
                    return
                end

                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(stdout, line)
                    end
                end
            end,

            -- ========================================
            -- STDERR
            -- ========================================

            on_stderr = function(_, data)
                if not data then
                    return
                end

                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(stderr, line)
                    end
                end
            end,

            -- ========================================
            -- PROCESS EXIT
            -- ========================================

            on_exit = function(_, exit_code)
                vim.schedule(function()
                    -- =================================
                    -- Timeout already handled
                    -- =================================

                    if finished then
                        return
                    end

                    finished = true

                    timer:stop()
                    timer:close()

                    -- =================================
                    -- Execution time
                    -- =================================

                    local elapsed = (vim.uv.hrtime() - start_time) / 1000000

                    local elapsed_ms = math.floor(elapsed + 0.5)

                    -- =================================
                    -- Actual output
                    -- =================================

                    local actual = normalize_output(stdout)

                    -- =================================
                    -- Runtime error
                    -- =================================

                    if exit_code ~= 0 then
                        table.insert(results, {
                            name = test_name,

                            passed = false,

                            expected = expected,

                            actual = actual,

                            error = stderr,

                            time = elapsed_ms,
                        })
                    else
                        -- =============================
                        -- Compare output
                        -- =============================

                        local passed = true

                        if #expected ~= #actual then
                            passed = false
                        else
                            for i = 1, #expected do
                                if expected[i] ~= actual[i] then
                                    passed = false
                                    break
                                end
                            end
                        end

                        table.insert(results, {
                            name = test_name,

                            passed = passed,

                            expected = expected,

                            actual = actual,

                            error = {},

                            time = elapsed_ms,
                        })
                    end

                    -- =================================
                    -- Continue
                    -- =================================

                    current_test = current_test + 1

                    run_next()
                end)
            end,
        })

        -- ====================================================
        -- Check job creation
        -- ====================================================

        if job_id <= 0 then
            timer:stop()
            timer:close()

            vim.notify("Failed to start program", vim.log.levels.ERROR)

            return
        end

        -- ====================================================
        -- Send input directly to stdin
        -- ====================================================

        if input_data ~= "" then
            vim.fn.chansend(job_id, input_data)
        end

        -- ====================================================
        -- Close stdin
        --
        -- This is VERY important for programs that read until
        -- EOF.
        -- ====================================================

        vim.fn.chanclose(job_id, "stdin")
    end

    -- ========================================================
    -- COMPILE / BUILD ONCE
    -- ========================================================

    if compiled_language then
        local compile_command = get_compile_command()

        local compile_stderr = {}

        vim.notify(
            "Building " .. vim.fn.fnamemodify(file, ":t") .. "...",
            vim.log.levels.INFO
        )

        -- ====================================================
        -- Compile
        -- ====================================================

        local compile_job = vim.fn.jobstart({
            "sh",
            "-c",
            compile_command,
        }, {
            stdout_buffered = true,
            stderr_buffered = true,

            -- ========================================
            -- Compiler stderr
            -- ========================================

            on_stderr = function(_, data)
                if data then
                    for _, line in ipairs(data) do
                        if line ~= "" then
                            table.insert(compile_stderr, line)
                        end
                    end
                end
            end,

            -- ========================================
            -- Compilation finished
            -- ========================================

            on_exit = function(_, exit_code)
                vim.schedule(function()
                    -- =================================
                    -- Compilation failed
                    -- =================================

                    if exit_code ~= 0 then
                        local lines = {
                            "========================================",
                            "COMPILATION / BUILD FAILED",
                            "========================================",
                            "",
                            "File: " .. vim.fn.fnamemodify(file, ":t"),
                            "",
                        }

                        if #compile_stderr > 0 then
                            vim.list_extend(lines, compile_stderr)
                        else
                            table.insert(
                                lines,
                                "Compiler exited with code " .. exit_code
                            )
                        end

                        table.insert(lines, "")

                        table.insert(
                            lines,
                            "========================================"
                        )

                        show_cp_result(lines, 15)

                        vim.notify("Compilation failed", vim.log.levels.ERROR)

                        vim.fn.delete(executable)

                        return
                    end

                    -- =================================
                    -- Build successful
                    -- =================================

                    vim.notify(
                        "Build successful. Running "
                            .. #test_cases
                            .. " tests...",
                        vim.log.levels.INFO
                    )

                    -- =================================
                    -- Start tests
                    -- =================================

                    run_next()
                end)
            end,
        })

        if compile_job <= 0 then
            vim.notify("Failed to start compiler", vim.log.levels.ERROR)

            vim.fn.delete(executable)

            return
        end
    else
        -- ====================================================
        -- Interpreted languages
        -- ====================================================

        run_next()
    end
end, {
    desc = "Quick CP test summary",
})
