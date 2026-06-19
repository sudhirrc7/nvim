return {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    enabled = true,
    priority = 1000,
    opts = {
        transparent = true, -- Enable this to disable setting the background color
        styles = {
            sidebars = "transparent", -- Makes sidebars like NvimTree, neo-tree transparent
            floats = "transparent", -- Optional: Makes floating windows transparent
        },
    },
}
