-- Auto-close Neovim when only sidebars/utility panes remain.
-- Once we've seen at least one real file window in this session,
-- auto-quit when no real file windows are left.

local seen_real_window = false

local function check_and_close()
  local ignored_filetypes = {
    NvimTree = true,
    aerial = true,
    alpha = true,
    dashboard = true,
    lazy = true,
    mason = true,
    help = true,
    qf = true,
    spectre_panel = true,
    toggleterm = true,
    diagnostic_panel = true,
    ["neo-tree"] = true,
    Trouble = true,
    trouble = true,
    notify = true,
  }

  local function is_real_window(win)
    if not vim.api.nvim_win_is_valid(win) then
      return false
    end
    local win_cfg = vim.api.nvim_win_get_config(win)
    if win_cfg.relative ~= "" then
      return false
    end

    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype
    local bufname = vim.api.nvim_buf_get_name(buf)

    return (not ignored_filetypes[ft])
      and bt == ""
      and bufname ~= ""
      and not bufname:match("^term://")
  end

  -- Get all windows
  local wins = vim.api.nvim_list_wins()
  local has_real_window = false
  
  for _, win in ipairs(wins) do
    if is_real_window(win) then
      has_real_window = true
      seen_real_window = true
      break
    end
  end
  
  -- If no real windows, quit everything
  if seen_real_window and not has_real_window then
    vim.cmd("qall!")
  end
end

-- Re-check only on destructive/close events.
-- Buf/Win enter checks are high-frequency and can add noticeable latency.
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "WinClosed", "TabClosed" }, {
  group = vim.api.nvim_create_augroup("AutoCloseNvim", { clear = true }),
  callback = function()
    vim.defer_fn(check_and_close, 50)
  end,
})

-- Add a manual command to test
vim.api.nvim_create_user_command("CheckAutoClose", function()
  local wins = vim.api.nvim_list_wins()
  local info = {}
  
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local bt = vim.bo[buf].buftype
      local name = vim.api.nvim_buf_get_name(buf)
      table.insert(info, string.format("Win %d: ft=%s, bt=%s, name=%s", win, ft, bt, name))
    end
  end
  
  print(vim.inspect(info))
  check_and_close()
end, { desc = "Debug auto-close logic" })

vim.api.nvim_create_user_command("CloseIfEmpty", function()
  check_and_close()
end, { desc = "Close Neovim if only tree/aerial remain" })

return {}
