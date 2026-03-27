# Telescope

Config file:
- /home/horduntech/.config/nvim/lua/plugins/nvim_telescope.lua
- /home/horduntech/.config/nvim/lua/config/remap.lua

Reference:
- https://github.com/nvim-telescope/telescope.nvim

## What Telescope does
Telescope provides fuzzy finding and pickers for files, text search, keymaps, diagnostics, and more.

## Keymaps
- `leader /` current buffer fuzzy find
- `Alt f` current buffer fuzzy find
- `Ctrl f` live grep
- `Ctrl p` git files
- `leader fb` buffers
- `leader fo` old files
- `leader fk` keymaps
- `leader fh` command history
- `leader fs` grep string
- `leader ft` treesitter symbols

These keymaps are defined in the telescope plugin spec and in remap.lua.

## Picker configuration
- layout strategy: centered
- width/height: 85% of editor
- live_grep adds `--hidden` and `--no-ignore-vcs`

## Notes
If Alt key mappings do not work in your terminal, check the terminal configuration for sending Meta/Alt as ESC-prefixed sequences. `ttimeoutlen` also affects Alt key recognition in Neovim.
