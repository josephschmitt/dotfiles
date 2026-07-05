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
