return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        no_italic = false,
        term_colors = true,
        transparent_background = true,
        styles = {
            comments = { "italic" },
            conditionals = {},
            loops = {},
            functions = {},
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
        },
        color_overrides = {
            mocha = {
                -- base = "#000000",
                -- mantle = "#000000",
                -- crust = "#000000",
            },
        },
        float = {
            transparent = false, -- enables transparency on floating windows
            solid = true, -- use nvchad styling for floating windows
        },
        integrations = {
            telescope = {
                enabled = true,
            },
            dropbar = {
                enabled = true,
                color_mode = true,
            },
        },
    },
}
