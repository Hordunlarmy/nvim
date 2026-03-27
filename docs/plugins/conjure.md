# Conjure (Clojure REPL)

Config file:
- /home/horduntech/.config/nvim/lua/plugins/conjure.lua

References:
- https://github.com/Olical/conjure
- https://github.com/clojure-lsp/clojure-lsp

## What Conjure does
Conjure is an interactive REPL-driven workflow for Clojure. It connects to an nREPL server and lets you evaluate forms, inspect results, and navigate code without leaving Neovim.

This config enables Conjure only for `clojure` and `edn` buffers and auto-starts an nREPL based on your project type. It also disables the floating HUD and uses a vertical split log buffer instead. The Conjure log is integrated with Aerial so it replaces the Aerial slot and restores it when closed.

## Auto REPL behavior
This config enables Conjure auto-repl for Clojure and uses a custom command that walks up the directory tree to find project files:
- If `project.clj` is found, it runs `lein repl`
- If `deps.edn` or `shadow-cljs.edn` or `bb.edn` is found, it runs a `clojure -M:nrepl` or a fallback with explicit nrepl middleware

This means opening any Clojure file in a project will spawn a REPL automatically.

Key options set:
- `conjure#client#clojure#nrepl#connection#auto_repl#enabled = true`
- `conjure#client#clojure#nrepl#connection#auto_repl#cmd = <custom command>`

## Log window behavior
The Conjure log is configured to open on the far right as a vertical split:
- `conjure#log#hud#enabled = false`
- `conjure#log#botright = true`
- `conjure#log#split#width = 0.2`

There is a custom integration so that the Conjure log replaces Aerial (outline) and then restores Aerial after the log closes. This prevents the log from stealing focus or resizing the main buffer unpredictably.

## Keymaps
Conjure keymaps use the local leader (`\\`). These are buffer-local in Clojure files.

Core evaluation:
- `\\eb` eval buffer
- `\\ee` eval form under cursor
- `\\er` eval root form
- `\\ew` eval word
- `\\e!` eval and replace form

Log control:
- `\\lv` open log as vertical split, replacing Aerial
- `\\lt` toggle log in Aerial slot
- `\\lq` close log and restore Aerial
- `\\ls` show log
- `\\lr` reset log

Session:
- `\\sc` connect or select REPL
- `\\cd` disconnect

Navigation:
- `\\gd` go to definition
- `\\vs` view source
- `\\vd` view doc

These descriptions are also registered in which-key for discoverability.

## Typical workflow
1. Open a Clojure file in your project.
2. Conjure auto-starts an nREPL based on project files.
3. Evaluate forms using `\\ee`, `\\er`, or `\\eb`.
4. Toggle the log with `\\lt` and inspect results.
5. Jump to definitions with `\\gd` or view docs with `\\vd`.

## Troubleshooting
- If auto-repl launches the wrong command, check the project root files and the custom auto-repl command in the config.
- If a REPL hangs, use `\\cd` to disconnect, then `\\sc` to reconnect.
- If the log window size looks wrong, it is tied to Aerial width restoration. Close/reopen Aerial or the log once to reset.
- If clojure-lsp is slow, see docs/plugins/lsp.md for cache and project indexing behavior.

## Why Conjure is configured this way
This configuration prioritizes a stable layout and fast feedback:
- The Aerial slot is reused for logs to avoid reflowing your main editing window.
- Auto-repl removes manual setup time.
- The log is made predictable and consistent in size.
