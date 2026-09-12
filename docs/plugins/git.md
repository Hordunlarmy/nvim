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
- `leader gb` toggle inline blame for the cursor line
- `leader gB` blame current line (full popup)
- `leader gc` diff all uncommitted changes against `HEAD`
- `leader gt` diff unstaged changes side by side
- `leader gT` diff this against the previous commit side by side

## Notes
Gitsigns loads on file open and does not block startup. The side-by-side diff
views use Neovim's native diff mode. `leader gt` compares against the index;
`leader gc` compares the current file against `HEAD`, including staged and
unstaged changes. `leader gb` shows subtle grey blame text only for the line
under the cursor.
