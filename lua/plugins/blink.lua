vim.g.blink_auto_show = true

local function toggle_auto_show()
    vim.g.blink_auto_show = not vim.g.blink_auto_show
    -- Hide any currently visible completion menu
    require("blink.cmp").hide()
end

-- Appearances cycled with <leader>tz: current (the opts below) -> blink
-- default -> ide
local styles = {
    {
        name = "Current",
        -- filled from the live config on first use so it always matches the opts below
    },
    {
        name = "Default",
        menu = {
            border = "none",
            winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
            scrollbar = true,
            max_height = 10,
            padding = 1,
            gap = 1,
            treesitter = {},
            columns = {
                { "kind_icon" },
                { "label", "label_description", gap = 1 },
            },
        },
        doc = {
            border = "padded",
            winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
        },
    },
    {
        -- my pick: square borders, treesitter-coloured labels, kind name on the right
        name = "IDE",
        menu = {
            border = "single",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
            scrollbar = false,
            max_height = 14,
            padding = { 0, 1 },
            gap = 2,
            treesitter = { "lsp" },
            columns = {
                { "kind_icon" },
                { "label", "label_description", gap = 1 },
                { "kind" },
            },
        },
        doc = {
            border = "single",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,EndOfBuffer:NormalFloat",
        },
    },
}
local style_idx = 1

local function apply_style(style)
    local cfg = require("blink.cmp.config").completion
    local menu = require("blink.cmp.completion.windows.menu")
    local docs = require("blink.cmp.completion.windows.documentation")
    require("blink.cmp").hide()
    docs.close()

    -- the renderer reads draw.columns on every draw, padding/gap only on creation
    local draw = cfg.menu.draw
    draw.columns = style.menu.columns
    draw.padding = style.menu.padding
    draw.gap = style.menu.gap
    draw.treesitter = style.menu.treesitter
    menu.renderer = nil

    -- windows copy their options once at creation, so patch the live copies
    local mw = menu.win.config
    mw.border = style.menu.border
    mw.winhighlight = style.menu.winhighlight
    mw.max_height = style.menu.max_height
    if style.menu.scrollbar and not menu.win.scrollbar then
        menu.win.scrollbar = require("blink.cmp.lib.window.scrollbar").new({
            enable_gutter = style.menu.border == "none",
        })
    elseif not style.menu.scrollbar and menu.win.scrollbar then
        menu.win.scrollbar:update()
        menu.win.scrollbar = nil
    end

    docs.win.config.border = style.doc.border
    docs.win.config.winhighlight = style.doc.winhighlight
end

local function cycle_style()
    local current = styles[1]
    if not current.menu then
        local draw = require("blink.cmp.config").completion.menu.draw
        local menu = require("blink.cmp.completion.windows.menu").win
        local docs = require("blink.cmp.completion.windows.documentation").win
        current.menu = {
            border = menu.config.border,
            winhighlight = menu.config.winhighlight,
            scrollbar = menu.scrollbar ~= nil,
            max_height = menu.config.max_height,
            padding = draw.padding,
            gap = draw.gap,
            treesitter = draw.treesitter,
            columns = draw.columns,
        }
        current.doc = {
            border = docs.config.border,
            winhighlight = docs.config.winhighlight,
        }
    end

    style_idx = style_idx % #styles + 1
    apply_style(styles[style_idx])
    vim.notify("Blink appearance: " .. styles[style_idx].name)
end

return {
    "saghen/blink.cmp",
    keys = {
        {
            "<leader>tb",
            function()
                toggle_auto_show()
                vim.notify(
                    "Blink auto completion "
                        .. (vim.g.blink_auto_show and "Enabled" or "Disabled")
                )
            end,
            desc = "Toggle Blink auto completion",
        },
        {
            "<C-q>",
            toggle_auto_show,
            mode = { "n", "i" },
            desc = "Toggle Blink auto completion",
        },
        { "<leader>tz", cycle_style, desc = "Cycle Blink appearance" },
    },
    opts = {
        keymap = {
            preset = "super-tab",
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-u>"] = { "scroll_documentation_up", "fallback" },
            ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            ["<c-l>"] = { "snippet_forward", "fallback" },
        },
        signature = {
            enabled = true,
            trigger = {
                show_on_trigger_character = false,
                show_on_insert_on_trigger_character = false,
            },
            window = {
                border = "rounded",
                show_documentation = true,
            },
        },
        appearance = {
            use_nvim_cmp_as_default = false,
            nerd_font_variant = "mono",
        },
        completion = {
            trigger = { show_in_snippet = false },
            menu = {
                auto_show = function()
                    return vim.g.blink_auto_show
                end,
                -- auto_show_delay_ms = 500,
                border = "rounded",
                winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
                scrollbar = false,
                max_height = 10,
                draw = {
                    columns = {
                        { "kind_icon" },
                        { "label", "label_description", gap = 1 },
                        { "source_name" },
                    },
                    components = {
                        -- Native icon support (no lspkind needed)
                        source_name = {
                            text = function(ctx)
                                local source_names = {
                                    lsp = "[LSP]",
                                    buffer = "[Buffer]",
                                    path = "[Path]",
                                    snippets = "[Snippet]",
                                }
                                return (source_names[ctx.source_name] or "[")
                                    .. ctx.source_name
                                    .. "]"
                            end,
                            highlight = "CmpItemMenu",
                        },
                    },
                },
            },
            documentation = {
                window = {
                    border = "rounded",
                    scrollbar = false,
                    -- winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
                },
            },
        },
    },
}
