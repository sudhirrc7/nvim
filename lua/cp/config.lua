-- CP runner settings: limits, compilers and how results are labelled
local M = {}

M.TIMEOUT = 10 -- seconds per test
M.OUTPUT_LIMIT = 64 * 1024 * 1024 -- bytes per stream per test

-- Competitive Companion: browser extension settings -> Custom ports
M.COMPANION_PORT = 12345
M.COMPANION_WAIT = 60 -- seconds

-- 256 MB stack so deep recursion doesn't segfault (macOS default is 8 MB)
local STACK = "-Wl,-stack_size,0x10000000"

local CPP_FLAGS = {
    "-std=c++20",
    "-O2",
    "-Wall",
    "-Wextra",
    "-Wshadow",
    "-DLOCAL",
    STACK,
}

local C_FLAGS = {
    "-std=c17",
    "-O2",
    "-Wall",
    "-Wextra",
    "-DLOCAL",
    STACK,
}

local function argv(...)
    return vim.iter({ ... }):flatten():totable()
end

local function run_binary(_, out)
    return { out }
end

-- ============================================================
-- Languages
--
-- build(file, out) -> compile command (optional)
-- run(file, out)   -> program command
-- native = true    -> `out` is a freshly built executable
-- ============================================================

M.LANGS = {
    cpp = {
        native = true,
        build = function(file, out)
            return argv("g++-16", CPP_FLAGS, file, "-o", out)
        end,
        run = run_binary,
    },
    c = {
        native = true,
        build = function(file, out)
            return argv("gcc", C_FLAGS, file, "-o", out)
        end,
        run = run_binary,
    },
    rust = {
        native = true,
        build = function(file, out)
            return argv(
                "rustc",
                "-O",
                "--edition",
                "2021",
                "-C",
                "link-arg=" .. STACK,
                file,
                "-o",
                out
            )
        end,
        run = run_binary,
    },
    go = {
        native = true,
        build = function(file, out)
            return { "go", "build", "-o", out, file }
        end,
        run = run_binary,
    },
    java = {
        build = function(file, out)
            return { "javac", "-d", out, file }
        end,
        run = function(file, out)
            local class = vim.fn.fnamemodify(file, ":t:r")
            return { "java", "-Xss256m", "-cp", out, class }
        end,
    },
    python = {
        run = function(file)
            return { "python3", file }
        end,
    },
    javascript = {
        run = function(file)
            return { "node", file }
        end,
    },
    typescript = {
        run = function(file)
            return { "bun", "run", file }
        end,
    },
}

-- status -> { icon, label, highlight }
M.STATUS = {
    AC = { "✓", "PASSED", "DiagnosticOk" },
    WA = { "✗", "WRONG ANSWER", "DiagnosticError" },
    RE = { "✗", "RUNTIME ERROR", "DiagnosticError" },
    TLE = { "✗", "TIME LIMIT EXCEEDED", "DiagnosticWarn" },
    OLE = { "✗", "OUTPUT LIMIT EXCEEDED", "DiagnosticWarn" },
    ERR = { "✗", "FAILED TO START", "DiagnosticError" },
}

M.SIGNALS = {
    [4] = "SIGILL (illegal instruction)",
    [5] = "SIGTRAP (trap / sanitizer)",
    [6] = "SIGABRT (failed assert, bad_alloc, sanitizer...)",
    [8] = "SIGFPE (division by zero?)",
    [10] = "SIGBUS (bad memory access)",
    [11] = "SIGSEGV (out of bounds or stack overflow?)",
}

return M
