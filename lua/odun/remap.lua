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
vim.keymap.set("n", "<C-Left>", ":vertical resize +3<CR>", {silent = true, noremap = true})
vim.keymap.set("n", "<C-Right>", ":vertical resize -3<CR>", {silent = true, noremap = true})
vim.keymap.set("n", "<C-Up>", ":resize +3<CR>", {silent = true, noremap = true})
vim.keymap.set("n", "<C-Down>", ":resize -3<CR>", {silent = true, noremap = true})

-- Set esc to jj
vim.keymap.set("i", "jj", "<ESC>")

-- remap quit, save and save&&quit command
vim.keymap.set('n', 'qq', ':q!<CR>', { silent = true })
vim.keymap.set('n', 'wq', ':wq<CR>', { silent = true })
vim.keymap.set('n', 'ww', ':w<CR>', { silent = true })

-- Nvim-lint trigger
vim.api.nvim_set_keymap('n', '<Esc>', [[:Format<CR>:lua vim.defer_fn(function() require("lint").try_lint() end, 500)<CR>]], { noremap = true, silent = true })

-- Hover trigger
        vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim"})
        vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})

-- Code_Runner
vim.keymap.set('n', '<leader>r', ':RunCode<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>rf', ':RunFile<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>rft', ':RunFile tab<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>rp', ':RunProject<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>rc', ':RunClose<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>crf', ':CRFiletype<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>crp', ':CRProjects<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>c', ':!chmod u+rwx %<CR>', { noremap = true, silent = false })
