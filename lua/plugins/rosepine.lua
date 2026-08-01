return {
    "rose-pine/neovim",
    enabled = true,
    lazy = false,
    priority = 1000,
    name = "rose-pine",
    opts = {
        extend_background_behind_borders = false,
        highlight_groups = {
            -- EndOfBuffer = { fg = "base" },
            Visual = { fg = "base", bg = "#c4a7e7", inherit = false },
            StatusLine = { fg = "none", bg = "none" },
            NormalFloat = { bg = "none" },
            -- VisualNOS = { fg = "base", bg = "rose", inherit = false },
        },
        groups = {
            h1 = "love",
            h2 = "iris",
            h4 = "foam",
            h3 = "pine",
            h5 = "rose",
            h6 = "gold",
        },
        styles = {
            bold = true,
            italic = false,
            transparency = false,
        },
        palette = {
            main = {
                pine = "#3e8fb0",
                -- base = "#181616",
                -- base = "#000000",
            },
            -- Override the builtin palette per variant
            moon = {
                -- base = "#191724",
                base = "#181616",
                -- base = "#000000",
                -- overlay = "#000000",
            },
        },
    },
}
