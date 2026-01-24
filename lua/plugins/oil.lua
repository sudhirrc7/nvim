return {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        optional = true,
    },
    opts = {
        delete_to_trash = true,
        float = {
            max_height = 45,
            max_width = 90,
        },
        keymaps = {
            ["q"] = "actions.close",
        },
        view_options = {
            show_hidden = false,
        },
    },
  -- stylua: ignore
  keys = {
    { "-", function() require("oil").toggle_float() end, desc = "Toggle Oil" },
  },
}
