return {
    "rebelot/kanagawa.nvim",
    enabled = false,
    opts = {
        commentStyle = { italic = false, bold = false },
        functionStyle = { italic = false, bold = false },
        keywordStyle = { italic = false, bold = false },
        statementStyle = { bold = false, italic = false },
        typeStyle = { italic = false, bold = false },
        transparent = true, -- do not set background color
        overrides = function(colors)
            local theme = colors.theme
            return {
                NormalFloat = { bg = "none" },
                FloatBorder = { bg = "none" },
                FloatTitle = { bg = "none" },

                -- Save an hlgroup with dark background and dimmed foreground
                -- so that you can use it where your still want darker windows.
                -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
                NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

                -- Popular plugins that open floats will link to NormalFloat by default;
                -- set their background accordingly if you wish to keep them dark and borderless
                LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
                MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },

                Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
                PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
                PmenuSbar = { bg = theme.ui.bg_m1 },
                PmenuThumb = { bg = theme.ui.bg_p2 },
            }
        end,
        colors = {
            palette = {
                -- change all usages of these colors
                -- sumiInk0 = "#000000",
                -- fujiWhite = "#FFFFFF",
            },
            theme = {
                -- change specific usages for a certain theme, or for all of them
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
