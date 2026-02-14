return {
    "rose-pine/neovim",
    lazy = false,
    name = "rose-pine",
    opts = {
        highlight_groups = {
            EndOfBuffer = { fg = "base" },
            -- Visual = { fg = "base", bg = "#c4a7e7", inherit = false },
            -- VisualNOS = { fg = "base", bg = "rose", inherit = false },
        },

        styles = {
            bold = true,
            italic = false,
            transparency = true,
        },
        palette = {
            -- Override the builtin palette per variant
            moon = {
                -- base = "#1c1f20",
                base = "#030A15",
                -- overlay = "#363738",
            },
        },
    },
}
