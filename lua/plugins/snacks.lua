-- Snacks explorer appearances, cycled with <leader>te.
-- The chosen style is remembered across sessions.
local explorer_state = vim.fn.stdpath("state") .. "/snacks_explorer_style"

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
                { win = "preview", title = "{preview}", height = 0.4, border = "top" },
            },
        },
    },
    -- centered ranger-style popup with a live preview on the right
    {
        name = "Spotlight",
        icon = "",
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
                { win = "preview", title = " {preview} ", title_pos = "center", border = "rounded" },
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
                height = 0.92,
                backdrop = 40,
                border = "double",
                title = " 󰉋 {title} {live} {flags} ",
                title_pos = "left",
                box = "vertical",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
                { win = "preview", title = " {preview} ", height = 0.45, border = "top" },
            },
        },
    },
    -- borderless dock on the right, search always visible, P peeks in the main window
    {
        name = "Dock",
        icon = "",
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
                { win = "input", height = 1, border = "vpad", title = "{title} {live} {flags}", title_pos = "left" },
                { win = "list", border = "none" },
                { win = "preview", title = "{preview}", height = 0.4, border = "top" },
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
                { win = "preview", title = " {preview} ", title_pos = "right", border = "left" },
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
                { win = "input", height = 1, border = "vpad", title = "{live} {flags}", title_pos = "right" },
                { win = "list", border = "hpad" },
                { win = "preview", title = " {preview} ", height = 0.5, border = "top" },
            },
        },
    },
}

local function explorer_style_index(name)
    for i, style in ipairs(explorer_styles) do
        if style.name == name then
            return i
        end
    end
end

local explorer_current = 1
do
    local f = io.open(explorer_state, "r")
    if f then
        explorer_current = explorer_style_index(vim.trim(f:read("*a") or "")) or 1
        f:close()
    end
end

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
        layout = vim.deepcopy(style.layout),
    }
end

local function explorer_cycle_style()
    explorer_current = explorer_current % #explorer_styles + 1
    local style = explorer_styles[explorer_current]
    Snacks.config.picker.sources.explorer = explorer_source(explorer_current)

    local f = io.open(explorer_state, "w")
    if f then
        f:write(style.name)
        f:close()
    end

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
        ("%s  %s  (%d/%d)"):format(style.icon, style.name, explorer_current, #explorer_styles),
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
                explorer = explorer_source(explorer_current),
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
