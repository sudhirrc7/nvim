-- Lualine styles, cycled with <leader>tl.
-- The chosen style is remembered across sessions.
local style_state = vim.fn.stdpath("state") .. "/lualine_style"

local formatter = function()
    local formatters = require("conform").list_formatters(0)
    if #formatters == 0 then
        return ""
    end

    return "󰛖 "
end

local linter = function()
    local linters = require("lint").linters_by_ft[vim.bo.filetype]
    if #linters == 0 then
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

local function lsp_clients()
    local names = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        names[#names + 1] = client.name
    end
    return table.concat(names, " ")
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

local function append(list, items)
    return vim.list_extend(list, items)
end

local function is_hex(color)
    return type(color) == "string" and color:match("^#%x%x%x%x%x%x$") ~= nil
end

-- the editor background, used as dark text on filled sections
local function ink()
    return Snacks.util.color("Normal", "bg") or "#11111b"
end

-- mixes hex color `top` over `bottom`, `alpha` from 0 to 1
local function blend(top, bottom, alpha)
    if not (is_hex(top) and is_hex(bottom)) then
        return top
    end
    local function channel(i)
        local a = tonumber(top:sub(i, i + 1), 16)
        local b = tonumber(bottom:sub(i, i + 1), 16)
        return math.floor(a * alpha + b * (1 - alpha) + 0.5)
    end
    return ("#%02x%02x%02x"):format(channel(2), channel(4), channel(6))
end

-- Builds a theme transform that recolors every mode from its accent
-- (the mode color): `sections(accent, base, text)` returns the new
-- { a, b, c } where base/text are the theme background/foreground.
local function mode_tint(sections)
    return function(theme)
        local base = theme.normal and theme.normal.c and theme.normal.c.bg
        base = is_hex(base) and base or ink()
        local text = Snacks.util.color("Normal") or "#cdd6f4"
        for mode, old in pairs(theme) do
            local accent = old.a and old.a.bg
            if mode ~= "inactive" and is_hex(accent) then
                theme[mode] = sections(accent, base, text)
            end
        end
        return theme
    end
end

-- solid (a) through a half-tone (b) to a faint glow (c)
local mode_gradient = mode_tint(function(accent, base, text)
    return {
        a = { fg = base, bg = accent, gui = "bold" },
        b = { fg = blend(accent, text, 0.2), bg = blend(accent, base, 0.4) },
        c = { fg = accent, bg = blend(accent, base, 0.12) },
    }
end)

-- frosted glass: translucent mode tints with glowing text, no fill
local mode_glass = mode_tint(function(accent, base, text)
    return {
        a = { fg = accent, bg = blend(accent, base, 0.22), gui = "bold" },
        b = { fg = blend(accent, text, 0.45), bg = blend(accent, base, 0.1) },
        c = { fg = text, bg = "None" },
    }
end)

-- a deep band of the mode color: solid head (a), mid-tone fold (b),
-- rich dark body (c), all with light text so nothing washes out
local mode_ribbon = mode_tint(function(accent, base, text)
    return {
        a = { fg = base, bg = accent, gui = "bold" },
        b = { fg = blend(accent, text, 0.15), bg = blend(accent, base, 0.55) },
        c = { fg = blend(accent, text, 0.3), bg = blend(accent, base, 0.28) },
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
            fg = blend(accent, Snacks.util.color("Normal") or "#cdd6f4", 0.5),
            bg = blend(accent, ink(), alpha),
            gui = "bold",
        }
    end
end

local function gap()
    return {
        function()
            return " "
        end,
        padding = 0,
    }
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

-- Floating pills of one `shape` on a transparent bar:
-- mode, branch, file ... lsp, progress, location.
-- `colors` maps each pill to a capsule() color, plus the mode `icon`.
local function pills(opts, shape, colors)
    local diff, extras = split_x(opts)
    opts.options.theme = auto_theme(transparent_middle)
    opts.options.section_separators = ""
    opts.options.component_separators = ""

    opts.sections.lualine_a = {}
    opts.sections.lualine_b = {}
    opts.sections.lualine_c = {
        gap(),
        capsule({ "mode", icon = colors.icon }, colors.mode, shape),
        gap(),
        capsule({ "branch", icon = "\u{e725}" }, colors.branch, shape),
        gap(),
        capsule(file_with_icon(), colors.file, shape),
        diagnostics(),
    }
    opts.sections.lualine_x = append(extras, info_extras())
    vim.list_extend(opts.sections.lualine_x, {
        diff,
        capsule({
            lsp_clients,
            icon = "\u{f085}",
            cond = function()
                return lsp_clients() ~= ""
            end,
        }, colors.lsp, shape),
        gap(),
        capsule({ "progress" }, colors.progress, shape),
        gap(),
        capsule({ "location" }, colors.location, shape),
        gap(),
    })
    opts.sections.lualine_y = {}
    opts.sections.lualine_z = {}
    return opts
end

-- Powerline where every edge is a slash: `left`/`right` are the section
-- separators, `thin` the component one. With `gradient` it is tinted by
-- the mode, otherwise it uses the plain theme and shows the root dir.
local function slashed(gradient, left, right, thin)
    return function(opts)
        local diff, extras = split_x(opts)
        opts.options.theme = auto_theme(gradient and mode_gradient or nil)
        opts.options.section_separators = { left = left, right = right }
        opts.options.component_separators = { left = thin, right = thin }

        opts.sections.lualine_a = { { "mode", icon = "\u{e62b}" } }
        opts.sections.lualine_b = { { "branch", icon = "\u{e725}" }, diff }
        opts.sections.lualine_c = {
            {
                "filetype",
                icon_only = true,
                separator = "",
                padding = { left = 1, right = 0 },
            },
            pretty_path(),
            diagnostics(),
        }
        if not gradient then
            table.insert(opts.sections.lualine_c, 1, LazyVim.lualine.root_dir())
        end
        opts.sections.lualine_x = append(extras, info_extras())
        opts.sections.lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
        }
        opts.sections.lualine_z = {
            function()
                return "\u{f017} " .. os.date("%R")
            end,
        }
        return opts
    end
end

-- ============================================================
-- STYLES
-- Each `build` gets a fresh copy of LazyVim's lualine opts and must
-- set the theme, both separators and every section, since lualine
-- merges a new setup() into the previous config.
-- ============================================================

local lualine_styles = {
    -- the original look: LazyVim's arrows with the custom path
    {
        name = "Classic",
        desc = "LazyVim arrows with the custom path",
        icon = "\u{e0b0}",
        build = function(opts)
            opts.options.theme = auto_theme()
            opts.options.section_separators =
                { left = "\u{e0b0}", right = "\u{e0b2}" }
            opts.options.component_separators =
                { left = "\u{e0b1}", right = "\u{e0b3}" }

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
        build = function(opts)
            local diff, extras = split_x(opts)
            opts.options.theme = auto_theme(transparent_middle)
            opts.options.section_separators =
                { left = "\u{e0b4}", right = "\u{e0b6}" }
            opts.options.component_separators = ""

            opts.sections.lualine_a = {
                {
                    "mode",
                    separator = { left = "\u{e0b6}" },
                    padding = { left = 0, right = 1 },
                },
            }
            opts.sections.lualine_b = { { "branch", icon = "\u{e725}" }, diff }
            opts.sections.lualine_c = {
                {
                    "filetype",
                    icon_only = true,
                    separator = "",
                    padding = { left = 2, right = 0 },
                },
                pretty_path(),
                diagnostics(),
            }
            opts.sections.lualine_x = append(extras, info_extras())
            opts.sections.lualine_y = { "progress" }
            opts.sections.lualine_z = {
                {
                    "location",
                    separator = { right = "\u{e0b4}" },
                    padding = { left = 1, right = 0 },
                },
            }
            return opts
        end,
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
        build = function(opts)
            local diff, extras = split_x(opts)
            local bar = function()
                return "▊"
            end
            opts.options.theme = auto_theme(transparent_middle)
            opts.options.section_separators = ""
            opts.options.component_separators = ""

            opts.sections.lualine_a = {}
            opts.sections.lualine_b = {}
            opts.sections.lualine_c = {
                { bar, color = fg_mode(), padding = { left = 0, right = 1 } },
                {
                    function()
                        return "\u{e62b}"
                    end,
                    color = fg_mode(),
                    padding = { right = 1 },
                },
                {
                    "branch",
                    icon = "\u{e725}",
                    color = fg("Statement", "bold"),
                },
                {
                    "filetype",
                    icon_only = true,
                    separator = "",
                    padding = { left = 1, right = 0 },
                },
                pretty_path(),
                diagnostics(),
                {
                    function()
                        return "%="
                    end,
                },
                {
                    lsp_clients,
                    icon = "\u{f085}",
                    cond = function()
                        return lsp_clients() ~= ""
                    end,
                    color = fg("Comment", "bold"),
                },
            }
            opts.sections.lualine_x = append(extras, info_extras())
            vim.list_extend(opts.sections.lualine_x, {
                diff,
                { "progress", color = fg("Special", "bold") },
                { "location", color = fg("Function") },
                { bar, color = fg_mode(), padding = { left = 1, right = 0 } },
            })
            opts.sections.lualine_y = {}
            opts.sections.lualine_z = {}
            return opts
        end,
    },
    -- quiet text on a transparent bar, only the mode dot has color
    {
        name = "Minimal",
        desc = "quiet text, only the mode dot has color",
        icon = "\u{25cf}",
        build = function(opts)
            local diff, extras = split_x(opts)
            opts.options.theme = auto_theme(transparent_middle)
            opts.options.section_separators = ""
            opts.options.component_separators = ""

            opts.sections.lualine_a = {}
            opts.sections.lualine_b = {}
            opts.sections.lualine_c = {
                {
                    function()
                        return "\u{25cf}"
                    end,
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
            }
            opts.sections.lualine_x = append(extras, info_extras())
            vim.list_extend(opts.sections.lualine_x, {
                diff,
                { "branch", icon = "\u{e725}", color = fg("Comment") },
                {
                    function()
                        return "%l:%v"
                    end,
                    color = fg("Comment"),
                },
                {
                    "progress",
                    color = fg("Comment"),
                    padding = { left = 1, right = 2 },
                },
            })
            opts.sections.lualine_y = {}
            opts.sections.lualine_z = {}
            return opts
        end,
    },
    -- the whole bar is tinted by the mode: solid edges fading to a glow,
    -- so switching to insert/visual washes the bar in a new color
    {
        name = "Aurora",
        desc = "whole bar tinted by the mode, fading to a glow",
        icon = "\u{f186}",
        build = function(opts)
            local diff, extras = split_x(opts)
            opts.options.theme = auto_theme(mode_gradient)
            opts.options.section_separators =
                { left = "\u{e0b4}", right = "\u{e0b6}" }
            opts.options.component_separators =
                { left = "\u{e0b5}", right = "\u{e0b7}" }

            opts.sections.lualine_a = { { "mode", icon = "\u{f186}" } }
            opts.sections.lualine_b = { { "branch", icon = "\u{e725}" }, diff }
            opts.sections.lualine_c = {
                {
                    "filetype",
                    icon_only = true,
                    separator = "",
                    padding = { left = 1, right = 0 },
                },
                pretty_path(),
                diagnostics(),
            }
            opts.sections.lualine_x = append(extras, info_extras())
            opts.sections.lualine_y = { "progress" }
            opts.sections.lualine_z = { { "location", icon = "\u{f0d0}" } }
            return opts
        end,
    },
    -- every piece of info in its own colored capsule, floating apart
    -- on a transparent bar
    {
        name = "Capsules",
        desc = "rainbow capsules floating apart",
        icon = "\u{f135}",
        build = function(opts)
            local diff, extras = split_x(opts)
            opts.options.theme = auto_theme(transparent_middle)
            opts.options.section_separators = ""
            opts.options.component_separators = ""

            opts.sections.lualine_a = {}
            opts.sections.lualine_b = {}
            opts.sections.lualine_c = {
                gap(),
                capsule({ "mode", icon = "\u{f135}" }, "mode"),
                gap(),
                capsule(
                    { "branch", icon = "\u{e725}" },
                    { "Statement", "Keyword" }
                ),
                gap(),
                capsule(file_with_icon(), { "Function", "Identifier" }),
                diagnostics(),
            }
            opts.sections.lualine_x = append(extras, info_extras())
            vim.list_extend(opts.sections.lualine_x, {
                diff,
                capsule({
                    lsp_clients,
                    icon = "\u{f085}",
                    cond = function()
                        return lsp_clients() ~= ""
                    end,
                }, { "Type", "Special" }),
                gap(),
                capsule({ "progress" }, { "String", "DiagnosticOk" }),
                gap(),
                capsule({ "location" }, { "Constant", "Number" }),
                gap(),
            })
            opts.sections.lualine_y = {}
            opts.sections.lualine_z = {}
            return opts
        end,
    },
    -- flame-shaped separators burning into a transparent middle
    {
        name = "Flame",
        desc = "flame edges burning into the background",
        icon = "\u{f06d}",
        build = function(opts)
            local diff, extras = split_x(opts)
            opts.options.theme = auto_theme(transparent_middle)
            opts.options.section_separators =
                { left = "\u{e0c0}", right = "\u{e0c2}" }
            opts.options.component_separators =
                { left = "\u{e0c1}", right = "\u{e0c3}" }

            opts.sections.lualine_a = { { "mode", icon = "\u{f06d}" } }
            opts.sections.lualine_b = { { "branch", icon = "\u{e725}" } }
            opts.sections.lualine_c = {
                {
                    "filetype",
                    icon_only = true,
                    separator = "",
                    padding = { left = 2, right = 0 },
                },
                pretty_path(),
                diagnostics(),
            }
            opts.sections.lualine_x = append(extras, info_extras())
            table.insert(opts.sections.lualine_x, diff)
            opts.sections.lualine_y = { { "filetype", colored = false } }
            opts.sections.lualine_z = { "location" }
            return opts
        end,
    },
    -- 8-bit: pixelated edges, a gamepad and a scroll meter
    {
        name = "Pixel",
        desc = "8-bit edges, gamepad and a scroll meter",
        icon = "\u{f11b}",
        build = function(opts)
            local diff, extras = split_x(opts)
            opts.options.theme = auto_theme()
            opts.options.section_separators =
                { left = "\u{e0c6}", right = "\u{e0c7}" }
            opts.options.component_separators = ""

            opts.sections.lualine_a = { { "mode", icon = "\u{f11b}" } }
            opts.sections.lualine_b = { { "branch", icon = "\u{e725}" }, diff }
            opts.sections.lualine_c = {
                {
                    "filetype",
                    icon_only = true,
                    separator = "",
                    padding = { left = 1, right = 0 },
                },
                pretty_path(),
                diagnostics(),
            }
            opts.sections.lualine_x = append(extras, info_extras())
            opts.sections.lualine_y = {
                function()
                    return "%l/%L"
                end,
            }
            opts.sections.lualine_z = { scroll_bar }
            return opts
        end,
    },
    -- transparent bar where everything glows in the mode color
    {
        name = "Neon",
        desc = "everything glows in the mode color",
        icon = "\u{f0e7}",
        build = function(opts)
            local diff, extras = split_x(opts)
            opts.options.theme = auto_theme(transparent_middle)
            opts.options.section_separators = ""
            opts.options.component_separators = ""

            opts.sections.lualine_a = {}
            opts.sections.lualine_b = {}
            opts.sections.lualine_c = {
                {
                    "mode",
                    icon = "\u{f0e7}",
                    fmt = function(mode)
                        return mode .. "  │"
                    end,
                    color = fg_mode("bold"),
                },
                {
                    "branch",
                    icon = "\u{e725}",
                    fmt = function(branch)
                        return branch .. "  │"
                    end,
                    color = fg_mode("italic"),
                },
                {
                    "filetype",
                    icon_only = true,
                    separator = "",
                    padding = { left = 1, right = 0 },
                },
                pretty_path(),
                diagnostics(),
            }
            opts.sections.lualine_x = append(extras, info_extras())
            vim.list_extend(opts.sections.lualine_x, {
                diff,
                {
                    lsp_clients,
                    icon = "\u{f085}",
                    cond = function()
                        return lsp_clients() ~= ""
                    end,
                    fmt = function(names)
                        return names .. "  │"
                    end,
                    color = fg_mode(),
                },
                {
                    function()
                        return "%l:%v"
                    end,
                    color = fg_mode("bold"),
                },
                {
                    scroll_bar,
                    color = fg_mode(),
                    padding = { left = 1, right = 2 },
                },
            })
            opts.sections.lualine_y = {}
            opts.sections.lualine_z = {}
            return opts
        end,
    },
    -- frosted glass: translucent mode-tinted pills with glowing text
    {
        name = "Glass",
        desc = "frosted translucent pills with glowing text",
        icon = "\u{f0eb}",
        build = function(opts)
            local diff, extras = split_x(opts)
            opts.options.theme = auto_theme(mode_glass)
            opts.options.section_separators =
                { left = "\u{e0b4}", right = "\u{e0b6}" }
            opts.options.component_separators = ""

            opts.sections.lualine_a = {
                {
                    "mode",
                    icon = "\u{f0eb}",
                    separator = { left = "\u{e0b6}" },
                    padding = { left = 0, right = 1 },
                },
            }
            opts.sections.lualine_b = { { "branch", icon = "\u{e725}" }, diff }
            opts.sections.lualine_c = {
                {
                    "filetype",
                    icon_only = true,
                    separator = "",
                    padding = { left = 2, right = 0 },
                },
                pretty_path(),
                diagnostics(),
            }
            opts.sections.lualine_x = append(extras, info_extras())
            opts.sections.lualine_y = { "progress" }
            opts.sections.lualine_z = {
                {
                    "location",
                    separator = { right = "\u{e0b4}" },
                    padding = { left = 1, right = 0 },
                },
            }
            return opts
        end,
    },
    -- the whole bar is one deep band of the mode color
    {
        name = "Ribbon",
        desc = "a deep band of mode color, edge to edge",
        icon = "\u{f02e}",
        build = function(opts)
            local _, extras = split_x(opts)
            -- drop the extras' own colors (pink lazy updates etc.), they
            -- clash with the band, and use the band's text color instead
            extras = vim.tbl_map(function(component)
                if type(component) == "table" then
                    component = vim.tbl_extend("force", {}, component)
                    component.color = nil
                end
                return component
            end, extras)
            opts.options.theme = auto_theme(mode_ribbon)
            opts.options.section_separators =
                { left = "\u{e0b0}", right = "\u{e0b2}" }
            opts.options.component_separators =
                { left = "\u{e0b1}", right = "\u{e0b3}" }

            opts.sections.lualine_a = { { "mode", icon = "\u{f02e}" } }
            opts.sections.lualine_b = {
                { "branch", icon = "\u{e725}" },
                { "diff", colored = false },
            }
            opts.sections.lualine_c = {
                vim.tbl_extend(
                    "force",
                    file_with_icon(),
                    { color = { gui = "bold" } }
                ),
                vim.tbl_extend("force", diagnostics(), { colored = false }),
            }
            opts.sections.lualine_x = append(extras, info_extras())
            opts.sections.lualine_y = { "progress" }
            opts.sections.lualine_z = { "location" }
            return opts
        end,
    },
    -- oh-my-zsh robbyrussell prompt: ➜ project git:(main) ✗
    {
        name = "Prompt",
        desc = "a zsh prompt: ➜ project git:(main) ✗",
        icon = "\u{f120}",
        build = function(opts)
            local diff, extras = split_x(opts)
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
            opts.options.theme = auto_theme(transparent_middle)
            opts.options.section_separators = ""
            opts.options.component_separators = ""

            opts.sections.lualine_a = {}
            opts.sections.lualine_b = {}
            opts.sections.lualine_c = {
                {
                    function()
                        return "➜"
                    end,
                    color = fg_mode("bold"),
                },
                {
                    function()
                        return vim.fn.fnamemodify(LazyVim.root(), ":t")
                    end,
                    color = fg({ "DiagnosticInfo", "Special" }, "bold"),
                    padding = { left = 0, right = 1 },
                },
                {
                    function()
                        return "git:("
                    end,
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
                    function()
                        return ")"
                    end,
                    cond = in_git,
                    color = fg("Function", "bold"),
                    padding = { left = 0, right = 1 },
                },
                {
                    function()
                        return "✗"
                    end,
                    cond = dirty,
                    color = fg("DiagnosticWarn", "bold"),
                    padding = { left = 0, right = 1 },
                },
                pretty_path(),
                diagnostics(),
            }
            opts.sections.lualine_x = append(extras, info_extras())
            vim.list_extend(opts.sections.lualine_x, {
                diff,
                {
                    function()
                        return "[%l:%v]"
                    end,
                    color = fg("Comment"),
                },
                {
                    function()
                        return os.date("%R")
                    end,
                    color = fg("Comment", "italic"),
                    padding = { left = 0, right = 1 },
                },
            })
            opts.sections.lualine_y = {}
            opts.sections.lualine_z = {}
            return opts
        end,
    },
    -- the file sits in a glowing pill dead center, everything else
    -- is pushed to the edges
    {
        name = "Spotlight",
        desc = "your file in a glowing pill, dead center",
        icon = "\u{f005}",
        build = function(opts)
            local diff, extras = split_x(opts)
            opts.options.theme = auto_theme(transparent_middle)
            opts.options.section_separators = ""
            opts.options.component_separators = ""

            opts.sections.lualine_a = {}
            opts.sections.lualine_b = {}
            opts.sections.lualine_c = {
                {
                    "mode",
                    icon = "\u{f005}",
                    color = fg_mode("bold"),
                    padding = { left = 1, right = 1 },
                },
                { "branch", icon = "\u{e725}", color = fg("Comment") },
                {
                    function()
                        return "%="
                    end,
                },
                capsule(file_with_icon(), "mode"),
                diagnostics(),
            }
            opts.sections.lualine_x = append(extras, info_extras())
            vim.list_extend(opts.sections.lualine_x, {
                diff,
                { "location", color = fg("Comment") },
                {
                    scroll_bar,
                    color = fg_mode(),
                    padding = { left = 0, right = 1 },
                },
            })
            opts.sections.lualine_y = {}
            opts.sections.lualine_z = {}
            return opts
        end,
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
        build = function(opts)
            return pills(opts, "trapezoid", {
                icon = "\u{f1b2}",
                mode = "mode",
                branch = tinted("mode", 0.45),
                file = tinted("mode", 0.25),
                lsp = tinted("mode", 0.25),
                progress = tinted("mode", 0.45),
                location = "mode",
            })
        end,
    },
    -- upside-down trapezoids hanging like tabs, each its own color
    {
        name = "Tabs",
        desc = "rainbow tabs, wide at the top",
        icon = "\u{e0be}",
        build = function(opts)
            return pills(opts, "tab", {
                icon = "\u{f15b}",
                mode = "mode",
                branch = { "Statement", "Keyword" },
                file = { "Function", "Identifier" },
                lsp = { "Type", "Special" },
                progress = { "String", "DiagnosticOk" },
                location = { "Constant", "Number" },
            })
        end,
    },
    -- pointed hexagon pills, frosted versions of the rainbow colors
    {
        name = "Hexagon",
        desc = "frosted rainbow hexagons with pointed ends",
        icon = "\u{e0b2}",
        build = function(opts)
            return pills(opts, "hexagon", {
                icon = "\u{f121}",
                mode = "mode",
                branch = tinted({ "Statement", "Keyword" }, 0.3),
                file = tinted({ "Function", "Identifier" }, 0.3),
                lsp = tinted({ "Type", "Special" }, 0.3),
                progress = tinted({ "String", "DiagnosticOk" }, 0.3),
                location = tinted({ "Constant", "Number" }, 0.3),
            })
        end,
    },
}

local function lualine_style_index(name)
    for i, style in ipairs(lualine_styles) do
        if style.name == name then
            return i
        end
    end
end

local lualine_current = 1
do
    local f = io.open(style_state, "r")
    if f then
        lualine_current = lualine_style_index(vim.trim(f:read("*a") or "")) or 1
        f:close()
    end
end

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
    local original = lualine_current
    local confirmed = false
    local items = {}
    for i, style in ipairs(lualine_styles) do
        items[#items + 1] = {
            idx = i,
            text = style.name .. " " .. style.desc,
            style = style,
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
            lualine_current = item.idx
            lualine_apply(item.idx)

            local f = io.open(style_state, "w")
            if f then
                f:write(item.style.name)
                f:close()
            end

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
        return lualine_build(lualine_current)
    end,
    keys = {
        {
            "<leader>tl",
            lualine_pick_style,
            desc = "Select Lualine Style",
        },
    },
}

-- return {
--     "nvim-lualine/lualine.nvim",
--     enabled = true,
--     lazy = false,
--
--     opts = function(_, opts)
--         opts.options.component_separators = {
--             left = "",
--             right = "",
--         }
--
--         opts.options.section_separators = {
--             left = "",
--             right = "",
--         }
--
--         opts.sections.lualine_a = {
--             {
--                 "mode",
--             },
--         }
--
--         -- Git branch + buffers
--         opts.sections.lualine_b = {
--             {
--                 "branch",
--                 icon = "",
--             },
--             {
--                 "diff",
--                 symbols = {
--                     added = " ",
--                     modified = " ",
--                     removed = " ",
--                 },
--             },
--             {
--                 "buffers",
--                 mode = 0,
--                 show_filename_only = true,
--                 hide_filename_extension = false,
--                 show_modified_status = true,
--
--                 buffers_color = {
--                     active = "lualine_a_normal",
--                     inactive = "lualine_b_inactive",
--                 },
--
--                 symbols = {
--                     modified = " ●",
--                     alternate_file = "",
--                     directory = "",
--                 },
--             },
--         }
--
--         opts.sections.lualine_c[4] = {
--             LazyVim.lualine.pretty_path({
--                 filename_hl = "Bold",
--                 modified_hl = "MatchParen",
--                 directory_hl = "Conceal",
--             }),
--         }
--
--         if vim.g.lualine_info_extras == true then
--             table.insert(opts.sections.lualine_x, 2, { "lsp_status" })
--             table.insert(opts.sections.lualine_x, 2, formatter)
--             table.insert(opts.sections.lualine_x, 2, linter)
--         end
--
--         opts.sections.lualine_y = {
--             "progress",
--         }
--
--         opts.sections.lualine_z = {
--             {
--                 "location",
--                 separator = "",
--             },
--             {
--                 padding = {
--                     left = 0,
--                     right = 1,
--                 },
--             },
--         }
--
--         opts.extensions = false
--     end,
-- }
-- return {
--     "nvim-lualine/lualine.nvim",
--
--     opts = function(_, opts)
--         -- Eviline config for lualine
--         -- Author: shadmansaleh
--         -- Credit: glepnir
--
--         -- Get colors from the currently active colorscheme
--         local function hl_color(group, attr, fallback)
--             local hl = vim.api.nvim_get_hl(0, {
--                 name = group,
--                 link = true,
--             })
--
--             local value = hl[attr]
--
--             if value then
--                 return string.format("#%06x", value)
--             end
--
--             return fallback
--         end
--
--         local colors = {
--             bg = hl_color("Normal", "bg", "#202328"),
--             fg = hl_color("Normal", "fg", "#bbc2cf"),
--
--             yellow = hl_color("DiagnosticWarn", "fg", "#ECBE7B"),
--             cyan = hl_color("DiagnosticInfo", "fg", "#008080"),
--             darkblue = hl_color("NormalFloat", "bg", "#081633"),
--             green = hl_color("DiagnosticOk", "fg", "#98be65"),
--             orange = hl_color("WarningMsg", "fg", "#FF8800"),
--             violet = hl_color("Statement", "fg", "#a9a1e1"),
--             magenta = hl_color("Constant", "fg", "#c678dd"),
--             blue = hl_color("Function", "fg", "#51afef"),
--             red = hl_color("DiagnosticError", "fg", "#ec5f67"),
--         }
--
--         local conditions = {
--             buffer_not_empty = function()
--                 return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
--             end,
--
--             hide_in_width = function()
--                 return vim.fn.winwidth(0) > 80
--             end,
--
--             check_git_workspace = function()
--                 local filepath = vim.fn.expand("%:p:h")
--                 local gitdir = vim.fn.finddir(".git", filepath .. ";")
--
--                 return gitdir and #gitdir > 0 and #gitdir < #filepath
--             end,
--         }
--
--         -- Keep LazyVim's Lualine setup but replace the sections
--         opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
--             component_separators = "",
--             section_separators = "",
--
--             -- Follow the active colorscheme
--             theme = "auto",
--         })
--
--         -- Completely clean sections
--         opts.sections = {
--             lualine_a = {},
--             lualine_b = {},
--             lualine_c = {},
--             lualine_x = {},
--             lualine_y = {},
--             lualine_z = {},
--         }
--
--         opts.inactive_sections = {
--             lualine_a = {},
--             lualine_b = {},
--             lualine_c = {},
--             lualine_x = {},
--             lualine_y = {},
--             lualine_z = {},
--         }
--
--         local function ins_left(component)
--             table.insert(opts.sections.lualine_c, component)
--         end
--
--         local function ins_right(component)
--             table.insert(opts.sections.lualine_x, component)
--         end
--
--         ---------------------------------------------------------------------------
--         -- LEFT
--         ---------------------------------------------------------------------------
--
--         ins_left({
--             function()
--                 return "▊"
--             end,
--
--             color = { fg = colors.blue },
--
--             padding = {
--                 left = 0,
--                 right = 1,
--             },
--         })
--
--         ins_left({
--             -- Mode icon
--             function()
--                 return ""
--             end,
--
--             color = function()
--                 local mode_color = {
--                     n = colors.red,
--                     i = colors.green,
--                     v = colors.blue,
--                     [""] = colors.blue,
--                     V = colors.blue,
--                     c = colors.magenta,
--                     no = colors.red,
--                     s = colors.orange,
--                     S = colors.orange,
--                     [""] = colors.orange,
--                     ic = colors.yellow,
--                     R = colors.violet,
--                     Rv = colors.violet,
--                     cv = colors.red,
--                     ce = colors.red,
--                     r = colors.cyan,
--                     rm = colors.cyan,
--                     ["r?"] = colors.cyan,
--                     ["!"] = colors.red,
--                     t = colors.red,
--                 }
--
--                 return {
--                     fg = mode_color[vim.fn.mode()] or colors.fg,
--                 }
--             end,
--
--             padding = {
--                 right = 1,
--             },
--         })
--
--         ins_left({
--             "filesize",
--
--             cond = conditions.buffer_not_empty,
--         })
--
--         ins_left({
--             "branch",
--
--             icon = "",
--
--             color = {
--                 fg = colors.violet,
--                 gui = "bold",
--             },
--         })
--
--         ins_left({
--             "filename",
--
--             cond = conditions.buffer_not_empty,
--
--             color = {
--                 fg = colors.magenta,
--                 gui = "bold",
--             },
--         })
--
--         ins_left({
--             "location",
--         })
--
--         ins_left({
--             "progress",
--
--             color = {
--                 fg = colors.fg,
--                 gui = "bold",
--             },
--         })
--
--         ins_left({
--             "diagnostics",
--
--             sources = {
--                 "nvim_diagnostic",
--             },
--
--             symbols = {
--                 error = " ",
--                 warn = " ",
--                 info = " ",
--             },
--
--             diagnostics_color = {
--                 error = {
--                     fg = colors.red,
--                 },
--
--                 warn = {
--                     fg = colors.yellow,
--                 },
--
--                 info = {
--                     fg = colors.cyan,
--                 },
--             },
--         })
--
--         ---------------------------------------------------------------------------
--         -- CENTER
--         ---------------------------------------------------------------------------
--
--         ins_left({
--             function()
--                 return "%="
--             end,
--         })
--
--         ins_right({
--             -- LSP server name
--             function()
--                 local msg = "No Active Lsp"
--
--                 local buf_ft =
--                     vim.api.nvim_get_option_value("filetype", { buf = 0 })
--
--                 -- Only get clients attached to the current buffer
--                 local clients = vim.lsp.get_clients({
--                     bufnr = 0,
--                 })
--
--                 if next(clients) == nil then
--                     return msg
--                 end
--
--                 for _, client in ipairs(clients) do
--                     local filetypes = client.config.filetypes
--
--                     if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
--                         return client.name
--                     end
--                 end
--
--                 return msg
--             end,
--
--             icon = " :",
--
--             color = {
--                 fg = colors.fg,
--                 gui = "bold",
--             },
--         })
--
--         ---------------------------------------------------------------------------
--         -- RIGHT
--         ---------------------------------------------------------------------------
--
--         ins_right({
--             "o:encoding",
--
--             fmt = string.upper,
--
--             cond = conditions.hide_in_width,
--
--             color = {
--                 fg = colors.green,
--                 gui = "bold",
--             },
--         })
--
--         ins_right({
--             "fileformat",
--
--             fmt = string.upper,
--
--             icons_enabled = false,
--
--             color = {
--                 fg = colors.green,
--                 gui = "bold",
--             },
--         })
--
--         ins_right({
--             "diff",
--
--             symbols = {
--                 added = " ",
--                 modified = "󰏬 ",
--                 removed = " ",
--             },
--
--             diff_color = {
--                 added = {
--                     fg = colors.green,
--                 },
--
--                 modified = {
--                     fg = colors.orange,
--                 },
--
--                 removed = {
--                     fg = colors.red,
--                 },
--             },
--
--             cond = conditions.hide_in_width,
--         })
--
--         ins_right({
--             function()
--                 return "▊"
--             end,
--
--             color = {
--                 fg = colors.blue,
--             },
--
--             padding = {
--                 left = 1,
--             },
--         })
--
--         return opts
--     end,
-- }
