-- Enable cursor with SUPER THICK design and blinking!
vim.opt.guicursor = {
  "n-v-c:block-Cursor-blinkwait500-blinkoff400-blinkon400",      -- Block cursor in normal (blinking)
  "i-ci-ve:ver100-Cursor-blinkwait500-blinkoff400-blinkon400",   -- FULL WIDTH bar in insert (100% = block!, blinking)
  "r-cr-o:hor50-Cursor-blinkwait500-blinkoff400-blinkon400",     -- Thick horizontal bar in replace (blinking)
}

-- Cursor colors are now handled by mode_colors.lua
-- They change dynamically based on mode (white/green/purple/red/yellow/cyan)

-- MINIMALIST: Only show line number on CURRENT line (where cursor is)
vim.wo.number = true            -- Enable line numbers
vim.wo.relativenumber = false   -- Disable relative numbers
vim.wo.cursorline = true        -- Highlight current line
vim.wo.cursorlineopt = "number" -- Only highlight the line NUMBER, not the whole line

-- Line number colors are now handled by mode_colors.lua
-- They change dynamically based on mode (white/green/purple/red/yellow/cyan)

-- Set numberwidth to give space for numbers
vim.opt.numberwidth = 4

-- Right margin is handled by right_padding.lua
-- Adds 20 character padding on the right side of code buffers

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.laststatus = 3


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

-- Define autocmd for PHP files
vim.cmd([[
  autocmd FileType php
        \ setlocal tabstop=4 |
        \ setlocal softtabstop=4 |
        \ setlocal shiftwidth=4 |
        \ setlocal expandtab |
        \ setlocal noexpandtab
]])

-- Define autocmd for Makefiles (MUST use TABS, not spaces!)
vim.cmd([[
  autocmd FileType make
        \ setlocal tabstop=4 |
        \ setlocal softtabstop=0 |
        \ setlocal shiftwidth=4 |
        \ setlocal noexpandtab
]])

-- Also catch any file named "Makefile", "makefile", "GNUmakefile"
vim.cmd([[
  autocmd BufRead,BufNewFile Makefile,makefile,*.mk,GNUmakefile
        \ setlocal tabstop=4 |
        \ setlocal softtabstop=0 |
        \ setlocal shiftwidth=4 |
        \ setlocal noexpandtab
]])



vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.colorcolumn = ""  -- No column marker

vim.o.completeopt = "menuone,noselect"

-- Set timeoutlen for keymaps
vim.opt.timeoutlen = 1000

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

-- set background to transparent for main editor, but NOT for floating windows
vim.g.transparent_enabled = true  -- Keeps main background transparent
-- Floating windows will be opaque via borders.lua config

-- Enable mouse support
vim.o.mouse = 'a'

-- Suppress recording messages (recording @w, etc.) and mode messages
vim.opt.shortmess:append("q")  -- Don't show recording messages

-- Hide mode messages (-- INSERT --, -- VISUAL --, etc.) - shown in statusline instead
vim.opt.showmode = false

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
vim.cmd([[ set nu ]])  -- Enable numbers (removed ! which was toggling them OFF)
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
-- Cursor and cursorline are already configured above, don't override them
vim.cmd([[ syntax on ]])
vim.cmd([[ set termguicolors ]])

