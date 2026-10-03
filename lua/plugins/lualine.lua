-- Lualine styles, picked with <leader>tl.
-- The chosen style is remembered across sessions.
local color = require("config.color")
local blend, is_hex = color.blend, color.is_hex

local formatter = function()
    local formatters = require("conform").list_formatters(0)
    if #formatters == 0 then
        return ""
    end

    return "󰛖 "
end

local linter = function()
    local linters = require("lint").linters_by_ft[vim.bo.filetype]
    if not linters or #linters == 0 then
        return ""
    end

    return "󱉶 "
end

-- ============================================================
-- HELPERS SHARED BY THE STYLES
-- ============================================================

-- the mode colors (section "a" background) of the current theme,
-- refreshed every time the theme is (re)loaded
local mode_colors = {}

local mode_names = {
    n = "normal",
    i = "insert",
    v = "visual",
    V = "visual",
    ["\22"] = "visual",
    s = "visual",
    S = "visual",
    ["\19"] = "visual",
    R = "replace",
    c = "command",
    t = "terminal",
}

local function mode_color()
    local mode = mode_names[vim.fn.mode():sub(1, 1)] or "normal"
    return mode_colors[mode] or mode_colors.normal
end

-- Theme that follows the colorscheme like "auto". Being a function,
-- lualine calls it again on every ColorScheme change. `transform` can
-- tweak a copy of the theme (e.g. make the middle transparent).
local function auto_theme(transform)
    return function()
        local loader = require("lualine.utils.loader")
        local theme = vim.deepcopy(loader.load_theme("auto"))
        for mode, sections in pairs(theme) do
            mode_colors[mode] = sections.a and sections.a.bg
        end
        return transform and transform(theme) or theme
    end
end

-- clears the background of the middle (c / x) sections
local function transparent_middle(theme)
    for _, sections in pairs(theme) do
        if sections.c then
            sections.c.bg = "None"
        end
    end
    return theme
end

-- color = { fg = <highlight group fg> }, resolved on every redraw
local function fg(group, gui)
    return function()
        return { fg = Snacks.util.color(group), gui = gui }
    end
end

local function fg_mode(gui)
    return function()
        return { fg = mode_color(), gui = gui }
    end
end

-- a component that always shows `s`
local function text(s)
    return function()
        return s
    end
end

local function lsp_clients()
    local names = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        names[#names + 1] = client.name
    end
    return table.concat(names, " ")
end

-- attached LSP client names, hidden when there are none
local function lsp(extra)
    return vim.tbl_extend("force", {
        lsp_clients,
        icon = "\u{f085}",
        cond = function()
            return lsp_clients() ~= ""
        end,
    }, extra or {})
end

local function branch(extra)
    return vim.tbl_extend("force", { "branch", icon = "\u{e725}" }, extra or {})
end

-- the filetype icon, glued to the path that follows it
local function ft_icon(left)
    return {
        "filetype",
        icon_only = true,
        separator = "",
        padding = { left = left, right = 0 },
    }
end

local function pretty_path()
    return {
        LazyVim.lualine.pretty_path({
            filename_hl = "Bold",
            modified_hl = "MatchParen",
            directory_hl = "Conceal",
        }),
    }
end

local function diagnostics()
    local icons = LazyVim.config.icons.diagnostics
    return {
        "diagnostics",
        symbols = {
            error = icons.Error,
            warn = icons.Warn,
            info = icons.Info,
            hint = icons.Hint,
        },
    }
end

local function info_extras()
    if vim.g.lualine_info_extras ~= true then
        return {}
    end
    return { linter, formatter, { "lsp_status" } }
end

-- Splits LazyVim's lualine_x into the "diff" component and the
-- rest (noice, dap, lazy updates, profiler) so styles can reuse them.
local function split_x(base)
    local diff, extras = nil, {}
    for _, component in ipairs(base.sections.lualine_x) do
        if type(component) == "table" and component[1] == "diff" then
            diff = component
        else
            extras[#extras + 1] = component
        end
    end
    return diff or { "diff" }, extras
end

-- the editor background, used as dark text on filled sections
local function ink()
    return Snacks.util.color("Normal", "bg") or "#11111b"
end

-- the editor foreground
local function text_color()
    return Snacks.util.color("Normal") or "#cdd6f4"
end

-- Builds a theme transform that recolors every mode from its accent
-- (the mode color): `sections(accent, base, text)` returns the new
-- { a, b, c } where base/text are the theme background/foreground.
local function mode_tint(sections)
    return function(theme)
        local base = theme.normal and theme.normal.c and theme.normal.c.bg
        base = is_hex(base) and base or ink()
        local fg_text = text_color()
        for mode, old in pairs(theme) do
            local accent = old.a and old.a.bg
            if mode ~= "inactive" and is_hex(accent) then
                theme[mode] = sections(accent, base, fg_text)
            end
        end
        return theme
    end
end

-- solid (a) through a half-tone (b) to a faint glow (c)
local mode_gradient = mode_tint(function(accent, base, fg_text)
    return {
        a = { fg = base, bg = accent, gui = "bold" },
        b = { fg = blend(accent, fg_text, 0.2), bg = blend(accent, base, 0.4) },
        c = { fg = accent, bg = blend(accent, base, 0.12) },
    }
end)

-- frosted glass: translucent mode tints with glowing text, no fill
local mode_glass = mode_tint(function(accent, base, fg_text)
    return {
        a = { fg = accent, bg = blend(accent, base, 0.22), gui = "bold" },
        b = { fg = blend(accent, fg_text, 0.45), bg = blend(accent, base, 0.1) },
        c = { fg = fg_text, bg = "None" },
    }
end)

-- a deep band of the mode color: solid head (a), mid-tone fold (b),
-- rich dark body (c), all with light text so nothing washes out
local mode_ribbon = mode_tint(function(accent, base, fg_text)
    return {
        a = { fg = base, bg = accent, gui = "bold" },
        b = { fg = blend(accent, fg_text, 0.15), bg = blend(accent, base, 0.55) },
        c = { fg = blend(accent, fg_text, 0.3), bg = blend(accent, base, 0.28) },
    }
end)

-- shapes for capsule() edges
local edges = {
    round = { left = "\u{e0b6}", right = "\u{e0b4}" }, -- ( )
    trapezoid = { left = "\u{e0ba}", right = "\u{e0b8}" }, -- ◢ ◣ wide at the bottom
    tab = { left = "\u{e0be}", right = "\u{e0bc}" }, -- ◥ ◤ wide at the top
    hexagon = { left = "\u{e0b2}", right = "\u{e0b0}" }, -- < >
}

-- Wraps a component in its own capsule filled with the fg of `groups`
-- (first one that exists), or the mode color for "mode", or a color
-- function. `shape` is one of `edges` (round by default).
-- Put a gap() between capsules so they float apart.
local function capsule(component, groups, shape)
    component = type(component) == "table" and component or { component }
    component.separator = edges[shape or "round"]
    component.color = type(groups) == "function" and groups
        or function()
            local bg = groups == "mode" and mode_color()
                or Snacks.util.color(groups)
            return { fg = ink(), bg = bg, gui = "bold" }
        end
    return component
end

-- capsule color: the fg of `groups` (or the mode color for "mode")
-- mixed into the background by `alpha`, with light tinted text
local function tinted(groups, alpha)
    return function()
        local accent = groups == "mode" and mode_color()
            or Snacks.util.color(groups)
        return {
            fg = blend(accent, text_color(), 0.5),
            bg = blend(accent, ink(), alpha),
            gui = "bold",
        }
    end
end

local function gap()
    return { text(" "), padding = 0 }
end

-- file name with its devicon, plain text so it can sit on any fill
local function file_with_icon()
    return {
        "filename",
        path = 0,
        symbols = { modified = "●", readonly = "\u{f023}" },
        fmt = function(name)
            local ok, icons = pcall(require, "mini.icons")
            if not ok then
                return name
            end
            local icon = icons.get("file", vim.fn.expand("%:t"))
            return icon .. " " .. name
        end,
    }
end

-- a tiny bar that grows as you move down the file
local function scroll_bar()
    local blocks = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
    local ratio = vim.fn.line(".") / math.max(vim.fn.line("$"), 1)
    return blocks[math.max(1, math.ceil(ratio * #blocks))]:rep(2)
end

local function seps(left, right)
    return { left = left, right = right }
end

-- powerline arrows
local ARROWS = seps("\u{e0b0}", "\u{e0b2}")
local THIN_ARROWS = seps("\u{e0b1}", "\u{e0b3}")
-- rounded ends
local ROUND = seps("\u{e0b4}", "\u{e0b6}")

-- ============================================================
-- STYLE BUILDERS
-- Lualine merges a new setup() into the previous config, so every
-- style sets the theme, both separators and every section.
-- ============================================================

-- Turns `spec(diff, extras)` into a style builder. The spec returns the
-- `theme` transform, the separators (`sep` / `comp`, "" when left out)
-- and the sections `a` .. `z`; missing sections are left empty. lualine_x
-- is LazyVim's `extras` (noice, dap, lazy updates...), the info extras,
-- then the spec's `x`. `diff` is LazyVim's diff component.
local function style(spec)
    return function(opts)
        local diff, extras = split_x(opts)
        -- fresh tables on every build, lualine writes into its components
        local s = vim.deepcopy(spec(diff, extras))
        opts.options.theme = auto_theme(s.theme)
        opts.options.section_separators = s.sep or ""
        opts.options.component_separators = s.comp or ""

        local x = vim.list_extend(s.extras or extras, info_extras())
        opts.sections = {
            lualine_a = s.a or {},
            lualine_b = s.b or {},
            lualine_c = s.c or {},
            lualine_x = vim.list_extend(x, s.x or {}),
            lualine_y = s.y or {},
            lualine_z = s.z or {},
        }
        return opts
    end
end

-- mode | branch diff | [root] filetype path diagnostics ... | y | z
local function powerline(p)
    return style(function(diff)
        local c = { ft_icon(1), pretty_path(), diagnostics() }
        if p.root then
            table.insert(c, 1, LazyVim.lualine.root_dir())
        end
        return {
            theme = p.theme,
            sep = p.sep,
            comp = p.comp,
            a = { { "mode", icon = p.icon } },
            b = { branch(), diff },
            c = c,
            y = p.y,
            z = p.z,
        }
    end)
end

-- Powerline where every edge is a slash: `left`/`right` are the section
-- separators, `thin` the component one. With `gradient` it is tinted by
-- the mode, otherwise it uses the plain theme and shows the root dir.
local function slashed(gradient, left, right, thin)
    return powerline({
        theme = gradient and mode_gradient or nil,
        root = not gradient,
        sep = seps(left, right),
        comp = seps(thin, thin),
        icon = "\u{e62b}",
        y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
        },
        z = {
            function()
                return "\u{f017} " .. os.date("%R")
            end,
        },
    })
end

-- rounded pills at both ends: mode | branch diff | ... | progress | location
local function rounded(theme, icon)
    return style(function(diff)
        return {
            theme = theme,
            sep = ROUND,
            a = {
                {
                    "mode",
                    icon = icon,
                    separator = { left = "\u{e0b6}" },
                    padding = { left = 0, right = 1 },
                },
            },
            b = { branch(), diff },
            c = { ft_icon(2), pretty_path(), diagnostics() },
            y = { "progress" },
            z = {
                {
                    "location",
                    separator = { right = "\u{e0b4}" },
                    padding = { left = 1, right = 0 },
                },
            },
        }
    end)
end

-- Floating pills of one `shape` on a transparent bar:
-- mode, branch, file ... lsp, progress, location.
-- `colors` maps each pill to a capsule() color.
local function pills(shape, icon, colors)
    return style(function(diff)
        return {
            theme = transparent_middle,
            c = {
                gap(),
                capsule({ "mode", icon = icon }, colors.mode, shape),
                gap(),
                capsule(branch(), colors.branch, shape),
                gap(),
                capsule(file_with_icon(), colors.file, shape),
                diagnostics(),
            },
            x = {
                diff,
                capsule(lsp(), colors.lsp, shape),
                gap(),
                capsule({ "progress" }, colors.progress, shape),
                gap(),
                capsule({ "location" }, colors.location, shape),
                gap(),
            },
        }
    end)
end

-- every pill in its own syntax color
local rainbow = {
    mode = "mode",
    branch = { "Statement", "Keyword" },
    file = { "Function", "Identifier" },
    lsp = { "Type", "Special" },
    progress = { "String", "DiagnosticOk" },
    location = { "Constant", "Number" },
}

-- the rainbow colors, frosted
local frosted = vim.tbl_map(function(groups)
    return tinted(groups, 0.3)
end, rainbow)
frosted.mode = "mode"

-- ============================================================
-- STYLES
-- Each `build` gets a fresh copy of LazyVim's lualine opts.
-- ============================================================

local lualine_styles = {
    -- the original look: LazyVim's arrows with the custom path
    {
        name = "Classic",
        desc = "LazyVim arrows with the custom path",
        icon = "\u{e0b0}",
        build = function(opts)
            opts.options.theme = auto_theme()
            opts.options.section_separators = ARROWS
            opts.options.component_separators = THIN_ARROWS

            opts.sections.lualine_a = { "mode" }
            opts.sections.lualine_c[4] = pretty_path()
            for _, component in ipairs(info_extras()) do
                table.insert(opts.sections.lualine_x, 2, component)
            end
            opts.sections.lualine_y = { "progress" }
            opts.sections.lualine_z = {}
            return opts
        end,
    },
    -- rounded pills at both ends floating over a transparent middle
    {
        name = "Bubbles",
        desc = "rounded pills over a transparent middle",
        icon = "\u{e0b6}",
        build = rounded(transparent_middle),
    },
    -- powerline with forward slashes (/) and a clock
    {
        name = "Slant",
        desc = "slashed powerline with a clock",
        icon = "\u{e0bc}",
        build = slashed(false, "\u{e0bc}", "\u{e0ba}", "\u{e0bb}"),
    },
    -- Slant mirrored: every edge leans back (\)
    {
        name = "Backslant",
        desc = "back-slashed powerline with a clock",
        icon = "\u{e0b8}",
        build = slashed(false, "\u{e0b8}", "\u{e0be}", "\u{e0b9}"),
    },
    -- eviline: transparent, mode-colored edge bars, LSP name in the center
    {
        name = "Evil",
        desc = "eviline: mode bars, LSP in the center",
        icon = "\u{e62b}",
        build = style(function(diff)
            local bar = text("▊")
            return {
                theme = transparent_middle,
                c = {
                    { bar, color = fg_mode(), padding = { left = 0, right = 1 } },
                    { text("\u{e62b}"), color = fg_mode(), padding = { right = 1 } },
                    branch({ color = fg("Statement", "bold") }),
                    ft_icon(1),
                    pretty_path(),
                    diagnostics(),
                    text("%="),
                    lsp({ color = fg("Comment", "bold") }),
                },
                x = {
                    diff,
                    { "progress", color = fg("Special", "bold") },
                    { "location", color = fg("Function") },
                    { bar, color = fg_mode(), padding = { left = 1, right = 0 } },
                },
            }
        end),
    },
    -- quiet text on a transparent bar, only the mode dot has color
    {
        name = "Minimal",
        desc = "quiet text, only the mode dot has color",
        icon = "\u{25cf}",
        build = style(function(diff)
            return {
                theme = transparent_middle,
                c = {
                    {
                        text("\u{25cf}"),
                        color = fg_mode(),
                        padding = { left = 1, right = 1 },
                    },
                    {
                        "mode",
                        fmt = string.lower,
                        color = fg_mode("bold"),
                        padding = { left = 0, right = 2 },
                    },
                    pretty_path(),
                    diagnostics(),
                },
                x = {
                    diff,
                    branch({ color = fg("Comment") }),
                    { text("%l:%v"), color = fg("Comment") },
                    {
                        "progress",
                        color = fg("Comment"),
                        padding = { left = 1, right = 2 },
                    },
                },
            }
        end),
    },
    -- the whole bar is tinted by the mode: solid edges fading to a glow,
    -- so switching to insert/visual washes the bar in a new color
    {
        name = "Aurora",
        desc = "whole bar tinted by the mode, fading to a glow",
        icon = "\u{f186}",
        build = powerline({
            theme = mode_gradient,
            sep = ROUND,
            comp = seps("\u{e0b5}", "\u{e0b7}"),
            icon = "\u{f186}",
            y = { "progress" },
            z = { { "location", icon = "\u{f0d0}" } },
        }),
    },
    -- every piece of info in its own colored capsule, floating apart
    -- on a transparent bar
    {
        name = "Capsules",
        desc = "rainbow capsules floating apart",
        icon = "\u{f135}",
        build = pills("round", "\u{f135}", rainbow),
    },
    -- flame-shaped separators burning into a transparent middle
    {
        name = "Flame",
        desc = "flame edges burning into the background",
        icon = "\u{f06d}",
        build = style(function(diff)
            return {
                theme = transparent_middle,
                sep = seps("\u{e0c0}", "\u{e0c2}"),
                comp = seps("\u{e0c1}", "\u{e0c3}"),
                a = { { "mode", icon = "\u{f06d}" } },
                b = { branch() },
                c = { ft_icon(2), pretty_path(), diagnostics() },
                x = { diff },
                y = { { "filetype", colored = false } },
                z = { "location" },
            }
        end),
    },
    -- 8-bit: pixelated edges, a gamepad and a scroll meter
    {
        name = "Pixel",
        desc = "8-bit edges, gamepad and a scroll meter",
        icon = "\u{f11b}",
        build = powerline({
            sep = seps("\u{e0c6}", "\u{e0c7}"),
            icon = "\u{f11b}",
            y = { text("%l/%L") },
            z = { scroll_bar },
        }),
    },
    -- transparent bar where everything glows in the mode color
    {
        name = "Neon",
        desc = "everything glows in the mode color",
        icon = "\u{f0e7}",
        build = style(function(diff)
            local function divider(s)
                return s .. "  │"
            end
            return {
                theme = transparent_middle,
                c = {
                    {
                        "mode",
                        icon = "\u{f0e7}",
                        fmt = divider,
                        color = fg_mode("bold"),
                    },
                    branch({ fmt = divider, color = fg_mode("italic") }),
                    ft_icon(1),
                    pretty_path(),
                    diagnostics(),
                },
                x = {
                    diff,
                    lsp({ fmt = divider, color = fg_mode() }),
                    { text("%l:%v"), color = fg_mode("bold") },
                    {
                        scroll_bar,
                        color = fg_mode(),
                        padding = { left = 1, right = 2 },
                    },
                },
            }
        end),
    },
    -- frosted glass: translucent mode-tinted pills with glowing text
    {
        name = "Glass",
        desc = "frosted translucent pills with glowing text",
        icon = "\u{f0eb}",
        build = rounded(mode_glass, "\u{f0eb}"),
    },
    -- the whole bar is one deep band of the mode color
    {
        name = "Ribbon",
        desc = "a deep band of mode color, edge to edge",
        icon = "\u{f02e}",
        build = style(function(_, extras)
            return {
                theme = mode_ribbon,
                sep = ARROWS,
                comp = THIN_ARROWS,
                -- drop the extras' own colors (pink lazy updates etc.), they
                -- clash with the band, and use the band's text color instead
                extras = vim.tbl_map(function(component)
                    if type(component) == "table" then
                        component = vim.tbl_extend("force", {}, component)
                        component.color = nil
                    end
                    return component
                end, extras),
                a = { { "mode", icon = "\u{f02e}" } },
                b = { branch(), { "diff", colored = false } },
                c = {
                    vim.tbl_extend(
                        "force",
                        file_with_icon(),
                        { color = { gui = "bold" } }
                    ),
                    vim.tbl_extend("force", diagnostics(), { colored = false }),
                },
                y = { "progress" },
                z = { "location" },
            }
        end),
    },
    -- oh-my-zsh robbyrussell prompt: ➜ project git:(main) ✗
    {
        name = "Prompt",
        desc = "a zsh prompt: ➜ project git:(main) ✗",
        icon = "\u{f120}",
        build = style(function(diff)
            local function head()
                return vim.b.gitsigns_head or ""
            end
            local function in_git()
                return head() ~= ""
            end
            local function dirty()
                local s = vim.b.gitsigns_status_dict
                return s ~= nil
                    and (
                            (s.added or 0)
                            + (s.changed or 0)
                            + (s.removed or 0)
                        )
                        > 0
            end
            return {
                theme = transparent_middle,
                c = {
                    { text("➜"), color = fg_mode("bold") },
                    {
                        function()
                            return vim.fn.fnamemodify(LazyVim.root(), ":t")
                        end,
                        color = fg({ "DiagnosticInfo", "Special" }, "bold"),
                        padding = { left = 0, right = 1 },
                    },
                    {
                        text("git:("),
                        cond = in_git,
                        color = fg("Function", "bold"),
                        padding = 0,
                    },
                    {
                        head,
                        cond = in_git,
                        color = fg("DiagnosticError", "bold"),
                        padding = 0,
                    },
                    {
                        text(")"),
                        cond = in_git,
                        color = fg("Function", "bold"),
                        padding = { left = 0, right = 1 },
                    },
                    {
                        text("✗"),
                        cond = dirty,
                        color = fg("DiagnosticWarn", "bold"),
                        padding = { left = 0, right = 1 },
                    },
                    pretty_path(),
                    diagnostics(),
                },
                x = {
                    diff,
                    { text("[%l:%v]"), color = fg("Comment") },
                    {
                        function()
                            return os.date("%R")
                        end,
                        color = fg("Comment", "italic"),
                        padding = { left = 0, right = 1 },
                    },
                },
            }
        end),
    },
    -- the file sits in a glowing pill dead center, everything else
    -- is pushed to the edges
    {
        name = "Spotlight",
        desc = "your file in a glowing pill, dead center",
        icon = "\u{f005}",
        build = style(function(diff)
            return {
                theme = transparent_middle,
                c = {
                    {
                        "mode",
                        icon = "\u{f005}",
                        color = fg_mode("bold"),
                        padding = { left = 1, right = 1 },
                    },
                    branch({ color = fg("Comment") }),
                    text("%="),
                    capsule(file_with_icon(), "mode"),
                    diagnostics(),
                },
                x = {
                    diff,
                    { "location", color = fg("Comment") },
                    {
                        scroll_bar,
                        color = fg_mode(),
                        padding = { left = 0, right = 1 },
                    },
                },
            }
        end),
    },
    -- Slant mirrored: every edge leans back (\), over the mode gradient
    {
        name = "Backslash",
        desc = "reverse-slanted powerline fading through the mode",
        icon = "\u{e0b8}",
        build = slashed(true, "\u{e0b8}", "\u{e0be}", "\u{e0b9}"),
    },
    -- Backslash mirrored: every edge leans forward (/)
    {
        name = "Forwardslash",
        desc = "forward-slanted powerline fading through the mode",
        icon = "\u{e0bc}",
        build = slashed(true, "\u{e0bc}", "\u{e0ba}", "\u{e0bb}"),
    },
    -- floating trapezoids (wide at the bottom) in shades of the mode color
    {
        name = "Trapezoid",
        desc = "floating trapezoids in shades of the mode color",
        icon = "\u{e0ba}",
        build = pills("trapezoid", "\u{f1b2}", {
            mode = "mode",
            branch = tinted("mode", 0.45),
            file = tinted("mode", 0.25),
            lsp = tinted("mode", 0.25),
            progress = tinted("mode", 0.45),
            location = "mode",
        }),
    },
    -- upside-down trapezoids hanging like tabs, each its own color
    {
        name = "Tabs",
        desc = "rainbow tabs, wide at the top",
        icon = "\u{e0be}",
        build = pills("tab", "\u{f15b}", rainbow),
    },
    -- pointed hexagon pills, frosted versions of the rainbow colors
    {
        name = "Hexagon",
        desc = "frosted rainbow hexagons with pointed ends",
        icon = "\u{e0b2}",
        build = pills("hexagon", "\u{f121}", frosted),
    },
}

local styles = require("config.util").styles("lualine_style", lualine_styles)

-- LazyVim's lualine opts, captured once so every style starts from them
local lualine_base

local function lualine_build(idx)
    local opts = lualine_styles[idx].build(vim.deepcopy(lualine_base))
    opts.extensions = false
    return opts
end

local function lualine_apply(idx)
    require("lualine").setup(lualine_build(idx))
end

-- Picks a style with a Snacks picker. Moving through the list previews
-- each style live on the statusline; <CR> keeps it, <Esc> restores.
local function lualine_pick_style()
    local original = styles.index
    local confirmed = false
    local items = {}
    for i, s in ipairs(lualine_styles) do
        items[#items + 1] = {
            idx = i,
            text = s.name .. " " .. s.desc,
            style = s,
        }
    end

    Snacks.picker({
        title = "Lualine Style",
        items = items,
        layout = { preset = "select", preview = false },
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
        on_change = function(_, item)
            if item then
                lualine_apply(item.idx)
            end
        end,
        on_close = function()
            if not confirmed then
                lualine_apply(original)
            end
        end,
        confirm = function(picker, item)
            confirmed = item ~= nil
            picker:close()
            if not item then
                return
            end
            styles.set(item.idx)
            lualine_apply(item.idx)

            Snacks.notify(
                ("%s  %s"):format(item.style.icon, item.style.name),
                { title = "Lualine style" }
            )
        end,
    })
end

return {
    "nvim-lualine/lualine.nvim",
    enabled = true,
    opts = function(_, opts)
        lualine_base = vim.deepcopy(opts)
        return lualine_build(styles.index)
    end,
    keys = {
        {
            "<leader>tl",
            lualine_pick_style,
            desc = "Select Lualine Style",
        },
    },
}
