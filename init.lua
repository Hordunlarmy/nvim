if vim.loader and type(vim.loader.enable) == "function" then
  vim.loader.enable()
end

require("manager")
