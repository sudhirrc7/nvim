-- Buffer tabline. Tabs are the listed buffers in buffer-number order (the
-- order mini.tabline draws them). After <leader>b each tab shows its
-- position, so <leader>b1..b9 can jump to it; the next key hides it again.
-- Every tab has the same width and ends in a clickable close button (a dot
-- while the buffer is modified). Visibility (<leader>bt) is remembered.
local color = require("config.color")
local util = require("config.util")

local function listed()
    return vim.tbl_filter(function(buf)
        return vim.bo[buf].buflisted
    end, vim.api.nvim_list_bufs())
end

-- numbers are shown while a <leader>b mapping is pending. The keys are
-- watched with on_key since which-key reads them with getchar
local numbers = false
local function watch_leader_b()
    local leader = vim.keycode(vim.g.mapleader or "\\")
    local prev
    vim.on_key(function(_, typed)
        if not typed or typed == "" then
            return
        end
        local on = prev == leader
            and typed == "b"
            and vim.api.nvim_get_mode().mode:sub(1, 1) == "n"
        prev = typed
        if on ~= numbers then
            numbers = on
            vim.schedule(vim.cmd.redrawtabline)
        end
    end, vim.api.nvim_create_namespace("minitabline_numbers"))
end

local MAX_NAME = 16 -- longer names are cut with "…"
local CLOSE, MODIFIED = "󰅖", "●"

-- pads `s` with spaces, or cuts it with "…", to exactly `width` cells
local function fit(s, width)
    local w = vim.fn.strdisplaywidth(s)
    if w <= width then
        return s .. (" "):rep(width - w)
    end
    while s ~= "" and vim.fn.strdisplaywidth(s) > width - 1 do
        s = vim.fn.strcharpart(s, 0, vim.fn.strchars(s) - 1)
    end
    return fit(s .. "…", width)
end

-- " 󰢱 name 󰅖 ": every tab is as wide as the longest name needs (up to
-- MAX_NAME). While the numbers are shown they take the icon's place
local function format(buf, label)
    local bufs = listed()
    local name_width = 1
    for _, b in ipairs(bufs) do
        local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":t")
        name_width = math.max(name_width, vim.fn.strdisplaywidth(name))
    end
    local lead = numbers and tostring(vim.fn.index(bufs, buf) + 1)
        or require("mini.icons").get("file", vim.api.nvim_buf_get_name(buf))
    lead = fit(lead, #tostring(#bufs))
    local mark = vim.bo[buf].modified and MODIFIED or CLOSE
    local name = fit(label, math.min(name_width, MAX_NAME))
    return (" %s %s %s "):format(lead, name, mark)
end

-- clicked close button (`buf` is the click region's minwid)
function _G.MiniTablineCloseBuffer(buf, _, button)
    if button == "l" then
        vim.schedule(function()
            Snacks.bufdelete({ buf = buf })
        end)
    end
end

-- mini.tabline escapes "%" in labels, so the close mark gets its own click
-- region and color by rewriting the finished tabline string
local function add_close_buttons(line)
    local tab = "%%#(MiniTabline%w+)#%%(%d+)@MiniTablineSwitchBuffer@([^%%]*)"
    return (
        line:gsub(tab, function(hl, buf, label)
            local switch = "%" .. buf .. "@MiniTablineSwitchBuffer@"
            local before, mark, after =
                label:match("^(.*)(" .. CLOSE .. ")( ?)$")
            if not mark then
                before, mark, after =
                    label:match("^(.*)(" .. MODIFIED .. ")( ?)$")
            end
            if not mark then -- cut off at the screen edge
                return "%#" .. hl .. "#" .. switch .. label
            end
            -- the modified dot keeps the tab's own (warning) color
            local mark_hl = hl:find("Modified") and hl
                or hl == "MiniTablineCurrent" and "MiniTablineCloseCurrent"
                or "MiniTablineClose"
            return table.concat({
                "%#" .. hl .. "#" .. switch .. before,
                "%#" .. mark_hl .. "#",
                "%" .. buf .. "@v:lua.MiniTablineCloseBuffer@" .. mark .. "%X",
                "%#" .. hl .. "#" .. switch .. after,
            })
        end)
    )
end

local function show(visible)
    vim.o.showtabline = visible and 2 or 0
end

-- deletes the listed buffers before (dir = -1) or after (dir = 1) the current
local function delete_side(dir)
    local bufs = listed()
    local cur = vim.fn.index(bufs, vim.api.nvim_get_current_buf()) + 1
    if cur == 0 then
        return
    end
    for i, buf in ipairs(bufs) do
        if (i - cur) * dir > 0 then
            Snacks.bufdelete({ buf = buf })
        end
    end
end

-- Colors derived from the theme, re-applied on every ColorScheme: the bar
-- is the editor background shifted towards the text color (lighter on dark
-- themes, darker on light ones) so it stands apart from the buffer, the
-- current buffer is an accent-tinted pill on it, modified buffers use the
-- warning color and the tabpage counter is an accent badge.
local BAR_SHIFT = 0.08 -- how far the bar moves away from the editor bg

local function highlights()
    local c = Snacks.util.color
    local dark = vim.o.background == "dark"
    local base = c("Normal", "bg")
        or require("config.termsync").bg
        or (dark and "#11111b" or "#eff1f5")
    local text = c("Normal") or (dark and "#cdd6f4" or "#4c4f69")
    local dim = c("Comment") or color.blend(text, base, 0.5)
    local accent = c("Function") or c("Title") or text
    local warn = c("DiagnosticWarn") or accent
    local bar = color.blend(text, base, BAR_SHIFT)
    local pill = color.blend(accent, bar, 0.22)

    local groups = {
        Current = { fg = text, bg = pill, bold = true },
        Visible = { fg = text, bg = bar },
        Hidden = { fg = dim, bg = bar },
        ModifiedCurrent = { fg = warn, bg = pill, bold = true },
        ModifiedVisible = { fg = warn, bg = bar },
        ModifiedHidden = { fg = color.blend(warn, bar, 0.7), bg = bar },
        Close = { fg = dim, bg = bar },
        CloseCurrent = { fg = color.blend(text, pill, 0.6), bg = pill },
        Fill = { bg = bar },
        Trunc = { fg = dim, bg = bar },
        Tabpagesection = { fg = base, bg = accent, bold = true },
    }
    for name, hl in pairs(groups) do
        vim.api.nvim_set_hl(0, "MiniTabline" .. name, hl)
    end
end

local keys = {
    {
        "<leader>bt",
        function()
            local visible = vim.o.showtabline == 0
            show(visible)
            util.write_state("tabline", visible and "1" or "0")
        end,
        desc = "Toggle Tabline",
    },
    {
        "<leader>bl",
        function()
            delete_side(-1)
        end,
        desc = "Delete Buffers to the Left",
    },
    {
        "<leader>br",
        function()
            delete_side(1)
        end,
        desc = "Delete Buffers to the Right",
    },
}
for i = 1, 9 do
    table.insert(keys, {
        "<leader>b" .. i,
        function()
            local buf = listed()[i]
            if buf then
                vim.api.nvim_set_current_buf(buf)
            end
        end,
        desc = "Go to Buffer " .. i,
    })
end

return {
    {
        "nvim-mini/mini.tabline",
        version = false,
        event = "VeryLazy",
        keys = keys,
        opts = {
            show_icons = true,
            tabpage_section = "right",
            format = format,
        },
        config = function(_, opts)
            require("mini.tabline").setup(opts)
            local make = MiniTabline.make_tabline_string
            MiniTabline.make_tabline_string = function()
                return add_close_buttons(make())
            end
            highlights()
            watch_leader_b()
            vim.api.nvim_create_autocmd("ColorScheme", {
                group = vim.api.nvim_create_augroup(
                    "minitabline_colors",
                    { clear = true }
                ),
                callback = highlights,
            })
            -- setup forces showtabline = 2, restore the saved visibility
            show(util.read_state("tabline") ~= "0")
        end,
    },
}
