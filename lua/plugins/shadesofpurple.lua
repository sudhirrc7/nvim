return {
    "necrogoru/shades-of-purple.nvim",
    lazy = false,
    enabled = false,
    priority = 1000,
    config = function()
        require("shades-of-purple").setup()
    end,
}
