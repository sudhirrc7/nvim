local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
    spec = {
        {
            "LazyVim/LazyVim",
            import = "lazyvim.plugins",
            opts = {
                -- restore the colorscheme saved by the ColorScheme autocmd in config/autocmds.lua
                colorscheme = function()
                    local f = io.open(vim.fn.stdpath("state") .. "/last_colorscheme", "r")
                    local name = f and vim.trim(f:read("*a") or "") or ""
                    if f then
                        f:close()
                    end
                    if name == "" or not pcall(vim.cmd.colorscheme, name) then
                        vim.cmd.colorscheme("catppuccin-mocha")
                    end
                end,
            },
        },
        {
            import = "plugins",
        },
    },
    ui = {
        backdrop = 100,
    },
    defaults = {
        lazy = true,
        version = false, -- always use the latest git commit
        -- version = "*", -- try installing the latest stable version for plugins that support semver
    },
    local_spec = true,
    checker = { enabled = true }, -- automatically check for plugin updates
    performance = {
        cache = {
            enabled = true,
            -- disable_events = {},
        },
        rtp = {
            -- disable some rtp plugins
            disabled_plugins = {
                "netrw",
                "netrwPlugin",
                "netrwSettings",
                "netrwFileHandlers",
                "gzip",
                "zip",
                "zipPlugin",
                "tar",
                "tarPlugin",
                "tohtml",
                "tutor",
                "spec",
            },
        },
    },
})
