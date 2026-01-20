-- lua/plugins/gruvbox.lua
return {
    "https://gitlab.com/motaz-shokry/gruvbox.nvim",
    enabled = false,
    name = "gruvbox",
    priority = 1000,
    config = function()
        vim.cmd("colorscheme gruvbox")
    end,
}
