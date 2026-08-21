return {
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            clangd = {
                cmd = {
                    "clangd",
                    "--query-driver=/opt/homebrew/bin/g++-*",
                    "--background-index",
                    "--clang-tidy",
                },
            },
        },
    },
}
