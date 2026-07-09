return {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = true,
    enabled = false,
    opts = {
        transparent_mode = true,
        strikethrough = false,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        contrast = "", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
    },
}
