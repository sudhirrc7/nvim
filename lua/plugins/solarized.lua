return {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    enabled = true,
    priority = 1000,
    opts = {
        on_highlights = function(highlights, colors)
            highlights.WinSeparator = {
                fg = colors.blue,
            }
        end,
        transparent = false, -- Enable this to disable setting the background color
        styles = {
            sidebars = "transparent", -- Makes sidebars like NvimTree, neo-tree transparent
            floats = "transparent", -- Optional: Makes floating windows transparent
        },
    },
}
