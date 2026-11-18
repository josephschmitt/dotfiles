-- Helpers shared by the other config files.
local M = {}

-- Actions run in the *client's* Lua (the Mac app), not on the server, so
-- os.getenv("HOME") is the Mac's home even when the session lives on a remote
-- box. Never bake client paths into a block's command or cwd. home_cmd wraps a
-- $HOME-relative script in `sh -c` so $HOME expands on the box that runs it.
function M.home_cmd(rel, ...)
  return { "sh", "-c", 'exec "$HOME/' .. rel .. '" "$@"', "sh", ... }
end
M.terminal = "com.superlogical.terminal"
M.shell = "com.superlogical.terminal.shell"

local function url_decode(s)
  return (s:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

-- Live working directory of the focused pane (`nil` when unknown). Shells
-- that emit OSC 7 report it as file://HOST/path via `pwd`. Ours don't on
-- Linux, so fall back to the cwd the server reads from the pane's processes
-- (foreground first, e.g. nvim's dir, then the shell).
function M.cwd_of(ctx)
  if not ctx.block_id then return nil end
  local target = { session_id = ctx.session_id, block_id = ctx.block_id }
  local r = rex.block.call(M.terminal, "pwd", target)
  local url = r and (r.pwd or r.url)
  if url and url ~= "" then return url_decode((url:gsub("^file://[^/]*", ""))) end
  local p = rex.block.call(M.terminal, "process", target)
  local proc = p and (p.foreground or p.child)
  return proc and proc.cwd ~= "" and proc.cwd or nil
end

-- The active window of the action's session, from `session.view`.
function M.active_window(ctx)
  local view = rex.session.view{ session_id = ctx.session_id }
  for _, w in ipairs(view and view.windows or {}) do
    if w.window_id == view.active_window_id then return w, view end
  end
  return nil, view
end

return M
