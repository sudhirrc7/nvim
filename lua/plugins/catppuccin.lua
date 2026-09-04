return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        custom_highlights = function(colors)
            return {
                WinSeparator = {
                    fg = colors.lavender,
                },
            }
        end,
        no_italic = false,
        term_colors = true,
        transparent_background = false,
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
                base = "#181825",
                -- mantle = "#000000",
                -- crust = "#000000",
            },
        },
        float = {
            transparent = true, -- enables transparency on floating windows
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
            snacks = {
                enabled = true,
                indent_scope_color = "mauve",
            },
        },
    },
}
