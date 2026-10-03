-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
local ac = vim.api.nvim_create_autocmd
local ag = vim.api.nvim_create_augroup

-- Remember the last colorscheme, restored on startup in config/lazy.lua
ac("ColorScheme", {
    group = ag("remember_colorscheme", { clear = true }),
    callback = function(args)
        require("config.util").write_state("last_colorscheme", args.match)
    end,
})

-- No diagnostics in .env files and in node_modules (only for those buffers)
ac({ "BufNewFile", "BufRead" }, {
    group = ag("disable_diagnostics", { clear = true }),
    pattern = { ".env", "**/node_modules/**", "node_modules", "/node_modules/*" },
    callback = function(args)
        vim.diagnostic.enable(false, { bufnr = args.buf })
    end,
})

-- Disable leader and localleader for some filetypes
ac("FileType", {
    group = ag("lazyvim_unbind_leader_key", { clear = true }),
    pattern = {
        "lazy",
        "mason",
        "lspinfo",
        "toggleterm",
        "null-ls-info",
        "neo-tree-popup",
        "TelescopePrompt",
        "notify",
        "floaterm",
    },
    callback = function(event)
        for _, lhs in ipairs({ "<leader>", "<localleader>" }) do
            vim.keymap.set("n", lhs, "<nop>", { buffer = event.buf, desc = "" })
        end
    end,
})

-- Disable next line comments (ftplugins set these flags again, hence BufEnter)
ac("BufEnter", {
    group = ag("no_auto_comment", { clear = true }),
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Create a dir when saving a file if it doesnt exist
ac("BufWritePre", {
    group = ag("auto_create_dir", { clear = true }),
    callback = function(args)
        if args.match:match("^%w%w+://") then
            return
        end
        local file = vim.uv.fs_realpath(args.match) or args.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- Plain text: no spell, no wrap
ac({ "BufEnter", "BufWinEnter" }, {
    group = ag("txt_files", { clear = true }),
    pattern = "*.txt",
    callback = function()
        vim.opt_local.spell = false
        vim.opt_local.wrap = false
    end,
})
