-- Suppress known plugin noise without hiding real deprecation warnings
-- vim.deprecate is NOT overridden so you always see what needs updating

local suppressed_patterns = {
  "Neoscroll.*deprecated",
  "function signature scroll.*deprecated",
  "vim%.region.*deprecated",
  "^recording @",
  "^recording",
}

local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == "string" then
    for _, pat in ipairs(suppressed_patterns) do
      if msg:match(pat) then
        return
      end
    end
  end
  original_notify(msg, level, opts)
end

return {}

