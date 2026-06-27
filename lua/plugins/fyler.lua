return {
    "FylerOrg/fyler.nvim",
    enabled = true,
    lazy = false,
    opts = {
        integrations = { icon = "mini_icons" },
        -- integrations = { icon = "vim_nerdfont`" },
        extensions = { git = { enabled = true, inline = false } },
        ui = {
            hidden_items = {
                -- Toggleable pre-defined switches (e.g. 'dotfiles' to hide files starting with a dot).
                switches = {},
                -- Toggleable patterns (Lua patterns matched against the full path).
                patterns = {},
                -- Always visible items matching these patterns, even if they would normally be hidden.
                always_visible = {},
                -- Always hide items matching these patterns, even if they would normally be visible.
                always_hidden = {},
            },
            -- Whether to draw indent guides at each depth level.
            indent_guides = false,
        },
    },
}
