-- Auto-close Neovim when only nvim-tree and aerial buffers remain

-- Track if we just started (don't auto-close on initial startup)
local startup_time = vim.loop.hrtime()
local startup_grace_period = 10000000000  -- 10 seconds in nanoseconds
local user_has_opened_file = false  -- Track if user has ever opened a real file

-- Mark that user has opened a file
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local ft = vim.bo.filetype
    -- Mark as opened if it's a real file
    if bufname ~= "" and ft ~= "NvimTree" and ft ~= "aerial" then
      user_has_opened_file = true
    end
  end,
})

_G.check_and_close = function()
  -- Don't auto-close within first 10 seconds of startup
  local elapsed = vim.loop.hrtime() - startup_time
  if elapsed < startup_grace_period then
    return
  end
  
  -- Don't auto-close if user has never opened a file (just started nvim)
  if not user_has_opened_file then
    return
  end
  
  -- Get all windows
  local wins = vim.api.nvim_list_wins()
  local has_real_window = false
  local has_empty_buffer = false
  
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local bt = vim.bo[buf].buftype
      local bufname = vim.api.nvim_buf_get_name(buf)
      local line_count = vim.api.nvim_buf_line_count(buf)
      local first_line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
      
      -- Check for empty unnamed buffer (like when you just type 'nvim')
      if bufname == "" and ft == "" and line_count == 1 and first_line == "" then
        has_empty_buffer = true
      end
      
      -- Check if this is a real file window (not nvim-tree or aerial)
      local is_real = ft ~= "NvimTree" 
        and ft ~= "aerial"
        and ft ~= "alpha"
        and ft ~= "dashboard"
        and ft ~= "lazy"
        and ft ~= "mason"
        and ft ~= "help"
        and ft ~= "qf"
        and ft ~= "spectre_panel"
        and ft ~= "toggleterm"
        and bt ~= "nofile"
        and bt ~= "terminal"
        and bufname ~= ""
        and not bufname:match("^term://")
      
      if is_real then
        has_real_window = true
        break
      end
    end
  end
  
  -- Don't close if there's an empty buffer (user just opened nvim)
  if has_empty_buffer then
    return
  end
  
  -- If no real windows, quit everything
  if not has_real_window then
    vim.cmd("qall!")
  end
end

-- Check on buffer delete/wipeout
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = vim.api.nvim_create_augroup("AutoCloseNvim", { clear = true }),
  callback = function()
    vim.defer_fn(_G.check_and_close, 200)
  end,
})

-- Also check when trying to quit
vim.api.nvim_create_autocmd("QuitPre", {
  group = vim.api.nvim_create_augroup("AutoCloseQuit", { clear = true }),
  callback = function()
    vim.defer_fn(_G.check_and_close, 100)
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
  _G.check_and_close()
end, { desc = "Debug auto-close logic" })

-- Also add a simpler manual close command
vim.api.nvim_create_user_command("CloseIfEmpty", function()
  _G.check_and_close()
end, { desc = "Close Neovim if only tree/aerial remain" })

return {}

