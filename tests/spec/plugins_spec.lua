-- Tests that all plugin specs are valid and critical plugins load

-- Build a set of installed plugin names once (lazy must be loaded by minimal_init)
local function get_plugin_names()
  local ok, lazy = pcall(require, "lazy")
  if not ok then return nil end
  local names = {}
  for _, p in ipairs(lazy.plugins()) do
    names[p.name] = true
  end
  return names
end

describe("plugin specs", function()
  it("lazy.nvim is available", function()
    local ok, lazy = pcall(require, "lazy")
    assert.is_true(ok, "lazy.nvim should be requireable")
    assert.is_not_nil(lazy)
  end)

  it("all plugin specs parse without errors", function()
    local names = get_plugin_names()
    if not names then
      pending("lazy.nvim not available")
      return
    end
    local count = 0
    for _ in pairs(names) do count = count + 1 end
    assert.is_true(count > 0, "should have at least 1 plugin loaded")
  end)

  describe("critical plugins are installed", function()
    local critical_plugins = {
      "nvim-lspconfig",
      "mason.nvim",
      "mason-lspconfig.nvim",
      "mason-tool-installer.nvim",
      "nvim-treesitter",
      "nvim-cmp",
      "formatter.nvim",
      "plenary.nvim",
      "telescope.nvim",
      "lspsaga.nvim",
    }

    for _, plugin_name in ipairs(critical_plugins) do
      it("has " .. plugin_name, function()
        local names = get_plugin_names()
        if not names then
          pending("lazy.nvim not available")
          return
        end
        assert.is_true(names[plugin_name] == true, plugin_name .. " should be in plugin list")
      end)
    end
  end)

  describe("clojure plugins are installed", function()
    local clojure_plugins = {
      "conjure",
      "nvim-paredit",
      "cmp-conjure",
    }

    for _, plugin_name in ipairs(clojure_plugins) do
      it("has " .. plugin_name, function()
        local names = get_plugin_names()
        if not names then
          pending("lazy.nvim not available")
          return
        end
        assert.is_true(names[plugin_name] == true, plugin_name .. " should be in plugin list")
      end)
    end
  end)
end)
