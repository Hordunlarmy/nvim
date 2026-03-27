# Treesitter

Config file:
- /home/horduntech/.config/nvim/lua/plugins/nvim-treesitter.lua

Reference:
- https://github.com/nvim-treesitter/nvim-treesitter

## What Treesitter does
Treesitter provides fast, incremental parsing for code. Plugins use it for syntax highlighting, folding, text objects, and symbol extraction.

## How it is used here
- Aerial uses Treesitter as a backend when LSP symbols are not available.
- Telescope can use Treesitter for symbol browsing.
- Some plugins (like lspsaga and matchup) benefit from Treesitter data.

## Notes
If Treesitter-based highlighting is slow or broken, update parsers with:
- `:TSUpdate`
