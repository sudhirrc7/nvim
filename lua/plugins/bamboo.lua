-- Using lazy.nvim
return {
    "ribru17/bamboo.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
        require("bamboo").setup({
            -- optional configuration herea
            transparent = true,
            lualine = {
                transparent = true, -- lualine center bar transparency
            },
            highlights = {
                -- make comments blend nicely with background, similar to other color schemes
                ["@comment"] = { fg = "$grey" },
            },
        })
        -- require("bamboo").load()
    end,
}
