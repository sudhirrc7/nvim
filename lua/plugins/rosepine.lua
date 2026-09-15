return {
    "rose-pine/neovim",
    enabled = true,
    lazy = false,
    priority = 1000,
    name = "rose-pine",

    opts = {
        dim_inactive_windows = true,
        extend_background_behind_borders = false,

        highlight_groups = {
            Visual = { fg = "base", bg = "#c4a7e7", inherit = false },
            StatusLine = { fg = "none", bg = "none" },
            NormalFloat = { bg = "none" },
        },

        styles = {
            bold = true,
            italic = false,
            transparency = false,
        },

        palette = {
            main = {
                pine = "#3e8fb0",
            },

            moon = {
                base = "#141415",
            },
        },
    },

    keys = {
        {
            "<leader>iz",
            function()
                local rose_pine = require("rose-pine")

                local base_colors = {
                    "#141415",
                    "#1A1A1A",
                    "#181616",
                    "#000000",
                    "#232136",
                    "#030200",
                }

                vim.g.rose_pine_base_index = (vim.g.rose_pine_base_index or 1)
                        % #base_colors
                    + 1

                local base = base_colors[vim.g.rose_pine_base_index]

                rose_pine.setup({
                    palette = {
                        moon = {
                            base = base,
                        },
                    },
                })

                vim.cmd.colorscheme("rose-pine-moon")

                vim.notify("Rose Pine base: " .. base)
            end,
            desc = "Rose Pine: Cycle base color",
        },
    },
}
