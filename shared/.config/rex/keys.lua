-- Key bindings. Layer 1: alt+… (no prefix). Layer 2: ctrl+s, then a key.
-- Rex writes shifted keys unshifted (`shift+n`, not `N`), and a sequence is
-- `first>second`. Physical keys are `[Backquote]`, `[BracketLeft]`.
-- `rex keymap` shows what every key does after loading this file.

local function prefix(key, action, args) rex.bind("ctrl+s>" .. key, action, args) end

local dirs = { h = "left", j = "down", k = "up", l = "right" }

-- ---- Layer 1: alt+… --------------------------------------------------------

for key, dir in pairs(dirs) do
  rex.bind("alt+" .. key, "pane.focus", { direction = dir, wrap = false })
end
rex.bind("alt+z", "pane.zoom")
rex.bind("alt+[Backquote]", "pane.focus_next")
rex.bind("alt+shift+[Backquote]", "pane.focus_previous")

-- Tabs 1-9 (Rex: a session's windows), sessions with shift (Herdr: spaces).
for i = 1, 9 do
  rex.bind("alt+" .. i, "client.tab.goto", { index = i })
  rex.bind("alt+shift+" .. i, "goto_session", { index = i })
end
rex.bind("alt+[", "session.previous")
rex.bind("alt+]", "session.next")
-- alt+shift+[ / ] were Herdr's previous/next agent. Rex has no agent cycling;
-- the activity view (prefix+a) is the replacement.

-- ---- Layer 2: ctrl+s, then… ------------------------------------------------

-- Panes
for key, dir in pairs(dirs) do prefix(key, "pane.focus", { direction = dir }) end
prefix("\\", "pane.split", { direction = "down" })
prefix("shift+\\", "pane.split", { direction = "right" })
prefix("x", "pane.close")
prefix("z", "pane.zoom")
prefix("p", "pane.rename")
prefix("=", "pane.balance")

-- Tabs
prefix("n", "client.tab.new")
prefix("[", "client.tab.previous")
prefix("]", "client.tab.next")
prefix("shift+t", "client.tab.rename")
prefix("shift+x", "client.tab.close")

-- Sessions (Herdr spaces)
prefix("shift+n", "new_session_dev")
prefix("o", "session.switch")
prefix("shift+o", "popup_pj_picker")
prefix("w", "popup_wt_all")
prefix("shift+w", "popup_wt_repo")
prefix("shift+b", "popup_wt_branch")
prefix("shift+d", "popup_wt_remove")

-- Activity (Herdr agents): the picker of programs/agents, and the sidebar's activity view
prefix("a", "pane.view_activity")
prefix("shift+a", "client.sidebar.activity.toggle")

-- Popups
prefix("c", "popup_quick_shell")
prefix("shift+c", "popup_mini_shell")
prefix("shift+e", "popup_editor")
prefix("shift+g", "popup_lazygit")
prefix("shift+y", "popup_yazi")
prefix("shift+-", "popup_hide") -- `_`

-- Other
prefix("g", "open_pr")
prefix("b", "client.sidebar.toggle")
prefix("s", "client.settings")
prefix("shift+/", "client.palette.toggle") -- `?`
prefix("shift+r", "client.config.reload")

-- Resize mode (Herdr's prefix+r): sticky, so hjkl keeps resizing until Esc.
-- Exclusive, so a stray key can't type into the pane meanwhile.
rex.mode("resize", { exclusive = true })
prefix("r", "client.mode.enter", { name = "resize" })
local STEP, BIG = 5, 15
for key, dir in pairs(dirs) do
  rex.bind("resize/" .. key, "pane.resize", { direction = dir, amount = STEP })
  rex.bind("resize/shift+" .. key, "pane.resize", { direction = dir, amount = BIG })
  rex.bind("resize/" .. dir, "pane.resize", { direction = dir, amount = STEP })
  rex.bind("resize/shift+" .. dir, "pane.resize", { direction = dir, amount = BIG })
end
rex.bind("resize/=", "pane.balance")
for _, key in ipairs({ "enter", "q", "ctrl+c" }) do rex.bind("resize/" .. key, "client.mode.exit") end
