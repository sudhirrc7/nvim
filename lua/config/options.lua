-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local go = vim.g
local o = vim.opt

-- Optimizations on startup
vim.loader.enable()

-- Personal Config and LazyVim global options
go.lualine_info_extras = false
go.snacks_animate = true
go.codeium_cmp_hide = false
go.lazygit_config = false
go.lazyvim_cmp = "blink"
go.lazyvim_picker = "snacks"
go.trouble_lualine = false

--vim settings for me
-- Disable cursorline in all modes
vim.opt.cursorline = false

-- Set cursor to a block in all modes (normal, visual, insert, command)
-- The 'a' value applies the setting to all modes
vim.opt.guicursor = ""

-- Define leader key
go.mapleader = " "
go.maplocalleader = "\\"

-- Autoformat on save (Global)
go.autoformat = true

-- Font
go.gui_font_default_size = 10
go.gui_font_size = go.gui_font_default_size
go.gui_font_face = "Maple Mono NF"

-- Enable EditorConfig integration
go.editorconfig = true

-- Root dir detection
go.root_spec = {
  "lsp",
  { ".git", "lua", ".obsidian", "package.json", "Makefile", "go.mod", "cargo.toml", "pyproject.toml", "src" },
  "cwd",
}

-- Disable annoying cmd line stuff
o.showcmd = false
o.laststatus = 3
o.cmdheight = 0
-- o.cmdheight = 1

-- Disable mouse
o.mouse = ""

-- Disable native bufferline
o.showtabline = 0

-- Enable spell checking
o.spell = false
o.spelllang:append("es")

-- Backspacing and indentation when wrapping
o.backspace = { "start", "eol", "indent" }
o.breakindent = true

-- Smoothscroll
o.smoothscroll = true

o.conceallevel = 2

-- Fix the clipboard when using WSL. Install https://github.com/equalsraf/win32yank (https://github.com/microsoft/WSL/issues/4440#issuecomment-1212350183)
if os.getenv("WSL_DISTRO_NAME") ~= nil then
  o.clipboard = "unnamedplus"
end
