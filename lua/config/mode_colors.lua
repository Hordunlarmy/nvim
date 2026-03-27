-- Change window separator colors based on mode
-- Creates a visual indicator of which mode you're in

local M = {}
local cached_normal_bg = "NONE"
local mode_augroup = vim.api.nvim_create_augroup("ModeColors", { clear = true })

local function refresh_bg()
  local hl = vim.api.nvim_get_hl(0, { name = "Normal" })
  if hl.bg then
    cached_normal_bg = string.format("#%06x", hl.bg)
  else
    cached_normal_bg = "NONE"
  end
end

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

local function update_mode_colors()
  local mode = vim.api.nvim_get_mode().mode
  local color = mode_colors[mode] or "#888888"
  local bg = cached_normal_bg

  vim.api.nvim_set_hl(0, 'WinSeparator', { fg = color, bg = bg })
  vim.api.nvim_set_hl(0, 'VertSplit', { fg = color, bg = bg })
  vim.api.nvim_set_hl(0, 'Cursor', { fg = '#000000', bg = color, bold = true })
  vim.api.nvim_set_hl(0, 'lCursor', { fg = '#000000', bg = color, bold = true })
  vim.api.nvim_set_hl(0, 'TermCursor', { fg = '#000000', bg = color, bold = true })
  vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = color, bg = bg, bold = true })
  vim.api.nvim_set_hl(0, 'LineNr', { fg = '#1a1a1a', bg = bg })
end

vim.api.nvim_create_autocmd("ModeChanged", {
  group = mode_augroup,
  pattern = "*",
  callback = update_mode_colors,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = mode_augroup,
  pattern = "*",
  callback = function()
    refresh_bg()
    update_mode_colors()
  end,
})

refresh_bg()
vim.defer_fn(update_mode_colors, 100)

return M

