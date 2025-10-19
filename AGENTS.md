# Agent Guidelines for Dotfiles Repository

## Repository Overview
This is a personal dotfiles repository managed with GNU Stow. No build system - use `stow .` to install configs.

## Environment Context
- Platform: macOS (primary), Ubuntu Server (secondary)
- Shells: Fish (primary), Zsh (secondary), Bash (fallback)
- Editor: Neovim (LazyVim) + Helix as secondary
- Package Manager: GNU Stow
- Profiles: shared (all machines), personal (macOS personal), work (macOS work), ubuntu-server (Ubuntu servers)
- No tests/linting - configuration files only

## Key Commands
- **Install all**: `stow .` (from repo root)
- **Install profiles**: `stow shared personal` (macOS), `stow shared ubuntu-server` (Ubuntu)
- **Uninstall**: `stow -D .` or `stow -D shared personal`
- **Restow**: `stow -R .` or `stow -R shared personal`

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

#### Profile-Specific Configuration:
**CRITICAL**: Some configurations are specific to certain machine types or environments and should NOT be in shared configs.

**Profile-Specific Patterns:**
- **POSIX shells**: Use `aliases.{profile}.sh` and `functions.{profile}.sh` in `.config/shell/`
- **Fish shell**: Use `config.{profile}.fish` and `aliases.{profile}.fish` in `.config/fish/`
- **Auto-loading**: Shared configs automatically source profile-specific files using glob patterns

**Examples:**
- `ubuntu-server/.config/shell/aliases.ubuntu-server.sh` - Ubuntu server-specific aliases (nix_rebuild, nix_update)
- `ubuntu-server/.config/fish/config.ubuntu-server.fish` - Fish config for Ubuntu servers
- These are auto-sourced by shared shell configs when the profile is installed

**When to use profile-specific configs:**
- ✅ Platform-specific commands (nix on Ubuntu, darwin-rebuild on macOS)
- ✅ Environment-specific aliases (server management, work tools)
- ✅ Machine-specific paths or settings
- ❌ Universal tools that work the same everywhere

#### Multi-Shell Support Requirements:
**CRITICAL**: When making changes to shell environment configuration, you MUST ensure changes work across ALL supported shells:

**Currently Supported Shells:**
- Bash (fallback)
- Zsh (secondary)
- Fish (primary)

**Future Shells Under Consideration:**
- Nushell (may be added later)

**Required Actions:**
1. **POSIX shells (Bash/Zsh)**: Add to shared modules (`.config/shell/*.sh`) or profile-specific files
2. **Fish**: Add equivalent configuration to `.config/fish/config.fish` or appropriate Fish-specific files
3. **ALWAYS port across shells**: When adding ANY feature, function, alias, or export to one shell, you MUST add the equivalent to ALL other supported shells (Bash/Zsh/Fish). Do not consider a task complete until implemented in all shells.
4. **Test across shells**: Verify changes work in Bash, Zsh, AND Fish before considering complete
5. **Profile-specific considerations**: If adding to a profile (like ubuntu-server), ensure it works across all shells within that profile
6. **Future-proof**: Use approaches that can extend to Nushell if/when added
7. **Document shell-specific workarounds**: If a feature requires different implementations per shell, document why in comments

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
- Profile-specific shell config: `{profile}/.config/shell/aliases.{profile}.sh`, `{profile}/.config/fish/config.{profile}.fish`
- Shell profiles: Root level (`.profile`, `.zshrc`, `.bashrc`, etc.)
- Utilities: `bin/` directory
- Theme files in respective app config dirs
- Ubuntu server configs: `ubuntu-server/.config/nix/` (Nix configuration and system services)
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
**When to Update:**
- Adding/removing major tools or changing repository structure
- Adding/removing entire tool categories (terminal emulators, multiplexers, etc.)
- Changing theming systems (e.g., switching from Catppuccin to Tokyo Night)
- Modifying the quick start installation process
- Adding/removing shell support

**What to Verify After Changes:**
After making any significant configuration changes, verify the README sections remain accurate:

1. **Features section (lines 9-16)**: Ensure themes and core features match reality
2. **Core Tools section (lines 55-64)**: Verify shells, editors, terminals, and multiplexers are correctly listed
3. **Development Environment section (lines 66-71)**: Check languages and build tools are current
4. **Productivity Features section (lines 73-78)**: Confirm git workflow tools and features are accurate
5. **Repository Structure section (lines 80-93)**: Update if directory structure changes

**Examples of Changes Requiring README Updates:**
- ✅ Adding Zellij → Update "Multiplexer" in Core Tools section
- ✅ Switching from Catppuccin to Tokyo Night → Update Features section
- ✅ Adding Nushell support → Update "Multi-Shell Setup" in Core Tools
- ✅ Adding Wezterm config → Update "Terminal" in Core Tools (if it becomes primary/secondary)
- ❌ Tweaking individual plugin settings → No README update needed
- ❌ Adding a Fish function → No README update needed

### Setup Guide (`/shared/README.md`)
- Update "What's Included" section when adding/removing tools
- Add troubleshooting entries for new common issues
- Update installation steps if prerequisites change
- Keep tool descriptions accurate with actual configurations

### Tool-Specific READMEs (`.config/*/README.md`)
**CRITICAL**: When modifying any tool's configuration files, you MUST update its corresponding README to reflect the changes.

**Tools with README files:**
- `.config/fish/README.md` - Fish shell configuration
- `.config/ghostty/README.md` - Ghostty terminal emulator
- `.config/helix/README.md` - Helix editor
- `.config/eza/README.md` - Eza (ls replacement)
- `.config/leader-key/README.md` - Leader-key launcher
- `.config/oh-my-posh/README.md` - Oh-my-posh prompt
- `.config/sesh/README.md` - Sesh session manager
- `.config/twm/README.md` - TWM workspace manager
- `.config/zed/README.md` - Zed editor
- `.config/lazygit/README.md` - Lazygit git UI
- `.config/tmux/README.md` - Tmux multiplexer
- `.config/yazi/README.md` - Yazi file manager
- `.config/nvim/README.md` - Neovim editor (if exists)
- `.config/zellij/README.md` - Zellij multiplexer (if exists)

**When to Update Tool READMEs:**
- ✅ Adding/removing keybindings → Update "Keybindings" or "Key Bindings" section
- ✅ Changing configuration options → Update "Configuration" section with new values
- ✅ Adding/removing features → Update "Features" section
- ✅ Modifying integrations with other tools → Update "Integration" or "Related Tools" section
- ✅ Changing themes or appearance → Update "Theme" or "Appearance" section
- ✅ Adding new plugins or extensions → Update relevant sections
- ❌ Minor comment changes → No README update needed
- ❌ Whitespace/formatting only → No README update needed

**Update Process:**
1. Make the configuration change in the tool's config file(s)
2. Test the change to ensure it works as expected
3. Open the tool's README file (`.config/{tool}/README.md`)
4. Update the relevant section(s) to reflect the change
5. Ensure examples, keybindings, and descriptions are accurate
6. Commit both the config change and README update together

**Documentation Standards for Tool READMEs:**
- Keep keybinding tables or lists up to date
- Include examples for complex configurations
- Explain the "why" behind non-obvious settings
- Cross-reference related tools and integration points
- Use consistent formatting across all tool READMEs
- **Link to project homepage** - First line should be "Configuration for [Tool Name](https://project-url) - description"

### Documentation Update Process
When making significant changes:
1. **Make the configuration changes** first
2. **Test the changes** to ensure they work
3. **Update tool-specific README** - Update `.config/{tool}/README.md` for the tool being modified
4. **Review README.md** for accuracy - check all sections mentioned above (if it's a major change)
5. **Update AGENTS.md** if the change affects agent guidelines (new tools, workflow changes)
6. **Update shared/README.md** if setup/installation is affected
7. **Create a single commit** that includes config changes + all documentation updates

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