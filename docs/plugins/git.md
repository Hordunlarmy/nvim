# Git Integration

Config file:
- /home/horduntech/.config/nvim/lua/plugins/gitsigns.lua

Reference:
- https://github.com/lewis6991/gitsigns.nvim

## What Gitsigns does
Gitsigns shows git changes in the gutter and provides hunk operations for staging, previewing, and navigation.

## Keymaps
- `]h` next hunk
- `[h` previous hunk
- `leader gs` stage hunk
- `leader gr` reset hunk
- `leader gsa` stage buffer
- `leader gu` undo stage hunk
- `leader gra` reset buffer
- `leader gp` preview hunk
- `leader gb` blame line
- `leader gt` diff this
- `leader gT` diff this ~

## Notes
Gitsigns loads on file open and does not block startup.
