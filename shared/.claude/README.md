# Claude Code Configuration

## Statusline

The statusline script is defined per-profile (e.g. `personal/.claude/statusline.sh`, `work/.claude/statusline.sh`) so each profile can customize what's displayed. Each profile's `settings.json` points to its own copy.

## Settings

The `settings.json` file contains Claude Code configuration:
- Environment variables for default models

## Skills

`~/.claude/skills` is a real directory, not a symlink. `install.sh` creates it before running stow, so stow links each tracked skill (`shared/.claude/skills/<name>`) on its own. Skills installed by Claude Code, plugins, or other tools stay in `~/.claude/skills` and don't show up in this repo. To track a skill, move it into `shared/.claude/skills/` (or a profile's `.claude/skills/`) and restow.
