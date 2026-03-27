# Aerial (Code Outline)

Config file:
- /home/horduntech/.config/nvim/lua/plugins/aerial.lua

References:
- https://github.com/stevearc/aerial.nvim

## What Aerial does
Aerial shows a structured outline of symbols (functions, classes, etc.) for the current buffer using LSP or Treesitter. It helps you navigate large files quickly and understand structure at a glance.

## Backends
This config enables both backends:
- LSP
- Treesitter

LSP is preferred for Clojure so that custom macros are recognized and can be mapped to Functions in the outline.

## Auto open behavior
Aerial auto-opens for real code buffers only. It is suppressed for special buffers (help, quickfix, tree, etc.), terminals, Conjure log buffers, and large files. Auto-open uses Aerial’s native `open_automatic` hook instead of a custom timer, which is more stable and prevents hangs.

## Keymaps
- `leader o` toggle Aerial outline
- `leader O` open Aerial navigation float

In the Aerial buffer:
- `q` or `Esc` closes Aerial safely
- `o` toggles node fold
- `O` toggles recursive fold
- `l` opens tree
- `h` closes tree

## Conjure integration
When the Conjure log is opened, Aerial is closed and its width is preserved. When the log closes, Aerial is restored in the same slot. This keeps the layout stable.

## Notes
If you see a warning that no backend is available, the current buffer does not have symbols (no LSP or Treesitter support). That is normal for non-code buffers.
