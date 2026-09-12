# Changelog

## [2026-09-13 00:29:34]

### Added
- Global quit/save shortcuts: `Q` to quit all buffers and `W` to save all and quit.
- Inline Git blame toggle (`<leader>gb`) shows subtle grey blame text only for the cursor line.
- Git blame line popup (`<leader>gB`) for full blame of the current line.
- Git diff all uncommitted changes vs HEAD side by side (`<leader>gc`).
- Git diff this vs previous commit side by side (`<leader>gT`).
- Bufferline path tooltip: hover over a tab to see the full file path in a small popup.
- Conjure REPL shortcuts banner shown in log buffers with instructions for `i`, `Ctrl+Enter`/`Ctrl+e`, `Enter`, and `q`.
- Conjure evaluation mappings: `<localleader>ee` (current form), `<localleader>er` (root form), `<localleader>eb` (buffer).
- REPL log input evaluation via `<CR>` in normal mode and `<C-CR>`/`<C-e>` in insert mode.
- Literal search-and-replace workflow with scope selection (buffer, project, folder) and review/apply preview.
- Clojure docstring generation via `<leader>cc` for `defn`, `defmacro`, and `defmulti`.
- PHP language server (`intelephense`) and formatter (`php-cs-fixer`).
- Java language server (`jdtls`) and formatter (`google-java-format`).
- Rust language server (`rust-analyzer`) with Clippy checks on save.
- Python linter (`ruff`) with fallback to `flake8`.
- Go linter (`golangci-lint`).
- PHP linter (`phpcs`).
- JavaScript/TypeScript linter preference for `eslint_d` with fallback to `eslint`.
- LSP definition preview (`<leader>gD`) showing a floating window with the definition context and optional save support.
- LSP go to declaration (`<leader>gC`).
- LSP definition in vertical split (`<leader>gS`).
- Enhanced hover documentation (`K`) with centered floating window and Tree-sitter disabled for stability.
- Definition jump highlight: briefly highlights the target word after jumping to a definition.
- Telescope `find_files` (`<leader>ff`) and Telescope commands picker (`<leader>fB`).
- NvimTree cursor line and opened folder highlights.
- Notes keymaps: open global note (`<leader>mn`), search notes (`<leader>mf`), search note contents (`<leader>mg`).

### Changed
- Git diff commands now use Neovim's native side-by-side diff mode via gitsigns instead of custom popups.
- `<leader>gb` toggles inline blame for the cursor line instead of showing full buffer blame.
- `<leader>gt` opens a side-by-side diff against the index instead of a popup.
- Bufferline left-click now focuses an already-visible window for the target buffer instead of replacing the current buffer.
- Bufferline highlights rewritten for better contrast: selected tab uses a distinct background, inactive tabs are muted.
- Statusline guard is now dormant by default to avoid incompatibility with Neovim 0.13 option APIs.
- Conform formatting can be toggled off for Clojure files via `clojure_formatting_enabled`.
- Conjure REPL connection now waits for nREPL readiness before evaluating, with retry attempts and a warning if it fails.
- Session restore (`<leader>qs`) simplified: keeps one editor window with a restored file, closes extra editor splits, and reopens NvimTree without disturbing Aerial.
- Telescope pickers switched from `cursor` theme to a centered single-window layout with `preview_width = 0.52`.
- Buffer search (`<leader>/`, `<A-f>`, `<M-f>`) now uses a compact layout without previewer.
- Mason LSP installer: Python server changed from `jedi_language_server` to `basedpyright` with workspace diagnostic mode.
- Go LSP settings: `staticcheck` enabled.
- Clojure LSP root detection simplified; `single_file_support` disabled.
- efm language server: Python linter switched to Ruff (with flake8 fallback); JS/TS linter switched to `eslint_d` (with eslint fallback).
- Which-key popup now uses Telescope's vertical keymaps picker instead of a custom dropdown.
- LSP keymaps reorganized: `<leader>gd` goes to definition, `<leader>gD` previews definition, `<leader>gS` opens in vertical split.

### Fixed
- Git diff popup now warns and aborts if the current buffer is modified, preventing stale diff output.
- Git diff errors now report the actual `stderr` reason instead of a generic message.
- Conjure evaluation no longer drops the first request while the REPL boots.
- Bufferline hover autocmds cleaned up on `VimLeavePre` to prevent tooltip window leaks.
- NvimTree opened-file highlight resyncs with the actual current buffer via `BufEnter`/`WinEnter` autocmds.
- Session restore no longer closes NvimTree or Aerial windows in the wrong positions.
- Clojure docstring generator checks for existing docstrings and reports when already present.
- Definition preview hover documentation disables Tree-sitter parsing to avoid crashes on injected code blocks.

### Removed
- Custom `util.git_popup` module usage for diff commands (replaced by gitsigns native diffthis).
- Grug-far floating-window conversion autocmd and custom keymaps; replaced with a lightweight literal search-and-replace workflow.
- `<leader>qd` (don't save session) mapping retained but simplified.
- Legacy bufferline highlight autocmd that forced all backgrounds transparent.
- Old LSP mappings: `<leader>fd` (Lspsaga finder), `<leader>gd` (peek definition), `<leader>gD` (goto definition), `<leader>gS` (vsplit goto definition) replaced by new LSP workflow.
- Telescope `cursor` theme usage across all pickers.
