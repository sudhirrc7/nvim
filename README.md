# Neovim config

My personal Neovim setup, built on [LazyVim](https://www.lazyvim.org).
LazyVim provides the base (LSP, completion, formatting, pickers); this repo
adds my own keymaps, a theme system that keeps the terminal in sync, a set of
switchable statusline and file explorer styles, and a competitive programming
runner.

## Highlights

- **Theme switching that sticks.** Pick any colorscheme with `<leader>uC` and
  it is restored on the next start. Every theme is lazy-loaded, so having many
  of them installed doesn't slow startup.
- **Transparency for any theme.** `<leader>t1` clears the background of
  whatever colorscheme is active, instead of relying on each theme's own
  option.
- **Terminal follows the editor.** When the colorscheme changes, its palette is
  written to theme files for kitty, Alacritty and Ghostty, and any running
  terminal is reloaded.
- **20 statusline styles.** `<leader>tl` opens a picker that previews each
  lualine style live as you move through the list.
- **7 file explorer layouts.** `<leader>te` cycles the Snacks explorer between
  a sidebar, a drawer, a dock, a Quake-style drop-down and others.
- **Competitive programming runner.** Compile once, run every sample, see a
  side-by-side diff of wrong answers, edit tests in a side panel, and import
  problems straight from the browser with Competitive Companion.

## Requirements

- Neovim **0.12+**
- git, a C compiler, [ripgrep](https://github.com/BurntSushi/ripgrep) and
  [fd](https://github.com/sharkdp/fd) (the usual LazyVim requirements)
- A [Nerd Font](https://www.nerdfonts.com) (configured for JetBrainsMono Nerd
  Font)
- [fish](https://fishshell.com) for the tmux sessionizer and C++ folder
  keymaps
- For the CP runner, the compilers for the languages you use: `g++-16`
  (Homebrew GCC), `gcc`, `rustc`, `go`, `javac`/`java`, `python3`, `node`,
  `bun`

## Installation

Back up any existing config first, then clone this repo into place:

```sh
mv ~/.config/nvim ~/.config/nvim.bak
git clone git@github.com:sudhirrc7/nvim.git ~/.config/nvim
nvim
```

lazy.nvim bootstraps itself and installs every plugin on the first start.

### Terminal color sync (optional)

Point your terminal at the file Neovim generates:

| Terminal  | Add to its config                                                          |
| --------- | -------------------------------------------------------------------------- |
| kitty     | `include nvim-theme.conf` in `kitty.conf`                                  |
| Alacritty | `import = ["~/.config/alacritty/nvim-theme.toml"]` under `[general]`        |
| Ghostty   | `theme = nvim-sync`                                                        |

While transparency is on, the terminal background is set to pure black so the
editor looks the same through it.

## Layout

```
init.lua                 entry point, loads config/lazy.lua
lua/config/
  lazy.lua               lazy.nvim + LazyVim setup, restores the last colorscheme
  options.lua            editor options
  keymaps.lua            general keymaps
  autocmds.lua           autocommands
  termsync.lua           writes the colorscheme palette to terminal configs
  transparency.lua       theme-independent transparency
  util.lua               state files and remembered style choices
  color.lua              color helpers (hex, blend, contrast)
lua/cp/                  competitive programming runner (see below)
lua/plugins/             one file per plugin or plugin group
snippets/                custom snippets per language
```

LazyVim extras are enabled in `lazyvim.json` (open the list with
`<leader>lx`). Language support comes from these extras: C/C++, Go, Java,
Python, TypeScript, SQL, Docker, Markdown and more. `plugins/fish.lua` adds
fish and `plugins/flutter-tools.lua` adds Flutter/Dart.

Choices that should survive a restart are saved in Neovim's state directory
(`stdpath("state")`): the last colorscheme, transparency, the lualine style,
the explorer style and the Flutter decoration toggles.

## Keymaps

The leader key is `Space`. These are my additions on top of
[LazyVim's defaults](https://www.lazyvim.org/keymaps); press `<leader>sk` to
search every keymap.

### UI toggles

| Keys                        | Action                                         |
| --------------------------- | ---------------------------------------------- |
| `<leader>t1`                | Transparency on/off                            |
| `<leader>tl`                | Pick a lualine style (live preview)            |
| `<leader>te`                | Cycle the file explorer style                  |
| `<leader>tz`                | Cycle the completion menu style                |
| `<leader>tb` / `<C-q>`      | Completion menu auto-show on/off               |
| `<leader>tx`                | Reserve a line for the command line            |
| `<leader>uX`                | Statusline on/off                              |
| `<leader>tL`                | Cursorline: full line ↔ line number only       |
| `<leader>tB`                | Block cursor in every mode on/off              |
| `<leader>uu`                | Color column: off → 80 → 100                   |
| `<leader>ul` / `<leader>uL` | Line numbers on/off, absolute ↔ relative       |
| `<leader>iz`                | Cycle the Rose Pine background shade           |

### Files

| Keys                          | Action                                     |
| ----------------------------- | ------------------------------------------ |
| `ff` / `fg`                   | Find files / live grep (fff.nvim)          |
| `fz` / `fc`                   | Fuzzy grep / grep the word under the cursor |
| `<leader>fz`                  | Jump to a directory with zoxide            |
| `-` / `<leader>i-`            | Oil (buffer / float)                       |
| `\\`                          | mini.files (arrow keys work like hjkl)     |
| `<leader>ie` / `iE` / `if`    | Fyler (left / right / floating)            |
| `<leader>fV`                  | Open the working directory in VS Code      |

### Editing

| Keys                          | Action                                         |
| ----------------------------- | ---------------------------------------------- |
| `<A-d>` / `<A-c>`             | Delete / change without yanking                |
| `<A-s>`                       | Save without formatting                        |
| `<C-e>`                       | Select all                                     |
| `jj`                          | Leave insert mode                              |
| `[<CR>` / `]<CR>`             | Add blank lines above / below (takes a count)  |
| `<A-o>` / `<A-i>`             | Grow / shrink the selection (treesitter / LSP) |
| `<leader>s1` / `s2` / `s3`    | Replace the word under the cursor (`gI` / `gi` / confirm) |
| `<leader>ij`                  | Split / join a code block (treesj)             |
| `<leader>ig`                  | Detect the buffer's indentation                |
| `<leader>S` / `!` / `@`       | First spelling fix / add word / remove word    |

### Buffers and windows

| Keys                              | Action                                   |
| --------------------------------- | ---------------------------------------- |
| `<Tab>` / `<S-Tab>`               | Next / previous buffer                   |
| `<M-CR>`                          | Alternate buffer                         |
| `<leader>bf` / `<leader>ba`       | First / last buffer                      |
| `<leader>th` / `<leader>tu`       | Close hidden / nameless buffers          |
| `<leader>_` / `<leader>\`         | Split below / right                      |
| `<C-arrows>`                      | Resize the window                        |
| `<leader><arrows>`                | Move to a window                         |
| `<A-arrows>`                      | Swap buffers between windows             |

### Git, tools and info

| Keys                            | Action                                      |
| ------------------------------- | ------------------------------------------- |
| `<leader>gnn`                   | Neogit (`c` commit, `p` pull, `P` push, `f` fetch) |
| `<leader>gb` / `<leader>go`     | Blame line / open the line on the remote    |
| `<leader>ft` / `<leader>fT`     | Floating terminal (root dir / cwd)          |
| `<leader>tt`                    | tmux sessionizer                            |
| `<leader>?`                     | Search the word under the cursor on Brave   |
| `<leader>ll` / `lu` / `ls`      | Lazy / update / sync                        |
| `<leader>cif` / `cic` / `ciL`   | Formatter / Conform / linter info           |
| `<leader>cil` / `cir`           | LSP config / root dir                       |
| `<leader>in` / `<leader>it`     | Notifications / treesitter picker           |

## Competitive programming runner

Test cases live next to the solution as `input.txt`/`output.txt`,
`input1.txt`/`output1.txt`, and so on. Compiled languages are built once per
run and the binary is reused for every test. Only the run itself is timed;
compile time isn't counted.

Supported languages: C++, C, Rust, Go, Java, Python, JavaScript and TypeScript.
The time limit, compiler flags and commands are in `lua/cp/config.lua`.

| Keys                | Action                                                   |
| ------------------- | -------------------------------------------------------- |
| `<leader>ib`        | Receive a problem from Competitive Companion             |
| `<leader>iR`        | Run all tests, show a diff for each wrong answer         |
| `<leader>ia`        | Pass/fail and timing summary                             |
| `<leader>ir`        | Write the program's output into the `output*.txt` files  |
| `<leader>iq`        | Compile and run the current file in a terminal           |
| `<leader>ic`        | Toggle the test panel next to the code                   |
| `<leader>il`        | Open the floating test editor                            |
| `<leader>i1`–`i9`   | Jump to test N                                           |
| `<leader>ip`        | Pick a test with a preview                               |
| `<leader>iw`        | Save all test files                                      |
| `<leader>iC`        | Delete all test files                                    |

Inside the panel or editor, `<Tab>` switches between input and expected output.
`]t`/`[t` move between tests, `<C-n>` adds one and `<C-x>` deletes one. `R`
replaces the pane with the clipboard, `<C-s>` saves and `q` closes.

To import problems, install the
[Competitive Companion](https://github.com/jmerle/competitive-companion)
browser extension and add `12345` under its custom ports. Press `<leader>ib`,
then click the green `+` on the problem page. The samples replace the
solution's existing tests.

## Flutter

[flutter-tools.nvim](https://github.com/nvim-flutter/flutter-tools.nvim) starts
the Dart language server itself and runs `flutter run` with hot reload on every
save. It uses the project's `.fvm/flutter_sdk` when the project pins a version
with fvm, and the `flutter` on `$PATH` otherwise. Saving `pubspec.yaml` runs
`pub get`. All keymaps are under `<leader>=`.

| Keys                          | Action                                         |
| ----------------------------- | ---------------------------------------------- |
| `<leader>=r` / `=D`           | Run / run under the debugger (nvim-dap)        |
| `<leader>=h` / `=H`           | Hot reload / hot restart                       |
| `<leader>=q`                  | Quit the app                                   |
| `<leader>=a` / `=A`           | Attach to / detach from a running app          |
| `<leader>=d` / `=e`           | Pick a device / an emulator                    |
| `<leader>=c`                  | Pick any flutter-tools command                 |
| `<leader>=v`                  | Switch the project's SDK with fvm              |
| `<leader>=o`                  | Widget outline                                 |
| `<leader>=l` / `=L`           | Dev log / clear it                             |
| `<leader>=w` / `=W`           | Widget previewer / stop it                     |
| `<leader>=p` / `=P`           | `pub get` / `pub upgrade`                      |
| `<leader>=s`                  | Go to the super class or method                |
| `<leader>=n`                  | Rename, also renaming the file and imports     |
| `<leader>=f`                  | Refactor actions (wrap / extract widget)       |
| `<leader>=i` / `=F`           | Organize imports / fix all                     |
| `<leader>=z` / `=x`           | Reanalyze the project / restart the Dart LSP   |
| `<leader>=tt` / `to`          | Start DevTools / open it in the browser        |
| `<leader>=ta` / `tc`          | Activate DevTools / copy the profiler URL      |

Debug overlays in the running app (the same as the keys in `flutter run`):

| Keys                          | Action                                         |
| ----------------------------- | ---------------------------------------------- |
| `<leader>=mi`                 | Widget inspector                               |
| `<leader>=md` / `mb`          | Debug paint / paint baselines                  |
| `<leader>=mr` / `mp`          | Repaint rainbow / performance overlay          |
| `<leader>=ms`                 | Slow animations                                |
| `<leader>=ml` / `mt`          | Light ↔ dark / cycle the target platform       |

Editor decorations are toggles that are remembered across restarts. They are
set up the first time a Dart file is opened.

| Keys                          | Action                                                   |
| ----------------------------- | -------------------------------------------------------- |
| `<leader>=ug`                 | Widget guides, tree lines between widgets (off by default) |
| `<leader>=ut`                 | Closing tags, the widget name after its closing `)`      |
| `<leader>=uc`                 | Document colors, swatches for `Colors.red` etc.          |
| `<leader>=us`                 | Color style: background → foreground → `■` swatch        |
| `<leader>=un`                 | Pop up a notification for app errors                     |
