vim.g.blink_auto_show = true

local function toggle_auto_show()
    vim.g.blink_auto_show = not vim.g.blink_auto_show
    -- Hide any currently visible completion menu
    require("blink.cmp").hide()
end

-- short tags for the "Retro" style, coloured like the kind icons
local kind_tags = {
    Text = "txt",
    Method = "mth",
    Function = "fn",
    Constructor = "new",
    Field = "fld",
    Variable = "var",
    Class = "cls",
    Interface = "ifc",
    Module = "mod",
    Property = "prp",
    Unit = "unt",
    Value = "val",
    Enum = "enm",
    Keyword = "key",
    Snippet = "snp",
    Color = "clr",
    File = "fil",
    Reference = "ref",
    Folder = "dir",
    EnumMember = "mem",
    Constant = "cst",
    Struct = "st",
    Event = "evt",
    Operator = "op",
    TypeParameter = "typ",
}

-- "Badge" style: kind icon drawn as a filled block in the kind's colour.
-- Groups are derived from the theme, so they're rebuilt on ColorScheme.
local badge_groups = {}
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        badge_groups = {}
    end,
})

local function badge_hl(kind_hl)
    if not badge_groups[kind_hl] then
        local group = kind_hl .. "Badge"
        vim.api.nvim_set_hl(0, group, {
            fg = Snacks.util.color("Normal", "bg") or "#11111b",
            bg = Snacks.util.color(kind_hl) or Snacks.util.color("Special"),
            bold = true,
        })
        badge_groups[kind_hl] = group
    end
    return badge_groups[kind_hl]
end

-- Appearances cycled with <leader>tz, the pick is remembered across restarts
local styles = require("config.util").styles("blink_style", {
    {
        name = "Current",
        menu = {
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
            scrollbar = false,
            max_height = 10,
            padding = 1,
            gap = 1,
            treesitter = { "lsp" },
            columns = {
                { "kind_icon" },
                { "label", "label_description", gap = 1 },
                { "source_name" },
            },
        },
        doc = {
            border = "rounded",
            winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
        },
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
        -- square borders, treesitter-coloured labels, kind name on the right
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
    {
        -- nvim-cmp's stock look: plain Pmenu, label then kind name, no icons
        name = "nvim-cmp",
        menu = {
            border = "none",
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
            scrollbar = true,
            max_height = 12,
            padding = 1,
            gap = 1,
            treesitter = {},
            columns = {
                { "label", "label_description", gap = 1 },
                { "kind" },
            },
        },
        doc = {
            border = "padded",
            winhighlight = "Normal:NormalFloat,FloatBorder:NormalFloat,EndOfBuffer:NormalFloat",
        },
    },
    {
        -- borderless, each row starts with a solid colour block for its kind
        name = "Badge",
        menu = {
            border = "none",
            winhighlight = "Normal:NormalFloat,FloatBorder:NormalFloat,CursorLine:PmenuSel,Search:None",
            scrollbar = false,
            max_height = 10,
            padding = { 0, 1 },
            gap = 1,
            treesitter = { "lsp" },
            columns = {
                { "kind_badge" },
                { "label", "label_description", gap = 1 },
            },
        },
        doc = {
            border = "padded",
            winhighlight = "Normal:NormalFloat,FloatBorder:NormalFloat,EndOfBuffer:NormalFloat",
        },
    },
    {
        -- labels only, lots of air, a short menu that stays out of the way
        name = "Zen",
        menu = {
            border = "solid",
            winhighlight = "Normal:NormalFloat,FloatBorder:NormalFloat,CursorLine:CursorLine,Search:None",
            scrollbar = false,
            max_height = 7,
            padding = 2,
            gap = 1,
            treesitter = { "lsp" },
            columns = { { "label" } },
        },
        doc = {
            border = "solid",
            winhighlight = "Normal:NormalFloat,FloatBorder:NormalFloat,EndOfBuffer:NormalFloat",
        },
    },
    {
        -- double-line box, short kind tags (fn, var, cls) and the source id
        name = "Retro",
        menu = {
            border = "double",
            winhighlight = "Normal:Normal,FloatBorder:Comment,CursorLine:PmenuSel,Search:None",
            scrollbar = false,
            max_height = 12,
            padding = 1,
            gap = 2,
            treesitter = {},
            columns = {
                { "kind_tag" },
                { "label", "label_description", gap = 1 },
                { "source_id" },
            },
        },
        doc = {
            border = "double",
            winhighlight = "Normal:Normal,FloatBorder:Comment,EndOfBuffer:Normal",
        },
    },
    {
        -- tall and roomy: label first, icon + kind and source on the right,
        -- heavy accent-coloured border
        name = "Wide",
        menu = {
            border = "bold",
            winhighlight = "Normal:NormalFloat,FloatBorder:Special,CursorLine:PmenuSel,Search:None",
            scrollbar = true,
            max_height = 18,
            padding = 1,
            gap = 3,
            treesitter = { "lsp" },
            columns = {
                { "label", "label_description", gap = 1 },
                { "kind_icon", "kind", gap = 1 },
                { "source_name" },
            },
        },
        doc = {
            border = "bold",
            winhighlight = "Normal:NormalFloat,FloatBorder:Special,EndOfBuffer:NormalFloat",
        },
    },
})

-- switches the running blink to `style` (startup gets it through opts)
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
    local style = styles.next()
    apply_style(style)
    vim.notify(
        ("Blink appearance: %s (%d/%d)"):format(
            style.name,
            styles.index,
            #styles.list
        )
    )
end

local style = styles.current()

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
                border = style.menu.border,
                winhighlight = style.menu.winhighlight,
                scrollbar = style.menu.scrollbar,
                max_height = style.menu.max_height,
                draw = {
                    padding = style.menu.padding,
                    gap = style.menu.gap,
                    treesitter = style.menu.treesitter,
                    columns = style.menu.columns,
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
                        kind_badge = {
                            ellipsis = false,
                            text = function(ctx)
                                return " " .. ctx.kind_icon .. " "
                            end,
                            highlight = function(ctx)
                                return {
                                    {
                                        group = badge_hl(ctx.kind_hl),
                                        priority = 20000,
                                    },
                                }
                            end,
                        },
                        kind_tag = {
                            ellipsis = false,
                            width = { min = 3 },
                            text = function(ctx)
                                return kind_tags[ctx.kind]
                                    or ctx.kind:sub(1, 3):lower()
                            end,
                            highlight = function(ctx)
                                return ctx.kind_hl
                            end,
                        },
                    },
                },
            },
            documentation = {
                window = {
                    border = style.doc.border,
                    winhighlight = style.doc.winhighlight,
                    scrollbar = false,
                },
            },
        },
    },
}
