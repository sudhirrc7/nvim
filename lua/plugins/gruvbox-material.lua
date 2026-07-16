return {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
        -- Optionally configure and load the colorscheme
        -- directly inside the plugin declaration.
        vim.g.gruvbox_material_transparent_background = 2
        vim.g.gruvbox_material_enable_italic = true
        vim.g.gruvbox_material_float_style = "blend"
        vim.g.gruvbox_material_ui_contrast = "high"
        vim.g.gruvbox_material_menu_selection_background = "aqua"
        vim.g.gruvbox_material_visual = "reverse"
        -- vim.g.gruvbox_material_sign_column_background = "grey"
        vim.g.gruvbox_material_spell_foreground = "colored"
        -- vim.g.gruvbox_material_diagnostic_text_highlight = 1
        vim.g.gruvbox_material_diagnostic_line_highlight = 1
        vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
        vim.g.gruvbox_material_better_performance = 1
    end,
}
