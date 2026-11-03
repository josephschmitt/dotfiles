Configuration for [Herdr app](https://herdr.dev/) — the desktop (GUI) successor to the `herdr` terminal multiplexer. Its whole interface is files in `~/.config/herdr-app`; `herdr-app --skill` and the generated `~/.config/herdr-app/AGENTS.md` are the reference.

## What's tracked

Only `keys.json`, `mods/leader/` and `mods/pj-picker/` are symlinked from this repo (via GNU Stow). The rest of `~/.config/herdr-app` is written by the app (`settings.json`, `view.json`, `layouts/`, `mods/`, ...) and stays local — `settings.json` holds zoom, which changes constantly. Don't `stow` the whole directory's contents blindly: if `keys.json` is deleted while the app runs, it rewrites it within a second, so remove and re-stow in a single command.

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
| `O` / `P` | Project picker (`pj`; focuses the project's existing space or creates one; see [pj project picker](#pj-project-picker-modspj-picker)) |
| `w` / `W` / `D` | Open / new / remove worktree (the app's `worktree` mod dialogs) |
| `1..9` | Focus agent N (agents list order) |
| `c` / `C` | Quick shell / mini shell (the latter persists; `hide` keeps it, reopen with `C`) |
| `E` / `G` / `Y` | `$EDITOR` / `lazygit-launch` / `yazi` popups |
| `g` | Open the branch's PR (`gh pr view --web`) |
| `b` / `s` / `?` | Toggle sidebar / settings / keybinds |

Popups are a hidden `hc` terminal (started in the focused pane's folder, or on its machine) shown in a modal overlay under a title bar drawn by the same mod; they close when the program exits, and `✕` kills it.

Gotchas:
- `ctrl+s` is no longer passed to programs (same as with the TUI prefix).
- A mod can't open overlays from async work after its own popup has closed, so async items (`late: true`) run first and the leader closes afterwards. Terminal popups call `closeLeader()` themselves *right before* `openOverlay` (same tick, so it still works): a popup opened under a still-open leader loses the keyboard to the pane beneath when the leader closes.
- The mod folder is a symlink into this repo, and the app writes `gpui-kit.d.ts` and `jsconfig.json` into it; `.gitignore` here hides them.
- `quick-shell.sh` still tries `herdr notification show` for its "press Ctrl-c again" hint, which talks to the TUI server, so it only appears if that is running.

### How the mod is set up

| Piece | Where | Role |
|-------|-------|------|
| `mods/leader/main.js` | this repo, stowed to `~/.config/herdr-app/mods/leader` | The whole mod: `ITEMS` key table, the which-key popup, the popup-terminal runner, and the title bar for those popups |
| `mods/leader/mod.json` | same | `{"place": "none", "overlay": {"kind": "popup", "at": "bottom", ...}}`: not docked anywhere, opens as a bottom popup via `mod.open` |
| `"ctrl-s": "mod.open:leader"` | `keys.json` (`global`) | Opens the popup. `mod.open` toggles, so `ctrl+s` again closes it |
| `.gitignore` | this directory | Hides `gpui-kit.d.ts` / `jsconfig.json`, which the app writes into every mod folder (visible here because the mod dir is a symlink) |

How it works:
- The popup takes keyboard focus (`handle.focus()`) and reads `on_key_down`. Only typed characters (`key_char`) count; bare modifiers/arrows are ignored, `Esc`/`ctrl+s`/`ctrl+c` close.
- Plain actions call `run("<command>", args)` — the same commands `keys.json` binds (`herdr-app commands`). They close the popup first so focus is back in the terminal.
- Popup programs (`late: true` items) run `hc run --bg --json --no-parent --no-notify [--rm] -- bash -lc <cmd>` in the focused pane's folder (or `--on <machine>`), then `openOverlay` a modal layout: a 30px title-bar block (this same mod, via `props.bar`) over a `{ terminal: "<addr>" }` block. The overlay closes itself when the program exits; `✕` runs `terminal.kill`. The persistent mini shell skips `--rm`, remembers its address in `shared("leader.Mini shell")` and says `hide` instead of `✕`.
- Popup items finish their async work (spawning the terminal) while the leader is alive, then close it and open the overlay back to back, then `pane.focus` the popup's terminal so it takes keystrokes.

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

Opened by leader `O` or `P` (`run("mod.open", { name: "pj-picker" })`; `O` pairs with `o` = Go to…, `P` is the older key). The TUI's `prefix+shift+o` (`tv herdr-worktree`) was never ported, so `O` was free. Type to filter (case-insensitive substring over name, path and marker).

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

### Not ported from the TUI config

| TUI binding | Why |
|-------------|-----|
| `alt+backtick` pane cycling | No cycle-pane command (only directional `pane.go`) |
| `prefix+p` rename pane | No rename-pane command |
| `prefix+shift+o` (`tv herdr-worktree`) | Uses the TUI's `herdr worktree` CLI; use leader `w`/`W` |
| `prefix+u` refresh PR status | The `gh-pr` plugin labels TUI sidebar rows; no app equivalent |
| `copy_mode`, `[ui]` sidebar rows/widths, `[session]`, `[terminal] new_cwd` | Not applicable — mouse selection, layouts own the sidebar, core keeps terminals alive, new tabs/splits already follow the focused terminal's folder |
