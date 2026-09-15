return {
    "rebelot/kanagawa.nvim",
    enabled = true,

    opts = {
        background = {
            dark = "dragon",
            light = "lotus",
        },

        commentStyle = { italic = false, bold = false },
        functionStyle = { italic = false, bold = false },
        keywordStyle = { italic = false, bold = false },
        statementStyle = { bold = false, italic = false },
        typeStyle = { italic = false, bold = false },

        transparent = true,

        overrides = function(colors)
            local theme = colors.theme

            return {
                -- Window separators - Kanagawa only
                WinSeparator = {
                    fg = theme.ui.fg_dim,
                    bg = "none",
                },

                NormalFloat = { bg = "none" },
                FloatBorder = { bg = "none" },
                FloatTitle = { bg = "none" },

                NormalDark = {
                    fg = theme.ui.fg_dim,
                    bg = theme.ui.bg_m3,
                },

                LazyNormal = {
                    bg = theme.ui.bg_m3,
                    fg = theme.ui.fg_dim,
                },

                MasonNormal = {
                    bg = theme.ui.bg_m3,
                    fg = theme.ui.fg_dim,
                },

                Pmenu = {
                    fg = theme.ui.shade0,
                    bg = theme.ui.bg_p1,
                },

                PmenuSel = {
                    fg = "NONE",
                    bg = theme.ui.bg_p2,
                },

                PmenuSbar = {
                    bg = theme.ui.bg_m1,
                },

                PmenuThumb = {
                    bg = theme.ui.bg_p2,
                },
            }
        end,

        colors = {
            palette = {
                -- sumiInk0 = "#000000",
                -- fujiWhite = "#FFFFFF",
            },

            theme = {
                all = {
                    ui = {
                        bg_gutter = "none",
                    },
                },

                dragon = {
                    ui = {
                        float = {
                            bg = "none",
                        },
                    },
                },
            },
        },
    },
}
