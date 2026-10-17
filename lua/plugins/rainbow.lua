return {
    "HiPhish/rainbow-delimiters.nvim",
    event = "LazyFile",
    enabled = false,
    config = function()
        require("rainbow-delimiters.setup").setup()
    end,
}
