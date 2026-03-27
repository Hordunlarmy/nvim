# Completion and AI

Config files:
- /home/horduntech/.config/nvim/lua/plugins/nvim_cmp.lua
- /home/horduntech/.config/nvim/lua/plugins/copilot.lua
- /home/horduntech/.config/nvim/lua/plugins/copilot_lualine.lua

References:
- https://github.com/hrsh7th/nvim-cmp
- https://github.com/zbirenbaum/copilot.lua

## nvim-cmp
Provides autocompletion for LSP, buffer, path, and snippets. This config keeps completion disabled by default and exposes a toggle:
- `leader ce` toggles completion on/off

## LuaSnip
LuaSnip powers snippet expansion. It is bundled as a dependency of nvim-cmp.

## Copilot
Copilot loads on InsertEnter and is enabled only if Node.js is present. The config adds a Tab mapping that accepts Copilot suggestions when visible, otherwise it inserts a normal Tab.

Copilot also integrates into the statusline via copilot-lualine.
