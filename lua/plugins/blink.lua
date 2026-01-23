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
        completion = {
            documentation = {
                window = {
                    border = "rounded",
                },
            },
        },
    },
}
