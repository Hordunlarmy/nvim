-- Tests for critical keymappings

-- Neovim normalizes key notation internally (e.g. <C-f> becomes <C-F>).
-- Visual maps set via vim.keymap.set("v",...) are stored under both "x" and "s" modes.
local function find_keymap(modes, lhs)
  if type(modes) == "string" then modes = { modes } end
  -- Normalize: Neovim uppercases the letter after C- / M- / A-
  local alt_lhs = lhs:gsub("(<C%-)(%l)(>)", function(prefix, ch, suffix)
    return prefix .. ch:upper() .. suffix
  end)
  for _, mode in ipairs(modes) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      if map.lhs == lhs or map.lhs == alt_lhs then
        return map
      end
    end
    -- buffer-local keymaps
    local ok, buf_maps = pcall(vim.api.nvim_buf_get_keymap, 0, mode)
    if ok then
      for _, map in ipairs(buf_maps) do
        if map.lhs == lhs or map.lhs == alt_lhs then
          return map
        end
      end
    end
  end
  return nil
end

describe("keymaps", function()
  it("leader key is space", function()
    assert.are.equal(" ", vim.g.mapleader)
  end)

  describe("critical normal mode keymaps exist", function()
    local critical_keymaps = {
      { lhs = "<C-d>", desc = "half page down" },
      { lhs = "<C-u>", desc = "half page up" },
      { lhs = "<C-h>", desc = "move to left split" },
      { lhs = "<C-j>", desc = "move to lower split" },
      { lhs = "<C-k>", desc = "move to upper split" },
      { lhs = "<C-l>", desc = "move to right split" },
      { lhs = "<C-f>", desc = "telescope live grep" },
    }

    for _, km in ipairs(critical_keymaps) do
      it("has " .. km.desc .. " (" .. km.lhs .. ")", function()
        local map = find_keymap({ "n" }, km.lhs)
        assert.is_not_nil(map, "keymap " .. km.lhs .. " (" .. km.desc .. ") should exist in normal mode")
      end)
    end
  end)

  describe("visual mode keymaps", function()
    it("has visual indent left (<)", function()
      -- Neovim stores '<' as '<lt>' internally
      local map = find_keymap({ "v", "x" }, "<lt>")
      assert.is_not_nil(map, "visual indent left (<) should exist")
    end)

    it("has visual indent right (>)", function()
      local map = find_keymap({ "v", "x" }, ">")
      assert.is_not_nil(map, "visual indent right (>) should exist")
    end)
  end)
end)
