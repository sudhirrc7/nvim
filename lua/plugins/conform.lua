return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- Pass configuration preferences directly to the tsgo language server
                tsgo = {
                    settings = {
                        javascript = {
                            format = {
                                indentSize = 4,
                                tabSize = 4,
                                convertTabsToSpaces = true,
                            },
                            options = { indentSize = 4, tabSize = 4 },
                        },
                        typescript = {
                            format = {
                                indentSize = 4,
                                tabSize = 4,
                                convertTabsToSpaces = true,
                            },
                            options = { indentSize = 4, tabSize = 4 },
                        },
                    },
                },
            },
        },
    },
    {
        "stevearc/conform.nvim",
        opts = function(_, opts)
            -- Inject the 4-space tab-width argument into Prettier
            opts.formatters = opts.formatters or {}
            opts.formatters.prettier = {
                prepend_args = { "--tab-width", "4" },
            }
        end,
    },
}
