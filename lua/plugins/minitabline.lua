return {
    {
        "nvim-mini/mini.tabline",
        enabled = false,
        version = false,
        config = function()
            require("mini.tabline").setup({
                show_icons = true,
                format = nil,
                set_vim_settings = true,
                tabpage_section = "right",
            })
        end,
    },
}
