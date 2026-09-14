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

return {
    "nvim-lualine/lualine.nvim",
    enabled = true,
    lazy = false,
    opts = function(_, opts)
        -- opts.options.component_separators = { left = "", right = "" }
        -- opts.options.section_separators = { left = "", right = "" }

        opts.sections.lualine_a = {
            {
                "mode",
                -- icon = "",
                -- fmt = function(text, context)
                --     return string.sub(text, 1, 3)
                -- end,
            },
        }
        opts.sections.lualine_c[4] = {
            LazyVim.lualine.pretty_path({
                filename_hl = "Bold",
                modified_hl = "MatchParen",
                directory_hl = "Conceal",
            }),
        }

        if vim.g.lualine_info_extras == true then
            table.insert(opts.sections.lualine_x, 2, { "lsp_status" })
            table.insert(opts.sections.lualine_x, 2, formatter)
            table.insert(opts.sections.lualine_x, 2, linter)
        end

        opts.sections.lualine_y = { "progress" }
        opts.sections.lualine_z = {
            { "location", separator = "" },
            {
                -- function()
                --     return ""
                -- end,
                padding = { left = 0, right = 1 },
            },
        }
        opts.extensions = false
    end,
}
--
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
