# Claude Code Configuration

## Statusline

The statusline script (`statusline.sh`) customizes the Claude Code status display to show:

- **Model**: Current Claude model being used
- **Context %**: Real-time percentage of context window in use
  - 🟢 Green (0-50%): Safe usage
  - 🟡 Yellow (51-75%): Moderate usage - monitor context
  - 🔴 Red (76-100%): High usage - approaching auto-compaction
- **Directory**: Current working directory (relative to git root if in a repo)
- **Branch**: Current git branch (if in a git repository)

Example output: `🤖 Haiku 4.5 🧠 15% 📁 dotfiles 🌿 main`

This allows you to proactively manage context window usage and take action before auto-compaction occurs.

## Settings

The `settings.json` file contains Claude Code configuration:
- Environment variables for default models
- Statusline configuration pointing to `statusline.sh`
