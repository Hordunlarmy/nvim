-- indent-o-matic: Auto-detect indentation
return {
  "Darazaki/indent-o-matic",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    max_lines = 2048,
    standard_widths = { 2, 4, 8 },
    filetype_typescript = {
      standard_widths = { 2, 4 },
    },
    filetype_javascript = {
      standard_widths = { 2, 4 },
    },
    filetype_json = {
      standard_widths = { 2, 4 },
    },
    filetype_python = {
      standard_widths = { 4 },
    },
  },
}


