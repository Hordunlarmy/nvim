---@diagnostic disable: inject-field
-- change leader key to space
vim.g.mapleader = " "

-- map explorer command to make it easier to open
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- moving selection up and down (intelligently)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- keep cursor in center while jumping half pages
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- better replace: doesn't overwrite your copy buffer when you use it
vim.keymap.set("x", "<leader>p", '"_dP')

-- ability to copy to system clipboard
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- ability to delete line without copying
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

-- move between splits more easily
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- resize panes more easily
vim.keymap.set("n", "<C-Left>", ":vertical resize +3<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-Right>", ":vertical resize -3<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-Up>", ":resize +3<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-Down>", ":resize -3<CR>", { silent = true, noremap = true })

-- Set esc to jj
vim.keymap.set("i", "jj", "<ESC>")

-- remap quit, save and save&&quit command
vim.keymap.set('n', 'qq', ':q!<CR>', { silent = true })
vim.keymap.set('n', 'wq', ':wq!<CR>', { silent = true })
vim.keymap.set('n', 'ww', ':w<CR>', { silent = true })


-- -- Code_Runner
vim.keymap.set('n', '<leader>r', ':RunCode<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>rf', ':RunFile<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>rft', ':RunFile tab<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>rp', ':RunProject<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>rc', ':RunClose<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>crf', ':CRFiletype<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>crp', ':CRProjects<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>c', ':!chmod u+rwx %<CR>', { noremap = true, silent = false })

-- reload / source init.lua
vim.api.nvim_set_keymap('n', '<leader>so',
  ':so ~/.config/nvim/lua/init.lua | lua vim.defer_fn(function() vim.cmd("NvimTreeToggle") end, 100)<CR>',
  { noremap = true, silent = true })


-- Keybinding for Telescope live_grep to Ctrl+f
-- Helper function to get visual selection
function _G.get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.fn.getline(s_start[2], s_end[2])
  lines[1] = string.sub(lines[1], s_start[3])
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

vim.api.nvim_set_keymap('v', '<C-f>',
  [[<cmd>lua require('telescope.builtin').live_grep({ default_text = get_visual_selection() })<CR>]],
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-f>', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })

-- Example key mapping for generating documentation with vim-doge
vim.api.nvim_set_keymap('n', '<Leader>d', ':DogeGenerate<CR>', { noremap = true, silent = true })

-- Indenting
vim.keymap.set("v", "<", "<gv", { silent = true, noremap = true })
vim.keymap.set("v", ">", ">gv", { silent = true, noremap = true })
