return {
    "necrom4/convy.nvim",
    cmd = { "Convy", "ConvySeparator" },
    opts = {
        notifications = true,
        separator = " ",
        window = {
            blend = 25,
            border = "rounded",
        },
    },
    keys = {
        -- example keymaps
        {
            "<leader>ic",
            ":Convy<CR>",
            desc = "Convert (interactive selection)",
            mode = { "n", "v" },
            silent = true,
        },
        {
            "<leader>id",
            ":Convy auto dec<CR>",
            desc = "Convert to decimal",
            mode = { "n", "v" },
            silent = true,
        },
        {
            "<leader>is",
            ":ConvySeparator<CR>",
            desc = "Set convertion separator (visual selection)",
            mode = { "v" },
            silent = true,
        },
    },
}
