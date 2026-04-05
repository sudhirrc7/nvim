-- If you are using Packer
return {
    "EdenEast/nightfox.nvim",
    lazy = false,
    enabled = false,
    priority = 1000,
    config = function()
        local transparent_groups = {
            "NormalFloat",
            "FloatBorder",
            "FloatTitle",
            "Pmenu",
            -- "PmenuSel",
            "PmenuSbar",
            -- "PmenuThumb",
            "CmpPmenu",
            "CmpPmenuBorder",
            "CmpDoc",
            "CmpDocBorder",
            "SnacksNormal",
            "SnacksPicker",
            "SnacksPickerInput",
            "SnacksPickerList",
            "SnacksPickerPreview",
            "SnacksPickerBox",
            "SnacksPickerBorder",
            "SnacksPickerTitle",
        }

        local function apply_transparent_floats()
            for _, group in ipairs(transparent_groups) do
                vim.api.nvim_set_hl(0, group, { bg = "NONE" })
            end
        end

        require("nightfox").setup({
            options = {
                transparent = false,
                styles = { -- Style to be applied to different syntax groups
                    comments = "italic", -- Value is any valid attr-list value `:help attr-list`
                    conditionals = "NONE",
                    constants = "NONE",
                    functions = "italic",
                    keywords = "italic",
                    numbers = "NONE",
                    operators = "NONE",
                    strings = "NONE",
                    types = "italic",
                    variables = "NONE",
                },
            },
            groups = {
                all = {
                    NormalFloat = { bg = "NONE" },
                    FloatBorder = { bg = "NONE" },
                    FloatTitle = { bg = "NONE" },
                    Pmenu = { bg = "NONE" },
                    -- PmenuSel = { bg = "NONE" },
                    PmenuSbar = { bg = "NONE" },
                    -- PmenuThumb = { bg = "NONE" },
                },
            },
        })

        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "nordfox",
            callback = apply_transparent_floats,
        })

        if vim.g.colors_name == "nordfox" then
            apply_transparent_floats()
        end

        -- vim.cmd.colorscheme("nordfox")
    end,
}
