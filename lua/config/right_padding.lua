-- Add visual padding on the right side of main buffers
-- This creates space between your code and the right edge (Aerial)

local M = {}

-- Add right padding to buffer
local function add_right_padding()
  local ft = vim.bo.filetype
  local bt = vim.bo.buftype
  
  -- Skip special buffers and non-file buffers
  if ft == "NvimTree" or ft == "aerial" or ft == "alpha" or ft == "lazy" 
     or ft == "mason" or ft == "help" or ft == "qf" or ft == "terminal"
     or ft == "dashboard" or ft == "starter" or ft == "toggleterm"
     or ft == "Trouble" or ft == "trouble" or ft == "TelescopePrompt"
     or ft == "" or bt ~= "" then
    return
  end
  
  -- Also skip if buffer name is empty (like alpha)
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    return
  end
  
  -- Get current window width
  local win = vim.api.nvim_get_current_win()
  local width = vim.api.nvim_win_get_width(win)
  
  -- Set wrap settings with big right margin
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].breakindent = true
  
  -- Only apply to normal code buffers with actual files
  if width > 50 then
    vim.opt_local.textwidth = width - 20  -- 20 character right margin
    vim.opt_local.wrapmargin = 0  -- Don't use wrapmargin (conflicts with textwidth)
  end
end

-- Apply on buffer enter
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "VimResized" }, {
  pattern = "*",
  callback = add_right_padding,
})

return M

