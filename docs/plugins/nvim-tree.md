# NvimTree

Config file:
- /home/horduntech/.config/nvim/lua/plugins/nvim_tree.lua
- /home/horduntech/.config/nvim/lua/config/autocmd.lua

Reference:
- https://github.com/nvim-tree/nvim-tree.lua

## What NvimTree does
NvimTree is a file explorer sidebar for Neovim. It keeps a project tree visible and provides quick navigation and file operations.

## Behavior in this config
- Opens on startup
- Focus returns to the main editing window
- Cursor hijack is enabled
- Root is synced with current working directory
- Diagnostics in the tree are enabled based on diagnostics global state

## Key points
- View width is fixed at 30
- Tree is on the left
- Diagnostics and git icons are shown
- Tree updates focused file and root

## Diagnostics integration
Diagnostics display in the tree is tied to the global diagnostics toggle. When diagnostics are disabled globally, tree diagnostics are also disabled.

## Notes
If NvimTree is the only window left, the config attempts to close Neovim to avoid a stuck layout with only the tree visible.
