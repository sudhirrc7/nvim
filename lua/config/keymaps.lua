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
vim.keymap.set("n", "<leader>ie", function()
    fyler.open({ kind = "split_left_most" })
end, { desc = "Fyler.nvim - Open" })

vim.keymap.set("n", "<leader>if", function()
    fyler.open()
end, { desc = "Fyler.nvim - Open" })

vim.keymap.set("n", "<leader>iE", function()
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
vim.keymap.set("n", "[<CR>", function()
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
vim.keymap.set("n", "]<CR>", function()
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
vim.keymap.set("n", "<leader>sk", function()
    Snacks.picker.keymaps({ layout = "select" })
end, { desc = "show keymaps" })

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
vim.keymap.set("n", "<leader>tc", function()
    vim.g.blink_auto_show = not vim.g.blink_auto_show

    -- Hide any currently visible completion menu
    require("blink.cmp").hide()

    vim.notify(
        "Blink auto completion "
            .. (vim.g.blink_auto_show and "Enabled" or "Disabled")
    )
end, { desc = "Toggle Blink auto completion" })

vim.keymap.set({ "n", "i" }, "<C-q>", function()
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

vim.keymap.set("n", "<leader>iq", function()
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

-- vim.keymap.set("n", "<leader>ir", function()
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

local run_error_win = nil
local run_error_buf = nil

vim.keymap.set("n", "<leader>ir", function()
    local file = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local ft = vim.bo.filetype

    if file == "" then
        vim.notify("Please save the file first", vim.log.levels.WARN)
        return
    end

    local input_file = dir .. "/input.txt"
    local output_file = dir .. "/output.txt"

    -- Create input.txt if it doesn't exist
    if vim.fn.filereadable(input_file) == 0 then
        vim.fn.writefile({}, input_file)
    end

    -- Save current file
    vim.cmd("write")

    local redirect = " < "
        .. vim.fn.shellescape(input_file)
        .. " > "
        .. vim.fn.shellescape(output_file)

    local cmd

    if ft == "cpp" then
        cmd = "g++-16 "
            .. vim.fn.shellescape(file)
            .. " -o /tmp/nvim_run && /tmp/nvim_run"
            .. redirect
    elseif ft == "c" then
        cmd = "gcc "
            .. vim.fn.shellescape(file)
            .. " -o /tmp/nvim_run && /tmp/nvim_run"
            .. redirect
    elseif ft == "python" then
        cmd = "python3 " .. vim.fn.shellescape(file) .. redirect
    elseif ft == "javascript" then
        cmd = "node " .. vim.fn.shellescape(file) .. redirect
    elseif ft == "go" then
        cmd = "go run " .. vim.fn.shellescape(file) .. redirect
    elseif ft == "rust" then
        cmd = "rustc "
            .. vim.fn.shellescape(file)
            .. " -o /tmp/nvim_run && /tmp/nvim_run"
            .. redirect
    elseif ft == "typescript" then
        cmd = "bun run " .. vim.fn.shellescape(file) .. redirect
    elseif ft == "java" then
        cmd = "java " .. vim.fn.shellescape(file) .. redirect
    else
        vim.notify("Unsupported filetype: " .. ft, vim.log.levels.WARN)
        return
    end

    local stderr = {}

    -- Run the command once
    vim.fn.jobstart({ "sh", "-c", cmd }, {
        stdout_buffered = true,
        stderr_buffered = true,

        on_stderr = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(stderr, line)
                    end
                end
            end
        end,

        on_exit = function(_, exit_code)
            vim.schedule(function()
                -- =========================
                -- SUCCESS
                -- =========================
                if exit_code == 0 then
                    -- vim.notify("success", vim.log.levels.INFO)

                    -- Refresh output.txt if already open
                    local output_buf = vim.fn.bufnr(output_file)

                    if
                        output_buf ~= -1
                        and vim.api.nvim_buf_is_valid(output_buf)
                    then
                        vim.api.nvim_buf_call(output_buf, function()
                            vim.cmd("edit!")
                        end)
                    end

                    return
                end

                -- =========================
                -- ERROR
                -- =========================

                -- Create/reuse error buffer
                if
                    not run_error_buf
                    or not vim.api.nvim_buf_is_valid(run_error_buf)
                then
                    run_error_buf = vim.api.nvim_create_buf(false, true)

                    vim.bo[run_error_buf].bufhidden = "hide"
                    vim.bo[run_error_buf].filetype = "text"
                    vim.api.nvim_buf_set_name(run_error_buf, "Run Errors")
                end

                -- Put captured errors into buffer
                vim.bo[run_error_buf].modifiable = true

                vim.api.nvim_buf_set_lines(run_error_buf, 0, -1, false, stderr)

                vim.bo[run_error_buf].modifiable = false

                -- Reuse existing error window
                if
                    run_error_win
                    and vim.api.nvim_win_is_valid(run_error_win)
                then
                    vim.api.nvim_win_set_buf(run_error_win, run_error_buf)
                else
                    -- Open bottom split only on error
                    vim.cmd("botright new")
                    vim.cmd("resize 15")

                    run_error_win = vim.api.nvim_get_current_win()

                    vim.api.nvim_win_set_buf(run_error_win, run_error_buf)
                end
            end)
        end,
    })
end, {
    desc = "Run current file (input.txt -> output.txt)",
})

------------------- end of the new approach ----------------------------------------------------------

------------------------- this is a keymap to create out and input txt files and if they exist already then use them --------------------

vim.keymap.set("n", "<leader>ic", function()
    local dir = vim.fn.expand("%:p:h")
    if dir == "" then
        vim.notify("Please save the file first")
        return
    end

    local input_file = dir .. "/input.txt"
    local output_file = dir .. "/output.txt"

    -- Create input.txt / output.txt if they don't exist
    if vim.fn.filereadable(input_file) == 0 then
        vim.fn.writefile({}, input_file)
    end
    if vim.fn.filereadable(output_file) == 0 then
        vim.fn.writefile({}, output_file)
    end

    -- Remember the current (solution) buffer/window
    local sol_win = vim.api.nvim_get_current_win()

    -- Open a vertical split to the right for input.txt
    vim.cmd("rightbelow vsplit " .. vim.fn.fnameescape(input_file))
    local input_win = vim.api.nvim_get_current_win()

    -- Below input.txt, open output.txt (horizontal split)
    vim.cmd("belowright split " .. vim.fn.fnameescape(output_file))
    -- local output_win = vim.api.nvim_get_current_win()

    -- Make the right column roughly half the screen width
    vim.api.nvim_set_current_win(input_win)
    vim.cmd("vertical resize " .. math.floor(vim.o.columns / 2))

    -- Balance the two right windows (input/output) vertically
    vim.cmd("wincmd =")

    -- Return focus to the solution window
    vim.api.nvim_set_current_win(sol_win)
end, {
    desc = "Open CP layout: solution | input.txt / output.txt",
})
