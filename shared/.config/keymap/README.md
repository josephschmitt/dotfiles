Canonical keymap for the terminal multiplexers in this repo: [Herdr](https://herdr.dev/) (TUI and Mac app), [Rex](https://www.superlogical.com/rex/docs) and, later, tmux. `keymap.toml` holds one row per action, and `keymap-check` (`shared/bin/keymap-check`) checks each tool's live config against it.

Nothing is generated from this table. Each tool keeps its own config in its own format; the table records what they should agree on, and the checker reports where they don't.

## Scope

Covered: the bare `alt+` layer and the `ctrl+s` prefix layer, meaning navigation, panes, tabs and spaces, popups, plus a few others (sidebar, settings, PR).

Not covered:
- The macOS `cmd+` keymap and the app's `ctrl+1..9` / `f2` defaults.
- `[ui]`, `[session]` and other settings.
- Keys inside modes and pickers: Rex's resize mode (`h/j/k/l`, `=`), the worktree pickers' `ctrl-n` / `ctrl-d` / `ctrl-g`.
- Plugin extras outside those two layers.

## Where each tool lives

| Tool | Config | How the checker reads it |
|------|--------|--------------------------|
| Herdr TUI | `shared/.config/herdr/config.toml` | Parses `[keys]` and `[[keys.command]]`, then fills in herdr's own defaults from `herdr --default-config` (plus `copy_mode` and `swap_pane_*`, which that dump leaves out). A blanked native (`= ""`) counts as unbound. |
| Herdr app | `shared/.config/herdr-app/keys.json`, `mods/leader/main.js` | `keys.json`'s `global` section, and the `keys` and `label` of each entry in `ITEMS`. The `act` closures are code, so leader rows match on key and label. |
| Rex | `shared/.config/rex/keys.lua` (+ `popups.lua`, `actions.lua`) | `rex keymap --json`. This is the **server's loaded** config, so run `rex config reload` after editing. If `rex` isn't on `PATH`, the CLI inside `/Applications/Rex*.app` is used. Skipped with a warning when Rex isn't installed or its server isn't running. |
| tmux | `shared/.config/tmux/` | `tmux list-keys -T root` (alt keys only) and `-T prefix`, from the running server. Skipped when no server is running; it never starts one. **Report only**: tmux findings don't fail the run. |

## Schema

```toml
prefix = "ctrl+s"

[[binding]]
id = "zoom"                 # unique
category = "panes"          # navigation | panes | workspaces | popups | other
desc = "Zoom pane"          # shown in the table
key = "alt+z"               # canonical key
herdr = "zoom"
app = "pane.zoom"
rex = "pane.zoom"
tmux = "resize-pane -Z"
```

Every row names all four tools. Each one gets one of:

| Value | Means |
|-------|-------|
| `"action"` | Bound on the row's key |
| `{ action = "...", key = "..." }` | Bound on a different key (an exception, listed in the gap tables) |
| `{ action = "...", native-default = true }` | Herdr TUI only: herdr's own default, not written in `config.toml` |
| `{ absent = "reason" }` | Not bound, and why |

How actions are written:

| Tool | Form | Example |
|------|------|---------|
| `herdr` | Native action name. A `[[keys.command]]` is `plugin:<command>` for `plugin_action`, else `<type>:<description>` | `zoom`, `plugin:gh-pr.open-pr`, `popup:Lazygit` |
| `app` | `keys.json` command, or `leader:<label>` for an `ITEMS` entry | `pane.go:left`, `leader:Lazygit` |
| `rex` | Action name plus the args that matter; extra args on the binding are ignored | `pane.focus direction=left` |
| `tmux` | A substring of the bound command | `split-window -h` |

### Key notation

- Modifiers in the order `cmd`, `ctrl`, `alt`, `shift`. `prefix+` stands for the top-level `prefix`.
- A shifted character is written as `shift` plus its unshifted key: `|` is `shift+\`, `_` is `shift+-`, `?` is `shift+/`, `G` is `shift+g`, `~` is `` shift+` ``.
- `{a,b}` and `1..9` expand. A tool's action expands in step with the key (`key = "alt+{h,l}"`, `herdr = "focus_pane_{left,right}"`), or is shared by every expanded key when it doesn't expand (`app = "leader:Focus pane"`).
- Use TOML literal strings for backslashes: `key = 'prefix+{\,shift+\}'`.

The checker rejects a row whose key isn't in canonical form, whose expansions don't line up, or that is missing a tool.

## Adding or changing a binding

1. Edit the row in `keymap.toml` (or add one).
2. Change each tool's config to match, with the same key. Where a tool can't do it, give it `{ absent = "reason" }`. Never reuse a key another tool has for a row.
3. `herdr config check`, `rex config check`, `rex config reload`.
4. `keymap-check` until it prints "no drift".
5. `keymap-check --table --write shared/.config/herdr-app/README.md` to regenerate the parity table.
6. Commit the table, the configs and the READMEs together.

## Running the checker

```sh
keymap-check                     # all tools; exit 1 on drift
keymap-check -t rex -t herdr     # only these tools
keymap-check -v                  # also list matches, exceptions and every extra key
keymap-check --table             # the parity table as markdown
keymap-check --table --write shared/.config/herdr-app/README.md
```

Findings per tool:

| Finding | Means |
|---------|-------|
| missing | In the table, not bound in the config (names the file to add it to) |
| wrong | The key is bound to a different action (with `file:line`) |
| extra | Bound in the prefix or `alt+` layer, not in the table |
| conflict | One key bound to two actions |
| prefix | The tool's prefix isn't `prefix` |
| stale | The generated block in `herdr-app/README.md` differs from `--table` |

Exit codes: `0` no drift, `1` drift in Herdr TUI, Herdr app or Rex, `2` a broken `keymap.toml`.

Requirements: Python 3.11 or newer (for `tomllib`). It is pure standard library. On an older Python it exits with a clear message. Remote hosts without Rex or a tmux server just skip those tools.

## tmux (phase 2)

tmux still uses its older layout (`prefix+z` resize, `prefix+g` lazygit, `prefix+w` workmux, ...). Its rows record those differences now, so moving it to this layout can be driven by the checker's report. Once it is moved, make tmux findings fail the run (flip its `enforced` flag in the `TOOLS` table at the top of `keymap-check`).
