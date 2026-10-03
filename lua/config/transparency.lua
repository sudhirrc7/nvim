-- Theme-independent transparency.
-- When enabled, the background of the groups below is cleared every time a
-- colorscheme loads, so it works the same for every theme. Disabling just
-- reloads the current colorscheme. The state is remembered across sessions.
-- Toggled with <leader>t1 (see config/keymaps.lua).
local color = require("config.color")
local util = require("config.util")

local M = {}

local groups = {
    -- editor
    "Normal",
    "NormalNC",
    "NormalSB",
    "SignColumn",
    "LineNr",
    "CursorLineNr",
    "FoldColumn",
    "EndOfBuffer",
    "MsgArea",
    "WinSeparator",
    "VertSplit",
    "WinBar",
    "WinBarNC",
    "TabLine",
    "TabLineFill",
    -- floats
    "NormalFloat",
    "FloatBorder",
    "FloatTitle",
    "FloatFooter",
    -- signs
    "GitSignsAdd",
    "GitSignsChange",
    "GitSignsDelete",
    "DiagnosticSignError",
    "DiagnosticSignWarn",
    "DiagnosticSignInfo",
    "DiagnosticSignHint",
    -- plugins
    "SnacksNormal",
    "SnacksNormalNC",
    "SnacksDashboardNormal",
    "SnacksPickerBorder",
    "LazyNormal",
    "MasonNormal",
    "WhichKeyNormal",
    "WhichKeyBorder",
    "TroubleNormal",
    "TroubleNormalNC",
    "OilNormal",
}

M.enabled = util.read_state("transparent") == "1"

function M.apply()
    if not M.enabled then
        return
    end
    -- the theme's own background, read before Normal gets cleared
    local editor_bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
        or (vim.o.background == "light" and 0xffffff or 0x000000)
    for _, name in ipairs(groups) do
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        -- keep "badge" groups (dark text on a colored block, e.g. catppuccin's
        -- FloatTitle) opaque, their text would vanish on the editor background
        local badge = hl.fg and hl.bg and color.contrast(hl.fg, editor_bg) < 1.5
        if not vim.tbl_isempty(hl) and not badge then
            hl.bg = nil
            hl.ctermbg = nil
            vim.api.nvim_set_hl(0, name, hl)
        end
    end
end

function M.set(enabled)
    M.enabled = enabled
    util.write_state("transparent", enabled and "1" or "0")
    if vim.g.colors_name then
        -- reloading fires ColorScheme, which re-applies (or skips) the clearing
        vim.cmd.colorscheme(vim.g.colors_name)
    end
end

function M.toggle()
    M.set(not M.enabled)
end

-- registered before the startup colorscheme loads, so it applies there too
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("transparency", { clear = true }),
    callback = M.apply,
})

return M
