return {
    "haringsrob/nvim_context_vt",
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {
        -- Off by default; <leader>uj loads the plugin and turns it on
        enabled = false,
        prefix = " 󱞷",
        highlight = "NonText",
        min_rows = 7,
        disable_ft = { "markdown", "css" },
        -- Disable display of virtual text below blocks for indentation based
        -- languages like Python
        disable_virtual_lines_ft = { "yaml" },
    },
    keys = {
        {
            "<leader>uj",
            "<cmd>NvimContextVtToggle<CR>",
            desc = "Toggle Context",
        },
    },
}
