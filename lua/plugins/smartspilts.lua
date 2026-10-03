-- <C-arrow> resize, <leader><arrow> move the cursor, <A-arrow> swap buffers
local keys = {}
for _, dir in ipairs({ "Left", "Down", "Up", "Right" }) do
    local d = dir:lower()
    for _, action in ipairs({
        { "<C-" .. dir .. ">", "resize_", "Resize " },
        { "<leader><" .. dir .. ">", "move_cursor_", "Move Cursor " },
        { "<A-" .. dir .. ">", "swap_buf_", "Swap Buffer " },
    }) do
        local lhs, fn, desc = action[1], action[2], action[3]
        keys[#keys + 1] = {
            lhs,
            function()
                require("smart-splits")[fn .. d]()
            end,
            desc = desc .. dir,
        }
    end
end

return {
    "mrjones2014/smart-splits.nvim",
    event = "VeryLazy",
    keys = keys,
}
