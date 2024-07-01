--------------------------LSPs----------------------------------
----------------------------------------------------------------
-- require("config.lsp.handlers").setup()
local nvim_lsp = require('lspconfig')
local hover = require('hover')

-- Global hover setup
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
})

-- Common on_attach function
local function on_attach(client, bufnr)
    -- Setup keymaps
    vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim", buffer = bufnr})
    vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})
    vim.keymap.set("n", "<C-p>", function() require("hover").hover_switch("previous") end, {desc = "hover.nvim (previous source)"})
    vim.keymap.set("n", "<C-n>", function() require("hover").hover_switch("next") end, {desc = "hover.nvim (next source)"})

    -- Mouse support
    vim.keymap.set('n', '<MouseMove>', require('hover').hover_mouse, { desc = "hover.nvim (mouse)" })
    vim.o.mousemoveevent = true
end -- Add this `end` to close the function

-- Configure Jedi for Python
nvim_lsp.jedi_language_server.setup{
    on_attach = on_attach,
    settings = {
        jedi = {
            completion = {
                disableSnippets = false,
            },
        },
    },
}

-- Configure clangd for C
nvim_lsp.clangd.setup{
    on_attach = on_attach,
}

-- Configure tsserver for JavaScript/TypeScript
nvim_lsp.tsserver.setup{
    on_attach = function(client, bufnr)
        require('nvim-lsp-ts-utils').setup({
            filter_out_diagnostics_by_code = { 80001 },
        })
        require('nvim-lsp-ts-utils').setup_client(client)
        on_attach(client, bufnr) -- Ensure hover is also set up
    end,
}

-- Configure Lua Language Server
nvim_lsp.lua_ls.setup{
    on_attach = on_attach,
}

-- Configure HTML Language Server
nvim_lsp.html.setup{
    on_attach = on_attach,
    filetypes = { "htmldjango" },
}

-- Set LSP handlers for hover and signature help with custom settings
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    focusable = true,
    style = "minimal",
    border = "rounded",
    max_width = 80,
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    focusable = true,
    style = "minimal",
    border = "rounded",
    max_width = 80,
})



----------Nvim-lint autocmd to trigger linting------------
----------------------------------------------------------

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
callback = function()
  require("lint").try_lint()
  end,
})

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



