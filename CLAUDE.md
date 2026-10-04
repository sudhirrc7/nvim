# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim (0.12+) config built on top of LazyVim. LazyVim supplies the
base (LSP, completion, formatting, pickers, default keymaps/autocmds); this repo
layers custom keymaps, a theme/terminal-sync system, switchable UI styles and a
competitive programming runner (`lua/cp/`). `README.md` is the user-facing doc
and lists every custom keymap, so keep it in sync when keymaps or features change.

## Commands

There is no build or test suite. Useful checks:

- Format Lua: `stylua lua/` (config in `stylua.toml`: 4-space indent, 80 cols;
  stylua is installed via Mason at `~/.local/share/nvim/mason/bin/stylua`)
- Check the config loads without errors: `nvim --headless +qa`
- Sync plugins to `lazy-lock.json`: `nvim --headless "+Lazy! sync" +qa`
- Enabled LazyVim extras (language support, etc.) are listed in `lazyvim.json`,
  edited through `:LazyExtras` rather than by hand.

## Architecture

### Load order

`init.lua` → `config/lazy.lua` sets up lazy.nvim with LazyVim + `import =
"plugins"` (every file in `lua/plugins/` is a lazy.nvim spec; `defaults.lazy =
true`). LazyVim then auto-loads `config/options.lua` (early) and
`config/keymaps.lua` / `config/autocmds.lua` (on `VeryLazy`). These files
override/extend LazyVim's defaults rather than replacing them.

- `config/options.lua` ends by requiring `config.termsync` and then
  `config.transparency`. **Order matters**: both register `ColorScheme`
  autocmds before the startup colorscheme loads, and termsync must read the
  theme's `Normal` bg before transparency clears it.
- `config/keymaps.lua` ends with `require("cp").setup()`, which registers all
  `<leader>i*` CP runner keymaps.

### Persistent state (`config/util.lua`)

Choices that survive restarts are plain files in `stdpath("state")`, via
`util.read_state` / `util.write_state`. `util.styles(state_name, list)` wraps a
list of `{ name = ... }` style tables with a remembered current index and
`next()`/`set()`; it backs the lualine styles (`plugins/lualine.lua`), Snacks
explorer layouts (`plugins/snacks.lua`) and Snacks picker layouts
(`plugins/snacks-picker-styles.lua`). New switchable styles should follow this
pattern. (`plugins/blink.lua` has its own non-persisted cycler.)

### Colorscheme pipeline

- The `ColorScheme` autocmd in `config/autocmds.lua` saves `last_colorscheme`;
  LazyVim's `colorscheme` option in `config/lazy.lua` restores it (fallback
  `catppuccin-mocha`).
- `plugins/themes.lua` holds every theme except catppuccin
  (`plugins/catppuccin.lua`), all lazy-loaded. Themes should keep their own
  `transparent` options off — transparency is handled globally.
  Three themes are local dev plugins loaded via `dir = "~/personal/..."`
  (`farblue.nvim`, `neonprism.nvim`, `poimandres.nvim`).
- `config/transparency.lua` clears `bg` on a fixed list of highlight groups on
  every `ColorScheme` event (skipping low-contrast "badge" groups); toggling
  just reloads the current colorscheme.
- `config/termsync.lua` derives a 16-color ANSI palette from
  `g:terminal_color_*` (falling back to highlight groups) and writes theme
  files for kitty, Alacritty and Ghostty under `~/.config/`, then live-reloads
  running terminals. `config/color.lua` has the shared hex/blend/contrast
  helpers.
- Plugins that compute colors from the theme (e.g. lualine styles) must
  recompute on `ColorScheme`, since themes switch at runtime.

### CP runner (`lua/cp/`)

- `config.lua` — time/output limits, Competitive Companion port, and the
  `LANGS` table (`build(file, out)` / `run(file, out)` / `native`). Add a
  language here.
- `files.lua` — discovery of test pairs next to the solution (`input.txt` ↔
  `output.txt`, `inputN.txt` ↔ `outputN.txt`).
- `run.lua` — compiles once per run, runs every test (only run time is timed),
  generates outputs or checks against expected.
- `report.lua` — result rendering (statuses/signals from `config.lua`, diffs).
- `views.lua` — side panel and floating test editor with their buffer-local
  keymaps.
- `companion.lua` — local TCP listener for the Competitive Companion browser
  extension; imported samples replace existing tests.
- `init.lua` — keymap registration only.

Some keymaps shell out to `fish` functions (e.g. `cppfolders`, the tmux
sessionizer), so they assume fish is installed.
