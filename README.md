# 🚀 Modern Neovim Configuration

A sleek, powerful Neovim setup with 55+ carefully selected plugins for maximum productivity.

## 🎯 Quick Start


1. **Open Neovim** - Plugins auto-install on first launch (takes 2-3 minutes)
2. **Wait for LSP servers to install** - Mason automatically installs 13 essential LSP servers
3. **Restart Neovim** (optional, after first install)
4. **Press `<Space>`** and wait - Which-Key shows all commands (A-Z sorted)
5. **Press `<Space><Space>`** - Search ANY keybinding instantly! 🔍
6. **Start coding!**

Leader key: `<Space>`

**✨ Modern Floating UI:** Panels (Spectre, Mason, Lazy, Telescope) open as beautiful **centered, opaque floating overlays** that **use the exact same background color as your editor** with **clean white borders**! nvim-tree opens as a left side panel, Aerial auto-opens on the right side.

### What Gets Auto-Installed:

**LSP Servers (13):**
- lua_ls, ts_ls, jedi_language_server, bashls, jsonls, html, cssls, yamlls, dockerls, marksman, emmet_ls, efm

**Formatters & Linters (10):**
- prettier, stylua, black, isort, shfmt, eslint_d, pylint, shellcheck, markdownlint, debugpy

**Total: 60+ plugins + 23 tools = Complete development environment!**

---

## 📦 Plugin Guide

### 🔑 Which-Key
**What it does:** Shows a popup with available keybindings when you press a key
- Press `<Space>` and wait a moment to see all leader key options (A-Z sorted!)
- **`<Space><Space>`** - **Search ALL keybindings** (Telescope fuzzy search!) 🔍
- `<leader>?` - Show buffer-local keymaps
- `<leader>fk` - Search keymaps (alternative)
- Helps you discover keyboard shortcuts
- No need to memorize every command!

### 🎯 Harpoon 2
**What it does:** Quick file navigation - mark and jump between your most important files
- `<leader>ha` - Add current file to harpoon
- `<leader>hr` - **Remove current file from harpoon** 🗑️
- `<leader>hc` - **Clear ALL harpoon files** 🗑️
- `<leader>hh` - Show harpoon quick menu
- `<leader>h1` to `<leader>h4` - Jump to marked files 1-4
- `<leader>hn` / `<leader>hp` - Next/Previous marked file

### ⚡ Flash.nvim
**What it does:** Navigate your code with search labels, enhanced character motions
- `s` - Flash jump (shows labels to jump anywhere visible)
- `S` - Flash treesitter (jump to syntax nodes)
- `f`, `F`, `t`, `T` - Enhanced character motions with jump labels
- `r` - Remote flash (in operator mode)
- `R` - Treesitter search

### 🌲 Nvim-tree
**What it does:** File explorer sidebar with git integration - **OPENS AUTOMATICALLY!**
- **Auto-opens** when you start Neovim (shows on left side, cursor stays in main buffer)
- `<Ctrl-n>` - Toggle file tree
- Shows git status, diagnostics
- Navigate with `hjkl`, press `Enter` to open files
- `a` - Create file, `d` - Delete, `r` - Rename
- Opens as side panel (not floating)

### 🔭 Telescope
**What it does:** Fuzzy finder for files, text, and more
- `<Alt-f>` - Find all files
- `<Ctrl-p>` - Find git files
- `<Ctrl-f>` - Live grep (search text in files)
- `<leader>/` - Search in current buffer
- `<leader>fb` - Show buffers
- `<leader>fj` - Help tags
- `<leader>fh` - Command history
- `<leader>fk` - Show keymaps
- `<leader>fl` - LSP references
- `<leader>fo` - Old/recent files
- `<leader>fs` - Grep string under cursor
- `<leader>ft` - Treesitter symbols (also shows TODO comments)
- `<leader>ff` - Show all builtin functions
- `<leader>fq` - Quickfix list
- `<leader>fy` - Yank history

### 📝 TODO Comments
**What it does:** Highlight and search for todo comments like TODO, HACK, BUG, FIXME
- `]t` - Jump to next todo comment
- `[t` - Jump to previous todo comment
- `<leader>ft` - Find all todos with Telescope
- Automatically highlights: TODO, FIXME, BUG, HACK, WARN, PERF, NOTE, TEST

### 💾 Persistence
**What it does:** Session management - save and restore your workspace
- `<leader>qs` - Restore session for current directory
- `<leader>ql` - Restore last session
- `<leader>qw` - **Save session NOW** (manual save) 💾
- `<leader>qd` - Don't save current session
- Auto-saves your session on exit

### 🔄 Mini.surround
**What it does:** Add/delete/replace surroundings (brackets, quotes, tags)
- `gsa` - Add surrounding (e.g., `gsaiw"` surrounds word with quotes)
- `gsd` - Delete surrounding (e.g., `gsd"` removes quotes)
- `gsr` - Replace surrounding (e.g., `gsr"'` replaces " with ')
- `gsf` - Find surrounding (to the right)
- `gsF` - Find surrounding (to the left)
- `gsh` - Highlight surrounding
- `gsn` - Update n_lines

### 🎯 Mini.ai
**What it does:** Extend and create a/i textobjects (like di( or va")
- `vaf` / `daf` / `caf` - Select/delete/change around function
- `vif` / `dif` / `cif` - Select/delete/change inside function
- `vac` / `dac` / `cac` - Select/delete/change around class
- `vic` / `dic` / `cic` - Select/delete/change inside class
- Works with all vim motions (v=select, d=delete, c=change, y=yank)

### 🔍 Grug-far
**What it does:** Modern search and replace - MUCH better than spectre!
- `<leader>sr` - Open search/replace panel
- `<leader>sw` - Search and replace current word (auto-fills search!)
- `<leader>sf` - Search and replace in current file only

**How to use (super simple!):**
1. **Open:** `<leader>sr` (or `<leader>sw` on a word)
2. **Type search:** Just start typing (no insert mode needed!)
3. **Type replacement:** `<Tab>` to next field, type replacement
4. **See live preview:** Results update as you type! ✨
5. **Replace:** Press `<leader>r` - Done! 🎉
   - `<leader>r` - Replace all matches
   - `<Enter>` - Jump to file
   - `q` - Close window

### 🔀 Vim-matchup
**What it does:** Better % navigation and matching for brackets, if/else, functions
- `%` - Jump between matching pairs (brackets, if/endif, function/end, etc.)
- Shows matching pairs with highlighting
- Works with HTML tags, functions, classes, and more
- Popup shows matching line when off-screen

### 👗 Dressing.nvim
**What it does:** Better UI for vim.ui.select and vim.ui.input
- Makes all input prompts beautiful
- Uses Telescope for selections automatically
- Better rename dialogs, code actions, etc.
- Integrates seamlessly with other plugins

### 📊 Bufferline
**What it does:** VSCode-like buffer/tab line at the top of the screen
- `<Tab>` - Next buffer
- `<Shift-Tab>` - Previous buffer
- `<leader>bp` - Pick a buffer interactively
- `<leader>bc` - Pick and close a buffer
- `<leader>bd` - Delete current buffer (safe close)
- `<leader>bl` - Close all buffers to the right
- `<leader>bh` - Close all buffers to the left
- Click ✕ button to close individual buffers (safe, won't quit Neovim)
- Shows diagnostics, git status, and modifications
- Background matches your terminal perfectly

### 📖 Markdown Preview
**What it does:** Preview markdown files in browser with live updates
- `<leader>mp` - Toggle markdown preview
- Live updates as you type
- Perfect for README files, documentation
- Supports GitHub-flavored markdown

### 🔔 Nvim-notify
**What it does:** Beautiful notification system for Neovim
- `<leader>un` - Dismiss all notifications
- Shows plugin updates, LSP status, errors
- Non-intrusive floating notifications
- Customizable timeout and position
- Integrates with other plugins

### 🗺️ Aerial
**What it does:** Code outline sidebar showing symbols and structure - **OPENS AUTOMATICALLY!**
- **Auto-opens** when you open a code file (shows on the right side)
- `<leader>o` - Toggle outline (Aerial) - **MAIN KEYBINDING**
- `<leader>O` - Toggle Aerial navigation (floating)
- `q` or `<ESC>` - Close aerial
- Shows functions, classes, variables, etc.
- Navigate large files easily
- `<Enter>` - Jump to symbol
- `o` - Toggle fold
- `{` / `}` - Previous/Next symbol
- Gives you a file overview instantly!

### 🌙 Twilight
**What it does:** Dims inactive portions of code
- `<leader>tw` - Toggle twilight (press again to turn off!)
- Highlights only current block
- Helps focus on current code
- Great for reading large files

### 🌊 Neoscroll
**What it does:** Smooth scrolling animations
- `<Ctrl-Up>`, `<Ctrl-Down>` - Smooth scroll up/down (custom bindings!)
- `<Ctrl-b>` - Smooth page up
- `zt`, `zz`, `zb` - Smooth reposition
- Makes navigation feel fluid
- Note: `<Ctrl-f>` is used for Telescope search, not scrolling

### 📐 Indent-blankline
**What it does:** Shows indent guides
- Displays vertical lines for indentation levels
- Makes code structure more visible
- Subtle and clean (no scope highlighting)

### 🚀 Alpha Dashboard
**What it does:** Beautiful start screen when you open Neovim
- Shows ASCII art logo
- Quick actions:
  - `f` - Find files
  - `r` - Recent files
  - `c` - Config (opens init.lua and navigates nvim-tree to config folder)
  - `s` - Restore session
  - `l` - Lazy plugin manager
  - `q` - Quit
- Shows plugin count and Neovim version
- Appears when opening Neovim without a file

### 📦 Better Quickfix (nvim-bqf)
**What it does:** Enhanced quickfix window with preview
- Automatic preview of search results
- Better navigation in quickfix list
- Fzf integration for filtering
- Works with Telescope results

### 📋 Yanky
**What it does:** Advanced yank/paste with history
- `y` - Yank text (improved)
- `p` / `P` - Put yanked text after/before cursor
- `<Ctrl-n>` / `<Ctrl-p>` - Cycle through yank history after pasting
- `[p` / `]p` - Put with automatic indentation
- `<leader>fy` - Show yank history in Telescope
- Never lose copied text again!

### 📏 Indent-o-matic
**What it does:** Auto-detect indentation style
- Automatically detects tabs vs spaces
- Detects indent width (2 or 4 spaces)
- Per-filetype configuration
- Works alongside vim-sleuth

### 🔧 Vim-sleuth
**What it does:** Automatically adjusts shiftwidth and expandtab
- Detects indentation from file content
- No configuration needed
- Works silently in the background
- Essential for working on different projects

### ⚡ ToggleTerm
**What it does:** Better terminal integration with multiple modes
- `<Ctrl-\>` - Toggle terminal
- `<leader>tf` - Terminal in floating window
- `<leader>th` - Terminal in horizontal split
- `<leader>tv` - Terminal in vertical split
- Run commands without leaving Neovim

### 📘 Git-blame
**What it does:** Shows git blame information inline
- `<leader>gb` - Toggle git blame
- See who wrote each line and when
- Shows commit message inline
- Non-intrusive display

### 🌳 Treesitter
**What it does:** Advanced syntax highlighting and code understanding
- Better syntax highlighting than regex
- Incremental selection with `<Ctrl-s>`
- Powers many other plugins (aerial, flash, ufo)
- Auto-installs parsers for languages
- Supports: Python, JavaScript, TypeScript, Lua, Rust, Go, and 30+ more

### 🔧 Mason
**What it does:** Package manager for LSP servers, formatters, linters - **AUTO-INSTALLS ESSENTIALS!**
- `:Mason` - Open Mason UI to see installed tools
- **Automatically installs 23 essential tools on first launch**
- `i` - Install additional servers
- `u` - Update server
- `X` - Uninstall server
- `U` - Update all packages
- One-stop shop for all development tooling

### 💡 LSP Config
**What it does:** Configure Language Server Protocol for code intelligence
- `gd` - Go to definition
- `gr` - Show references
- `K` - Hover documentation
- `<leader>rn` - Rename symbol
- `[d` / `]d` - Previous/Next diagnostic
- Provides autocomplete, diagnostics, formatting
- Supports 50+ languages

### 🎯 LSP Saga
**What it does:** Better LSP UI with floating windows
- Beautiful code action UI
- Hover documentation with markdown
- Better rename UI
- Outline and diagnostic navigation
- Prettier than default LSP UI

### 💬 Nvim-cmp
**What it does:** Autocompletion engine
- Tab-based completion
- Sources: LSP, buffer, path, snippets
- Intelligent suggestions
- Integrates with Copilot

### 🤖 Copilot
**What it does:** GitHub Copilot AI code suggestions
- AI-powered code completion
- Suggests entire functions
- Learn from context
- Accepts suggestions with Tab

### 🐛 DAP (Debug Adapter Protocol)
**What it does:** Debugging support for multiple languages
- Set breakpoints in code
- Step through execution
- Inspect variables
- Supports Python, JavaScript, and more

### ✅ Nvim-autopairs
**What it does:** Auto-closes brackets, quotes, and parentheses
- Type `(` and get `()` with cursor in middle
- Type `"` and get `""` 
- Works with all bracket types
- Smart deletion

### 🎨 Rainbow Delimiters
**What it does:** Colors matching brackets in different colors
- Makes nested code easier to read
- Each bracket level has different color
- Helps spot mismatched brackets
- Works with treesitter

### 💡 Vim-illuminate
**What it does:** Highlights other uses of word under cursor
- Automatically highlights matching words
- Shows variable usage across file
- Helps understand code flow
- LSP-aware

### 📝 Comment.nvim
**What it does:** Smart code commenting
- `gcc` - Toggle line comment
- `gbc` - Toggle block comment
- `gc` (visual mode) - Comment selection
- Language-aware comments

### 🔗 Gitsigns
**What it does:** Git integration showing changes in sign column
- Shows added/modified/removed lines in gutter
- `]h` / `[h` - Next/Previous git hunk
- `<leader>gs` - Git stage hunk (works in visual mode too!)
- `<leader>gsa` - Git stage all (entire buffer)
- `<leader>gr` - Git reset hunk (works in visual mode too!)
- `<leader>gra` - Git reset all (entire buffer)
- `<leader>gp` - Git preview hunk (popup)
- `<leader>gb` - Git blame line (full)
- `<leader>gt` - Git diff this
- `<leader>gu` - Git undo stage hunk
- `<leader>tb` - Toggle inline git blame
- `<leader>tg` - Toggle show deleted lines

### 🎭 Transparent
**What it does:** Makes Neovim background transparent
- Shows your terminal background
- Keeps syntax colors
- Toggle with config

### ⚠️ Trouble
**What it does:** Pretty list for diagnostics, references, quickfix
- `<leader>xx` - Toggle trouble
- `<leader>xw` - Workspace diagnostics
- `<leader>xd` - Document diagnostics
- `<leader>xq` - Quickfix list
- `<leader>xl` - Location list
- `gR` - LSP references

### 📊 Lualine
**What it does:** Beautiful statusline at bottom of screen
- Shows mode, file, git branch
- LSP status, diagnostics
- File encoding, position
- Integrates with Copilot

### 🧪 Refactoring
**What it does:** Code refactoring tools
- Extract function/variable
- Inline variable
- Extract block
- Language-specific refactorings

### 📄 Lazydev
**What it does:** Better Lua development in Neovim
- Neovim API completion
- vim.* completion
- Plugin development helpers

### 🎯 Noice
**What it does:** Better UI for messages, cmdline, and popups
- Beautiful command line UI
- Better message notifications
- Integrates with notify
- Modern looking interface

### 📝 Neogen
**What it does:** Smart documentation/annotation generator (Treesitter-based)
- `<leader>cc` - Auto-generate documentation (double-tap c) - **MAIN**
- `<leader>cf` - Generate function documentation
- `<leader>cl` - Generate class documentation  
- `<leader>ct` - Generate type documentation
- `<leader>ci` - Generate file header
- Supports: Python (Google style), JavaScript/TypeScript (JSDoc), Rust, Go, Lua, and more
- Treesitter-powered - understands your code structure
- Auto-detects parameters, return types, and more

### 📝 Avante
**What it does:** AI-powered code assistance (if configured)
- AI chat interface
- Code suggestions
- Refactoring help
- Modern AI integration

### 💻 FTerm
**What it does:** Floating terminal
- Quick terminal popup
- Run commands without splits
- Clean interface

### ✨ Formatter
**What it does:** Code formatting for multiple languages
- Format on save (if configured)
- Supports: prettier, black, gofmt, etc.
- Integrates with Mason

### 📐 nvim-ts-autotag
**What it does:** Auto-close and auto-rename HTML/JSX tags
- Type `<div>` get `<div></div>`
- Rename opening tag, closing updates
- Works with React/Vue

---

## 🎯 Essential Keybindings Summary

### Navigation
- `<Space>` (hold) - Show all commands (Which-Key, A-Z sorted)
- `<Space><Space>` - **Search ALL keybindings** 🔍
- `s` - Flash jump anywhere
- `<Alt-f>` - Find files
- `<Ctrl-p>` - Git files
- `<Ctrl-f>` - Search text in files
- `<Ctrl-n>` - Toggle nvim-tree
- `<leader>o` - Code outline (Aerial)

### Editing
- `<ESC>` - Exit insert mode (use the ESC key)
- `gsa` - Add surround
- `gsd` - Delete surround
- `gsr` - Replace surround
- `gcc` - Toggle comment

### Harpoon (Quick Files)
- `<leader>ha` - Add file
- `<leader>hh` - Show menu
- `<leader>h1-4` - Jump to file 1-4

### Buffers & Windows
- `<Tab>` / `<Shift-Tab>` - Next/Prev buffer
- `<Ctrl-h/j/k/l>` - Navigate splits
- `<Ctrl-Left/Right/Up/Down>` - Resize splits

### Search & Replace
- `<leader>sr` - Search/replace project
- `<leader>sw` - Search/replace word
- `<leader>ft` - Find TODOs

### Focus & UI
- `<leader>tw` - Toggle Twilight (dim inactive code)
- `<leader>un` - Dismiss notifications

### Sessions
- `<leader>qs` - Restore session
- `<leader>ql` - Restore last session
- `<leader>qw` - Save session NOW (manual)

### Terminal
- `<Ctrl-\>` - Toggle terminal
- `<leader>tf` - Float terminal
- `<leader>th` - Horizontal terminal

### LSP
- `gd` - Go to definition
- `gr` - References
- `K` - Hover docs
- `[d` / `]d` - Next/Prev diagnostic

### Trouble (Diagnostics)
- `<leader>xx` - Toggle trouble
- `<leader>xw` - Workspace diagnostics
- `<leader>xd` - Document diagnostics

---

## 🚀 Getting Started

1. **Restart Neovim** - All plugins will auto-install
2. **Press `<Space>`** - Explore with Which-Key
3. **Try Flash** - Press `s` and see the magic
4. **Mark files with Harpoon** - `<leader>ha` on your core files

## 💡 Pro Tips

1. **Master Which-Key first** - It teaches you everything else
2. **Use Flash** - Press `s` for lightning-fast navigation
3. **Use Harpoon** - Mark your 3-4 most-used files
4. **Leave TODOs** - Find them with `<leader>ft`
5. **Try Twilight** - `<leader>tw` for focused reading

## 🔧 Management

- `:Lazy` - Plugin manager (update/install plugins)
- `:Mason` - View installed LSP servers (auto-installs 23 tools on startup)
- `:MasonToolsUpdate` - Update all Mason tools
- `:checkhealth` - Diagnose issues
- `:Telescope` - Explore all Telescope features

### First Launch

On your **first launch**, Neovim will:
1. Install all plugins (via Lazy) - ~60 plugins
2. Install LSP servers (via Mason) - 13 servers
3. Install formatters & linters (via Mason) - 10 tools
4. **Total setup time: 2-3 minutes**

Just open Neovim and wait! ☕

## 🎨 Theme

**Current:** GitHub Dark (clean, professional)
**Transparent background** - Shows your terminal background through

---

## 🌐 Languages Supported Out of the Box

After auto-installation, you get full LSP support for:

| Language | LSP Server | Formatter | Linter |
|----------|-----------|-----------|--------|
| **Lua** | lua_ls | stylua | ✅ |
| **JavaScript/TypeScript** | ts_ls | prettier | eslint_d |
| **Python** | jedi_language_server | black + isort | pylint |
| **HTML** | html | prettier | ✅ |
| **CSS** | cssls | prettier | ✅ |
| **JSON** | jsonls | prettier | ✅ |
| **YAML** | yamlls | prettier | ✅ |
| **Bash** | bashls | shfmt | shellcheck |
| **Markdown** | marksman | prettier | markdownlint |
| **Dockerfile** | dockerls | ✅ | ✅ |

**Want more?** Just uncomment in `mason_lspconfig.lua`:
- Go → `gopls`
- PHP → `intelephense`
- C/C++ → `clangd`
- Rust → `rust_analyzer`

---

## 📊 Stats

```
Plugins:        60+
LSP Servers:    13 (auto-installed)
Formatters:     6 (auto-installed)
Linters:        5 (auto-installed)
Debuggers:      1 (auto-installed)
Total Tools:    85+
Setup Time:     2-3 minutes
```

---

**Happy Coding! 🎉**

*Remember: Press `<Space>` to browse, or `<Space><Space>` to search any keybinding!*
