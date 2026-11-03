Configuration for [Herdr app](https://herdr.dev/) — the desktop (GUI) successor to the `herdr` terminal multiplexer. Its whole interface is files in `~/.config/herdr-app`; `herdr-app --skill` and the generated `~/.config/herdr-app/AGENTS.md` are the reference.

## What's tracked

Only `keys.json` and `mods/leader/` are symlinked from this repo (via GNU Stow). The rest of `~/.config/herdr-app` is written by the app (`settings.json`, `view.json`, `layouts/`, `mods/`, ...) and stays local — `settings.json` holds zoom, which changes constantly. Don't `stow` the whole directory's contents blindly: if `keys.json` is deleted while the app runs, it rewrites it within a second, so remove and re-stow in a single command.

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
| `P` | Project picker (`pj` + `fzf` in a popup, then `herdr-app do space.new`) |
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

### Not ported from the TUI config

| TUI binding | Why |
|-------------|-----|
| `alt+backtick` pane cycling | No cycle-pane command (only directional `pane.go`) |
| `prefix+p` rename pane | No rename-pane command |
| `prefix+shift+o` (`tv herdr-worktree`) | Uses the TUI's `herdr worktree` CLI; use leader `w`/`W` |
| `prefix+u` refresh PR status | The `gh-pr` plugin labels TUI sidebar rows; no app equivalent |
| `copy_mode`, `[ui]` sidebar rows/widths, `[session]`, `[terminal] new_cwd` | Not applicable — mouse selection, layouts own the sidebar, core keeps terminals alive, new tabs/splits already follow the focused terminal's folder |
