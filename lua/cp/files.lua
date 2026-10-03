-- CP test files, living next to the solution:
--     input.txt  -> output.txt     (Test 1, index 0)
--     input1.txt -> output1.txt    (Test 2, index 1)
--     ...
local M = {}

function M.test_files(dir, index)
    if index == 0 then
        return dir .. "/input.txt", dir .. "/output.txt"
    end

    return dir .. "/input" .. index .. ".txt",
        dir .. "/output" .. index .. ".txt"
end

-- Number of consecutive tests, from Test 1 on
function M.count_tests(dir)
    local n = 0

    while vim.fn.filereadable((M.test_files(dir, n))) == 1 do
        n = n + 1
    end

    return n
end

-- Remove leading/trailing blank lines (pasted samples often have them)
function M.trim_lines(lines)
    while #lines > 0 and lines[1]:match("^%s*$") do
        table.remove(lines, 1)
    end

    while #lines > 0 and lines[#lines]:match("^%s*$") do
        table.remove(lines)
    end

    return lines
end

-- Pasted / received text as trimmed lines, without \r
function M.split_lines(text)
    local lines = vim.split((text or ""):gsub("\r", ""), "\n", { plain = true })

    return M.trim_lines(lines)
end

-- Split into lines, strip trailing whitespace and trailing blank lines
function M.normalize(text)
    local lines = vim.split(text, "\n", { plain = true })

    for i, line in ipairs(lines) do
        lines[i] = line:gsub("%s+$", "")
    end

    while #lines > 0 and lines[#lines] == "" do
        table.remove(lines)
    end

    return lines
end

function M.read(path)
    local fd = io.open(path, "rb")

    if not fd then
        return ""
    end

    local data = fd:read("*a")
    fd:close()

    return data
end

-- Trim and save a modified test buffer, returns whether it was saved
function M.save_buf(buf)
    if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].modified then
        return false
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, M.trim_lines(lines))

    vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent noautocmd write")
    end)

    return true
end

-- Save every modified input/output buffer in dir
function M.save_tests(dir)
    local saved = 0

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        local is_test = name:match("/input%d*%.txt$")
            or name:match("/output%d*%.txt$")

        if is_test and vim.fs.dirname(name) == dir and M.save_buf(buf) then
            saved = saved + 1
        end
    end

    return saved
end

-- Reload the buffer showing `path`, if any, after it changed on disk
function M.reload(path)
    local buf = vim.fn.bufnr(path)

    if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
        vim.api.nvim_buf_call(buf, function()
            vim.cmd("silent edit!")
        end)
    end
end

-- Delete the tests from index `from` on, returns how many files went.
-- With `wipe`, buffers showing them are wiped too.
function M.delete_tests(dir, from, wipe)
    local deleted = 0
    local index = from

    while true do
        local found = false

        for _, path in ipairs({ M.test_files(dir, index) }) do
            local buf = vim.fn.bufnr(path)

            if wipe and buf ~= -1 then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end

            if vim.fn.filereadable(path) == 1 then
                vim.fn.delete(path)
                deleted = deleted + 1
                found = true
            end
        end

        -- input.txt may be missing while input1.txt exists
        if not found and index > 0 then
            break
        end

        index = index + 1
    end

    return deleted
end

-- Tests for the runners, nil + message when there are none
function M.find_tests(dir, need_expected)
    local tests = {}
    local index = 0

    while true do
        local input, output = M.test_files(dir, index)

        if vim.fn.filereadable(input) == 1 then
            if need_expected and vim.fn.filereadable(output) == 0 then
                return nil,
                    "Missing expected output: "
                        .. vim.fn.fnamemodify(output, ":t")
            end

            table.insert(tests, {
                name = "Test " .. (index + 1),
                input = input,
                output = output,
            })
        elseif index > 0 then
            break
        end

        index = index + 1
    end

    if #tests == 0 then
        return nil, "No test cases found. Press <leader>ic first."
    end

    return tests
end

return M
