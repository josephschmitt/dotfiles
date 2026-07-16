# Agent Guidelines for Herdr Configuration

Configuration for [Herdr](https://herdr.dev/) — a terminal multiplexer with first-class coding agent support.

## Documentation

Consult these for config syntax, available keys, CLI commands, and API details:

- Configuration reference: https://herdr.dev/docs/configuration/
- Agent support and integrations: https://herdr.dev/docs/agents/
- Socket API: https://herdr.dev/docs/socket-api/
- Session state and persistence: https://herdr.dev/docs/session-state/
- Print authoritative defaults: `herdr --default-config`

## Config File

- **Source of truth**: `shared/.config/herdr/config.toml` in this dotfiles repo
- **Symlinked to**: `~/.config/herdr/config.toml` via GNU Stow
- **Always edit the repo copy**, never `~/.config/herdr/config.toml` directly — that's a symlink
- **Format**: TOML (2-space indent, lowercase-with-hyphens keys per repo convention)
- **Live reload**: `herdr server reload-config` applies most UI settings without restart

## Before Making Changes

1. **Read `config.toml`** to understand current bindings and avoid conflicts
2. **Check the docs** for syntax and available options — don't rely on memorized defaults, they change between herdr versions
3. **Run `herdr --default-config`** if you need the current defaults for comparison

## Keybinding Design Principles

This config customizes bindings heavily. The guiding principles:

- **Prefix is `ctrl+s`** (not the default `ctrl+b`) — frees `ctrl+b` for shell backward-char
- **Pane focus uses `alt+hjkl`** (no prefix needed) — matches tmux-tilish / vim-tmux-navigator muscle memory
- **Tab switching uses `alt+1..9`** (no prefix needed) — direct access like browser tabs
- **Agent/workspace navigation uses `alt+[/]` and `alt+shift+[/]`** — bracket pattern for sequential cycling
- **Splits use `prefix+\` and `prefix+|`** — matches tmux visual split conventions
- **Frequently-used actions skip the prefix** (`alt+z` for zoom, `` alt+` `` for pane cycling) — speed over consistency

When adding new bindings, follow these patterns: use `alt+<key>` for high-frequency actions, `prefix+<key>` for everything else. Document the binding's purpose with a TOML comment.

## Custom Command Bindings

The config includes `[[keys.command]]` entries for launching tools in temporary panes. When adding new ones, read `config.toml` for the existing commands and follow the same pattern.

## Plugins

Herdr plugins are installed per-machine into `~/.config/herdr/plugins/`, and herdr
tracks that live state in `~/.config/herdr/plugins.json`. That file is **not** checked
into this repo and never will be — it's herdr-generated state (absolute install paths,
resolved commit hashes, install timestamps), not portable config, and stow never
touches it (it's a real file, not a symlink into this repo).

**Source of truth**: `plugins.manifest.toml` in *this* directory (`shared/.config/herdr/`)
— a hand-maintained, declarative manifest of which plugins should be installed. Named
`plugins.manifest.toml` rather than `plugins.json` so stow can symlink it into
`~/.config/herdr/` without colliding with herdr's own generated `plugins.json` there
(and TOML, not JSON, since TOML supports real `#` comments — no fake `"//"` key hack).

`herdr-plugins` (lives in `shared/bin/`, symlinked to `~/bin/` and on `PATH`
— it's a command you run, not config) is the only supported way to change
plugin state. It drives herdr's plugin CLI *and* keeps the manifest in sync in
the same step, so the manifest never drifts from what's actually installed:

```sh
# Adding/changing a plugin — one command does both the herdr call and the manifest edit
herdr-plugins install <owner>/<repo>[/subdir] [--ref REF] [--description TEXT]
herdr-plugins link <path> [--description TEXT]

# Removing a plugin — likewise updates both
herdr-plugins uninstall <plugin_id>
herdr-plugins unlink <plugin_id>

# Reconciling herdr's installed plugins to match the manifest (e.g. on a new
# machine, or after a manual manifest edit) — the only subcommand that reads
# the manifest without writing to it. Runs automatically from shared's
# post-stow hook, so `stow shared ...` reconciles plugins too.
herdr-plugins sync            # install anything missing
herdr-plugins sync --dry-run  # preview without changing anything
herdr-plugins sync --update   # also refresh already-installed plugins
herdr-plugins sync --prune    # also remove installed plugins NOT in the manifest
```

`install`/`link` look up the actual `plugin_id` herdr assigned (never assume one) and
upsert it into the manifest, merging onto any existing entry rather than replacing it
wholesale — hand-added fields (like `gh-pr`'s `note` below) and a hand-written
`description` survive a re-run. `uninstall`/`unlink` remove the matching entry. Since
`install`/`link` run the real herdr command first and only touch the manifest on
success, a failed install/link never leaves a stale entry behind.

Never call `herdr plugin install`/`link`/`uninstall`/`unlink` directly for a plugin you
intend to keep — that changes herdr's live state without updating the manifest, which
is exactly the drift this script exists to prevent.

Manifest entry shapes (see `plugins.manifest.toml`):
```toml
[[plugins]]
plugin_id = "..."
install = "<owner>/<repo>[/subdir]"   # or `link = "<path, ~ allowed>"` instead
ref = "<optional>"
description = "<optional>"
```

Current plugins:

| Plugin ID | Purpose | Notes |
|-----------|---------|-------|
| `pj` | Fuzzy-find `pj` projects and open them as herdr workspaces (`prefix+shift+p`) | Installed from GitHub (`josephschmitt/pj-herdr`) |
| `gh-pr` | Labels the focused agent pane's sidebar row with its branch's GitHub PR status; powers `prefix+g` (open PR) and `prefix+u` (refresh) | Linked from a local clone at `~/development/herdr-plugin-gh-pr` — **your own fork** (`josephschmitt/herdr-plugin-gh-pr`, tracking `upstream: wyattjoh/herdr-plugin-gh-pr`). `herdr-plugins link` re-links whatever branch/worktree is currently checked out there; switch worktrees manually first if you want a specific patch set active. That repo is its own git checkout with its own history — nothing to vendor into dotfiles. |

When adding a new plugin:
1. `herdr-plugins install ...` or `herdr-plugins link ...` — this installs/links
   it via herdr *and* records it in `plugins.manifest.toml` in one step.
2. Add a row to the table above.
3. If it adds `[[keys.command]]` bindings, document those in `config.toml` per the
   usual pattern.

When removing a plugin:
1. `herdr-plugins uninstall <plugin_id>` or `herdr-plugins unlink <plugin_id>` —
   this removes it via herdr *and* deletes its `plugins.manifest.toml` entry in one step.
2. Delete its table row and any bindings that referenced it.
