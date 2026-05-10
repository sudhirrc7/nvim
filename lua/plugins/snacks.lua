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
            enabled = false,
            style = "fancy",
        },
        terminal = {
            win = {
                position = "float",
            },
        },
        picker = {
            exclude = { -- add folder names here to exclude
                ".git",
                "node_modules",
            },
            layout = "telescope",
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
                    actions = {
                        float_preview = function(picker)
                            local item = picker:current()

                            if not item or not item.file then
                                return
                            end

                            local buf = vim.api.nvim_create_buf(false, true)

                            vim.api.nvim_buf_call(buf, function()
                                vim.cmd(
                                    "silent read "
                                        .. vim.fn.fnameescape(item.file)
                                )
                                vim.cmd("0d_")
                            end)

                            vim.bo[buf].filetype = vim.filetype.match({
                                filename = item.file,
                            }) or ""
                            vim.bo[buf].buftype = "nofile"
                            vim.bo[buf].bufhidden = "wipe"
                            vim.bo[buf].swapfile = false
                            vim.bo[buf].modifiable = false

                            local win = require("snacks.win")({
                                buf = buf,
                                style = "float",
                                border = "rounded",
                                width = 0.8,
                                height = 0.8,
                            })

                            vim.wo[win.win].number = true
                            vim.wo[win.win].relativenumber = false
                            vim.wo[win.win].signcolumn = "yes"
                            vim.wo[win.win].cursorline = true
                            vim.wo[win.win].wrap = false
                        end,
                    },
                    win = {
                        list = {
                            keys = {
                                ["P"] = "float_preview",
                            },
                        },
                    },
                    layout = {
                        preview = false,
                        layout = {
                            -- title = "explorer",
                            -- title_pos = "center",
                            width = 30,
                            min_width = 30,
                            height = 0,
                            position = "left",
                            border = "rounded",
                            backdrop = false,
                            box = "vertical",
                            {
                                win = "input",
                                height = 1,
                                border = "bottom",
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
            enabled = false,
            doc = {
                inline = false,
            },
        },
        explorer = {
            replace_netrw = true, -- Replace netrw with the snacks explorer
        },
        indent = {
            enabled = true,
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
  -- stylua: ignore
  keys = {
    { "<leader>fz", function() Snacks.picker.zoxide({
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
    }) end, desc = "Zoxide" },
    { "<leader>gb", function() Snacks.picker.git_log_line() end, desc = "Blame Line"},
    { "<leader>cil", function() Snacks.picker.lsp_config() end, desc = "Lsp"},
    { "<leader>sn", function() Snacks.picker.notifications() end, desc = "Notifications" },
    { "<leader>st", function() Snacks.picker.treesitter() end, desc = "Treesitter" },
    { "<leader>go", function() Snacks.gitbrowse() end, desc = "Git Open Line" },
  },
}
