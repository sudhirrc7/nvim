return {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,

    opts = {
        transparent_mode = true,
        invert_selection = true,
        strikethough = true,
        dim_inactive = false,

        italic = {
            strings = false,
            emphasis = false,
            comments = false,
            operators = true,
            folds = false,
        },

        overrides = {
            CursorLineNr = {
                bg = "NONE",
            },
        },
    },

    config = function(_, opts)
        require("gruvbox").setup(opts)
    end,
}
