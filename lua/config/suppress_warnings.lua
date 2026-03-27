-- Suppress known plugin noise without hiding real deprecation warnings
-- vim.deprecate is NOT overridden so you always see what needs updating

local suppressed_patterns = {
  "Neoscroll.*deprecated",
  "function signature scroll.*deprecated",
  "vim%.region.*deprecated",
  "^recording @",
  "^recording",
  "client%.supports_method is deprecated",
  "^Run \":checkhealth vim%.deprecated\"",
}

local original_notify = vim.notify
local ok_ticker, ticker = pcall(require, "util.notify_ticker")
vim.notify = function(msg, level, opts)
  if type(msg) == "string" then
    for _, pat in ipairs(suppressed_patterns) do
      if msg:match(pat) then
        return
      end
    end
  end
  if ok_ticker then
    pcall(ticker.push, msg, level, opts)
  end
  if type(original_notify) == "function" and opts and opts._echo then
    original_notify(msg, level, opts)
  end
end

return {}
