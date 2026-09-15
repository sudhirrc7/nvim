return {
    "Aejkatappaja/cendre",
    enabled = true,
    lazy = false,
    priority = 1000,
    config = function()
        require("cendre").setup({
            transparent = true,
            background = "hard", -- "hard" | "medium" | "soft"
            italic_virtual_text = false,
            italic_comments = false,
        })
    end,
}
