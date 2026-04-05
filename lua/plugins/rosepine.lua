return {
    "rose-pine/neovim",
    lazy = false,
    priority = 10000,
    enabled = true,
    name = "rose-pine",
    opts = {
        extend_background_behind_borders = false,
        highlight_groups = {
            EndOfBuffer = { fg = "base" },
            Visual = { fg = "base", bg = "#c4a7e7", inherit = false },

            NormalFloat = { bg = "none" },
            -- VisualNOS = { fg = "base", bg = "rose", inherit = false },
        },

        styles = {
            bold = true,
            italic = true,
            transparency = true,
        },
        palette = {
            -- Override the builtin palette per variant
            moon = {
                base = "#000000",
                -- base = "#030A15",
                -- overlay = "#000000",
            },
        },
    },
}
