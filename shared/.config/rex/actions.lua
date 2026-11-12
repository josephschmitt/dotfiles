-- Custom actions (rex.action). Key bindings live in keys.lua.
local util = require("util")

-- Switch the client to a session. Scripts (rex-open, the pickers) call this with
-- `rex do select_session session_id=…`.
rex.action{
  name = "select_session",
  title = "Select Session",
  category = "Sessions",
  args = { session_id = "string", window_id = "string?" },
  run = function(_, args)
    rex.client.queue("session.select", { session_id = args.session_id, window_id = args.window_id })
  end,
}

-- Herdr's "new space" (prefix+N): a session that starts in ~/development.
-- Splits and new tabs keep following the focused pane's directory.
rex.action{
  name = "new_session_dev",
  title = "New Session in ~/development",
  category = "Sessions",
  run = function()
    local created, err = rex.call("session.create", {
      initial_windows = {
        {
          window_label = "shell",
          layout = { block = { flavor = util.shell, options = { cwd = util.home .. "/development" } } },
        },
      },
    })
    if err then error(err, 0) end
    rex.client.queue("session.select", { session_id = created.session_id })
  end,
}

-- alt+shift+1..9 (Herdr's switch_workspace): the Nth session, in `session.list`
-- order.
rex.action{
  name = "goto_session",
  title = "Go to Session by Number",
  category = "Sessions",
  args = { index = "integer" },
  run = function(_, args)
    local list = rex.call("session.list")
    local s = list and list.sessions and list.sessions[args.index]
    if s then rex.client.queue("session.select", { session_id = s.session_id }) end
  end,
}

-- prefix+g: open the focused pane's branch PR in the browser.
rex.action{
  name = "open_pr",
  title = "Open PR in Browser",
  category = "Git",
  run = function(ctx)
    -- A login bash, so gh is found on the PATH the profile sets (the server may
    -- have been started with a minimal one).
    local r, err = rex.exec({ "/bin/bash", "-lc", "gh pr view --web" }, { cwd = util.cwd_of(ctx), timeout = 20 })
    if err then error(err, 0) end
    if not r.ok then
      local msg = (r.stderr ~= "" and r.stderr or r.stdout):match("[^\n]+") or "gh failed"
      error("No PR for this branch: " .. msg, 0)
    end
  end,
}
