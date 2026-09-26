return {
    "nmac427/guess-indent.nvim",
    lazy = false,
    config = function()
        require("guess-indent").setup({
            -- auto_cmd = true,
        })
    end,
    keys = {
        { "<leader>ig", "<cmd>GuessIndent<cr>", { desc = "GuessBufferIndent" } },
    },
}
