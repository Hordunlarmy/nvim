-- Conjure: Interactive REPL-driven development for Clojure

return {
  "Olical/conjure",
  ft = { "clojure", "edn" },
  dependencies = {
    "PaterJason/cmp-conjure",
  },
  init = function()
    local auto_repl_cmd = [[sh -lc 'dir="$PWD"; while [ "$dir" != "/" ]; do if [ -f "$dir/project.clj" ]; then cd "$dir"; exec lein repl :headless :host 127.0.0.1 :port $port; fi; if [ -f "$dir/deps.edn" ] || [ -f "$dir/shadow-cljs.edn" ] || [ -f "$dir/bb.edn" ]; then cd "$dir"; exec clojure -M:nrepl --bind 127.0.0.1 --port $port 2>/dev/null || exec clojure -Sdeps "{:deps {nrepl/nrepl {:mvn/version \"1.3.1\"} cider/cider-nrepl {:mvn/version \"0.52.1\"}}}" -M -m nrepl.cmdline --middleware "[cider.nrepl/cider-middleware]" --bind 127.0.0.1 --port $port; fi; dir="$(dirname "$dir")"; done; exec lein repl :headless :host 127.0.0.1 :port $port']]

    -- Prefix for all Conjure mappings
    vim.g["conjure#mapping#prefix"] = "<localleader>"

    -- Auto-start and connect nREPL when opening Clojure buffers.
    vim.g["conjure#client#clojure#nrepl#connection#auto_repl#enabled"] = true
    vim.g["conjure#client#clojure#nrepl#connection#auto_repl#cmd"] = auto_repl_cmd
    vim.g["conjure#client#clojure#nrepl#connection#auto_repl#port_file"] = ".nrepl-port"
    vim.g["conjure#client#clojure#nrepl#connection#auto_repl#hidden"] = true

    -- Disable HUD popup, use vertical split instead
    vim.g["conjure#log#hud#enabled"] = false

    -- Log opens on the far right
    vim.g["conjure#log#botright"] = true

    -- Conjure expects fractional width, not columns.
    vim.g["conjure#log#split#width"] = 0.2

    -- Log display settings
    vim.g["conjure#log#wrap"] = true
    vim.g["conjure#log#fold#enabled"] = false

    -- Make \lv the default log open (vertical split)
    vim.g["conjure#mapping#log_vsplit"] = "lv"
    vim.g["conjure#mapping#log_split"] = "ls"
    vim.g["conjure#mapping#log_toggle"] = "lt"

    -- Evaluation result display
    vim.g["conjure#eval#result_register"] = "*"
    vim.g["conjure#eval#inline#highlight"] = "Comment"

    -- Disable Conjure for non-Clojure filetypes it might try to attach to
    vim.g["conjure#filetype#rust"] = false
    vim.g["conjure#filetype#python"] = false
    vim.g["conjure#filetype#lua"] = false
  end,
  config = function()
    if vim.fn.exists("*ConjureProcessOnExit") == 0 then
      _G.__conjure_process_on_exit = function(job_id)
        local ok, process = pcall(require, "conjure.process")
        if not ok or type(process) ~= "table" then
          return
        end
        local on_exit = process["on-exit"]
        if type(on_exit) ~= "function" then
          return
        end
        on_exit(tonumber(job_id) or job_id)
      end

      vim.cmd([[
        function! ConjureProcessOnExit(job_id, data, event) abort
          call v:lua.__conjure_process_on_exit(a:job_id)
        endfunction
      ]])
    end

    local function read_port(path)
      local file = io.open(path, "r")
      if not file then
        return nil
      end
      local content = file:read("*a")
      file:close()
      if not content then
        return nil
      end
      local port = tonumber((content:gsub("%s+", "")))
      return port
    end

    local function tcp_port_open(_host, port)
      local port_s = tostring(port)
      if vim.fn.executable("lsof") == 1 then
        local out = vim.fn.system({ "lsof", "-nP", "-iTCP:" .. port_s, "-sTCP:LISTEN", "-t" })
        if vim.v.shell_error == 0 and out and out:gsub("%s+", "") ~= "" then
          return true
        end
      end
      if vim.fn.executable("ss") == 1 then
        local out = vim.fn.system({ "ss", "-ltn", "sport = :" .. port_s })
        if vim.v.shell_error == 0 and out and out:find(port_s, 1, true) then
          return true
        end
      end
      -- Fallback: if we can't verify listener presence, assume closed.
      return false
    end

    local function prune_stale_port_files()
      local candidates = { ".nrepl-port", ".shadow-cljs/nrepl.port" }
      local cwd = vim.fn.getcwd()
      local dir = cwd

      while dir and dir ~= "" and dir ~= "/" do
        for _, rel in ipairs(candidates) do
          local path = dir .. "/" .. rel
          if vim.fn.filereadable(path) == 1 then
            local port = read_port(path)
            if port and not tcp_port_open("127.0.0.1", port) and not tcp_port_open("localhost", port) then
              pcall(vim.fn.delete, path)
            end
          end
        end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
          break
        end
        dir = parent
      end
    end

    local function ensure_repl_connected()
      prune_stale_port_files()

      local ok_action, action = pcall(require, "conjure.client.clojure.nrepl.action")
      local ok_auto, auto_repl = pcall(require, "conjure.client.clojure.nrepl.auto-repl")
      local ok_server, server = pcall(require, "conjure.client.clojure.nrepl.server")
      if not (ok_action and ok_auto and ok_server) then
        vim.notify("Conjure nREPL modules unavailable", vim.log.levels.WARN)
        return
      end

      local connected = false
      if type(server["connected?"]) == "function" then
        local ok_conn, is_conn = pcall(server["connected?"])
        connected = ok_conn and is_conn == true
      end
      if connected then
        return
      end

      if type(action["connect-port-file"]) == "function" then
        pcall(action["connect-port-file"])
      end

      vim.defer_fn(function()
        local now_connected = false
        if type(server["connected?"]) == "function" then
          local ok_conn, is_conn = pcall(server["connected?"])
          now_connected = ok_conn and is_conn == true
        end
        if now_connected then
          return
        end

        if type(auto_repl["restart-auto-repl-proc"]) == "function" then
          pcall(auto_repl["restart-auto-repl-proc"])
        elseif type(auto_repl["upsert-auto-repl-proc"]) == "function" then
          pcall(auto_repl["upsert-auto-repl-proc"])
        end

        vim.defer_fn(function()
          if type(action["connect-port-file"]) == "function" then
            pcall(action["connect-port-file"])
          end
        end, 350)
      end, 220)
    end

    local function set_sc_map(bufnr)
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      local ft = vim.bo[bufnr].filetype
      if ft ~= "clojure" and ft ~= "edn" then
        return
      end
      prune_stale_port_files()
      vim.keymap.set("n", "<localleader>sc", ensure_repl_connected, {
        buffer = bufnr,
        silent = true,
        desc = "Conjure/Compojure: connect or start nREPL",
      })
    end

    local function is_conjure_log_buf(bufnr)
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return false
      end
      local name = vim.api.nvim_buf_get_name(bufnr)
      return name ~= "" and name:match("conjure%-log%-") ~= nil
    end

    local function find_log_wins()
      local wins = {}
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if is_conjure_log_buf(buf) then
          table.insert(wins, win)
        end
      end
      return wins
    end

    local function find_aerial_win()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "aerial" then
          return win
        end
      end
      return nil
    end

    local function open_aerial_with_prev_width()
      local ok, aerial = pcall(require, "aerial")
      if not ok then
        return
      end
      pcall(function()
        aerial.open({ focus = false })
      end)

      local width = vim.t.conjure_aerial_prev_width
      if not width then
        return
      end

      local aerial_win = find_aerial_win()
      if aerial_win then
        pcall(vim.api.nvim_win_set_width, aerial_win, width)
      end
    end

    local function maybe_restore_aerial()
      local log_wins = find_log_wins()
      if #log_wins > 0 then
        vim.t.conjure_log_visible = true
        return
      end

      vim.t.conjure_log_visible = false
      if vim.t.conjure_restore_aerial ~= true then
        return
      end
      if find_aerial_win() then
        return
      end

      open_aerial_with_prev_width()
      vim.t.conjure_restore_aerial = nil
      vim.t.conjure_aerial_prev_width = nil
    end

    local function close_aerial_for_log()
      local aerial_win = find_aerial_win()
      if not aerial_win then
        vim.t.conjure_restore_aerial = false
        vim.t.conjure_aerial_prev_width = nil
        return
      end

      vim.t.conjure_restore_aerial = true
      vim.t.conjure_aerial_prev_width = vim.api.nvim_win_get_width(aerial_win)
      local ok, aerial = pcall(require, "aerial")
      if ok then
        pcall(aerial.close)
      else
        pcall(vim.api.nvim_win_close, aerial_win, true)
      end
    end

    local function open_log_vsplit_replacing_aerial()
      local origin_win = vim.api.nvim_get_current_win()
      close_aerial_for_log()

      local ok, log = pcall(require, "conjure.log")
      if not ok then
        return
      end
      log.vsplit()

      local log_wins = find_log_wins()
      if #log_wins > 0 then
        vim.t.conjure_log_visible = true
        if vim.t.conjure_aerial_prev_width then
          pcall(vim.api.nvim_win_set_width, log_wins[1], vim.t.conjure_aerial_prev_width)
        end
      end

      if origin_win and vim.api.nvim_win_is_valid(origin_win) then
        pcall(vim.api.nvim_set_current_win, origin_win)
      end
    end

    local function close_log_and_restore()
      local ok, log = pcall(require, "conjure.log")
      if ok then
        log["close-visible"]()
      end
      vim.schedule(maybe_restore_aerial)
    end

    local function toggle_log_replacing_aerial()
      if #find_log_wins() > 0 then
        close_log_and_restore()
      else
        open_log_vsplit_replacing_aerial()
      end
    end

    local function clear_conjure_log()
      local ok, log = pcall(require, "conjure.log")
      if ok and log then
        if type(log["reset-soft"]) == "function" then
          log["reset-soft"]()
          return
        end
        if type(log["reset-hard"]) == "function" then
          log["reset-hard"]()
          return
        end
      end
      pcall(vim.cmd, "ConjureLogResetSoft")
    end

    local function eval_buffer_on_insert_leave(bufnr)
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      local ft = vim.bo[bufnr].filetype
      if ft ~= "clojure" and ft ~= "edn" then
        return
      end
      ensure_repl_connected()
      local ok, eval = pcall(require, "conjure.eval")
      if ok and eval and type(eval.buf) == "function" then
        pcall(eval.buf)
        return
      end
      pcall(vim.cmd, "ConjureEvalBuf")
    end

    local function attach_log_keymaps(bufnr)
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        local ft = vim.bo[bufnr].filetype
        if ft ~= "clojure" and ft ~= "edn" then
          return
        end

        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "<localleader>lv", function()
          ensure_repl_connected()
          vim.defer_fn(open_log_vsplit_replacing_aerial, 220)
        end, vim.tbl_extend("force", opts, {
          desc = "Conjure/Compojure: open log in Aerial slot",
        }))
        vim.keymap.set("n", "<localleader>lt", function()
          ensure_repl_connected()
          vim.defer_fn(toggle_log_replacing_aerial, 220)
        end, vim.tbl_extend("force", opts, {
          desc = "Conjure/Compojure: toggle log in Aerial slot",
        }))
        vim.keymap.set("n", "<localleader>lq", close_log_and_restore, vim.tbl_extend("force", opts, {
          desc = "Conjure/Compojure: close log and restore Aerial",
        }))
        vim.keymap.set("n", "<localleader>rr", function()
          local ok, eval = pcall(require, "conjure.eval")
          if ok then
            eval.command("(clojure.tools.namespace.repl/refresh)")
          end
        end, vim.tbl_extend("force", opts, {
          desc = "Conjure: reload all modified namespaces (tools.namespace)",
        }))
        vim.keymap.set({"n", "i"}, "<F2>", function()
          clear_conjure_log()
        end, vim.tbl_extend("force", opts, {
          desc = "Conjure: clear log (F2 shortcut)",
        }))
        set_sc_map(bufnr)
        -- Re-apply shortly after, so our map wins even if Conjure sets defaults later.
        vim.defer_fn(function()
          set_sc_map(bufnr)
        end, 120)
      end)
    end

    local group = vim.api.nvim_create_augroup("ConjureAerialBridge", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = { "clojure", "edn" },
      callback = function(args)
        prune_stale_port_files()
        attach_log_keymaps(args.buf)
        
        -- Auto-eval on InsertLeave (with small delay to ensure buffer is consistent)
        vim.api.nvim_create_autocmd("InsertLeave", {
          group = group,
          buffer = args.buf,
          callback = function()
            eval_buffer_on_insert_leave(args.buf)
          end,
        })
      end,
    })

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        attach_log_keymaps(bufnr)
      end
    end

    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = group,
      pattern = "*",
      callback = function(args)
        if not is_conjure_log_buf(args.buf) then
          return
        end
        vim.t.conjure_log_visible = true
        vim.keymap.set("n", "q", close_log_and_restore, { buffer = args.buf, silent = true, desc = "Close log + restore Aerial" })
        vim.keymap.set("n", "<Esc>", close_log_and_restore, { buffer = args.buf, silent = true, desc = "Close log + restore Aerial" })
        vim.keymap.set({ "n", "i" }, "<F2>", clear_conjure_log, { buffer = args.buf, silent = true, desc = "Conjure: clear log (F2)" })
      end,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
      group = group,
      pattern = "*",
      callback = function()
        vim.schedule(maybe_restore_aerial)
      end,
    })
  end,
}
