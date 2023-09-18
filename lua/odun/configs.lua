--------------------nvim-tree configs----------------------
----------------------------------------------------------

-- Require the NvimTree plugin
--local nvim_tree = require('nvim-tree')

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Close editor if nvim is the last buffer
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local invalid_win = {}
    local wins = vim.api.nvim_list_wins()
    for _, w in ipairs(wins) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
      if bufname:match("NvimTree_") ~= nil then
        table.insert(invalid_win, w)
      end
    end
    if #invalid_win == #wins - 1 then
      -- Should quit, so we close all invalid windows.
      for _, w in ipairs(invalid_win) do vim.api.nvim_win_close(w, true) end
    end
  end
})

-- Configure NvimTree options
vim.g.nvim_tree_ignore = { '.git', 'node_modules', '.cache' }
vim.g.nvim_tree_gitignore = 1
vim.g.nvim_tree_auto_open = 1
vim.g.nvim_tree_auto_close = 1

-- Open NvimTree on startup
vim.cmd([[autocmd VimEnter * NvimTreeOpen]])

-- Move cursor to the other buffer
vim.cmd([[autocmd VimEnter * wincmd p]])

-- Set nvim-tree size on open
vim.cmd([[autocmd VimEnter * NvimTreeResize 30]])

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- Set the open size of NvimTree
vim.g.nvim_tree_width = 20

-- Set `fg` to the color you want your window separators to have
vim.cmd([[highlight WinSeparator guifg=#8B8B8B guibg=NONE]])

-------------------SnipRun Config------------------
---------------------------------------------------
require('sniprun').setup({
  display = {"NvimNotify"},

  display_options = {
    notification_timeout = 5   -- timeout for nvim_notify output
  },
})


vim.cmd('highlight NotifyERRORBorder guifg=#8A1F1F')
vim.cmd('highlight NotifyWARNBorder guifg=#79491D')
vim.cmd('highlight NotifyINFOBorder guifg=#4F6752')
vim.cmd('highlight NotifyDEBUGBorder guifg=#8B8B8B')
vim.cmd('highlight NotifyTRACEBorder guifg=#4F3552')
vim.cmd('highlight NotifyERRORIcon guifg=#F70067')
vim.cmd('highlight NotifyWARNIcon guifg=#F79000')
vim.cmd('highlight NotifyINFOIcon guifg=#A9FF68')
vim.cmd('highlight NotifyDEBUGIcon guifg=#8B8B8B')
vim.cmd('highlight NotifyTRACEIcon guifg=#D484FF')
vim.cmd('highlight NotifyERRORTitle guifg=#F70067')
vim.cmd('highlight NotifyWARNTitle guifg=#F79000')
vim.cmd('highlight NotifyINFOTitle guifg=#A9FF68')
vim.cmd('highlight NotifyDEBUGTitle guifg=#8B8B8B')
vim.cmd('highlight NotifyTRACETitle guifg=#D484FF')
vim.cmd('highlight link NotifyERRORBody Normal')
vim.cmd('highlight link NotifyWARNBody Normal')
vim.cmd('highlight link NotifyINFOBody Normal')
vim.cmd('highlight link NotifyDEBUGBody Normal')
vim.cmd('highlight link NotifyTRACEBody Normal')

-- Map F10 to SnipRun in insert mode
vim.api.nvim_set_keymap('i', '<F10>', '<Esc>:SnipRun<CR>', { silent = true })

-- Map F10 to SnipRun in normal mode
vim.api.nvim_set_keymap('n', '<F10>', ':SnipRun<CR>', { silent = true })

-- Map F10 to SnipRun in visual mode
vim.api.nvim_set_keymap('v', '<F10>', ':SnipRun<CR>', { silent = true })

-----------------------------------------------------------------------------
-- For nvim-web-devicons
require'nvim-web-devicons'.get_icons()

--------------For Status Bar-----------------
--------------------------------------------
require("lfs")

local function dot_git_exists()
  local path = "./.git"
  if (lfs.attributes(path, "mode") == "directory") then
    return true
  end
  return false
end

if dot_git_exists() then
  branch = '-branch'
else
  branch = '-📁'
  --branch = '- '
end

local function get_var(my_var_name)
  return vim.api.nvim_get_var(my_var_name)
end

extension = get_var("extension")

if extension == "cpp" or extension == "hpp" or extension == "h" then
  this_lsp = '-lsp_name'
else
  this_lsp = '-file_size'
end


require('staline').setup{
  sections = {
    left = {
      ' ', 'right_sep_double', '-mode', 'left_sep_double', ' ',
      'right_sep', '-file_name', 'left_sep', ' ',
      'right_sep_double', branch, 'left_sep_double', ' ',
    },
    mid = {'-lsp'},
    right= {
      'right_sep', '-cool_symbol', 'left_sep', ' ',
      'right_sep', '- ', this_lsp, '- ', 'left_sep',
      'right_sep_double', '-line_column', 'left_sep_double', ' ',
    }
  },

  defaults={
    fg = "#f7f7f7",
    cool_symbol = "  ",
    left_separator = "",
    right_separator = "",
    --line_column = "%l:%c [%L]",
    true_colors = false,
    line_column = "[%l:%c] 並%p%% ",
    stab_start = "",
    stab_end = ""
    --font_active = "bold"
  },
  mode_colors = {
    n = "#921F81",
    i = "#006A6B",
    ic = "#E4BF7B",
    c = "#2a6099",
    v = "#D71B39"
  }
}

---------FOR THE INDENTATION LINES-------------
-----------------------------------------------

vim.opt.listchars:append("space:⋅")
--vim.opt.listchars:append("eol:↴")
vim.cmd [[highlight IndentBlanklineIndent1 guifg=#808080 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent2 guifg=#808080 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent3 guifg=#808080 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent4 guifg=#808080 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent5 guifg=#808080 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent6 guifg=#808080 gui=nocombine]]

vim.cmd([[
hi! MatchParen cterm=NONE,bold gui=NONE,bold guibg=NONE guifg=#FFFFFF
let g:indentLine_fileTypeExclude = ['dashboard']
]])


require("indent_blankline").setup {
  filetype = {
    "lua",
    "python",
    "c"
    -- Add more filetypes as needed
  },
  show_end_off_line = true,
  space_char_blankline = " ",
  char_highlight_list = {
    "IndentBlanklineIndent1",
    "IndentBlanklineIndent2",
    "IndentBlanklineIndent3",
    "IndentBlanklineIndent4",
    "IndentBlanklineIndent5",
    "IndentBlanklineIndent6",
  },
}

----------------Auto Pairs config ----------------
--------------------------------------------------
require('nvim-autopairs').setup{}

----------------Highlight Yank------------------
------------------------------------------------
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-------Key bindings in nvim lsp diagnostics-----
------------------------------------------------

vim.api.nvim_set_keymap('n', '<leader>do', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>d[', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>d]', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })

-- The following command requires plug-ins "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim", and optionally "kyazdani42/nvim-web-devicons" for icon support
vim.api.nvim_set_keymap('n', '<leader>dd', '<cmd>Telescope diagnostics<CR>', { noremap = true, silent = true })
-- If you don't want to use the telescope plug-in but still want to see all the errors/warnings, comment out the telescope line and uncomment this:
-- vim.api.nvim_set_keymap('n', '<leader>dd', '<cmd>lua vim.diagnostic.setloclist()<CR>', { noremap = true, silent = true })

-- Severity signs in nvim lsp diagnostics
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

------turn off virtual text from the lsp------
-----------------------------------------------
vim.diagnostic.config({
  virtual_text = false,
})

-- Setup Hover configuration and Signature help configuration--
----------------------------------------------------------------
-- require("config.lsp.handlers").setup()
local nvim_lsp = require('lspconfig')
local hover = require('hover')

-- Define the 'lsp' table for custom floating window settings
local lsp = {
    float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        max_width = 80,
    },
}

-- Configure the Jedi Language Server for python
nvim_lsp.jedi_language_server.setup{
    on_attach = function(client, bufnr)
        -- Customize hover.nvim appearance using 'lsp.float' settings
        hover.setup({
            border = {
                { "╭", "FloatBorder" },
                { "─", "FloatBorder" },
                { "╮", "FloatBorder" },
                { "│", "FloatBorder" },
                { "╯", "FloatBorder" },
                { "─", "FloatBorder" },
                { "╰", "FloatBorder" },
                { "│", "FloatBorder" },
            },
            winblend = 10, -- Transparency (0-100)
            cursorline = false, -- Highlight line under cursor
            focusin = false, -- Focus the popup automatically
            auto_close = false, -- Auto-close hover popup
            auto_hover = true, -- Auto-hover when idle
            hide_on_shift = true, -- Hide on shift key press
            hover_close_events = { "CursorMoved", "BufHidden", "InsertEnter" }, -- Events to close the hover popup
           -- Other settings here
        })

        hover.buf_init(bufnr)
        hover.buf_attach(bufnr)
    end,
    settings = {
        jedi = {
            completion = {
                disableSnippets = false,
            },
        },
    },
}

-- Configure the clangd server for C
nvim_lsp.clangd.setup{
    on_attach = function(client, bufnr)
        hover.setup({
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            max_width = 80,
            winblend = 10,
            cursorline = false,
            focusin = false,
            auto_close = false,
            auto_hover = true,
            hide_on_shift = true,
            hover_close_events = { "CursorMoved", "BufHidden", "InsertEnter" },
        })

        hover.buf_init(bufnr)
        hover.buf_attach(bufnr)
    end,
}
-- Set the hover handler for LSP to use 'lsp.float' settings
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, lsp.float)
-- Signature help configuration
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, lsp.float)


----------Nvim-lint autocmd to trigger linting------------
----------------------------------------------------------

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
callback = function()
  require("lint").try_lint()
  end,
})
