return {
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        enabled = true,
        priority = 1000,
        opts = {
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
        },
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

