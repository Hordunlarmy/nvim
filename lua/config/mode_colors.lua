-- Change window separator colors based on mode
-- Creates a visual indicator of which mode you're in

local M = {}

-- Define colors for each mode
local mode_colors = {
  -- Normal mode - White
  n = "#ffffff",
  no = "#ffffff",
  nov = "#ffffff",
  noV = "#ffffff",
  ["no\22"] = "#ffffff",
  
  -- Insert mode - Blue
  i = "#61afef",
  ic = "#61afef",
  ix = "#61afef",
  
  -- Visual mode - Purple/Magenta
  v = "#c678dd",
  V = "#c678dd",
  [""] = "#c678dd",  -- Visual block
  
  -- Replace mode - Red
  R = "#e06c75",
  Rc = "#e06c75",
  Rv = "#e06c75",
  Rx = "#e06c75",
  
  -- Command mode - Yellow
  c = "#e5c07b",
  cv = "#e5c07b",
  ce = "#e5c07b",
  
  -- Terminal mode - Cyan
  t = "#56b6c2",
  
  -- Select mode - Orange
  s = "#d19a66",
  S = "#d19a66",
  [""] = "#d19a66",
}

-- Function to update separator, cursor, AND line number colors based on mode
local function update_mode_colors()
  local mode = vim.api.nvim_get_mode().mode
  local color = mode_colors[mode] or "#888888"  -- Default gray
  
  -- Get normal background for transparency
  local normal_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "bg")
  if not normal_bg or normal_bg == "" then
    normal_bg = "NONE"
  end
  
  -- Update window separator colors
  vim.api.nvim_set_hl(0, 'WinSeparator', { fg = color, bg = normal_bg })
  vim.api.nvim_set_hl(0, 'VertSplit', { fg = color, bg = normal_bg })
  
  -- Update cursor colors (matches mode!)
  vim.api.nvim_set_hl(0, 'Cursor', { fg = '#000000', bg = color, bold = true })
  vim.api.nvim_set_hl(0, 'lCursor', { fg = '#000000', bg = color, bold = true })
  vim.api.nvim_set_hl(0, 'TermCursor', { fg = '#000000', bg = color, bold = true })
  
  -- Update current line number color (matches mode!)
  vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = color, bg = normal_bg, bold = true })
  
  -- Keep other line numbers invisible
  vim.api.nvim_set_hl(0, 'LineNr', { fg = '#1a1a1a', bg = normal_bg })
end

-- Set up autocmd to update on mode change
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*",
  callback = update_mode_colors,
})

-- Also update on colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = update_mode_colors,
})

-- Also update on entering/leaving insert mode
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  pattern = "*",
  callback = update_mode_colors,
})

-- Set initial color
vim.defer_fn(update_mode_colors, 100)

return M

