# which-key

Config file:
- /home/horduntech/.config/nvim/lua/plugins/which_key.lua

Reference:
- https://github.com/folke/which-key.nvim

## What which-key does
which-key shows a popup with possible key bindings after you press a prefix key (like `leader`). It makes key discovery and learning easier.

## Behavior in this config
- Popup delay is immediate (delay = 0)
- Triggers are manually defined for `leader` and `localleader`
- The popup is styled with rounded borders and padding
- Which-key descriptions are registered for many mappings for searchability

## Useful mappings
- `leader` shows the key map popup
- `leader ?` shows buffer-local keymaps
- `leader leader` opens a telescope keymap search
- `leader fC` filters to Clojure-related keymaps

If which-key feels slow, it is usually caused by mappings that trigger expensive callbacks. This config keeps the popup immediate and avoids running heavy functions during the popup itself.
