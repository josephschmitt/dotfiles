-- Floating popups: Herdr's popup keys (quick shell, mini shell, editor, lazygit,
-- yazi, worktree and project pickers) as Rex floating layers.
--
-- Each popup is a floating terminal labelled "popup:<name>" that starts in the
-- focused pane's directory. Pressing its key again closes it (or, for persistent
-- ones, hides it). A *persistent* popup keeps running while hidden: hiding
-- detaches the block from the layout, showing floats it back. `prefix+_` hides
-- whatever popup is open.
local util = require("util")

local SCRIPTS = util.home .. "/.config/herdr/scripts" -- quick-shell.sh, wt-picker.sh (shared with Herdr)
local REX_SCRIPTS = util.home .. "/.config/rex/scripts"
local PREFIX = "popup:"

-- Bounds are fractions of the window: x, y, width, height.
local function centered(w, h) return { (1 - w) / 2, (1 - h) / 2, w, h } end

local persistent = {} -- label -> true

local function find_block(ctx, label)
  local list = rex.session.list_blocks{ session_id = ctx.session_id }
  for _, b in ipairs(list and list.blocks or {}) do
    if b.label == label then return b end
  end
end

local function floating_in(window, block_id)
  for _, layer in ipairs(window and window.layers or {}) do
    if layer.kind ~= "tiled" then
      for _, b in ipairs(layer.blocks or {}) do
        if b.block_id == block_id then return true end
      end
    end
  end
  return false
end

local function open_new(ctx, label, command, bounds)
  local _, err = rex.session.new_layer{
    session_id = ctx.session_id,
    bounds = bounds,
    focus = true,
    layout = rex.layout.block{
      flavor = util.shell,
      label = label,
      options = { command = command, cwd = util.cwd_of(ctx) },
    },
  }
  if err then error(err, 0) end
end

local function toggle(ctx, spec)
  local label = PREFIX .. spec.name
  local block = find_block(ctx, label)

  if not spec.persist then
    if block and block.placement ~= "detached" then
      rex.call("block.close", { session_id = ctx.session_id, block_id = block.block_id })
    else
      open_new(ctx, label, spec.command, spec.bounds)
    end
    return
  end

  persistent[label] = true
  if not block then return open_new(ctx, label, spec.command, spec.bounds) end

  local window = util.active_window(ctx)
  if window and floating_in(window, block.block_id) then
    -- Shown: hide it, keeping the process alive.
    rex.session.detach_block{ session_id = ctx.session_id, block_id = block.block_id }
    return
  end
  -- Hidden (or floating in another window): float it over the focused pane.
  if block.placement ~= "detached" then
    rex.session.detach_block{ session_id = ctx.session_id, block_id = block.block_id }
  end
  local anchor = ctx.block_id
  if not anchor or anchor == block.block_id then anchor = window and window.focused_block_id end
  local _, err = rex.session.move_block{
    session_id = ctx.session_id,
    block_id = block.block_id,
    anchor_block_id = anchor,
    direction = "vertical",
  }
  if err then error(err, 0) end
  rex.session.float_block{ session_id = ctx.session_id, block_id = block.block_id, bounds = spec.bounds }
  rex.session.focus_block{ session_id = ctx.session_id, block_id = block.block_id }
end

local quick_shell = SCRIPTS .. "/quick-shell.sh"
local wt = { "env", "WT_ENGINE=rex-wt", SCRIPTS .. "/wt-picker.sh" }
local function with(base, ...) -- base command + extra args
  local c = {}
  for _, a in ipairs(base) do c[#c + 1] = a end
  for _, a in ipairs({ ... }) do c[#c + 1] = a end
  return c
end

-- name = action name, title = palette title.
local specs = {
  { name = "quick_shell", title = "Quick Shell", command = { quick_shell }, bounds = centered(0.6, 0.6) },
  { name = "mini_shell", title = "Mini Shell (persists)", command = { quick_shell, "--persist" },
    bounds = centered(0.6, 0.6), persist = true },
  -- $EDITOR is exported by the shell the terminal runs through, so a `sh -c` sees it.
  { name = "editor", title = "Editor", command = { "sh", "-c", "exec $EDITOR" }, bounds = centered(0.8, 0.8) },
  { name = "lazygit", title = "Lazygit", command = { "lazygit-launch" }, bounds = centered(0.9, 0.9), persist = true },
  { name = "yazi", title = "Yazi", command = { "yazi" }, bounds = centered(0.8, 0.8) },
  { name = "pj_picker", title = "Project Picker (pj)", command = { REX_SCRIPTS .. "/pj-picker.sh" },
    bounds = centered(0.6, 0.6) },
  { name = "wt_all", title = "Worktrees: All Repos", command = with(wt, "--all"), bounds = centered(0.8, 0.6) },
  { name = "wt_repo", title = "Worktrees: This Repo", command = wt, bounds = centered(0.8, 0.6) },
  { name = "wt_branch", title = "Worktrees: From Branch", command = with(wt, "--branch"), bounds = centered(0.8, 0.6) },
  { name = "wt_remove", title = "Worktrees: Remove Current", command = with(wt, "--remove-current"),
    bounds = centered(0.7, 0.4) },
}

for _, spec in ipairs(specs) do
  rex.action{
    name = "popup_" .. spec.name,
    title = "Popup: " .. spec.title,
    category = "Popups",
    run = function(ctx) toggle(ctx, spec) end,
  }
  if spec.persist then persistent[PREFIX .. spec.name] = true end
end

-- prefix+_: hide the popup that's open. A persistent one is detached (and comes
-- back with its key), the others are closed.
rex.action{
  name = "popup_hide",
  title = "Popup: Hide",
  category = "Popups",
  run = function(ctx)
    local window = util.active_window(ctx)
    local list = rex.session.list_blocks{ session_id = ctx.session_id }
    for _, b in ipairs(list and list.blocks or {}) do
      if b.label and b.label:sub(1, #PREFIX) == PREFIX and floating_in(window, b.block_id) then
        if persistent[b.label] then
          rex.session.detach_block{ session_id = ctx.session_id, block_id = b.block_id }
        else
          rex.call("block.close", { session_id = ctx.session_id, block_id = b.block_id })
        end
        return
      end
    end
  end,
}
