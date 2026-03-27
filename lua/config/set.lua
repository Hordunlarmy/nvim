-- Cursor
vim.opt.guicursor = {
  "n-v-c:block-Cursor-blinkwait500-blinkoff400-blinkon400",
  "i-ci-ve:ver100-Cursor-blinkwait500-blinkoff400-blinkon400",
  "r-cr-o:hor50-Cursor-blinkwait500-blinkoff400-blinkon400",
}

-- Line numbers (minimalist: only current line number visible)
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.numberwidth = 4

-- Indentation defaults
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Filetype-specific indentation (with proper augroup so :source won't stack)
local indent_group = vim.api.nvim_create_augroup("FileTypeIndent", { clear = true })

local indent_rules = {
  { ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "lua", "json", "yaml", "html", "css" },
    opts = { tabstop = 2, softtabstop = 2, shiftwidth = 2, expandtab = true } },
  { ft = { "python" },
    opts = { tabstop = 4, softtabstop = 4, shiftwidth = 4, expandtab = true } },
  { ft = { "php" },
    opts = { tabstop = 4, softtabstop = 4, shiftwidth = 4, expandtab = false } },
  { ft = { "make" },
    opts = { tabstop = 4, softtabstop = 0, shiftwidth = 4, expandtab = false } },
}

for _, rule in ipairs(indent_rules) do
  vim.api.nvim_create_autocmd("FileType", {
    group = indent_group,
    pattern = rule.ft,
    callback = function()
      for k, v in pairs(rule.opts) do
        vim.opt_local[k] = v
      end
    end,
  })
end

-- Files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Search
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Display
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = ""
vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.title = true
vim.opt.wildmenu = true
vim.opt.confirm = true

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Mouse
vim.opt.mouse = "a"

-- Completion
vim.opt.completeopt = "menuone,noselect"

-- Timing
vim.opt.updatetime = 50
vim.opt.timeoutlen = 700
-- Meta/Alt keys in terminals are sent as Esc-prefixed sequences.
-- A slightly longer keycode timeout makes <A-...> mappings reliable.
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 120

-- Misc
vim.opt.isfname:append("@-@")
vim.opt.shortmess:append("q")
vim.opt.encoding = "utf-8"

-- Stop newline continuation of comments
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("FormatOptions", { clear = true }),
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Transparent main editor background
vim.g.transparent_enabled = true

-- Hexokinase highlighters
vim.g.Hexokinase_highlighters = { "foregroundfull" }
