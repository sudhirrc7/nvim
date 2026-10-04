-- All colorschemes except catppuccin (the default, see catppuccin.lua).
-- Everything here is lazy: lazy.nvim loads a theme the moment it is picked
-- with `:colorscheme` or <leader>uC, so none of them slow down startup.
-- The last picked theme is restored on startup (config/lazy.lua).
-- Leave each theme's own transparency off: <leader>t1 (config/transparency.lua)
-- makes any of them transparent.

-- shared by the folke-style themes (tokyonight, solarized-osaka): blue
-- window separators, transparent sidebars and floats
local function blue_separator(highlights, colors)
    highlights.WinSeparator = { fg = colors.blue }
end
local function transparent_panels(styles)
    return vim.tbl_extend(
        "force",
        { sidebars = "transparent", floats = "transparent" },
        styles or {}
    )
end

return {
    -- Local classic DOS / Far Manager blue theme: `farblue` / `farblue-midnight`
    {
        dir = "~/personal/farblue.nvim",
        name = "farblue.nvim",
        opts = {
            -- variant = "classic", -- "classic" | "midnight"
            -- classic_selection = true, -- Far style cyan selection bar
            -- styles = { comments = { italic = true } },
        },
    },

    -- Local neon-on-black theme with prism.el style depth colours: `neonprism`
    -- (`:NeonPrism toggle` switches the depth colouring off and on)
    {
        dir = "~/personal/neonprism.nvim",
        name = "neonprism.nvim",
        opts = {
            -- prism = { enabled = true, exclude = { "markdown", ... } },
        },
    },

    -- Local Poimandres with the colours of the original VS Code theme:
    -- `poimandres` / `poimandres-storm` / `poimandres-dark`
    {
        dir = "~/personal/poimandres.nvim",
        name = "poimandres.nvim",
        opts = {
            -- variant = "main", -- "main" | "storm" | "dark"
            -- styles = { comments = { italic = false } },
        },
    },

    {
        "Aejkatappaja/cendre",
        opts = {
            transparent = false,
            background = "hard", -- "hard" | "medium" | "soft"
            italic_virtual_text = false,
            italic_comments = false,
        },
    },

    {
        "scottmckendry/cyberdream.nvim",
        opts = {
            transparent = false,
            cache = true,
            borderless_pickers = true,
            italic_comments = false,
            colors = {
                -- Override colors for both light and dark variants
                bg = "#000000",
            },
        },
    },

    {
        "ellisonleao/gruvbox.nvim",
        opts = function()
            local contrast = "hard" -- can be "hard", "soft" or empty string
            local p = require("gruvbox").palette
            -- the editor background for the chosen contrast
            local bg = ({ hard = p.dark0_hard, soft = p.dark0_soft })[contrast]
                or p.dark0
            return {
                transparent_mode = false,
                invert_selection = false,
                strikethough = true,
                contrast = contrast,
                dim_inactive = false,
                italic = {
                    strings = false,
                    emphasis = false,
                    comments = false,
                    operators = true,
                    folds = false,
                },
                overrides = {
                    CursorLineNr = { bg = "NONE" },
                    -- blend floats (blink docs/borders, which-key, hover) into
                    -- the editor like gruvbox-material, instead of grey boxes
                    NormalFloat = { fg = p.light1, bg = bg },
                    FloatBorder = { fg = p.gray, bg = bg },
                },
            }
        end,
    },
    {
        "sainnhe/gruvbox-material",
        config = function()
            vim.g.gruvbox_material_transparent_background = 0
            vim.g.gruvbox_material_enable_bold = 1
            vim.g.gruvbox_material_enable_italic = 0
            vim.g.gruvbox_material_float_style = "blend"
            vim.g.gruvbox_material_ui_contrast = "high"
            vim.g.gruvbox_material_menu_selection_background = "aqua"
            vim.g.gruvbox_material_background = "hard"
            -- vim.g.gruvbox_material_visual = "reverse"
            -- vim.g.gruvbox_material_sign_column_background = "grey"
            vim.g.gruvbox_material_spell_foreground = "colored"
            -- vim.g.gruvbox_material_diagnostic_text_highlight = 1
            vim.g.gruvbox_material_diagnostic_line_highlight = 1
            vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
            vim.g.gruvbox_material_better_performance = 1
        end,
    },
    {
        "sainnhe/everforest",
        config = function()
            vim.g.everforest_enable_italic = true
            vim.g.everforest_disable_italic_comment = 0
            vim.g.everforest_background = "hard"
            vim.g.everforest_float_style = "blend"
            vim.g.everforest_diagnostic_line_highlight = 1
            vim.g.everforest_diagnostic_virtual_text = "colored"
        end,
    },

    {
        "rebelot/kanagawa.nvim",
        opts = {
            background = {
                dark = "dragon",
                light = "lotus",
            },
            commentStyle = { italic = false, bold = false },
            functionStyle = { italic = false, bold = false },
            keywordStyle = { italic = false, bold = false },
            statementStyle = { bold = false, italic = false },
            typeStyle = { italic = false, bold = false },
            transparent = false,
            overrides = function(colors)
                local theme = colors.theme
                return {
                    WinSeparator = { fg = theme.ui.fg_dim, bg = "none" },
                    NormalFloat = { bg = "none" },
                    FloatBorder = { bg = "none" },
                    FloatTitle = { bg = "none" },
                    NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
                    LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
                    MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
                    Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
                    PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
                    PmenuSbar = { bg = theme.ui.bg_m1 },
                    PmenuThumb = { bg = theme.ui.bg_p2 },
                }
            end,
            colors = {
                palette = {
                    -- sumiInk0 = "#000000",
                    -- fujiWhite = "#FFFFFF",
                },
                theme = {
                    all = { ui = { bg_gutter = "none" } },
                    dragon = { ui = { float = { bg = "none" } } },
                },
            },
        },
    },

    { "wtfox/luna.nvim", opts = {} },
    { "xero/miasma.nvim" },
    { "nvim-mini/mini.hues" },
    { "wnkz/monoglow.nvim", opts = {} },
    { "dgox16/oldworld.nvim" },

    {
        "rose-pine/neovim",
        name = "rose-pine",
        opts = {
            dim_inactive_windows = true,
            extend_background_behind_borders = false,
            highlight_groups = {
                Visual = { fg = "base", bg = "#c4a7e7", inherit = false },
                StatusLine = { fg = "none", bg = "none" },
                NormalFloat = { bg = "none" },
            },
            styles = {
                bold = true,
                italic = false,
                transparency = false,
            },
            palette = {
                main = { pine = "#3e8fb0" },
                moon = { base = "#141415" },
            },
        },
        keys = {
            {
                "<leader>iz",
                function()
                    local base_colors = {
                        "#1A1A1A",
                        "#141415",
                        "#181616",
                        "#000000",
                        "#232136",
                        "#030200",
                        "#242425",
                    }
                    vim.g.rose_pine_base_index = (
                        vim.g.rose_pine_base_index or 1
                    )
                            % #base_colors
                        + 1
                    local base = base_colors[vim.g.rose_pine_base_index]
                    require("rose-pine").setup({
                        palette = { moon = { base = base } },
                    })
                    vim.cmd.colorscheme("rose-pine-moon")
                    vim.notify("Rose Pine base: " .. base)
                end,
                desc = "Rose Pine: Cycle base color",
            },
        },
    },

    {
        "craftzdog/solarized-osaka.nvim",
        opts = {
            on_highlights = blue_separator,
            transparent = false,
            styles = transparent_panels(),
        },
    },

    { "rezniqov/soviet.nvim", opts = {} },
    { "srcery-colors/srcery-vim" },

    {
        "folke/tokyonight.nvim",
        opts = {
            on_highlights = blue_separator,
            transparent = false,
            styles = transparent_panels({
                comments = { italic = true },
                keywords = { italic = true },
                functions = { italic = true },
                variables = { italic = false },
            }),
        },
    },

    {
        "vague-theme/vague.nvim",
        opts = {
            transparent = false,
            italic = false, -- Disable italic globally
        },
    },

    ---------------------------------------------------------------------------
    -- Disabled (flip `enabled` to try one again)
    ---------------------------------------------------------------------------
    { "AlessandroYorba/alduin", enabled = false },
    { "szymonwilczek/arete.nvim", enabled = false },
    { "RRethy/base16-nvim", enabled = false },
    { "tjdevries/colorbuddy.nvim", enabled = false },
    { "dasupradyumna/midnight.nvim", enabled = false },
    { "bluz71/vim-moonfly-colors", enabled = false },
    { "nyoom-engineering/oxocarbon.nvim", enabled = false, build = false },
    { "rivethorn/turbo-plus.nvim", enabled = false },
    { "tiagovla/tokyodark.nvim", enabled = false, opts = {} },
    { "Mofiqul/vscode.nvim", enabled = false },
    { "savq/melange-nvim", enabled = false, opts = { transparent = false } },

    {
        "ribru17/bamboo.nvim",
        enabled = false,
        opts = {
            transparent = false,
            lualine = { transparent = true },
            highlights = {
                -- make comments blend nicely with background, similar to other color schemes
                ["@comment"] = { fg = "$grey" },
            },
        },
    },

    {
        "xiantang/darcula-dark.nvim",
        enabled = false,
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },

    {
        "projekt0n/github-nvim-theme",
        name = "github-theme",
        enabled = false,
        opts = {},
    },

    { "ramojus/mellifluous.nvim", enabled = false, opts = {} },

    {
        "loctvl842/monokai-pro.nvim",
        enabled = false,
        opts = {
            transparent_background = false,
            override = function()
                return {
                    NormalFloat = { bg = "none" },
                }
            end,
        },
    },

    {
        "ankushbhagats/pastel.nvim",
        enabled = false,
        opts = {
            style = {
                transparent = false,
                inactive = true,
                float = false,
                border = true,
                bold = true,
                italic = true,
                underline = false,
                invert_title = false,
                simple_syntax = false,
                dynamic_statusline = false,
            },
        },
    },

    {
        "necrogoru/shades-of-purple.nvim",
        enabled = false,
        opts = {},
    },

    {
        "olimorris/onedarkpro.nvim",
        enabled = false,
        opts = {
            highlights = {
                ["@variable.rocq"] = { fg = "${green}" },
                ["@variable.imp"] = { fg = "${purple}" },
                ["@variable.qualid"] = { fg = "${green}", bold = true },
                ["@variable.metavariable"] = {
                    fg = "${orange}",
                    italic = true,
                    bold = true,
                },
                ["@variable.quantifier"] = { fg = "${purple}" },
                ["@number.rocq"] = { fg = "${cyan}" },
                ["@string.rocq"] = { fg = "${blue}" },
                ["@string.special.rocq"] = { fg = "${green}" },
                ["@variable.builtin.rocq"] = { fg = "${red}" },
                ["@comment.rocq"] = { fg = "${comment}", italic = true },
                ["@punctuation.special.rocq"] = { fg = "${red}" },

                ["@keyword.modifier"] = {
                    fg = "${purple}",
                    italic = true,
                    bold = true,
                },
                ["@keyword.directive"] = {
                    fg = "${purple}",
                    italic = true,
                    bold = true,
                },
                ["@keyword.directive.fail"] = { fg = "${red}", bold = true },
                ["@keyword.directive.language"] = { fg = "${orange}" },
                ["@keyword.declaration"] = {
                    fg = "${orange}",
                    italic = true,
                    bold = true,
                },
                ["@keyword.declaration.inductive"] = {
                    fg = "#E56BB1",
                    italic = true,
                    bold = true,
                },
                ["@keyword.module"] = { fg = "${purple}", bold = true },
                ["@keyword.notation"] = { fg = "${orange}", bold = true },
                ["@keyword.control"] = {
                    fg = "${purple}",
                    italic = true,
                    bold = true,
                },
                ["@keyword.control.abort"] = { fg = "${red}", bold = true },
                ["@keyword.control.imp"] = {
                    fg = "#E56BB1",
                    italic = true,
                    bold = true,
                },

                ["@keyword.tactic"] = { fg = "${cyan}", bold = true },
                ["@keyword.tactical"] = { fg = "${purple}", bold = true },
                ["@keyword.directive.ltac"] = { fg = "${orange}", bold = true },
                ["@proof.dash"] = { fg = "${green}", bold = true },
                ["@proof.plus"] = { fg = "${orange}", bold = true },
                ["@proof.star"] = { fg = "${red}", bold = true },
                ["@proof.block"] = { fg = "${orange}", bold = true },

                ["@type.rocq"] = { fg = "${yellow}", bold = true },
                ["@type.builtin"] = { fg = "${yellow}", bold = true },
                ["@type.definition"] = { fg = "${yellow}", bold = true },

                ["@operator.rocq"] = { fg = "${red}" },
                ["@punctuation.delimiter"] = { fg = "${blue}" },
                ["@punctuation.bracket"] = { fg = "${blue}" },
                ["@punctuation.bracket.braces"] = { fg = "${purple}" },

                ["@module"] = { fg = "${purple}", bold = true },
                ["@module.path.rocq"] = { fg = "${orange}", bold = true },
                ["@module.name"] = { fg = "${green}", bold = true },

                ["@function.rocq"] = { fg = "${red}", bold = true },
                ["@function.call.rocq"] = { fg = "${blue}", bold = true },
                ["@variable.parameter"] = { fg = "${yellow}", bold = true },
                ["@variable.parameter.tactic"] = { fg = "${purple}" },
                ["@constructor"] = {
                    fg = "${yellow}",
                    italic = false,
                    bold = true,
                },
                ["@attribute"] = { fg = "${blue}" },
            },
        },
    },
}
