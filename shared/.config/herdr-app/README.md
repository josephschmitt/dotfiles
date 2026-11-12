Configuration for [Herdr app](https://herdr.dev/) — the desktop (GUI) successor to the `herdr` terminal multiplexer. Its whole interface is files in `~/.config/herdr-app`; `herdr-app --skill` and the generated `~/.config/herdr-app/AGENTS.md` are the reference.

## What's tracked

Only `keys.json`, `mods/leader/`, `mods/pj-picker/` and `mods/wt-picker/` are symlinked from this repo (via GNU Stow). The rest of `~/.config/herdr-app` is written by the app (`settings.json`, `view.json`, `layouts/`, `mods/`, ...) and stays local — `settings.json` holds zoom, which changes constantly. Don't `stow` the whole directory's contents blindly: if `keys.json` is deleted while the app runs, it rewrites it within a second, so remove and re-stow in a single command.

## Keybindings (`keys.json`)

The file is Herdr's default `cmd-` keymap plus the overrides below, ported from the old TUI `herdr/config.toml`. `keys.json` only supports single key combos, so the TUI's `ctrl+s` prefix is rebuilt as the `leader` mod (next section).

| Key | Action |
|-----|--------|
| `alt+h/j/k/l` | Focus pane left/down/up/right |
| `alt+z` | Zoom pane |
| `alt+1..9` | Select tab |
| `alt+[` / `alt+]` | Previous / next space |
| `alt+shift+1..9` | Select space |
| `alt+shift+[` / `alt+shift+]` | Previous / next agent |

Why `alt`: matches tmux-tilish / vim-tmux-navigator. Needs `option_as_alt` (Settings → Keyboard), which `"auto"` enables on US layouts.

## Leader key (`mods/leader/`)

> **Temporary workaround.** Herdr app has no native leader/prefix key (`keys.json` takes single key combos only), so this mod emulates the TUI's `ctrl+s` prefix. **If Herdr app ever ships native leader-key support, replace this mod with it:** port the key table (`ITEMS` in `mods/leader/main.js`, summarized below) into the native config, delete `mods/leader/`, drop the `"ctrl-s": "mod.open:leader"` binding, and remove this section.

`ctrl+s` (`"ctrl-s": "mod.open:leader"`) opens a which-key popup that takes the keyboard; the next typed character runs an action and closes it. `Esc`, `ctrl+s` again or any unmapped key just closes it. The key table is `ITEMS` at the top of `mods/leader/main.js` — edit it there; the popup draws itself from it.

| Key | Action |
|-----|--------|
| `h j k l` | Focus pane |
| `\` / `\|` | Split down / right |
| `x` / `z` | Close / zoom pane |
| `n`, `[`, `]`, `T`, `X` | New, previous, next, rename, close tab |
| `N` | New space in `~/development` |
| `o` | Go to… (picker) |
| `O` | Project picker (`pj`; focuses the project's existing space or creates one; see [pj project picker](#pj-project-picker-modspj-picker)) |
| `w` / `W` / `B` / `D` | All worktrees (every repo) / worktree picker for this repo (find-or-create) / branch picker (existing branch -> worktree) / remove this worktree (`wt-picker`; see [Worktree picker](#worktree-picker-modswt-picker)). `w` works from any space; on a remote space `W`, `B` and `D` open the shipped `worktree` mod's dialogs instead |
| `1..9` | Focus agent N (agents list order) |
| `c` / `C` | Quick shell / mini shell (the latter persists; `hide` keeps it, reopen with `C`) |
| `E` / `G` / `Y` | `$EDITOR` / `lazygit-launch` / `yazi` popups |
| `_` | Hide the open popup if it persists (mini shell, Lazygit). Any other popup is closed like `✕`, which kills its program |
| `g` | Open the branch's PR (`gh pr view --web`) |
| `b` / `s` / `?` | Toggle sidebar / settings / keybinds |

Popups are a hidden `hc` terminal (started in the focused pane's folder, or on its machine) shown in a modal overlay under a title bar drawn by the same mod; they close when the program exits, and `✕` kills it.

Gotchas:
- `ctrl+s` is no longer passed to programs (same as with the TUI prefix).
- A mod can't open overlays from async work after its own popup has closed, so async items (`late: true`) run first and the leader closes afterwards. Terminal popups call `closeLeader()` themselves *right before* `openOverlay` (same tick, so it still works): a popup opened under a still-open leader loses the keyboard to the pane beneath when the leader closes.
- The mod folder is a symlink into this repo, and the app writes `gpui-kit.d.ts` and `jsconfig.json` into it; `.gitignore` here hides them.
- `quick-shell.sh` binds Ctrl-c itself for the double-tap close: fish 4 reads Ctrl-c as a key at the prompt (no SIGINT), and oh-my-posh binds it too, so the bind is made at the first `fish_prompt`.
- `quick-shell.sh` still tries `herdr notification show` for its "press Ctrl-c again" hint, which talks to the TUI server, so it only appears if that is running.

### How the mod is set up

| Piece | Where | Role |
|-------|-------|------|
| `mods/leader/main.js` | this repo, stowed to `~/.config/herdr-app/mods/leader` | The whole mod: `ITEMS` key table, the which-key popup, the popup-terminal runner, and the title bar for those popups |
| `mods/leader/mod.json` | same | `{"place": "none", "overlay": {"kind": "popup", "frame": "none", "at": "bottom", "width": 1, "height": 1}}`: not docked anywhere; `mod.open` shows it as a frameless popup covering the window, and `render()` draws the 740x380 card at the bottom center itself (a popup's own position follows the mouse pointer, so the mod can't rely on it). A press beside the card closes it. After editing `mod.json`, write it in place (`cat x > mod.json`, not an editor's atomic replace) or the app's watcher may miss it |
| `"ctrl-s": "mod.open:leader"` | `keys.json` (`global`) | Opens the popup. `mod.open` toggles, so `ctrl+s` again closes it |
| `.gitignore` | this directory | Hides `gpui-kit.d.ts` / `jsconfig.json`, which the app writes into every mod folder (visible here because the mod dir is a symlink) |

How it works:
- The popup takes keyboard focus (`handle.focus()`) and reads `on_key_down`. Only typed characters (`key_char`) count; bare modifiers/arrows are ignored, `Esc`/`ctrl+s`/`ctrl+c` close.
- Plain actions call `run("<command>", args)` — the same commands `keys.json` binds (`herdr-app commands`). They close the popup first so focus is back in the terminal.
- Popup programs (`late: true` items) run `hc run --bg --json --no-parent --no-notify [--rm] [--on <machine>] [--cwd <folder>] -- bash -lc <cmd>`, where the folder is the focused pane's live `cwd` (from `panes()`, since `focused().cwd` is only set for layout blocks). On a remote space the folder is left out unless the pane reports one, so `hc` starts in that machine's home; the Mac's home is never sent to a remote. Then `openOverlay` a modal layout: a 30px title-bar block (this same mod, via `props.bar`) over a `{ terminal: "<addr>" }` block. The overlay closes itself when the program exits; `✕` runs `terminal.kill`. The persistent popups skip `--rm`, remember their address in `shared("leader.<title>")` and say `hide` instead of `✕`: the mini shell (`C`) and Lazygit (`G`). Hiding keeps the program running; pressing the same key reattaches to it.
- Popup items finish their async work (spawning the terminal) while the leader is alive, then close it and open the overlay back to back. No `pane.focus`: the overlay's terminal takes the keys itself, and since Herdr 0.1.12 `pane.focus {terminal}` only finds layout blocks and panes, so it fails with "no such pane" for a popup terminal.

Editing it: the app hot-reloads on save (a broken save keeps the old version and reports in `herdr-app status`). After every change:

```sh
herdr-app check ~/.config/herdr-app/mods/leader   # loads and renders once
herdr-app do mod.open --name leader               # open the popup
herdr-app shot /tmp/leader.png                    # then look at it
herdr-app do overlay.close
```

Reinstalling on a new machine: `stow shared` links the mod and `keys.json`. There is no hook for this; if the app already created `keys.json`, delete it and stow in one command (see above).

## pj project picker (`mods/pj-picker/`)

A native-looking project picker styled like the app's "Go to…" window (`cmd+p`, leader `o`). Go to… is the shipped `picker` mod with hard-coded rows (spaces, tabs, agents) and no source/provider API, so this is a sibling mod that lists `pj` projects instead. The shipped `picker` is untouched and keeps getting app updates.

Opened by leader `O` (`run("mod.open", { name: "pj-picker" })`), the same keys as the TUI's `prefix+shift+o` and a pair with `o` = Go to…. Type to filter (case-insensitive substring over name, path and marker).

| Key | Action |
|-----|--------|
| `Enter` | Focus the project's open space, else create one (`space.new` with the folder and name) |
| `ctrl+n` | Always create a new space, even if one is open |
| `↑` / `↓`, `ctrl+k` / `ctrl+j` | Move (wraps) |
| `Esc` | Close |

- **Open space match:** a space on this computer (`machine` null) whose `folder` equals the project path (trailing `/` ignored). Matching rows show a dot in the space's color right after the name.
- **Icons:** each row shows `pj`'s marker icon (`pj --icons`, `%i`) and color (`%c`). The icons are Nerd Font glyphs, drawn in the app's terminal font (`settings().font`, a Nerd Font here); `pj`'s color names map onto the theme's `ansi0..15`.
- **Data source:** `pj --icons --format '%P\t%n\t%l\t%i\t%c' --sort alpha` (one tab-separated line per project), so it honors `~/.config/pj/config.yaml` (search paths, markers, excludes). `pj` only runs locally, so projects on remote machines (Crafting sandbox) aren't listed; new spaces are pinned to this computer (`machine: ""`).
- **Why a mod:** the only extension route in the app is a mod, which can `exec(...)`. The layout (header, filter field, fixed-height scroll strip, key handling) is copied from the shipped `picker` mod.
- A direct shortcut is one line in `keys.json`, e.g. `"cmd-shift-o": "mod.open:pj-picker"`.

Same setup and editing notes as the leader mod (stowed directory symlink, hot-reload, `.gitignore` hides the generated `gpui-kit.d.ts` / `jsconfig.json`):

```sh
herdr-app check ~/.config/herdr-app/mods/pj-picker   # loads and renders once
herdr-app do mod.open --name pj-picker               # open the picker
herdr-app shot /tmp/pj.png                           # then look at it
herdr-app do overlay.close
```

## Worktree picker (`mods/wt-picker/`)

Git worktree pickers, the app side of the TUI's `prefix+w` / `prefix+shift+w` / `prefix+shift+b` / `prefix+shift+d` popups (`shared/.config/herdr/scripts/wt-picker.sh`), in the same look as the pj picker. Four modes (`props.mode`):

| Leader | Mode | Does |
|--------|------|------|
| `w` | `all` | Every managed worktree (`~/.herdr/worktrees/<repo>/<name>`) across all repos, the repo as a dim tag before the branch. Enter switches to or opens it, `ctrl+d` removes it, `ctrl+g` merges it. No create. Works from any space, even a remote one or one outside a repo. Main checkouts aren't listed (the pj picker covers those) |
| `W` | `pick` (default) | Find-or-create in the focused space's repo: type a name, the matching checkouts are listed below (case-insensitive substring over branch and path). The title names the repo (`Worktrees (dotfiles)`), as the TUI's prompt does (`worktree (dotfiles) ❯`). There's no separate "new worktree" key: Enter on an unmatched name, or `ctrl+n`, creates |
| `B` | `branch` | Existing branch -> worktree: the focused space's repo's local and `origin/` branches that have no worktree yet, newest first (`herdr-wt branches`; remote-only ones are tagged, the commit subject and age are dim). Type to filter on branch and subject; `Tab` cycles the list all / local / remote (remote = origin-only, the tagged rows; local includes branches that are on both). Enter checks the branch out into a worktree (a remote-only branch gets a tracking branch, Worktrunk hooks run) and opens a space for it. No create, no delete. The refs are whatever is already local: nothing is fetched, so `git fetch` first for a branch someone just pushed |
| `D` | `remove` | Skips the list and goes straight to the remove confirmation for the focused space's checkout |

Keys in the lists (`branch` mode only has `Enter`, `Tab`, the arrows and `Esc`; `ctrl+n` / `ctrl+d` / `ctrl+g` do nothing there):

| Key | Action |
|-----|--------|
| `Enter` | Focus the checkout's open space, else open one (`space.new`, unnamed so it nests under the repo). Repo mode, nothing matching: a "Create worktree `<name>`" row creates it and opens it |
| `ctrl+n` | Repo mode: create the typed name even when something matches (e.g. `foo` while `foo-bar` exists). Does nothing in `all` mode |
| `ctrl+d` | Offer to remove the highlighted worktree: asks first, lists uncommitted changes and forces if there are any; refuses the main checkout. Its space is closed after the checkout is gone |
| `ctrl+g` | Offer to merge the highlighted worktree into the default branch with [`wt merge`](https://worktrunk.dev/merge/): asks first and lists uncommitted changes (they're committed with the merge). Worktrunk squashes the branch's commits, rebases onto the target, fast-forwards it, runs the merge hooks, then removes the worktree and branch; the space is closed once the checkout is gone. Refuses the main checkout and a detached HEAD. On failure (conflict, failing `pre-merge` hook) the output's tail is shown and the worktree and space are kept; after a conflict the rebase is waiting in the worktree |
| `↑` / `↓`, `ctrl+k` / `ctrl+j` | Move (wraps) |
| `Esc` | Close (cancels a remove / merge confirmation first) |

- **Engine:** everything git-side is `~/bin/herdr-wt` (its Herdr-independent subcommands `managed`, `checkouts`, `branches`, `current`, `dirty`, `create`, `delete`, `default-branch`, `merge`; in `all` mode `dirty` / `delete` / `default-branch` / `merge` run in the worktree's main checkout, since they resolve against the repo of their cwd), which uses [Worktrunk](https://worktrunk.dev) — so new worktrees land in `~/.herdr/worktrees/<repo>/<branch>`, branch from a freshly fetched `origin/<default>`, and run the hooks in `~/.config/worktrunk/config.toml` (see `shared/.config/worktrunk/README.md`). The mod only does the space side (`space.select` / `space.new` / `space.close`).
- **Open space match:** like the shipped `worktree` mod, a local space whose first terminal is inside the checkout (and not inside a deeper one). The dot after the name is in that space's color.
- **Local only:** `herdr-wt` runs on this computer. Leader `w` lists this computer's worktrees from any space; `W`, `B` and `D` fall back to the shipped `worktree` mod on remote spaces.
- `herdr-wt` is called by absolute path and appends the usual tool dirs to `PATH` itself, so it works when the app was launched from Finder.

```sh
herdr-app check ~/.config/herdr-app/mods/wt-picker
herdr-app do mod.open --name wt-picker               # pick mode (props need the leader; to see `all`, default `mode` to it temporarily)
herdr-app shot /tmp/wt.png
herdr-app do overlay.close
```

## Keymap parity (TUI, app, Rex)

Goal: switch between the Herdr TUI (`shared/.config/herdr/config.toml`), the Herdr Mac app and Rex (`shared/.config/rex/`) without relearning keys. **Same action, same keys, wherever the tool allows it.** They can't be identical (the app has no native leader key, no plugins and a different popup mechanism; Rex has no agents list), so every difference is recorded on purpose.

The source of truth is [`shared/.config/keymap/keymap.toml`](../keymap/keymap.toml): one row per action, with each tool's action or the reason it has none. `keymap-check` (`shared/bin/`) reads each tool's live config and reports drift from it; see [`shared/.config/keymap/README.md`](../keymap/README.md). tmux is listed for reference and moves to this layout in a later change.

`prefix` is `ctrl+s` everywhere. In the app it is the `leader` mod, so `prefix+x` there means `ctrl+s` then `x`.

Where each side lives: TUI = `config.toml` (`[keys]`, `[[keys.command]]`; a "default" cell is herdr's own default, not written there). App = `keys.json` (single combos) and `ITEMS` in `mods/leader/main.js` (prefix keys). Rex = `keys.lua`, `popups.lua`, `actions.lua`.

### Bindings

Generated by `keymap-check --table --write shared/.config/herdr-app/README.md`; don't edit between the markers.

<!-- BEGIN keymap-check --table -->
<!-- Generated from shared/.config/keymap/keymap.toml by `keymap-check --table --write`. Don't edit by hand. -->

`prefix` is `ctrl+s` everywhere (in the app, the `leader` mod). `—` means the tool doesn't have it; the reason is in the gap tables below. "on `key`" means the tool binds it on a different key.

#### Navigation

| Action | Keys | Herdr TUI | Herdr app | Rex | tmux |
|---|---|---|---|---|---|
| Focus pane left/down/up/right | `alt+{h,j,k,l}` | `focus_pane_{left,down,up,right}` | `pane.go:{left,down,up,right}` | `pane.focus direction={left,down,up,right}` | `select-pane -{L,D,U,R}` |
| Focus pane (prefix) | `prefix+{h,j,k,l}` | `focus_pane_{left,down,up,right}` | `leader:Focus pane` | `pane.focus direction={left,down,up,right}` | — |
| Next / previous pane | `` alt+{`,shift+`} `` | `cycle_pane_{next,previous}` | — | `pane.focus_{next,previous}` | `select-pane -t :.{+,-}` |
| Select tab N | `alt+1..9` | `switch_tab` | `tab.select:1..9` | `client.tab.goto index=1..9` | `select-window -t :1..9` |
| Previous / next tab | `prefix+{[,]}` | `{previous,next}_tab` | `leader:{Previous,Next} tab` | `client.tab.{previous,next}` | on `alt+{[,]}`: `{previous,next}-window` |
| Previous / next space (Rex/tmux: session) | `alt+{[,]}` | `{previous,next}_workspace` | `space.{prev,next}` | `session.{previous,next}` | on `alt+shift+{[,]}`: `switch-client -{p,n}` |
| Select space N | `alt+shift+1..9` | `switch_workspace` | `space.select:1..9` | `goto_session index=1..9` | — |
| Previous / next agent | `alt+shift+{[,]}` | `{previous,next}_agent` | `agent.{prev,next}` | — | — |
| Focus agent N | `prefix+1..9` | `focus_agent` | `leader:Focus agent` | — | — |
| Go to… (spaces, agents) | `prefix+o` | `goto` | `leader:Go to…` | `session.switch` | `Sesh` |
| Activity view (programs and agents) | `prefix+a` | — | — | `pane.view_activity` | — |
| Toggle the sidebar's activity view | `prefix+shift+a` | — | — | `client.sidebar.activity.toggle` | — |

#### Panes

| Action | Keys | Herdr TUI | Herdr app | Rex | tmux |
|---|---|---|---|---|---|
| Split down / right | `prefix+{\,shift+\}` | `split_{horizontal,vertical}` | `leader:Split {down,right}` | `pane.split direction={down,right}` | `split-window -{v,h}` |
| Close pane | `prefix+x` | `close_pane` (default) | `leader:Close pane` | `pane.close` | `kill-pane` |
| Zoom pane | `alt+z` | `zoom` | `pane.zoom` | `pane.zoom` | `resize-pane -Z` |
| Zoom pane (prefix) | `prefix+z` | `zoom` | `leader:Zoom pane` | `pane.zoom` | — |
| Float the pane, or dock a floating one | `alt+f` | — | — | `pane.float` | — |
| Rename pane | `prefix+p` | `rename_pane` | — | `pane.rename` | — |
| Resize mode (h/j/k/l until Esc) | `prefix+r` | `resize_mode` (default) | — | `client.mode.enter name=resize` | on `prefix+z`: `switch-client -T resize` |
| Balance pane sizes | `prefix+=` | — | — | `pane.balance` | — |
| Swap pane left/down/up/right | `prefix+shift+{h,j,k,l}` | `swap_pane_{left,down,up,right}` (default) | — | — | on `alt+shift+{h,j,k,l}`: `swap-pane` |
| Copy mode | `prefix+v` | `copy_mode` | — | — | `copy-mode` |
| Edit scrollback in $EDITOR | `prefix+e` | `edit_scrollback` (default) | — | — | — |

#### Tabs and spaces

| Action | Keys | Herdr TUI | Herdr app | Rex | tmux |
|---|---|---|---|---|---|
| New tab | `prefix+n` | `new_tab` | `leader:New tab` | `client.tab.new` | `new-window` |
| Rename tab | `prefix+shift+t` | `rename_tab` (default) | `leader:Rename tab` | `client.tab.rename` | on `prefix+r`: `rename-window` |
| Close tab | `prefix+shift+x` | `close_tab` (default) | `leader:Close tab` | `client.tab.close` | `kill-window` |
| New space in ~/development (Rex/tmux: session) | `prefix+shift+n` | `shell:New space` | `leader:New space (~/development)` | `new_session_dev` | `tmux-new-session` |
| Project picker (pj) | `prefix+shift+o` | `plugin:pj.open-picker` | `leader:Project picker (pj)` | `popup_pj_picker` | on `prefix+shift+p`: `tv pj` |
| All worktrees, every repo | `prefix+w` | `popup:All worktrees` | `leader:All worktrees` | `popup_wt_all` | — |
| Worktree picker for this repo (find-or-create) | `prefix+shift+w` | `popup:Worktree picker (this repo)` | `leader:Worktree picker (this repo)` | `popup_wt_repo` | — |
| Branch picker (existing branch → worktree) | `prefix+shift+b` | `popup:Branch picker (worktree from branch)` | `leader:Branch picker (worktree from branch)` | `popup_wt_branch` | — |
| Remove the focused worktree | `prefix+shift+d` | `popup:Remove worktree` | `leader:Remove worktree` | `popup_wt_remove` | — |

#### Popups

| Action | Keys | Herdr TUI | Herdr app | Rex | tmux |
|---|---|---|---|---|---|
| Quick shell (closes after a successful command) | `prefix+c` | `popup:Quick shell` | `leader:Quick shell` | `popup_quick_shell` | `Quick Shell` |
| Mini shell (persists) | `prefix+shift+c` | `popup:Mini shell` | `leader:Mini shell (persists)` | `popup_mini_shell` | `Mini Shell` |
| $EDITOR | `prefix+shift+e` | `popup:Editor` | `leader:Editor` | `popup_editor` | `Editor` |
| Lazygit | `prefix+shift+g` | `popup:Lazygit` | `leader:Lazygit` | `popup_lazygit` | `Lazygit` |
| Yazi (tmux: in a window) | `prefix+shift+y` | `popup:Yazi file manager` | `leader:Yazi` | `popup_yazi` | `yazi` |
| Hide the open popup (persistent ones keep running) | `prefix+shift+-` | — | `leader:Hide popup (mini shell, Lazygit)` | `popup_hide` | — |

#### Other

| Action | Keys | Herdr TUI | Herdr app | Rex | tmux |
|---|---|---|---|---|---|
| Open the branch's PR in the browser | `prefix+g` | `plugin:gh-pr.open-pr` | `leader:Open PR in browser` | `open_pr` | — |
| Refresh PR status | `prefix+u` | `plugin:gh-pr.refresh` | — | — | — |
| Toggle sidebar | `prefix+b` | `toggle_sidebar` (default) | `leader:Toggle sidebar` | `client.sidebar.toggle` | — |
| Settings | `prefix+s` | `settings` (default) | `leader:Settings` | `client.settings` | — |
| Keybinds (Rex: command palette, which lists keys) | `prefix+shift+/` | `help` (default) | `leader:Keybinds` | `client.palette.toggle` | — |
| Reload config | `prefix+shift+r` | `reload_config` (default) | — | `client.config.reload` | `source-file` |
| Detach | `prefix+q` | `detach` (default) | — | — | on `prefix+d`: `detach-client` |

#### Gaps (Herdr TUI, Herdr app, Rex)

| Action | Keys | Tool | Why |
|---|---|---|---|
| Next / previous pane | `` alt+{`,shift+`} `` | Herdr app | no cycle-pane command, only directional pane.go |
| Previous / next agent | `alt+shift+{[,]}` | Rex | no agent cycling; the activity view (prefix+a) replaces it |
| Focus agent N | `prefix+1..9` | Rex | no numbered agent list; the activity view (prefix+a) replaces it |
| Activity view (programs and agents) | `prefix+a` | Herdr TUI | no activity view; goto (prefix+o) lists agents |
| Activity view (programs and agents) | `prefix+a` | Herdr app | no activity view; Go to… (prefix+o) lists agents |
| Toggle the sidebar's activity view | `prefix+shift+a` | Herdr TUI | the sidebar always lists agents |
| Toggle the sidebar's activity view | `prefix+shift+a` | Herdr app | the sidebar always lists agents |
| Float the pane, or dock a floating one | `alt+f` | Herdr TUI | no floating panes (herdr 0.9.5) |
| Float the pane, or dock a floating one | `alt+f` | Herdr app | no floating panes; terminal.peek only previews a terminal over the tab |
| Rename pane | `prefix+p` | Herdr app | no rename-pane command |
| Resize mode (h/j/k/l until Esc) | `prefix+r` | Herdr app | no pane resize command (layout.resize sizes layout nodes) |
| Balance pane sizes | `prefix+=` | Herdr TUI | no balance action |
| Balance pane sizes | `prefix+=` | Herdr app | no balance command |
| Swap pane left/down/up/right | `prefix+shift+{h,j,k,l}` | Herdr app | not on the leader; pane.swap is on cmd+alt+shift+arrows |
| Swap pane left/down/up/right | `prefix+shift+{h,j,k,l}` | Rex | not bound; pane.move.* moves rather than swaps |
| Copy mode | `prefix+v` | Herdr app | mouse selection and cmd+c |
| Copy mode | `prefix+v` | Rex | no copy mode; mouse selection, find with client.find.open |
| Edit scrollback in $EDITOR | `prefix+e` | Herdr app | no edit-scrollback command |
| Edit scrollback in $EDITOR | `prefix+e` | Rex | no edit-scrollback action |
| Hide the open popup (persistent ones keep running) | `prefix+shift+-` | Herdr TUI | no command hides or closes a popup |
| Refresh PR status | `prefix+u` | Herdr app | the gh-pr plugin labels TUI sidebar rows; no app equivalent |
| Refresh PR status | `prefix+u` | Rex | no PR status in the sidebar |
| Reload config | `prefix+shift+r` | Herdr app | hot-reloads on save |
| Detach | `prefix+q` | Herdr app | GUI app: closing the window detaches |
| Detach | `prefix+q` | Rex | GUI app: closing the window detaches |

#### tmux differences (phase 2)

| Action | Keys | Tool | Why |
|---|---|---|---|
| Focus pane (prefix) | `prefix+{h,j,k,l}` | tmux | prefix+h/j/k/l resize the pane (repeatable) |
| Previous / next tab | `prefix+{[,]}` | tmux | on `alt+{[,]}` |
| Previous / next space (Rex/tmux: session) | `alt+{[,]}` | tmux | on `alt+shift+{[,]}` |
| Select space N | `alt+shift+1..9` | tmux | tilish: alt+shift+1..9 moves the pane to window N |
| Previous / next agent | `alt+shift+{[,]}` | tmux | no agents; alt+shift+[ / ] is previous / next session |
| Focus agent N | `prefix+1..9` | tmux | prefix+1..9 selects pane N |
| Activity view (programs and agents) | `prefix+a` | tmux | no agents |
| Toggle the sidebar's activity view | `prefix+shift+a` | tmux | prefix+shift+a opens Claude in a split (phase 2: move it) |
| Zoom pane (prefix) | `prefix+z` | tmux | prefix+z enters the resize table (phase 2: move it to prefix+r) |
| Float the pane, or dock a floating one | `alt+f` | tmux | no floating panes |
| Rename pane | `prefix+p` | tmux | no pane names; prefix+p is display-panes |
| Resize mode (h/j/k/l until Esc) | `prefix+r` | tmux | on `prefix+z` |
| Balance pane sizes | `prefix+=` | tmux | not bound |
| Swap pane left/down/up/right | `prefix+shift+{h,j,k,l}` | tmux | on `alt+shift+{h,j,k,l}` |
| Edit scrollback in $EDITOR | `prefix+e` | tmux | not bound |
| Rename tab | `prefix+shift+t` | tmux | on `prefix+r` |
| Project picker (pj) | `prefix+shift+o` | tmux | on `prefix+shift+p` |
| All worktrees, every repo | `prefix+w` | tmux | prefix+w enters the workmux table |
| Worktree picker for this repo (find-or-create) | `prefix+shift+w` | tmux | workmux table instead (prefix+w a) |
| Branch picker (existing branch → worktree) | `prefix+shift+b` | tmux | not bound |
| Remove the focused worktree | `prefix+shift+d` | tmux | workmux table instead (prefix+w r); prefix+shift+d detaches |
| Hide the open popup (persistent ones keep running) | `prefix+shift+-` | tmux | not bound |
| Open the branch's PR in the browser | `prefix+g` | tmux | prefix+g opens lazygit in a window |
| Refresh PR status | `prefix+u` | tmux | prefix+u is tmux-fzf-url |
| Toggle sidebar | `prefix+b` | tmux | no sidebar; prefix+b toggles pane border status |
| Settings | `prefix+s` | tmux | prefix+s renames the session |
| Keybinds (Rex: command palette, which lists keys) | `prefix+shift+/` | tmux | not bound; prefix+/ opens scooter |
| Detach | `prefix+q` | tmux | on `prefix+d` |
<!-- END keymap-check --table -->

### Non-key differences

| Item | TUI | App | Why / status |
|------|-----|-----|--------------|
| Worktree picker on a remote space | works if `herdr-wt`, `wt` and `git` are on that box | leader `w` still lists this computer's worktrees; `W`/`B`/`D` fall back to the shipped `worktree` mod's dialogs (no hooks; `B` gets the same "open" dialog as `W`, which has no branch list) | `wt-picker` runs `herdr-wt` on this computer only |
| Worktree picker UI | fzf (type, then `ctrl-n` / `ctrl-d` / `ctrl-g`) | native list | Same keys and behavior; the TUI shows the dirty-files list and confirms in the terminal; a merge streams `wt merge`'s output live (the app shows its last lines on failure) |
| `cmd+` shortcuts, `ctrl+1..9` space select, `f2` rename | none | app defaults in `keys.json` | Native macOS app keymap; harmless extras, not in `keymap.toml` |
| `[ui]` sidebar rows/widths, `[session]`, `[terminal] new_cwd`, toasts | configured | n/a | Layouts own the sidebar, core keeps terminals alive, new tabs and splits already follow the focused terminal's folder |
| Popup size | per-command `width`/`height` | per-item `width`/`height` in `leader/main.js` | Kept close, not identical |

### Open items

None.

### Keeping them in sync

When you add, change or remove a keybinding or user-visible feature in **any** of the three:

1. Edit the row in `keymap.toml` first (or add one).
2. Make the same change in every tool that can do it, with the **same keys**. Where one can't, give it `{ absent = "reason" }`.
3. Never put a different action on a key another tool already uses for a row.
4. Run `keymap-check` until it says "no drift", then `keymap-check --table --write shared/.config/herdr-app/README.md`.
5. Commit the table, the configs and this README together. The repo-root `CLAUDE.md` and `shared/.config/herdr/AGENTS.md` point here.
