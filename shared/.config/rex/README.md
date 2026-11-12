Configuration for [Rex](https://www.superlogical.com/rex/docs) — Superlogical's multiplexer for all work (beta). `~/.config/rex/init.lua` is Lua; the files here are symlinked into `~/.config/rex` by GNU Stow.

The key layout is the tmux/Herdr muscle memory: `alt+…` with no prefix, and `ctrl+s` as the prefix. The keys match the Herdr TUI and app: the shared rows are in [`shared/.config/keymap/keymap.toml`](../keymap/keymap.toml), and `keymap-check` reports drift (run `rex config reload` first, since it reads the loaded config).

## Files

| File | Does |
|------|------|
| `init.lua` | Loads the others (`require` resolves siblings). |
| `keys.lua` | Every `rex.bind`: the `alt+` layer, the `ctrl+s` prefix, the resize mode. |
| `actions.lua` | Lua actions: new session in `~/development`, session by number, open PR, `select_session` (used by scripts). |
| `popups.lua` | Floating popups: shells, editor, lazygit, yazi, the pj and worktree pickers. |
| `util.lua` | Shared helpers (focused pane's directory, active window). |
| `scripts/pj-picker.sh` | fzf project picker behind `prefix+O`. |

Helpers outside this folder:

| File | Does |
|------|------|
| `shared/bin/rex-open` | Find or create the session working in a directory, switch to it, or kill it. |
| `shared/bin/rex-wt` | Rex flavour of `herdr-wt`: the same subcommands, driving Rex sessions. Git/Worktrunk subcommands are delegated to `herdr-wt`. |
| `shared/.config/herdr/scripts/wt-picker.sh` | The worktree picker UI, shared with Herdr. The Rex popups run it with `WT_ENGINE=rex-wt`. |
| `shared/.config/herdr/scripts/quick-shell.sh` | Quick/mini shell. Shared with Herdr; prints the Ctrl-c hint in the terminal when `REX_SESSION` is set. |

## Setup

- **Reload** after editing: `ctrl+s>R`, or `rex config reload`. Rex doesn't watch the file. Check with `rex config check` (errors) and `rex keymap` (what every key does).
- **Option as Alt**: the `alt+` keys need Settings → Keyboard → Option key to send Alt. "Automatic (by keyboard layout)" does on US layouts.
- **Remote Control** (Settings → Server → Client Info) must be on for the pickers to *switch* to a session (`prefix+O`, the worktree pickers). A script can't do that without it, because the request doesn't come from a key press. Without it the session is still created, and the popup says so. Everything else works with it off.
- Stow: `install.sh` pre-creates `~/.config/rex` so stow links individual files, leaving anything Rex writes there out of the repo.

## Keys

Rex terminology: Herdr **space** = Rex **session**, Herdr tab = Rex tab (a session's window), pane = pane, Herdr **agent** = Rex **activity**.

### No prefix

| Key | Action |
|-----|--------|
| `alt+h/j/k/l` | Focus pane left/down/up/right (no wrap) |
| `` alt+` `` / `` alt+shift+` `` | Next / previous pane |
| `alt+z` | Zoom pane |
| `alt+f` | Float the pane, or dock a floating one back |
| `alt+1..9` | Go to tab N |
| `alt+shift+1..9` | Go to session N (in `session.list` order, which may differ from the sidebar's) |
| `alt+[` / `alt+]` | Previous / next session |

`alt+shift+[` / `]` (Herdr's previous/next agent) are unbound: Rex has no agent cycling. Use the activity view.

### Prefix: `ctrl+s`, then…

| Key | Action |
|-----|--------|
| `h j k l` | Focus pane |
| `\` / `\|` | Split down / right |
| `x` / `z` / `p` / `=` | Close / zoom / rename / balance pane |
| `n` / `[` / `]` | New / previous / next tab |
| `T` / `X` | Rename / close tab |
| `N` | New session in `~/development` |
| `o` | Switch session |
| `O` | Project picker (`pj`) |
| `w` | Worktrees, all repos |
| `W` | Worktree picker, this repo (type to find or create) |
| `B` | Branch picker (existing branch → worktree) |
| `D` | Remove the focused pane's worktree |
| `a` | Activity view (the picker of programs/agents) |
| `A` | Toggle the sidebar's activity view |
| `c` | Quick shell popup (closes after one successful command) |
| `C` | Mini shell popup (persists) |
| `E` | `$EDITOR` popup |
| `G` | Lazygit popup (persists) |
| `Y` | Yazi popup |
| `_` | Hide the open popup |
| `g` | Open the branch's PR in the browser |
| `b` / `s` | Toggle sidebar / settings |
| `?` | Command palette |
| `R` | Reload this config |
| `r` | **Resize mode** |

Rex shows its own which-key popup ("Show Keys") after `ctrl+s`, listing every binding from this config under the action titles in `actions.lua`/`popups.lua`; the sticky mode is the `Resize ›` entry. Escape cancels a half-typed prefix.

### Resize mode (`prefix+r`)

Sticky: it stays on until you leave it. `h j k l` or the arrows resize by 5%, with `shift` by 15%; `=` balances. `Esc`, `Enter`, `q` or `ctrl+c` leave. The mode is exclusive, so other keys do nothing instead of typing into the pane. Rex shows a `resize` pill with the mode's keys, and it stays open until you leave the mode.

## Popups

A popup is a floating terminal labelled `popup:<name>`, started in the focused pane's directory. Pressing its key again closes it. Persistent ones (mini shell, lazygit) keep running while hidden: `prefix+_` or their key again hides them (the block is detached from the layout), their key brings them back. The helper follows the scratch-shell pattern from the community config.

Popup commands run through the user's shell startup files (Rex's `command` option), so `lazygit-launch`, `yazi` and `$EDITOR` resolve as in a normal terminal.

## Worktrees and projects

Same flow as Herdr's: the worktree pickers are the shared `wt-picker.sh`, with Worktrunk making the checkouts and running the hooks (`shared/.config/worktrunk/config.toml`). Only the session side differs, and `rex-open` does it. A session counts as "in" a checkout when one of its terminals is in that folder or below it (a terminal's folder comes from the shell's OSC 7 reports). So opening a worktree focuses the session already working there instead of creating another, and removing or merging one kills its session after the checkout is gone.

## Known gaps

| Herdr | Rex |
|-------|-----|
| Copy mode (`prefix+v`) | Not carried over; Rex's own selection and copy (`pane.copy`, mouse) apply. |
| PR status in the sidebar, `prefix+u` | None (that was the `gh-pr` plugin). `prefix+g` still opens the PR. |
| Focus agent N (`prefix+1..9`), previous/next agent | Activity view instead (`prefix+a`). |
| Minimizing a floating pane | `pane.minimize_floating` is listed by Rex but did nothing on any key we tried (`ctrl+s>_`, `ctrl+s>m`, `alt+_`), and it isn't in the pane's context menu. Unbound until a Rex update. |

## Unverified

Written against Rex Beta 0.1.0 (1925). Checked from the CLI: the config loads cleanly, every binding resolves in `rex keymap`, the popups open/close/hide, `rex-open` and `rex-wt` find, create and close sessions. Confirmed in the app: the `ctrl+s` prefix and its which-key popup, which lists every binding below. Not checked, because they need keys pressed in the app: that each `alt+` combination arrives as written, that `pane.view_activity` does what the name suggests, and `client.tab.goto` after switching sessions (the community config reports it counting in another session).

## Troubleshooting

- A key does nothing: `rex keymap --json | jq '.bindings[] | select(.keys[0] == "alt+h")'` shows what the server resolved; the client's own "Change Shortcut…" settings outrank the config file.
- `rex` isn't on `PATH` outside a Rex terminal: use `$REX_BIN_DIR/rex` (`rex-open` falls back to it).
