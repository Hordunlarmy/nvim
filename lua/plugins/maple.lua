-- Personal Markdown notes, stored outside every code repository.
return {
  "forest-nvim/maple.nvim",
  cmd = {
    "MapleToggle",
    "MapleToggleFloat",
    "MapleSearch",
    "MapleSwitchMode",
  },
  opts = {
    storage_path = vim.fn.stdpath("data") .. "/maple",
    notes_mode = "global",
    use_project_specific_notes = false,
    open_style = "float",
    width = 0.72,
    height = 0.72,
    border = "rounded",
    title = " Notes ",
    title_pos = "center",
  },
  keys = {
    { "<leader>mn", "<cmd>MapleToggle<cr>", desc = "Notes: open global note" },
    { "<leader>mf", "<cmd>MapleSearch<cr>", desc = "Notes: search all notes" },
    { "<leader>mg", "<cmd>MapleSearch grep<cr>", desc = "Notes: search note contents" },
  },
}
