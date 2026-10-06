return {
    "nvim-mini/mini.files",
    init = function()
        -- Arrow keys mirror hjkl (Up/Down already move like j/k)
        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesBufferCreate",
            callback = function(args)
                local buf = args.data.buf_id
                local MiniFiles = require("mini.files")
                vim.keymap.set("n", "<Left>", MiniFiles.go_out, {
                    buffer = buf,
                    desc = "Go out of directory",
                })
                vim.keymap.set("n", "<Right>", MiniFiles.go_in, {
                    buffer = buf,
                    desc = "Go in entry",
                })
            end,
        })
    end,
}
