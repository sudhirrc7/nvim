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
            style = "compact",
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
                explorer = {
                    icons = {
                        tree = {
                            vertical = "  ",
                            middle = "  ",
                            last = "  ",
                        },
                    },
                    layout = {
                        cycle = false,
                        auto_hide = { "input" },
                        preview = false,
                        layout = {
                            -- relative = "editor",
                            -- row = 0,
                            -- col = 0,
                            --
                            -- width = 30,
                            -- height = 0,
                            --
                            -- border = "rounded",
                            -- backdrop = true,
                            -- box = "vertical",

                            -- this is another style of the layout here
                            width = 30,
                            min_width = 30,
                            height = 0,
                            position = "left",
                            border = "single", -- options are single|double|solid|shadow|rounded|bold
                            backdrop = true,
                            box = "vertical",
                            {
                                win = "input",
                                height = 1,
                                border = "none",
                                title = "{title} {live} {flags}",
                                title_pos = "center",
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
            -- indent = {
            --     char = "┊",
            -- },
            -- scope = {
            --     enabled = true,
            --     char = "┊",
            -- },
        },
        scroll = {
            animate = {
                duration = { step = 10, total = 100 },
            },
        },
    },
    keys = {
        {
            "<leader>fz",
            function()
                Snacks.picker.zoxide({
                    finder = "files_zoxide",
                    format = "file",
                    -- confirm = "load_session" -- Disable loading session by default.
                    confirm = function(picker, item)
                        picker:close()
                        if item then
                            Snacks.picker.files({ cwd = item.text })
                        end
                        local dir = item.file
                        vim.fn.chdir(dir)
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
