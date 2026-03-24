return {
    "ankushbhagats/pastel.nvim",
    lazy = false,
    priority = 1000, -- load earlier
    config = function()
        require("pastel").setup({
            style = {
                transparent = false,
                inactive = true,
                float = false,
                border = true,
                bold = true,
                italic = true,
                underline = true,
                invert_title = false,
                simple_syntax = false,
                dynamic_statusline = false,
            },
        })
    end,
}
