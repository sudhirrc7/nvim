-- Cursor shapes cycled with <leader>tB and remembered across sessions.
-- Applied at startup from config/options.lua.
--
-- The hor/ver size only applies in GUIs like Neovide; terminals draw the
-- underline at their own thickness (kitty: cursor_underline_thickness,
-- ghostty: adjust-cursor-thickness, alacritty: cursor.thickness).
local util = require("config.util")

local styles = util.styles("cursor_style", {
    {
        name = "Default",
        icon = "\u{f246}",
        guicursor = vim.api.nvim_get_option_info2("guicursor", {}).default,
    },
    { name = "Block", icon = "\u{2588}", guicursor = "a:block" },
    -- underline while typing, block everywhere else
    {
        name = "Underline",
        icon = "\u{2581}",
        guicursor = "a:block,i-ci:hor30",
    },
})

function styles.apply()
    vim.go.guicursor = styles.current().guicursor
end

function styles.cycle()
    local style = styles.next()
    styles.apply()
    Snacks.notify(
        ("%s  %s  (%d/%d)"):format(
            style.icon,
            style.name,
            styles.index,
            #styles.list
        ),
        { title = "Cursor style" }
    )
end

return styles
