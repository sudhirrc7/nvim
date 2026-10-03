-- Small helpers shared by the config: files, state remembered across
-- sessions (in stdpath("state")) and lists of named styles.
local M = {}

-- writes `content` to `path` only when it changed, returns whether it did
function M.write_file(path, content)
    local f = io.open(path, "r")
    if f then
        local old = f:read("*a")
        f:close()
        if old == content then
            return false
        end
    end
    vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
    f = io.open(path, "w")
    if not f then
        return false
    end
    f:write(content)
    f:close()
    return true
end

local function state_path(name)
    return vim.fn.stdpath("state") .. "/" .. name
end

-- the value saved under `name`, nil when missing or empty
function M.read_state(name)
    local f = io.open(state_path(name), "r")
    if not f then
        return nil
    end
    local value = vim.trim(f:read("*a") or "")
    f:close()
    return value ~= "" and value or nil
end

function M.write_state(name, value)
    M.write_file(state_path(name), tostring(value))
end

-- A list of `{ name = ... }` styles whose pick is remembered under
-- `state_name`. `index` is the current style.
function M.styles(state_name, list)
    local self = { list = list, index = 1 }
    local saved = M.read_state(state_name)
    for i, style in ipairs(list) do
        if style.name == saved then
            self.index = i
        end
    end

    function self.current()
        return list[self.index]
    end

    function self.set(i)
        self.index = i
        M.write_state(state_name, list[i].name)
    end

    -- moves to the next style (wrapping around) and returns it
    function self.next()
        self.set(self.index % #list + 1)
        return self.current()
    end

    return self
end

return M
