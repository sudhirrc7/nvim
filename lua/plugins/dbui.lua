return {
    "kristijanhusak/vim-dadbod-ui",
    cmd = {
        "DBUI",
        "DBUIToggle",
        "DBUIAddConnection",
        "DBUIFindBuffer",
    },
    init = function()
        vim.g.db_ui_use_nerd_fonts = 1

        -- Disable default SQL omnicompletion keybindings
        vim.g.omni_sql_no_default_maps = 1
    end,
}
