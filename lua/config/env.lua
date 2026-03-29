local M = {}

M.blocked_env_keys = {
  GITHUB_TOKEN = true,
  GH_TOKEN = true,
}

function M.clear_blocked_env_keys()
  for key, _ in pairs(M.blocked_env_keys) do
    vim.env[key] = nil
  end
end

-- Never expose GitHub auth env vars inside Neovim or its child processes.
M.clear_blocked_env_keys()

return M
