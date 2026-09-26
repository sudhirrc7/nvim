return {
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        enabled = true,
        priority = 1000,
        config = function()
            require("tiny-inline-diagnostic").setup({
                preset = "modern",
                options = {
                    add_messages = {
                        display_count = true,
                        messages = true,
                    },
                    multilines = {
                        always_show = true,
                        enabled = true,
                        severity = { vim.diagnostic.severity.ERROR },
                    },
                },
            })
            -- vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = {
                enabled = false,
            },
            diagnostics = {
                virtual_text = false,
                signs = true,
            },
        },
    },
}

--- use this along with the autocmd for the floating diagnostics

-- return {
--     {
--         "neovim/nvim-lspconfig",
--         opts = {
--             diagnostics = {
--                 virtual_text = false,
--
--                 float = {
--                     border = "rounded",
--                     source = "if_many",
--                     header = "",
--                     prefix = "",
--                     focusable = false,
--                 },
--
--                 signs = true,
--                 underline = true,
--                 update_in_insert = false,
--                 severity_sort = true,
--             },
--         },
--     },
-- }
