return {
    "loctvl842/monokai-pro.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
        require("monokai-pro").setup({
            transparent_background = true,
            override = function(scheme)
                return {
                    NormalFloat = { bg = "none" },
                    -- IndentBlanklineChar = { fg = scheme.base.dimmed4 },
                }
            end,
        })
        -- vim.cmd.colorscheme("monokai-pro")
    end,
}
