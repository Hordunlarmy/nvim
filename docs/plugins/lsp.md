# LSP and Diagnostics

Config file:
- /home/horduntech/.config/nvim/lua/plugins/nvim_lspconfig.lua
- /home/horduntech/.config/nvim/lua/util/lsp.lua
- /home/horduntech/.config/nvim/lua/config/remap.lua

References:
- https://github.com/neovim/nvim-lspconfig
- https://github.com/clojure-lsp/clojure-lsp

## What this LSP setup does
Neovim LSP provides diagnostics, go-to definition, completion data, hover, and code actions. This config uses nvim-lspconfig to set up multiple language servers and connects them to nvim-cmp for completion.

Diagnostics are configured to be readable but not overly noisy:
- virtual text is disabled
- signs and underlines are enabled by default
- floats are styled and show source

There is also a global and per-buffer diagnostics toggle system with persistence across restarts.

## Clojure LSP
The Clojure server used is `clojure-lsp`. This config:
- sets a cache path under `stdpath("cache")/clojure-lsp`
- sets `CLJ_KONDO_CACHE` for clj-kondo
- disables linting of project files immediately after startup
- ignores cache heavy folders (`target`, `node_modules`, etc.)
- disables single-file support to avoid heavy work in random scratch buffers

Key settings:
- `init_options["cache-path"]`: makes clojure-lsp reuse its cache
- `init_options["lint-project-files-after-startup?"] = false`

These settings reduce startup lag in larger Clojure projects.

## Diagnostics toggles
Keymaps are set up so you can turn diagnostics on/off quickly:
- `leader dt` toggles diagnostics for current buffer
- `leader dT` toggles diagnostics globally and persists across restarts
- `leader dk` toggles Clojure diagnostics only

State is saved under `stdpath("state")/diagnostics_state.json` so a global disable persists.

## Code actions
Global keymap:
- `leader ca` runs code actions via Lspsaga

## LSP servers configured
- Lua: `lua_ls`
- JSON: `jsonls`
- Python: `jedi_language_server`
- PHP: `intelephense`
- TypeScript/JavaScript: `ts_ls`
- Bash: `bashls`
- Docker: `dockerls`
- C/C++: `clangd`
- Go: `gopls`
- Clojure: `clojure_lsp`
- EFM (conditional): `efm` only if installed

## EFM language server
EFM is configured only when `efm-langserver` is installed, and then only for linters that are actually present on the machine. This avoids slow startup or noisy errors.

## Common LSP issues
- If LSP doesn’t attach, check `:LspInfo` for server status and root directory.
- For Clojure, if classpath resolution is slow, make sure `project.clj` or `deps.edn` is in the root and that the cache is writable.
- If diagnostics are stuck disabled, use `leader dT` to re-enable globally.
