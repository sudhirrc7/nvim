-- ============================================================
-- CP Runner keymaps
--
-- Test files live next to the solution:
--     input.txt  -> output.txt     (Test 1)
--     input1.txt -> output1.txt    (Test 2)
--     ...
--
-- <leader>iq        compile + run the current file in a terminal
-- <leader>ir        build once, write program output into outputN.txt
-- <leader>iR        run all tests, compare with outputN.txt, show diffs
-- <leader>ia        quick pass/fail + timing summary
-- <leader>iC        delete all CP input/output files
-- <leader>im        create C++ folders (fish `cppfolders`)
--
-- <leader>ic        toggle the side panel (code stays visible)
-- <leader>il        open the floating editor
-- <leader>i1..i9    show Test N (in the panel if it's open,
--                   otherwise in the floating editor)
-- <leader>iw        save all CP test files
-- <leader>ip        pick a test with Snacks, open it in the panel
-- <leader>ib        receive a problem from Competitive Companion
--
-- Settings (time limit, compilers...) are in cp/config.lua.
-- ============================================================
local M = {}

function M.setup()
    local run = require("cp.run")
    local views = require("cp.views")
    local companion = require("cp.companion")

    local function map(lhs, fn, desc)
        vim.keymap.set("n", lhs, fn, { desc = desc })
    end

    map("<leader>iq", run.quick, "Run current file")
    map("<leader>ir", run.generate, "Build once and generate CP outputs")
    map("<leader>iR", run.check, "Compile once and run all CP tests")
    map("<leader>ia", run.summary, "Quick CP test summary")
    map("<leader>iC", views.clean, "Delete all CP input/output files")

    map("<leader>im", function()
        vim.fn.jobstart({ "fish", "-c", "cppfolders" }, {
            cwd = vim.fn.getcwd(),
            detach = true,
        })
    end, "Create C++ folders")

    map("<leader>ic", views.toggle_panel, "Toggle CP test panel")
    map("<leader>il", views.open_editor, "CP test editor")

    for n = 1, 9 do
        map("<leader>i" .. n, function()
            views.show_test(n)
        end, "CP test " .. n)
    end

    map("<leader>iw", views.save_all, "Save CP test files")
    map("<leader>ip", views.pick, "Pick CP test")
    map("<leader>ib", companion.toggle, "Receive problem from Competitive Companion")
end

return M
