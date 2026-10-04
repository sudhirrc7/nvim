-- Flutter / Dart: flutter-tools.nvim runs the dart language server itself
-- (no lspconfig / Mason entry needed), plus `flutter run` with hot reload on
-- save, devices, emulators, logs, outline, DevTools and nvim-dap debugging.
-- Every keymap lives under <leader>= (toggles under <leader>=u).
--
-- The heavier editor decorations are toggles, remembered across restarts:
-- widget guides (off by default), closing tags and LSP document colors.

local util = require("config.util")

local P = "<leader>="

-- persisted on/off flags in stdpath("state")
local function flag(name, default)
    local saved = util.read_state("flutter_" .. name)
    if saved == nil then
        return default
    end
    return saved == "true"
end

local function save_flag(name, value)
    util.write_state("flutter_" .. name, value)
end

local colors_on = flag("document_colors", true)

-- Neovim 0.12's built-in LSP document colors (Colors.red, Color(0xFF...))
local color_styles = util.styles("flutter_color_style", {
    { name = "background" },
    { name = "foreground" },
    { name = "virtual", style = "■ " },
})

local function color_opts()
    local s = color_styles.current()
    return { style = s.style or s.name }
end

-- every buffer the dart language server is attached to
local function dart_buffers()
    local bufs = {}
    for _, client in ipairs(vim.lsp.get_clients({ name = "dartls" })) do
        for buf in pairs(client.attached_buffers) do
            bufs[#bufs + 1] = buf
        end
    end
    return bufs
end

local function apply_colors(opts)
    for i, buf in ipairs(dart_buffers()) do
        -- opts are global, so they only need passing once
        vim.lsp.document_color.enable(
            colors_on,
            { bufnr = buf },
            i == 1 and opts or nil
        )
    end
end

-- The :Flutter* commands only exist once the plugin has started, which it
-- does on the first BufEnter of a dart file. Start it early when a keymap is
-- used before any dart file was entered.
local function ensure_started()
    if vim.fn.exists(":FlutterRun") == 2 then
        return
    end
    pcall(vim.api.nvim_exec_autocmds, "BufEnter", {
        group = "FlutterToolsGroup",
        pattern = "pubspec.yaml",
    })
end

local function cmd(name)
    return function()
        ensure_started()
        vim.cmd(name)
    end
end

-- commands sent to the running app (same as the keys in `flutter run`)
local function app(fn)
    return function()
        require("flutter-tools.commands")[fn]()
    end
end

local function code_action(kind)
    return function()
        vim.lsp.buf.code_action({ context = { only = { kind } } })
    end
end

-- clears a flutter-tools extmark namespace in every buffer
local function clear_ns(name)
    local ns = vim.api.nvim_create_namespace(name)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end
end

-- on/off decoration backed by flutter-tools' config table, which the
-- plugin reads every time the language server sends new data
local function decoration_toggle(opts)
    return Snacks.toggle({
        name = opts.name,
        get = function()
            return require("flutter-tools.config")[opts.key].enabled
        end,
        set = function(state)
            require("flutter-tools.config")[opts.key].enabled = state
            save_flag(opts.key, state)
            if state then
                if opts.on_enable then
                    opts.on_enable()
                end
                vim.notify(
                    opts.name .. " shows up on the next edit",
                    vim.log.levels.INFO,
                    { title = "Flutter" }
                )
            else
                clear_ns(opts.ns)
            end
        end,
    })
end

local function setup_toggles()
    decoration_toggle({
        name = "Flutter Widget Guides",
        key = "widget_guides",
        ns = "flutter_tools_outline_guides",
        on_enable = function()
            require("flutter-tools.guides").setup()
        end,
    }):map(P .. "ug")

    decoration_toggle({
        name = "Flutter Closing Tags",
        key = "closing_tags",
        ns = "flutter_tools_closing_labels",
    }):map(P .. "ut")

    Snacks.toggle({
        name = "Flutter Document Colors",
        get = function()
            return colors_on
        end,
        set = function(state)
            colors_on = state
            save_flag("document_colors", state)
            apply_colors()
        end,
    }):map(P .. "uc")

    Snacks.toggle({
        name = "Flutter Error Notifications",
        get = function()
            return require("flutter-tools.config").dev_log.notify_errors
        end,
        set = function(state)
            require("flutter-tools.config").dev_log.notify_errors = state
            save_flag("notify_errors", state)
        end,
    }):map(P .. "un")
end

return {
    {
        "nvim-flutter/flutter-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        -- before BufEnter, so the plugin's own start-on-BufEnter still fires
        event = {
            "BufReadPre *.dart",
            "BufNewFile *.dart",
            "BufReadPre pubspec.yaml",
        },
        opts = {
            ui = { border = "rounded" },
            -- uses <project>/.fvm/flutter_sdk when the project pins a version
            -- with fvm, otherwise the `flutter` on $PATH
            fvm = true,
            root_patterns = { ".git", "pubspec.yaml" },
            -- FlutterRun runs plainly, <leader>=D runs under nvim-dap
            debugger = {
                enabled = false,
                exception_breakpoints = {},
            },
            widget_guides = { enabled = flag("widget_guides", false) },
            closing_tags = {
                enabled = flag("closing_tags", true),
                highlight = "Comment",
                prefix = "  ",
            },
            dev_log = {
                enabled = true,
                notify_errors = flag("notify_errors", false),
                open_cmd = "botright 15split",
                focus_on_open = false,
            },
            dev_tools = {
                autostart = false,
                auto_open_browser = false,
            },
            outline = {
                open_cmd = "botright 35vnew",
                auto_open = false,
            },
            lsp = {
                settings = {
                    showTodos = true,
                    completeFunctionCalls = true,
                    renameFilesWithClasses = "prompt",
                    enableSnippets = true,
                    updateImportsOnRename = true,
                },
            },
        },
        config = function(_, opts)
            require("flutter-tools").setup(opts)

            -- apply the remembered document color state/style to dartls
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup(
                    "FlutterDocumentColors",
                    { clear = true }
                ),
                callback = function(ev)
                    local client = vim.lsp.get_client_by_id(ev.data.client_id)
                    if client and client.name == "dartls" then
                        vim.lsp.document_color.enable(
                            colors_on,
                            { bufnr = ev.buf },
                            color_opts()
                        )
                    end
                end,
            })

            setup_toggles()
        end,
        -- stylua: ignore
        keys = {
            { P, "", desc = "+flutter" },
            { P .. "u", "", desc = "+toggle" },
            { P .. "t", "", desc = "+devtools" },
            { P .. "m", "", desc = "+app debug overlays" },

            -- run / session
            { P .. "r", cmd("FlutterRun"), desc = "Run" },
            { P .. "D", cmd("FlutterDebug"), desc = "Run with Debugger (dap)" },
            { P .. "h", cmd("FlutterReload"), desc = "Hot Reload" },
            { P .. "H", cmd("FlutterRestart"), desc = "Hot Restart" },
            { P .. "q", cmd("FlutterQuit"), desc = "Quit App" },
            { P .. "a", cmd("FlutterAttach"), desc = "Attach to Running App" },
            { P .. "A", cmd("FlutterDetach"), desc = "Detach (keep app running)" },
            { P .. "d", cmd("FlutterDevices"), desc = "Devices" },
            { P .. "e", cmd("FlutterEmulators"), desc = "Emulators" },
            { P .. "c", cmd("FlutterCommands"), desc = "All Flutter Commands" },
            { P .. "v", cmd("FlutterFvm"), desc = "Switch SDK (fvm)" },

            -- views
            { P .. "o", cmd("FlutterOutlineToggle"), desc = "Widget Outline" },
            { P .. "l", cmd("FlutterLogToggle"), desc = "Dev Log" },
            { P .. "L", cmd("FlutterLogClear"), desc = "Clear Dev Log" },
            { P .. "w", cmd("FlutterWidgetPreview"), desc = "Widget Previewer" },
            { P .. "W", cmd("FlutterWidgetPreviewStop"), desc = "Stop Widget Previewer" },

            -- pub
            { P .. "p", cmd("FlutterPubGet"), desc = "Pub Get" },
            { P .. "P", cmd("FlutterPubUpgrade"), desc = "Pub Upgrade" },

            -- code / lsp
            { P .. "s", cmd("FlutterSuper"), desc = "Go to Super" },
            { P .. "n", cmd("FlutterRename"), desc = "Rename (+ file & imports)" },
            { P .. "f", code_action("refactor"), desc = "Refactor (wrap / extract widget)", mode = { "n", "x" } },
            { P .. "i", code_action("source.organizeImports"), desc = "Organize Imports" },
            { P .. "F", code_action("source.fixAll"), desc = "Fix All" },
            { P .. "z", cmd("FlutterReanalyze"), desc = "Reanalyze Project" },
            { P .. "x", cmd("FlutterLspRestart"), desc = "Restart Dart LSP" },

            -- devtools
            { P .. "tt", cmd("FlutterDevTools"), desc = "Start DevTools Server" },
            { P .. "to", cmd("FlutterOpenDevTools"), desc = "Open DevTools in Browser" },
            { P .. "ta", cmd("FlutterDevToolsActivate"), desc = "Activate DevTools" },
            { P .. "tc", cmd("FlutterCopyProfilerUrl"), desc = "Copy Profiler URL" },

            -- running app toggles (sent to `flutter run`)
            { P .. "mi", app("inspect_widget"), desc = "Widget Inspector" },
            { P .. "md", app("visual_debug"), desc = "Debug Paint" },
            { P .. "mb", app("paint_baselines"), desc = "Paint Baselines" },
            { P .. "mr", app("repaint_rainbow"), desc = "Repaint Rainbow" },
            { P .. "mp", app("performance_overlay"), desc = "Performance Overlay" },
            { P .. "ms", app("slow_animations"), desc = "Slow Animations" },
            { P .. "ml", app("brightness"), desc = "Light / Dark Brightness" },
            { P .. "mt", app("change_target_platform"), desc = "Cycle Target Platform" },

            -- editor decorations (<leader>=ug / ut / uc / un are Snacks
            -- toggles registered in config); color style cycles here
            {
                P .. "us",
                function()
                    local s = color_styles.next()
                    apply_colors(color_opts())
                    vim.notify("Document colors: " .. s.name, vim.log.levels.INFO, { title = "Flutter" })
                end,
                desc = "Cycle Document Color Style",
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = { ensure_installed = { "dart" } },
    },
}
