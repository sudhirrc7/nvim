return {
    "saghen/blink.cmp",
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
            menu = {
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
                                return (source_names[ctx.source_name] or "[") .. ctx.source_name .. "]"
                            end,
                            highlight = "CmpItemMenu",
                        },
                    },
                },
            },

            documentation = {
                window = {
                    border = "rounded",
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
                },
            },
        },
    },
}
