-- Add visual padding on the right side of main buffers
-- Uses wrap/linebreak/breakindent — does NOT touch textwidth (which affects gq formatting)

local M = {}

local skip_ft = {
  NvimTree = true, aerial = true, alpha = true, lazy = true,
  mason = true, help = true, qf = true, terminal = true,
  dashboard = true, starter = true, toggleterm = true,
  Trouble = true, trouble = true, TelescopePrompt = true,
}

local function add_right_padding()
  if skip_ft[vim.bo.filetype] or vim.bo.filetype == "" or vim.bo.buftype ~= "" then
    return
  end
  if vim.api.nvim_buf_get_name(0) == "" then
    return
  end
  if vim.api.nvim_buf_line_count(0) > 5000 then
    return
  end

  local win = vim.api.nvim_get_current_win()
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].breakindent = true
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "VimResized" }, {
  group = vim.api.nvim_create_augroup("RightPadding", { clear = true }),
  pattern = "*",
  callback = add_right_padding,
})

return M
