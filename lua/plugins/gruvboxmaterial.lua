return {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
        -- Optionally configure and load the colorscheme
        -- directly inside the plugin declaration.
        vim.g.gruvbox_material_enable_italic = false
        vim.g.gruvbox_material_transparent_background = 2
        vim.g.gruvbox_material_float_style = "blend"
        vim.g.gruvbox_material_disable_italic_comment = 1
        vim.g.gruvbox_material_ui_contrast = "high"
        vim.g.gruvbox_material_current_word = "high contrast background"
        -- local function set_transparent_bg(group)
        --     local ok, hl =
        --         pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        --     if not ok then
        --         return
        --     end
        --     hl.bg = "none"
        --     hl.ctermbg = "none"
        --     vim.api.nvim_set_hl(0, group, hl)
        -- end
        --
        -- set_transparent_bg("FloatBorder")
        -- set_transparent_bg("NormalFloat")
    end,
}
