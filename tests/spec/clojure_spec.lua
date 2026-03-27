-- Tests specific to the Clojure development environment

describe("clojure support", function()

  describe("language server", function()
    it("clojure_lsp config exists in lspconfig", function()
      local ok, configs = pcall(require, "lspconfig.configs")
      if not ok then
        pending("lspconfig.configs not available")
        return
      end
      assert.is_not_nil(configs.clojure_lsp, "clojure_lsp config should exist")
    end)

    it("clojure-lsp binary is installed", function()
      local is_installed = vim.fn.executable("clojure-lsp") == 1
      if not is_installed then
        pending("clojure-lsp not found in PATH (run :MasonInstall clojure-lsp)")
      else
        assert.is_true(is_installed)
      end
    end)
  end)

  describe("treesitter", function()
    it("clojure parser is installed", function()
      local ok, parsers = pcall(require, "nvim-treesitter.parsers")
      if not ok then
        pending("nvim-treesitter.parsers not available")
        return
      end
      assert.is_true(parsers.has_parser("clojure"), "clojure treesitter parser should be installed")
    end)
  end)

  describe("conjure (REPL)", function()
    it("conjure plugin spec exists", function()
      local ok, lazy = pcall(require, "lazy")
      if not ok then
        pending("lazy.nvim not available")
        return
      end
      local found = false
      for _, p in ipairs(lazy.plugins()) do
        if p.name == "conjure" then
          found = true
          break
        end
      end
      assert.is_true(found, "conjure should be in plugin list")
    end)

    it("conjure mapping prefix is set", function()
      local prefix = vim.g["conjure#mapping#prefix"]
      assert.is_not_nil(prefix, "conjure mapping prefix should be set")
      assert.are.equal("<localleader>", prefix)
    end)

    it("conjure is disabled for non-clojure filetypes", function()
      assert.is_false(vim.g["conjure#filetype#rust"] or false)
      assert.is_false(vim.g["conjure#filetype#python"] or false)
      assert.is_false(vim.g["conjure#filetype#lua"] or false)
    end)
  end)

  describe("paredit (structural editing)", function()
    it("nvim-paredit plugin spec exists", function()
      local ok, lazy = pcall(require, "lazy")
      if not ok then
        pending("lazy.nvim not available")
        return
      end
      local found = false
      for _, p in ipairs(lazy.plugins()) do
        if p.name == "nvim-paredit" then
          found = true
          break
        end
      end
      assert.is_true(found, "nvim-paredit should be in plugin list")
    end)
  end)

  describe("rainbow delimiters", function()
    it("clojure uses rainbow-blocks query", function()
      local rd_config = vim.g.rainbow_delimiters
      if not rd_config then
        pending("rainbow_delimiters config not loaded yet")
        return
      end
      assert.is_not_nil(rd_config.query, "rainbow_delimiters should have query table")
      assert.are.equal("rainbow-blocks", rd_config.query.clojure,
        "clojure should use rainbow-blocks query for better S-expression highlighting")
    end)
  end)

  describe("formatter", function()
    it("cljfmt binary is installed", function()
      local is_installed = vim.fn.executable("cljfmt") == 1
      if not is_installed then
        pending("cljfmt not found in PATH (run :MasonInstall cljfmt)")
      else
        assert.is_true(is_installed)
      end
    end)
  end)

  describe("linter", function()
    it("clj-kondo binary is installed", function()
      local is_installed = vim.fn.executable("clj-kondo") == 1
      if not is_installed then
        pending("clj-kondo not found in PATH (run :MasonInstall clj-kondo)")
      else
        assert.is_true(is_installed)
      end
    end)
  end)
end)
