# Formatting and Linters

Config files:
- /home/horduntech/.config/nvim/lua/plugins/conform.lua
- /home/horduntech/.config/nvim/lua/plugins/formatter.lua
- /home/horduntech/.config/nvim/lua/plugins/efmls_configs_nvim.lua

References:
- https://github.com/stevearc/conform.nvim
- https://github.com/mhartington/formatter.nvim
- https://github.com/creativenull/efmls-configs-nvim

## Conform
Conform provides formatting integrations and a clean API for format-on-save or explicit formatting. This config uses Conform for the main formatting flow, and makes formatting quiet to avoid disruptive popups.

## Formatter.nvim
Formatter is present but not necessarily used for all languages; it is configured in case specific formatters are needed beyond Conform.

## EFM
EFM is enabled only when `efm-langserver` is installed and only for linters/formatters that are present. This prevents noisy errors and saves startup time.

## Clojure formatting
If `zprint` is installed (via Mason), Conform can run it for Clojure. The setup avoids throwing errors when formatters are missing.
