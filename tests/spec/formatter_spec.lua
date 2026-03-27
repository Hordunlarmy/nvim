-- Tests for formatter configuration

describe("formatter", function()
  it("formatter.nvim is requireable", function()
    local ok = pcall(require, "formatter")
    assert.is_true(ok, "formatter.nvim should be requireable")
  end)

  describe("formatter executables are discoverable", function()
    local formatters = {
      { name = "prettier", filetypes = "js/ts/html/css/markdown" },
      { name = "black", filetypes = "python" },
      { name = "isort", filetypes = "python imports" },
      { name = "shfmt", filetypes = "shell" },
      { name = "stylua", filetypes = "lua" },
    }

    for _, fmt in ipairs(formatters) do
      it(fmt.name .. " is installed (" .. fmt.filetypes .. ")", function()
        local is_installed = vim.fn.executable(fmt.name) == 1
        if not is_installed then
          pending(fmt.name .. " not found in PATH (install via Mason or system package manager)")
        else
          assert.is_true(is_installed)
        end
      end)
    end
  end)

  describe("clojure formatter", function()
    it("cljfmt is installed", function()
      local is_installed = vim.fn.executable("cljfmt") == 1
      if not is_installed then
        pending("cljfmt not found in PATH (install via Mason: :MasonInstall cljfmt)")
      else
        assert.is_true(is_installed)
      end
    end)
  end)
end)

describe("linters", function()
  describe("linter executables are discoverable", function()
    local linters = {
      { name = "eslint_d", filetypes = "js/ts" },
      { name = "shellcheck", filetypes = "shell" },
    }

    for _, linter in ipairs(linters) do
      it(linter.name .. " is installed (" .. linter.filetypes .. ")", function()
        local is_installed = vim.fn.executable(linter.name) == 1
        if not is_installed then
          pending(linter.name .. " not found in PATH")
        else
          assert.is_true(is_installed)
        end
      end)
    end
  end)

  describe("clojure linter", function()
    it("clj-kondo is installed", function()
      local is_installed = vim.fn.executable("clj-kondo") == 1
      if not is_installed then
        pending("clj-kondo not found in PATH (install via Mason: :MasonInstall clj-kondo)")
      else
        assert.is_true(is_installed)
      end
    end)
  end)
end)
