return {
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        enabled = true,

        opts = {
            options = {
                -- Your bufferline options
            },
        },

        config = function(_, opts)
            require("bufferline").setup(opts)

            -- Hide Bufferline by default
            vim.opt.showtabline = 0
        end,

        keys = {
            {
                "<leader>uA",
                function()
                    Snacks.toggle
                        .option("showtabline", {
                            off = 0,
                            on = 2,
                            name = "Bufferline",
                        })
                        :toggle()
                end,
                desc = "Toggle Bufferline",
            },
        },
    },
}
