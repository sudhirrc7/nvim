return {
    "projekt0n/github-nvim-theme",
    enabled = false,
    name = "github-theme",
    config = function()
        require("github-theme").setup({
            options = {
                styles = { -- Style to be applied to different syntax groups
                    comments = "Italic", -- Value is any valid attr-list value `:help attr-list`
                    functions = "Italic",
                    keywords = "Italic",
                    variables = "NONE",
                    conditionals = "NONE",
                    constants = "NONE",
                    numbers = "NONE",
                    operators = "NONE",
                    strings = "NONE",
                    types = "NONE",
                },
            },
        })
    end,
}
