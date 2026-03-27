-- Tests for core Neovim settings

describe("settings", function()
  it("tabstop is 4", function()
    assert.are.equal(4, vim.opt.tabstop:get())
  end)

  it("shiftwidth is 4", function()
    assert.are.equal(4, vim.opt.shiftwidth:get())
  end)

  it("expandtab is enabled", function()
    assert.is_true(vim.opt.expandtab:get())
  end)

  it("smartindent is enabled", function()
    assert.is_true(vim.opt.smartindent:get())
  end)

  it("swapfile is disabled", function()
    assert.is_false(vim.opt.swapfile:get())
  end)

  it("backup is disabled", function()
    assert.is_false(vim.opt.backup:get())
  end)

  it("undofile is enabled", function()
    assert.is_true(vim.opt.undofile:get())
  end)

  it("termguicolors is enabled", function()
    assert.is_true(vim.opt.termguicolors:get())
  end)

  it("clipboard is set to unnamedplus", function()
    local clipboard = vim.opt.clipboard:get()
    local has_unnamedplus = false
    for _, v in ipairs(clipboard) do
      if v == "unnamedplus" then
        has_unnamedplus = true
        break
      end
    end
    assert.is_true(has_unnamedplus, "clipboard should include unnamedplus")
  end)

  it("ignorecase is enabled", function()
    assert.is_true(vim.opt.ignorecase:get())
  end)

  it("smartcase is enabled", function()
    assert.is_true(vim.opt.smartcase:get())
  end)

  it("mouse is enabled", function()
    assert.are.equal("a", vim.o.mouse)
  end)

  it("showmode is disabled", function()
    assert.is_false(vim.opt.showmode:get())
  end)

  it("signcolumn is yes", function()
    assert.are.equal("yes", vim.opt.signcolumn:get())
  end)

  it("scrolloff is 8", function()
    assert.are.equal(8, vim.opt.scrolloff:get())
  end)

  it("laststatus is 3 (global statusline)", function()
    assert.are.equal(3, vim.opt.laststatus:get())
  end)
end)
