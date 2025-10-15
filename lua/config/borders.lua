-- Set popup backgrounds to match theme with WHITE BORDERS

-- Function to set popup backgrounds dynamically (called after colorscheme loads)
local function set_float_colors()
  -- Get background color
  local normal_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "bg")
  if not normal_bg or normal_bg == "" or normal_bg == "NONE" then
    normal_bg = "NONE"  -- Keep transparent
  end
  
  -- White borders on all popups!
  vim.cmd("highlight! FloatBorder guifg=#ffffff guibg=" .. normal_bg)
  vim.cmd("highlight! link NormalFloat Normal")
  vim.cmd("highlight! FloatTitle guifg=#ffffff guibg=" .. normal_bg)
  
  -- Telescope with white borders
  vim.cmd("highlight! TelescopeBorder guifg=#ffffff guibg=" .. normal_bg)
  vim.cmd("highlight! TelescopePromptBorder guifg=#ffffff guibg=" .. normal_bg)
  vim.cmd("highlight! TelescopeResultsBorder guifg=#ffffff guibg=" .. normal_bg)
  vim.cmd("highlight! TelescopePreviewBorder guifg=#ffffff guibg=" .. normal_bg)
  vim.cmd("highlight! link TelescopeNormal Normal")
  vim.cmd("highlight! link TelescopePromptNormal Normal")
  vim.cmd("highlight! link TelescopeResultsNormal Normal")
  vim.cmd("highlight! link TelescopePreviewNormal Normal")
  
  -- Which-Key with white borders
  vim.cmd("highlight! WhichKeyBorder guifg=#ffffff guibg=" .. normal_bg)
  vim.cmd("highlight! link WhichKeyFloat Normal")
  
  -- Lazy with white borders
  vim.cmd("highlight! link LazyNormal Normal")
  vim.cmd("highlight! link LazyFloat Normal")
  vim.cmd("highlight! LazyFloatBorder guifg=#ffffff guibg=" .. normal_bg)
  
  -- Mason with white borders
  vim.cmd("highlight! link MasonNormal Normal")
  vim.cmd("highlight! link MasonFloat Normal")
  
  -- LSP with white borders
  vim.cmd("highlight! LspInfoBorder guifg=#ffffff guibg=" .. normal_bg)
  vim.cmd("highlight! DiagnosticFloatingBorder guifg=#ffffff guibg=" .. normal_bg)
end

-- Set immediately
set_float_colors()

-- Re-apply after colorscheme changes AND after VimEnter
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = set_float_colors,
})

vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    vim.defer_fn(set_float_colors, 500)  -- Apply after everything loads
  end,
})

-- White border characters
_G.border_chars = {
  { "─", "FloatBorder" },
  { "│", "FloatBorder" },
  { "─", "FloatBorder" },
  { "│", "FloatBorder" },
  { "╭", "FloatBorder" },
  { "╮", "FloatBorder" },
  { "╯", "FloatBorder" },
  { "╰", "FloatBorder" },
}

-- Set default border style for floating windows with padding
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"  -- White rounded border
  opts.max_width = opts.max_width or math.floor(vim.o.columns * 0.6)
  opts.max_height = opts.max_height or math.floor(vim.o.lines * 0.8)
  opts.focusable = true
  opts.close_events = { "BufLeave", "CursorMoved", "InsertEnter" }
  -- Add padding to contents
  if type(contents) == "table" then
    for i, line in ipairs(contents) do
      contents[i] = "  " .. line .. "  "
    end
  end
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Set LSP handlers to use floating windows
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "rounded",
    max_width = math.floor(vim.o.columns * 0.6),
    max_height = math.floor(vim.o.lines * 0.8),
    focusable = true,
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = "rounded",
    max_width = math.floor(vim.o.columns * 0.6),
    max_height = math.floor(vim.o.lines * 0.8),
    focusable = true,
  }
)

-- Global border settings
vim.diagnostic.config({
  float = {
    border = "rounded",
  },
})

return {}

