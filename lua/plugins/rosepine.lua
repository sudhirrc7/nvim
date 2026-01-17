return {
    "rose-pine/neovim",
    lazy = false,
    name = "rose-pine",
    opts = {
        highlight_groups = {
            EndOfBuffer = { fg = "base" },
        },

        styles = {
            bold = true,
            italic = false,
            transparency = false,
        },
        palette = {
            -- Override the builtin palette per variant
            moon = {
                -- base = "#1c1f20",
                base = "#000000",
                -- overlay = "#363738",
            },
        },
    },
}
