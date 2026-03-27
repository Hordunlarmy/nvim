-- Tests for LSP server configurations

describe("lsp configuration", function()
  it("lspconfig is requireable", function()
    local ok, lspconfig = pcall(require, "lspconfig")
    assert.is_true(ok, "nvim-lspconfig should be requireable")
    assert.is_not_nil(lspconfig)
  end)

  describe("server configs exist in lspconfig", function()
    local expected_servers = {
      "lua_ls",
      "jsonls",
      "jedi_language_server",
      "ts_ls",
      "bashls",
      "dockerls",
      "gopls",
      "clojure_lsp",
    }

    for _, server_name in ipairs(expected_servers) do
      it("has config for " .. server_name, function()
        local ok, configs = pcall(require, "lspconfig.configs")
        if not ok then
          pending("lspconfig.configs not available")
          return
        end
        assert.is_not_nil(configs[server_name], server_name .. " should have a config entry")
      end)
    end
  end)

  it("cmp_nvim_lsp is requireable for capabilities", function()
    local ok = pcall(require, "cmp_nvim_lsp")
    assert.is_true(ok, "cmp_nvim_lsp should be requireable")
  end)

  it("diagnostic config is set", function()
    local diag_config = vim.diagnostic.config()
    assert.is_not_nil(diag_config, "diagnostic config should exist")
    assert.is_false(diag_config.virtual_text, "virtual_text should be disabled")
    assert.is_true(diag_config.underline, "underline should be enabled")
    assert.is_true(diag_config.severity_sort, "severity_sort should be enabled")
  end)
end)

describe("mason", function()
  it("mason is requireable", function()
    local ok = pcall(require, "mason")
    assert.is_true(ok, "mason should be requireable")
  end)

  it("mason-lspconfig is requireable", function()
    local ok = pcall(require, "mason-lspconfig")
    assert.is_true(ok, "mason-lspconfig should be requireable")
  end)
end)
