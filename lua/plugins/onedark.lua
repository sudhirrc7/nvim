return {
    {
        "olimorris/onedarkpro.nvim",
        priority = 1000,
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
