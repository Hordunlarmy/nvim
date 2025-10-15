-- Suppress deprecation warnings from plugins that haven't updated yet

-- Store originals
local original_notify = vim.notify
local original_deprecate = vim.deprecate

-- Override vim.notify to filter out deprecation warnings and recording messages
vim.notify = function(msg, level, opts)
  -- Suppress specific messages
  if type(msg) == "string" then
    -- Suppress deprecation warnings
    if msg:match("buf_get_clients.*deprecated") 
       or msg:match("lspconfig.*deprecated")
       or msg:match("get_active_clients.*deprecated")
       or msg:match("vim%.lsp%.buf_get_clients")
       or msg:match("supports_method.*deprecated")
       or msg:match("client%.supports_method")
       or msg:match("client%.request.*deprecated")
       or msg:match("Neoscroll.*deprecated")
       or msg:match("function signature scroll.*deprecated")
       or msg:match("client.is_stopped is deprecated")
       or msg:match("vim%.deprecated") then
      return  -- Suppress these warnings silently
    end
    
    -- Suppress recording messages (recording @w, recording @q, etc.)
    if msg:match("^recording @") or msg:match("^recording") then
      return  -- Suppress recording notifications
    end
  end
  
  -- Pass through all other notifications
  original_notify(msg, level, opts)
end

-- Override vim.deprecate to suppress specific deprecations
vim.deprecate = function(name, alternative, version, plugin, backtrace)
  -- Suppress specific function deprecations
  if name and (name:match("buf_get_clients") 
              or name:match("get_active_clients")
              or name:match("supports_method")
              or name:match("client%.request")
              or name:match("request")
              or name == "client.supports_method"
              or name == "client.request") then
    return  -- Suppress silently
  end
  
  -- Pass through other deprecations
  if original_deprecate then
    original_deprecate(name, alternative, version, plugin, backtrace)
  end
end

return {}

