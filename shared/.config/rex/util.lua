-- Helpers shared by the other config files.
local M = {}

M.home = os.getenv("HOME")
M.terminal = "com.superlogical.terminal"
M.shell = "com.superlogical.terminal.shell"

local function url_decode(s)
  return (s:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

-- Live working directory of the focused pane (`nil` when unknown). Terminals
-- report it as file://HOST/path (OSC 7).
function M.cwd_of(ctx)
  if not ctx.block_id then return nil end
  local r = rex.block.call(M.terminal, "pwd", { session_id = ctx.session_id, block_id = ctx.block_id })
  local url = r and (r.pwd or r.url)
  if not url or url == "" then return nil end
  return url_decode((url:gsub("^file://[^/]*", "")))
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
