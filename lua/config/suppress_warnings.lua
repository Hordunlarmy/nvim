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

local ok_ticker, ticker = pcall(require, "util.notify_ticker")

local function notify_to_ticker(msg, level, opts)
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
end

vim.notify = notify_to_ticker

-- Some plugins replace vim.notify later (e.g. on VeryLazy). Re-assert ticker routing.
local group = vim.api.nvim_create_augroup("NotifyTickerRouter", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function()
    vim.schedule(function()
      vim.notify = notify_to_ticker
    end)
  end,
})
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "VeryLazy",
  callback = function()
    vim.schedule(function()
      vim.notify = notify_to_ticker
    end)
  end,
})

return {}
