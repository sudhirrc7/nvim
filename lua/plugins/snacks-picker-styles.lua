-- Snacks picker layouts, picked with <leader>tp.
-- Moving through the list morphs the picker into each style live;
-- <CR> keeps it (remembered across sessions), <Esc> changes nothing.
--
-- Self-contained: delete this file to go back to the layout set in
-- plugins/snacks.lua. Pickers whose source sets its own layout (explorer,
-- select, ...) keep it.

local picker_styles = {
    {
        name = "Default",
        icon = "\u{f0db}",
        desc = "snacks default: list left, preview right",
        layout = { preset = "default" },
    },
    {
        name = "Telescope",
        icon = "\u{f1ff}",
        desc = "prompt at the bottom, results grow upwards",
        layout = { preset = "telescope" },
    },
    {
        name = "Ivy",
        icon = "󰁅",
        desc = "full width panel along the bottom",
        layout = { preset = "ivy" },
    },
    {
        name = "Ivy Split",
        icon = "󰤼",
        desc = "bottom split, previews in the main window",
        layout = { preset = "ivy_split" },
    },
    {
        name = "Dropdown",
        icon = "󰍝",
        desc = "preview on top, prompt and list below",
        layout = { preset = "dropdown" },
    },
    {
        name = "VSCode",
        icon = "󰨞",
        desc = "command palette at the top, no preview",
        layout = { preset = "vscode" },
    },
    {
        name = "Vertical",
        icon = "󰕭",
        desc = "single column, preview under the list",
        layout = { preset = "vertical" },
    },
    {
        name = "Sidebar",
        icon = "󰙅",
        desc = "left sidebar, previews in the main window",
        layout = { preset = "sidebar" },
    },
    {
        name = "Spotlight",
        icon = "\u{f002}",
        desc = "centered, dimmed backdrop, rounded panes",
        layout = {
            cycle = true,
            layout = {
                box = "horizontal",
                width = 0.8,
                min_width = 100,
                height = 0.8,
                min_height = 20,
                backdrop = 60,
                border = "none",
                {
                    box = "vertical",
                    width = 0.4,
                    border = "rounded",
                    title = " {title} {live} {flags} ",
                    title_pos = "center",
                    { win = "input", height = 1, border = "bottom" },
                    { win = "list", border = "none" },
                },
                {
                    win = "preview",
                    title = " {preview} ",
                    title_pos = "center",
                    border = "rounded",
                },
            },
        },
    },
    {
        name = "Fullscreen",
        icon = "󰊓",
        desc = "takes the whole screen, big preview",
        layout = {
            cycle = true,
            layout = {
                box = "horizontal",
                width = 0,
                height = 0,
                border = "none",
                {
                    box = "vertical",
                    width = 0.35,
                    border = "single",
                    title = " {title} {live} {flags} ",
                    { win = "input", height = 1, border = "bottom" },
                    { win = "list", border = "none" },
                },
                {
                    win = "preview",
                    title = " {preview} ",
                    border = "single",
                },
            },
        },
    },
    {
        name = "Cards",
        icon = "󰆼",
        desc = "prompt, list and preview as separate cards",
        layout = {
            cycle = true,
            layout = {
                box = "horizontal",
                width = 0.85,
                min_width = 110,
                height = 0.8,
                backdrop = 40,
                border = "none",
                {
                    box = "vertical",
                    width = 0.4,
                    {
                        win = "input",
                        height = 1,
                        border = "rounded",
                        title = " {title} {live} {flags} ",
                        title_pos = "center",
                    },
                    {
                        win = "list",
                        border = "rounded",
                        title = " Results ",
                        title_pos = "center",
                    },
                },
                {
                    win = "preview",
                    title = " {preview} ",
                    title_pos = "center",
                    border = "rounded",
                },
            },
        },
    },
    {
        name = "Quake",
        icon = "󱞣",
        desc = "drops down from the top edge, full width",
        layout = {
            cycle = true,
            layout = {
                box = "horizontal",
                row = 0,
                width = 0,
                height = 0.5,
                min_height = 18,
                backdrop = 50,
                border = "bold",
                title = " {title} {live} {flags} ",
                title_pos = "center",
                {
                    box = "vertical",
                    width = 0.35,
                    { win = "input", height = 1, border = "bottom" },
                    { win = "list", border = "none" },
                },
                {
                    win = "preview",
                    title = " {preview} ",
                    title_pos = "right",
                    border = "left",
                },
            },
        },
    },
    {
        name = "Mirror",
        icon = "󰯌",
        desc = "preview on the left, list on the right",
        layout = {
            cycle = true,
            layout = {
                box = "horizontal",
                width = 0.85,
                min_width = 110,
                height = 0.8,
                border = "double",
                title = " {title} {live} {flags} ",
                title_pos = "center",
                {
                    win = "preview",
                    title = " {preview} ",
                    border = "right",
                },
                {
                    box = "vertical",
                    width = 0.4,
                    { win = "input", height = 1, border = "bottom" },
                    { win = "list", border = "none" },
                },
            },
        },
    },
    {
        name = "Zen",
        icon = "󰚀",
        desc = "slim padded column on a heavily dimmed screen",
        layout = {
            cycle = true,
            hidden = { "preview" },
            layout = {
                box = "vertical",
                width = 60,
                min_width = 60,
                height = 0.7,
                min_height = 20,
                backdrop = 90,
                border = "solid",
                title = " {title} ",
                title_pos = "center",
                {
                    win = "input",
                    height = 1,
                    border = "vpad",
                    title = "{live} {flags}",
                    title_pos = "right",
                },
                { win = "list", border = "hpad" },
                {
                    win = "preview",
                    title = " {preview} ",
                    height = 0.5,
                    border = "top",
                },
            },
        },
    },
    {
        name = "Minimal",
        icon = "󰘷",
        desc = "borderless and compact, no titles",
        layout = {
            cycle = true,
            layout = {
                box = "vertical",
                width = 0.55,
                min_width = 80,
                height = 0.6,
                min_height = 16,
                backdrop = false,
                border = "solid",
                { win = "input", height = 1, border = "none" },
                { win = "list", height = 0.4, border = "top" },
                { win = "preview", border = "top" },
            },
        },
    },
}

local styles = require("config.util").styles("snacks_picker_style", picker_styles)

-- each style is registered as its own snacks layout preset
local function preset_name(idx)
    return "picker_style_" .. idx
end

-- registers every style and makes the chosen one the global picker layout
local function picker_apply()
    local cfg = Snacks.config.picker
    cfg.layouts = cfg.layouts or {}
    for i, style in ipairs(picker_styles) do
        cfg.layouts[preset_name(i)] = vim.deepcopy(style.layout)
    end
    cfg.layout = preset_name(styles.index)
end

local function picker_pick_style()
    local original = styles.index
    local file = vim.api.nvim_buf_get_name(0)
    file = vim.uv.fs_stat(file) and file or nil

    local items = {}
    for i, s in ipairs(picker_styles) do
        items[#items + 1] = {
            idx = i,
            text = s.name .. " " .. s.desc,
            style = s,
            -- preview the current file so the style is seen with real content
            file = file,
            preview = not file and {
                text = ("%s  %s\n\n%s"):format(s.icon, s.name, s.desc),
            } or nil,
        }
    end

    Snacks.picker({
        title = "Picker Style",
        items = items,
        layout = preset_name(original),
        preview = file and "file" or "preview",
        format = function(item)
            local current = item.idx == original
            local ret = {
                { item.style.icon, "Special" },
                { "  " },
                {
                    ("%-11s"):format(item.style.name),
                    current and "DiagnosticOk" or "Normal",
                },
                { item.style.desc, "Comment" },
            }
            if current then
                ret[#ret + 1] = { "  ● current", "DiagnosticOk" }
            end
            return ret
        end,
        on_show = function(picker)
            vim.schedule(function()
                picker.list:view(original)
            end)
        end,
        -- morph this picker into the style under the cursor, keeping its
        -- list order so moving through the styles never flips direction
        on_change = function(picker, item)
            if item then
                vim.schedule(function()
                    if not picker.closed then
                        local layout =
                            Snacks.picker.config.layout(preset_name(item.idx))
                        layout.reverse = picker.list.reverse
                        picker:set_layout(layout)
                    end
                end)
            end
        end,
        confirm = function(picker, item)
            picker:close()
            if not item then
                return
            end
            styles.set(item.idx)
            picker_apply()

            Snacks.notify(
                ("%s  %s  (%d/%d)"):format(
                    item.style.icon,
                    item.style.name,
                    item.idx,
                    #picker_styles
                ),
                { title = "Picker style" }
            )
        end,
    })
end

return {
    "folke/snacks.nvim",
    opts = function()
        -- Snacks keeps its own copy of the opts, so apply once setup is done
        vim.schedule(picker_apply)
    end,
    keys = {
        {
            "<leader>tp",
            picker_pick_style,
            desc = "Select Picker Style",
        },
    },
}
