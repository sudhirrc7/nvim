return {
    "kyazdani42/nvim-tree.lua",
    enabled = false,
    dependencies = {
        "kyazdani42/nvim-web-devicons",
    },
    lazy = false,
    keys = {
        {
            "<C-n>",
            "<cmd>NvimTreeToggle<cr>",
            desc = "Find file in filetree",
        },
    },
    opts = {
        filters = {
            custom = { ".git", "node_modules", ".vscode" },
            dotfiles = true,
        },
        git = {},
        view = {
            adaptive_size = true,
            float = {
                enable = true,
            },
        },
    },
}
