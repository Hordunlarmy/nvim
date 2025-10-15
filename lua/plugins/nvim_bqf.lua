-- nvim-bqf: Better quickfix window
return {
  "kevinhwang91/nvim-bqf",
  ft = "qf",
  opts = {
    auto_enable = true,
    auto_resize_height = true,
    preview = {
      win_height = 12,
      win_vheight = 12,
      delay_syntax = 80,
      border_chars = { "┃", "━", "┏", "┓", "┗", "┛", "━", "┃", " " },
      show_title = false,
      should_preview_cb = function(bufnr, qwinid)
        local ret = true
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        local fsize = vim.fn.getfsize(bufname)
        if fsize > 100 * 1024 then
          ret = false
        elseif bufname:match("^fugitive://") then
          ret = false
        end
        return ret
      end,
    },
    func_map = {
      vsplit = "",
      ptogglemode = "z,",
      stoggleup = "",
    },
    filter = {
      fzf = {
        action_for = { ["ctrl-s"] = "split" },
        extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
      },
    },
  },
}


