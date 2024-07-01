vim.opt.guicursor = ""

-- Enable line numbers and make them relative initially
vim.wo.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Define autocmd for Python files
vim.cmd([[
  autocmd FileType python
        \ setlocal tabstop=4 |
        \ setlocal softtabstop=4 |
        \ setlocal shiftwidth=4 |
        \ setlocal expandtab
]])

-- Define autocmd for JavaScript files
vim.cmd([[
  autocmd FileType javascript
        \ setlocal tabstop=2 |
        \ setlocal softtabstop=2 |
        \ setlocal shiftwidth=2 |
        \ setlocal expandtab
]])

-- Define autocmd for JavaScript files
vim.cmd([[
  autocmd FileType lua
        \ setlocal tabstop=2 |
        \ setlocal softtabstop=2 |
        \ setlocal shiftwidth=2 |
        \ setlocal expandtab
]])


vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = false

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

vim.o.completeopt = "menuone,noselect"

-- Enable system clipboard
vim.opt.clipboard = "unnamedplus"

-- ignore case when searching
vim.opt.ignorecase = true

-- automatically switch to case-sensitive if a capital letter is used
vim.opt.smartcase = true

-- make new splits go below and to the right of the current pane
vim.cmd("set splitright splitbelow")

-- make vertical split filler just empty (is '|' by default)
--vim.cmd("set fillchars+=vert:\\ ")

-- set background to transparent
vim.g.transparent_enabled = true

-- Enable mouse support
vim.o.mouse = 'a'

-- Enable syntax highlighting
vim.cmd('syntax enable')

-- Enable file type detection
vim.cmd('filetype on')

-- Enable auto-indentation
vim.o.autoindent = true

-- Set clipboard option to always use the system clipboard
vim.api.nvim_set_option('clipboard', 'unnamedplus')
-- Stop newline continuation of comments
vim.api.nvim_command('set formatoptions-=cro')

-- Configure Hexokinase highlighters
vim.g.Hexokinase_highlighters = { 'backgroundfull' }
vim.g.Hexokinase_highlighters = { 'foregroundfull' }

-------------------Other Utils---------------------------
---------------------------------------------------------
vim.cmd([[ let extension = expand('%:e') ]])
vim.cmd([[ set encoding=utf8 ]])
vim.cmd([[ set nu! ]])
vim.cmd([[ set mouse=a ]])
vim.cmd([[ set wildmenu ]])
vim.cmd([[ set confirm ]])
vim.cmd([[ set incsearch ]])
vim.cmd([[ set title ]])
vim.cmd([[ set t_Co=256 ]])
vim.cmd([[ set shiftwidth=4 ]])
vim.cmd([[ set softtabstop=4 ]])
vim.cmd([[ set expandtab ]])
vim.cmd([[ set shiftwidth=4 ]])
vim.cmd([[ set softtabstop=4 ]])
vim.cmd([[ set expandtab ]])
vim.cmd([[ set guicursor= ]])
vim.cmd([[ set cursorline ]])
vim.cmd([[ syntax on ]])
vim.cmd([[ set termguicolors ]])

