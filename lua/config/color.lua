-- Color helpers shared by termsync, transparency and lualine.
local M = {}

function M.is_hex(color)
    return type(color) == "string" and color:match("^#%x%x%x%x%x%x$") ~= nil
end

-- "#rrggbb" from a 0xRRGGBB number, a hex string or a color name
function M.hex(v)
    if type(v) == "number" then
        return string.format("#%06x", v)
    end
    if type(v) == "string" then
        if M.is_hex(v) then
            return v:lower()
        end
        local n = vim.api.nvim_get_color_by_name(v)
        return n ~= -1 and M.hex(n) or nil
    end
end

-- mixes hex color `top` over `bottom`, `alpha` from 0 to 1
-- (returns `top` untouched when either isn't a hex color)
function M.blend(top, bottom, alpha)
    if not (M.is_hex(top) and M.is_hex(bottom)) then
        return top
    end
    local function channel(i)
        local a = tonumber(top:sub(i, i + 1), 16)
        local b = tonumber(bottom:sub(i, i + 1), 16)
        return math.floor(a * alpha + b * (1 - alpha) + 0.5)
    end
    return ("#%02x%02x%02x"):format(channel(2), channel(4), channel(6))
end

-- WCAG contrast ratio between two 0xRRGGBB colors (1 = identical, 21 = black/white)
function M.contrast(a, b)
    local function luminance(c)
        local function channel(v)
            v = v / 255
            return v <= 0.03928 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
        end
        local r = channel(math.floor(c / 0x10000) % 0x100)
        local g = channel(math.floor(c / 0x100) % 0x100)
        local bl = channel(c % 0x100)
        return 0.2126 * r + 0.7152 * g + 0.0722 * bl
    end
    local la, lb = luminance(a), luminance(b)
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05)
end

return M
