-- Guard against invalid control characters in statusline values.
-- Some async component callbacks may emit bytes that break :set statusline.

if not vim.g._statusline_guard_installed then
  vim.g._statusline_guard_installed = true

  local raw_set_option = vim.api.nvim_set_option
  local raw_win_set_option = vim.api.nvim_win_set_option
  local raw_set_option_value = vim.api.nvim_set_option_value
  local guarded_names = {
    statusline = true,
    winbar = true,
    tabline = true,
  }

  local function sanitize_option(name, value)
    if not guarded_names[name] or type(value) ~= "string" then
      return value
    end
    value = value:gsub("[%z\1-\31\127]", " ")
    local ok_utf8 = pcall(vim.str_utfindex, value)
    if not ok_utf8 then
      -- If bytes are invalid UTF-8, strip high bytes to prevent option errors.
      value = value:gsub("[\128-\255]", " ")
    end
    return value
  end

  local function strict_ascii(value)
    if type(value) ~= "string" then
      return ""
    end
    value = value:gsub("[%z\1-\31\127]", " ")
    value = value:gsub("[^\32-\126]", " ")
    value = value:gsub("%s+", " ")
    return value
  end

  local function safe_call(setter, ...)
    local ok, err = pcall(setter, ...)
    if ok then
      return true
    end
    local args = { ... }
    local name = args[1]
    local value = args[2]
    if guarded_names[name] and type(value) == "string" and tostring(err):find("E539", 1, true) then
      local cleaned = strict_ascii(value)
      local ok2 = pcall(setter, name, cleaned)
      if ok2 then
        return true
      end
      pcall(setter, name, "")
      return true
    end
    error(err)
  end

  vim.api.nvim_set_option = function(name, value)
    safe_call(raw_set_option, name, sanitize_option(name, value))
  end

  vim.api.nvim_win_set_option = function(win, name, value)
    local sanitized = sanitize_option(name, value)
    local ok, err = pcall(raw_win_set_option, win, name, sanitized)
    if ok then
      return
    end
    if guarded_names[name] and type(sanitized) == "string" and tostring(err):find("E539", 1, true) then
      local cleaned = strict_ascii(sanitized)
      local ok2 = pcall(raw_win_set_option, win, name, cleaned)
      if ok2 then
        return
      end
      pcall(raw_win_set_option, win, name, "")
      return
    end
    error(err)
  end

  if type(raw_set_option_value) == "function" then
    vim.api.nvim_set_option_value = function(name, value, opts)
      local sanitized = sanitize_option(name, value)
      local ok, err = pcall(raw_set_option_value, name, sanitized, opts)
      if ok then
        return
      end
      if guarded_names[name] and type(sanitized) == "string" and tostring(err):find("E539", 1, true) then
        local cleaned = strict_ascii(sanitized)
        local ok2 = pcall(raw_set_option_value, name, cleaned, opts)
        if ok2 then
          return
        end
        pcall(raw_set_option_value, name, "", opts)
        return
      end
      error(err)
    end
  end
end

return {}
