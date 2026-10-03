-- Snacks explorer appearances, cycled with <leader>te.
-- The chosen style is remembered across sessions.

local explorer_styles = {
    -- the original left sidebar
    {
        name = "Classic",
        icon = "󰙅",
        auto_close = false,
        layout = {
            cycle = false,
            auto_hide = { "input" },
            preview = false,
            layout = {
                width = 30,
                min_width = 30,
                height = 0,
                position = "left",
                border = "single", -- options are single|double|solid|shadow|rounded|bold
                title = "{title} {live} {flags}",
                title_pos = "center",
                box = "vertical",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
                {
                    win = "preview",
                    title = "{preview}",
                    height = 0.4,
                    border = "top",
                },
            },
        },
    },
    -- centered ranger-style popup with a live preview on the right
    {
        name = "Spotlight",
        icon = "\u{f002}",
        auto_close = true,
        layout = {
            cycle = true,
            preview = true,
            layout = {
                position = "float",
                width = 0.8,
                min_width = 100,
                height = 0.8,
                min_height = 20,
                backdrop = 60,
                border = "none",
                box = "horizontal",
                {
                    box = "vertical",
                    width = 0.35,
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
    -- floating drawer that slides over the editor from the left edge
    {
        name = "Drawer",
        icon = "󰉋",
        auto_close = true,
        layout = {
            cycle = true,
            auto_hide = { "input" },
            preview = false,
            layout = {
                position = "float",
                row = 1,
                col = 1,
                width = 40,
                min_width = 40,
                height = 0.95,
                backdrop = 40,
                border = "double",
                title = " 󰉋 {title} {live} {flags} ",
                title_pos = "left",
                box = "vertical",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
                {
                    win = "preview",
                    title = " {preview} ",
                    height = 0.45,
                    border = "top",
                },
            },
        },
    },
    -- borderless dock on the right, search always visible, P peeks in the main window
    {
        name = "Dock",
        icon = "\u{f0db}",
        auto_close = false,
        layout = {
            cycle = false,
            preview = "main",
            hidden = { "preview" },
            layout = {
                width = 34,
                min_width = 34,
                height = 0,
                position = "right",
                border = "left",
                box = "vertical",
                {
                    win = "input",
                    height = 1,
                    border = "vpad",
                    title = "{title} {live} {flags}",
                    title_pos = "left",
                },
                { win = "list", border = "none" },
                {
                    win = "preview",
                    title = "{preview}",
                    height = 0.4,
                    border = "top",
                },
            },
        },
    },
    -- quake-console style: drops down from the top edge, full width, tree + preview side by side
    {
        name = "Quake",
        icon = "󱞣",
        auto_close = true,
        layout = {
            cycle = true,
            preview = true,
            layout = {
                position = "float",
                row = 0,
                width = 0,
                height = 0.5,
                min_height = 18,
                backdrop = 50,
                border = "bold",
                title = " 󱞣 {title} {live} {flags} ",
                title_pos = "center",
                box = "horizontal",
                {
                    box = "vertical",
                    width = 0.3,
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
    -- focus mode: a slim padded column in the middle of a heavily dimmed screen
    {
        name = "Zen",
        icon = "󰚀",
        auto_close = true,
        layout = {
            cycle = true,
            preview = false,
            layout = {
                position = "float",
                width = 46,
                min_width = 46,
                height = 0.75,
                min_height = 20,
                backdrop = 90,
                border = "solid",
                title = " 󰚀 {title} ",
                title_pos = "center",
                box = "vertical",
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
    -- nvim-tree float look-alike: top-left popup, no title, / arrows before folders
    {
        name = "Tree",
        icon = "\u{f0e8}",
        auto_close = true,
        format = function(item, picker)
            local ret = Snacks.picker.format.file(item, picker)
            if not item.parent then
                return ret -- root line, like nvim-tree's "~/.."
            end
            for i, seg in ipairs(ret) do
                if seg[2] == "SnacksPickerTree" then
                    local arrow = not item.dir and "  " or item.open and "\u{f47c} " or "\u{f460} "
                    table.insert(ret, i + 1, { arrow, "SnacksPickerTree" })
                    break
                end
            end
            return ret
        end,
        layout = {
            cycle = false,
            auto_hide = { "input" },
            preview = false,
            layout = {
                position = "float",
                row = 1,
                col = 1,
                width = 0.35,
                min_width = 40,
                max_width = 70,
                height = 32,
                backdrop = false,
                border = "rounded",
                box = "vertical",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
                {
                    win = "preview",
                    title = " {preview} ",
                    height = 0.45,
                    border = "top",
                },
            },
        },
    },
}

local explorer = require("config.util").styles(
    "snacks_explorer_style",
    explorer_styles
)

-- builds the `picker.sources.explorer` config for a style
local function explorer_source(idx)
    local style = explorer_styles[idx]
    return {
        icons = {
            tree = {
                vertical = "  ",
                middle = "  ",
                last = "  ",
            },
        },
        -- floating styles close themselves once a file is opened
        auto_close = style.auto_close,
        jump = { close = style.auto_close },
        format = style.format or "file",
        layout = vim.deepcopy(style.layout),
    }
end

local function explorer_cycle_style()
    local style = explorer.next()
    Snacks.config.picker.sources.explorer = explorer_source(explorer.index)

    -- reopen any visible explorer so the new style applies right away
    local open = Snacks.picker.get({ source = "explorer" })
    if #open > 0 then
        local cwd = open[1]:cwd()
        for _, picker in ipairs(open) do
            picker:close()
        end
        vim.schedule(function()
            Snacks.explorer({ cwd = cwd })
        end)
    end

    Snacks.notify(
        ("%s  %s  (%d/%d)"):format(
            style.icon,
            style.name,
            explorer.index,
            #explorer_styles
        ),
        { title = "Explorer style" }
    )
end

return {
    "folke/snacks.nvim",
    opts = {
        dashboard = {
            enabled = true,
            preset = {
                -- keys = {},
                header = [[
                                                                   
      ████ ██████           █████      ██                    
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
        ]],
            },
        },
        lazygit = {
            configure = false,
            win = {
                width = 0,
                height = 0,
            },
        },
        notifier = {
            enabled = true,
            style = "minimal",
            top_down = false,
        },
        -- terminal = {
        --     win = {
        --         position = "float",
        --     },
        -- },
        picker = {
            exclude = { -- add folder names here to exclude
                ".git",
                "node_modules",
            },
            layout = "default",

            ---- this one modifies the default telescope setup
            -- reverse = false,

            previewers = {
                git = {
                    builtin = false,
                },
            },
            matcher = {
                frecency = true,
            },
            sources = {
                explorer = explorer_source(explorer.index),
            },
            -- layouts = {
            --   default = {
            --     layout = {
            --       box = "horizontal",
            --       width = 0,
            --       height = 0,
            --       {
            --         box = "vertical",
            --         border = "rounded",
            --         title = "{title} {live} {flags}",
            --         { win = "input", height = 1, border = "bottom" },
            --         { win = "list", border = "none" },
            --       },
            --       { win = "preview", title = "{preview}", border = "rounded", width = 0.65 },
            --     },
            --   },
            -- },
            -- win = {
            --   input = {
            --     keys = {
            --       ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
            --       ["<a-j>"] = { "list_scroll_down", mode = { "i", "n" } },
            --       ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            --       ["<a-k>"] = { "list_scroll_up", mode = { "i", "n" } },
            --     },
            --   },
            -- },
        },
        image = {
            enabled = true,
            doc = {
                enabled = false,
                inline = false,
            },
        },
        explorer = {
            replace_netrw = true, -- Replace netrw with the snacks explorer
        },
        indent = {
            enabled = false,
            indent = {
                char = "┊",
            },
            scope = {
                enabled = true,
                char = "┊",
            },
        },
        scroll = {
            animate = {
                duration = { step = 10, total = 100 },
            },
        },
    },
    keys = {
        {
            "<leader>te",
            explorer_cycle_style,
            desc = "Toggle Explorer Style",
        },
        {
            "<leader>fz",
            function()
                Snacks.picker.zoxide({
                    finder = "files_zoxide",
                    format = "file",
                    -- confirm = "load_session" -- Disable loading session by default.
                    confirm = function(picker, item)
                        picker:close()
                        if not item then
                            return
                        end
                        Snacks.picker.files({ cwd = item.text })
                        vim.fn.chdir(item.file)
                    end,
                    win = {
                        preview = {
                            minimal = true,
                        },
                    },
                })
            end,
            desc = "Zoxide",
        },
        {
            "<leader>gb",
            function()
                Snacks.picker.git_log_line()
            end,
            desc = "Blame Line",
        },
        {
            "<leader>cil",
            function()
                Snacks.picker.lsp_config()
            end,
            desc = "Lsp",
        },
        {
            "<leader>in",
            function()
                Snacks.picker.notifications()
            end,
            desc = "Notifications",
        },
        {
            "<leader>it",
            function()
                Snacks.picker.treesitter({ layout = "default" })
            end,
            desc = "Treesitter",
        },
        {
            "<leader>go",
            function()
                Snacks.gitbrowse()
            end,
            desc = "Git Open Line",
        },
    },
}
