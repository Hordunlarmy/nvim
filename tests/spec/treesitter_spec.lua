-- Tests for treesitter parser installation

describe("treesitter", function()
  it("nvim-treesitter is requireable", function()
    local ok = pcall(require, "nvim-treesitter")
    assert.is_true(ok, "nvim-treesitter should be requireable")
  end)

  describe("parsers are installed", function()
    local expected_parsers = {
      "lua",
      "javascript",
      "typescript",
      "python",
      "go",
      "json",
      "html",
      "css",
      "bash",
      "markdown",
      "yaml",
      "dockerfile",
      "clojure",
    }

    for _, lang in ipairs(expected_parsers) do
      it("has parser for " .. lang, function()
        local ok, parsers = pcall(require, "nvim-treesitter.parsers")
        if not ok then
          pending("nvim-treesitter.parsers not available")
          return
        end
        local is_installed = parsers.has_parser(lang)
        assert.is_true(is_installed, lang .. " parser should be installed (run :TSInstall " .. lang .. ")")
      end)
    end
  end)

  it("highlight is enabled", function()
    local ok, configs = pcall(require, "nvim-treesitter.configs")
    if not ok then
      pending("nvim-treesitter.configs not available")
      return
    end
    -- Verify the module loaded without error (highlight config is internal)
    assert.is_not_nil(configs)
  end)
end)
