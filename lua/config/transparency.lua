-- Theme-independent transparency.
-- When enabled, the background of the groups below is cleared every time a
-- colorscheme loads, so it works the same for every theme. Disabling just
-- reloads the current colorscheme. The state is remembered across sessions.
-- Toggled with <leader>t1 (see config/keymaps.lua).
local M = {}

local state_file = vim.fn.stdpath("state") .. "/transparent"

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

local function read_state()
    local f = io.open(state_file, "r")
    if not f then
        return false
    end
    local enabled = vim.trim(f:read("*a") or "") == "1"
    f:close()
    return enabled
end

M.enabled = read_state()

-- WCAG contrast ratio between two 0xRRGGBB colors (1 = identical, 21 = black/white)
local function contrast(a, b)
    local function luminance(c)
        local function channel(v)
            v = v / 255
            return v <= 0.03928 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
        end
        local r = channel(math.floor(c / 0x10000) % 0x100)
        local g = channel(math.floor(c / 0x100) % 0x100)
        local b = channel(c % 0x100)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    end
    local la, lb = luminance(a), luminance(b)
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05)
end

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
        local badge = hl.fg and hl.bg and contrast(hl.fg, editor_bg) < 1.5
        if not vim.tbl_isempty(hl) and not badge then
            hl.bg = nil
            hl.ctermbg = nil
            vim.api.nvim_set_hl(0, name, hl)
        end
    end
end

function M.set(enabled)
    M.enabled = enabled
    local f = io.open(state_file, "w")
    if f then
        f:write(enabled and "1" or "0")
        f:close()
    end
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
