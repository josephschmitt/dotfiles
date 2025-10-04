# Agent Guidelines for Dotfiles Repository

## Repository Overview
This is a personal dotfiles repository managed with GNU Stow. No build system - use `stow .` to install configs.

## Environment Context
- Platform: macOS
- Shells: Fish (primary), Zsh (secondary), Bash (fallback)
- Editor: Neovim (LazyVim) + Helix as secondary
- Package Manager: GNU Stow
- No tests/linting - configuration files only

## Key Commands
- **Install**: `stow .` (from repo root)
- **Uninstall**: `stow -D .`
- **Restow**: `stow -R .`

## Code Style Guidelines

### Shell Configuration Philosophy

**CRITICAL**: This repository follows a strict shell configuration organization. Always maintain this structure:

#### File Purposes (DO NOT DEVIATE):
- **`.profile`** - POSIX environment setup (PATH, exports) for all shells
- **`.zshenv`** - Sources `.profile`, minimal Zsh environment
- **`.zshrc`** - Zsh interactive configuration (plugins, completions, prompt)
- **`.zprofile`** - Minimal macOS Terminal.app compatibility only
- **`.bash_profile`** - Sources `.profile` + `.bashrc` for Bash login shells
- **`.bashrc`** - Bash interactive configuration
- **`fish/config.fish`** - Self-contained Fish configuration (Fish doesn't follow POSIX)

#### Shared Configuration Modules:
- **`.config/shell/exports.sh`** - Environment variables for POSIX shells
- **`.config/shell/aliases.sh`** - Shared aliases (bash/zsh compatible)
- **`.config/shell/functions.sh`** - Shared functions (bash/zsh compatible)

#### Rules:
1. **NO DUPLICATION**: Environment variables, aliases, and functions should be defined once in shared modules
2. **PROPER SOURCING**: Each shell file should only source appropriate shared modules
3. **Shell-specific only**: Only put shell-specific features in shell-specific files
4. **macOS compatibility**: Handle Terminal.app's login shell behavior correctly
5. **POSIX compliance**: Shared modules must work across bash/zsh

#### When modifying shell configs:
- Environment variables → `.config/shell/exports.sh`
- Aliases → `.config/shell/aliases.sh` (or shell-specific if needed)
- Functions → `.config/shell/functions.sh` (or shell-specific if needed)
- Interactive features → appropriate shell's rc file
- Never duplicate configuration between shells

#### Multi-Shell Support Requirements:
**CRITICAL**: When making changes to shell environment configuration, you MUST ensure changes work across ALL supported shells:

**Currently Supported Shells:**
- Bash (fallback)
- Zsh (secondary)
- Fish (primary)

**Future Shells Under Consideration:**
- Nushell (may be added later)

**Required Actions:**
1. **POSIX shells (Bash/Zsh)**: Add to shared modules (`.config/shell/*.sh`)
2. **Fish**: Add equivalent configuration to `.config/fish/config.fish` or appropriate Fish-specific files
3. **Test across shells**: Verify changes work in Bash, Zsh, AND Fish before considering complete
4. **Future-proof**: Use approaches that can extend to Nushell if/when added
5. **Document shell-specific workarounds**: If a feature requires different implementations per shell, document why in comments

### Shell Scripts
- Use `#!/bin/sh` for POSIX compatibility
- Set `set -x` for debugging when needed
- Use `[[ ]]` for bash-specific tests
- Variables in `${var}` format for clarity

### Lua (Neovim configs)
- 2-space indentation (per stylua.toml)
- Column width: 120 characters  
- Use `-- stylua: ignore` to skip formatting specific lines
- Plugin configs return tables with dependency/opts structure
- Comment disabled code with early returns: `if true then return {} end`

### TOML/Config Files
- 2-space indentation for nested structures
- Use lowercase with hyphens for keys (`line-number`, `cursor-line`)
- Keep related settings grouped together

## File Organization
- Neovim plugins: `.config/nvim/lua/plugins/`
- Fish functions: `.config/fish/functions/`
- Shared shell config: `.config/shell/` (exports.sh, aliases.sh, functions.sh)
- Shell profiles: Root level (`.profile`, `.zshrc`, `.bashrc`, etc.)
- Utilities: `bin/` directory
- Theme files in respective app config dirs
- OpenCode agents: `.config/opencode/agents/` (NOT `agent/` - see below)

### CRITICAL: OpenCode Agents Directory Naming
**ALWAYS use `agents/` (plural), NEVER `agent/` (singular)** for the OpenCode agents directory.

**Why:**
- OpenCode auto-detects `agent/` directories for custom instructions
- GitHub Copilot also auto-detects `.github/copilot/agent/` directories
- Using `.config/opencode/agent/` causes conflicts between OpenCode and Copilot
- The `agents/` (plural) naming avoids this clash while maintaining clarity

**Correct structure:**
```
.config/opencode/
├── agents/          # ✅ Custom agent definitions
│   ├── architect.md
│   ├── implementer.md
│   └── ...
└── opencode.json    # References ./agents/ path
```

**Configuration in opencode.json:**
```json
{
  "agent": {
    "Agent Name": {
      "prompt": "{file:./agents/filename.md}"
    }
  }
}
```

### CRITICAL: .config Directory Handling
**NEVER symlink the entire `.config` directory!** Some subdirectories contain local-only data that should not be version controlled or shared across machines.

**Rules:**
- **Individual app configs only**: Symlink specific subdirectories like `.config/nvim/`, `.config/fish/`, `.config/tmux/`
- **Never `.config` root**: The `.config` directory itself must remain local to preserve machine-specific configurations
- **Local-only examples**: `.config/gh/`, `.config/1Password/`, `.config/BetterDisplay/`, etc.
- **When adding new configs**: Always add the specific subdirectory, never the parent `.config`

**Correct approach:**
```bash
# Good - specific app configs
stow --target=~/.config/nvim shared/.config/nvim
stow --target=~/.config/fish shared/.config/fish

# Bad - entire .config directory
stow --target=~/.config shared/.config  # DON'T DO THIS
```

## Documentation Maintenance

**CRITICAL**: When making consequential changes to configurations, always update relevant documentation:

### Root README (`/README.md`)
- Update if adding/removing major tools or changing repository structure
- Keep feature list current with actual configurations
- Update quick start instructions if setup process changes

### Setup Guide (`/shared/README.md`)
- Update "What's Included" section when adding/removing tools
- Add troubleshooting entries for new common issues
- Update installation steps if prerequisites change
- Keep tool descriptions accurate with actual configurations

### Nested Project READMEs
- Update any README files in subdirectories (e.g., `.config/*/README.md`)
- Ensure project-specific documentation reflects current configurations
- Update setup instructions for individual tools if changed

### When to Update Documentation
- Adding or removing major tools/configurations
- Changing installation or setup procedures
- Modifying directory structure
- Adding new troubleshooting scenarios
- Updating tool versions with breaking changes
- Changing theming or major customizations

### Documentation Standards
- Keep instructions clear and step-by-step
- Include troubleshooting for common issues
- Maintain consistent formatting and style
- Test instructions on fresh installations when possible
- Link between related documentation sections

## Git Workflow

**CRITICAL**: NEVER commit without explicit user approval. Always follow this process:

### Before ANY Commit:
1. **Stage changes**: Use `git add` to stage the intended files
2. **Show what will be committed**: 
   - Run `git status` to show staged files
   - Run `git diff --staged` to show the actual changes
3. **Present commit message**: Draft the complete commit message
4. **List all files being committed**: Clearly show which files are included
5. **WAIT FOR EXPLICIT APPROVAL**: Do not run `git commit` until user says "yes" or "approve"
6. **Only then commit**: After approval, run the commit command
7. **Push only when requested**: Don't push to remote unless specifically asked

### Commit Message Format:
Present the commit message in a code block so the user can review it exactly as it will appear.

### Example Workflow:
```
Files to be committed:
- .claude.md (modified)
- README.md (modified)

Proposed commit message:
```
Update agent instructions to require commit approval

- Add mandatory review process before any commits
- Require explicit user approval for all git operations
- Ensure user maintains full control over git history

🤖 Generated with [opencode](https://opencode.ai)

Co-Authored-By: opencode <noreply@opencode.ai>
```

Do you approve this commit? (yes/no)
```

**NEVER** run `git commit` without this approval process. This ensures the user maintains complete control over their git history and commit messages.