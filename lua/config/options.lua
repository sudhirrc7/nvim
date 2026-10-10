-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local g = vim.g
local opt = vim.opt

-- Optimizations on startup
vim.loader.enable()

-- Define leader key
g.mapleader = " "
g.maplocalleader = "\\"

-- Personal Config and LazyVim global options
g.lualine_info_extras = false
g.snacks_animate = false
g.codeium_cmp_hide = false
g.lazygit_config = false
g.lazyvim_cmp = "blink.cmp"
g.lazyvim_picker = "snacks"
g.trouble_lualine = false
g.omni_sql_no_default_maps = 1
g.neovide_input_macos_option_key_is_meta = "only_left"
g.moonflyTransparent = true
g.moonflyNormalFloat = true

-- Autoformat on save (Global)
g.autoformat = true

-- Enable EditorConfig integration
g.editorconfig = true

-- Root dir detection
g.root_spec = {
    "lsp",
    {
        ".git",
        "lua",
        ".obsidian",
        "package.json",
        "Makefile",
        "go.mod",
        "cargo.toml",
        "pyproject.toml",
        "src",
    },
    "cwd",
}

-- Indentation
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.shiftround = true

opt.autoread = true
opt.background = "dark"
opt.scrolloff = 8
opt.guifont = "CaskaydiaCove Nerd Font:h18"

-- Cursorline only in the gutter (<leader>tL) and a block cursor in every
-- mode (<leader>tB), restored from the last session
local util = require("config.util")
if util.read_state("cursorline_full") == "0" then
    opt.cursorlineopt = "number"
end
if util.read_state("block_cursor") == "1" then
    opt.guicursor = ""
end

-- Disable annoying cmd line stuff
opt.showcmd = false
opt.laststatus = 3
opt.cmdheight = 0 -- <leader>tx brings the command line back

opt.list = false
opt.relativenumber = true

-- Disable native bufferline
opt.showtabline = 0

-- Spell checking (off, toggled per buffer)
opt.spell = false
opt.spelllang:append("es")

-- Backspacing and indentation when wrapping
opt.backspace = { "start", "eol", "indent" }
opt.breakindent = true
opt.smoothscroll = true

opt.conceallevel = 2

-- One border style for every built-in float (LSP hover, signature, diagnostics)
opt.winborder = "rounded"

-- Terminal colors follow the colorscheme (before transparency clears Normal's bg)
require("config.termsync")

-- Transparency for every colorscheme, toggled with <leader>t1
require("config.transparency")

-- Fix the clipboard when using WSL. Install https://github.com/equalsraf/win32yank (https://github.com/microsoft/WSL/issues/4440#issuecomment-1212350183)
if os.getenv("WSL_DISTRO_NAME") ~= nil then
    opt.clipboard = "unnamedplus"
end
