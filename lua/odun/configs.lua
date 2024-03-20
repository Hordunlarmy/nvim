--------------------------LSPs----------------------------------
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

-- Configure tsserver for javascript/typescript
nvim_lsp.tsserver.setup({
    on_attach = function(client, bufnr)
        require('nvim-lsp-ts-utils').setup({
            filter_out_diagnostics_by_code = { 80001 },
        })
        require('nvim-lsp-ts-utils').setup_client(client)
    end,
})

-- Configure the lua_language_server for lua
nvim_lsp.lua_ls.setup{
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

-- Configure for html-languageserver
nvim_lsp.html.setup{
    filetypes = { "htmldjango" },
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


--------------------nvim-tree configs----------------------
----------------------------------------------------------

-- Require the NvimTree plugin
-- local nvim_tree = require('nvim-tree')
require("bufferline").setup{}

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

-- nvim-tree transparent BG
--vim.cmd("autocmd Colorscheme * highlight NvimTreeNormal guibg=none guifg=#9da5b3")
vim.cmd[[hi NvimTreeNormal guibg=NONE ctermbg=NONE]]

-- Set `fg` to the color you want your window separators to have
vim.cmd([[highlight WinSeparator guifg=#8B8B8B guibg=NONE]])

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

local extension = get_var("extension")

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

vim.opt.list = true
--vim.opt.listchars:append("space:⋅")
--vim.opt.listchars:append "eol:↴"

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
    "c",
    "javascript"
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

local Rule = require('nvim-autopairs.rule')
local npairs = require('nvim-autopairs')
npairs.add_rule(Rule("__", "__", "python"))

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
local signs = { Error = "🛑", Warn = "🟨", Hint = "💭", Info = "💌" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

------turn off virtual text from the lsp------
-----------------------------------------------
vim.diagnostic.config({
  virtual_text = false,
})

--------- Run Code From Vim(code_runner)--------------
------------------------------------------------------

require('code_runner').setup({
  mode = 'float', -- Set mode to float
  filetype = {
    java = {
      "cd $dir &&",
      "javac $fileName &&",
      "java $fileNameWithoutExt"
    },
    python = "python3 -u",
    typescript = "deno run",
    javascript = "node",
    rust = {
      "cd $dir &&",
      "rustc $fileName &&",
      "$dir/$fileNameWithoutExt"
    },
  },
  float = {
    border = "double",
    border_hl = "GreenBorder", -- Highlight group for the window border (use your desired highlight group)
  },
})

-- Define the GreenBorder highlight group
vim.cmd([[highlight GreenBorder guifg=#00FF00]])

-- Gitblame config
require('gitblame').setup {
     --Note how the `gitblame_` prefix is omitted in `setup`
    enabled = false,
}


