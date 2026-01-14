# Agent Guidelines for Dotfiles Repository

## Critical Context
- **Repository Type**: Personal dotfiles managed with GNU Stow
- **No Build System**: Configuration files only, no tests/linting
- **Platforms**: macOS (primary), Ubuntu Server (secondary)
- **Shells**: Fish (primary) → Zsh (secondary) → Bash (fallback)
- **Editors**: Neovim (dual setup: LazyVim + AstroNvim) + Helix (secondary)
- **Profiles**: `shared/` (all), `personal/` (macOS), `work/` (macOS), `ubuntu-server/` (Ubuntu)

### Stow Commands
```bash
stow .                        # Install all
stow shared personal          # Install specific profiles (macOS)
stow shared ubuntu-server     # Install specific profiles (Ubuntu)
stow -R .                     # Restow (re-link)
stow -D .                     # Uninstall
```

## Shell Configuration Architecture

### CRITICAL RULE: Zero Duplication
**Define once, source everywhere.** Changes must work across ALL shells: Bash, Zsh, Fish.

### Shell Configuration Map
| File | Purpose | Sources |
|------|---------|---------|
| `.profile` | POSIX environment (PATH, exports) | - |
| `.config/shell/exports.sh` | Shared environment variables | - |
| `.config/shell/aliases.sh` | Shared aliases (POSIX) | - |
| `.config/shell/functions.sh` | Shared functions (POSIX) | - |
| `.bash_profile` | Bash login shell | `.profile`, `.bashrc` |
| `.bashrc` | Bash interactive | `shell/{exports,aliases,functions}.sh` |
| `.zshenv` | Zsh environment | `.profile` |
| `.zshrc` | Zsh interactive | `shell/{exports,aliases,functions}.sh` |
| `fish/config.fish` | Fish (self-contained) | Fish-specific equivalents |

### Decision Tree for Configuration Changes
```
New configuration needed?
├─ Environment variable → `.config/shell/exports.sh` + Fish equivalent
├─ Alias/Function → Is it profile-specific?
│  ├─ YES → `{profile}/.config/shell/aliases.{profile}.sh` + Fish equivalent
│  └─ NO → `.config/shell/aliases.sh` + Fish equivalent
└─ Interactive feature → Shell-specific rc file only
```

### Multi-Shell Requirements (NON-NEGOTIABLE)
**Task incomplete until implemented in ALL shells: Bash, Zsh, Fish**

1. Add to POSIX shells: `.config/shell/*.sh`
2. Add Fish equivalent: `.config/fish/config.fish` or `functions/*.fish`
3. Test in all three shells
4. Document shell-specific workarounds if needed

### CI Performance Tracking
**When modifying shell startup:** Update `.github/workflows/shell-performance.yml`

**Startup dependencies** (auto-run on shell init): oh-my-posh, zoxide, fzf, basher, zinit
- Add new tools to CI "Install shell startup tools" step
- Remove from CI when lazy-loading or removing tools

## Code Style (Quick Reference)
| Language | Style |
|----------|-------|
| **Shell** | `#!/bin/sh`, `${var}` format, `[[ ]]` for bash tests |
| **Lua** | 2-space indent, 120 char width, return tables, `-- stylua: ignore` to skip format |
| **TOML** | 2-space indent, lowercase-with-hyphens keys |

## File Organization
```
.config/
├── nvim/lua/plugins/          # Neovim plugins
├── fish/functions/            # Fish functions
├── shell/                     # Shared POSIX configs (exports, aliases, functions)
└── opencode/agents/           # ⚠️ MUST be 'agents/' plural (not 'agent/' - conflicts with Copilot)

{profile}/.config/
├── shell/aliases.{profile}.sh # Profile-specific POSIX configs
└── fish/config.{profile}.fish # Profile-specific Fish configs

Root:
├── .profile, .zshrc, .bashrc  # Shell init files
└── bin/                       # Utilities

ubuntu-server/.config/nix/     # Nix configs and services
```

## Neovim Configuration (Dual Setup)

### Critical Context: Two Separate Neovim Configs
This repository maintains **two independent Neovim configurations** using `NVIM_APPNAME`:

| Config | Location | Based On | Default Alias |
|--------|----------|----------|---------------|
| **LazyVim** | `shared/.config/nvim/` | [LazyVim](https://www.lazyvim.org/) | `lazyvim`, `lvim` |
| **AstroNvim** | `shared/.config/astronvim/` | [AstroNvim v5+](https://astronvim.com/) | `vim`, `nvim`, `astrovim`, `avim` |

**Key Points**:
- Completely isolated (separate plugins, data, state, cache)
- Current default: `nvim` command launches **AstroNvim**
- Each has own README.md with configuration docs
- AstroNvim has additional AGENTS.md with AI assistant guidelines

### Decision Tree for Neovim Changes
```
User requests Neovim configuration change?
├─ User says "neovim" or "nvim" (ambiguous)
│  └─ ASK: "Which config? LazyVim (shared/.config/nvim/) or AstroNvim (shared/.config/astronvim/)?"
├─ User says "lazyvim"
│  └─ Modify shared/.config/nvim/
├─ User says "astrovim" or "astronvim"
│  └─ Modify shared/.config/astronvim/
└─ User asks for both
   └─ Modify both configurations (implement feature in each)
```

### MANDATORY: Ask for Clarification
**Always ask which config to modify unless explicitly specified:**
- ❌ "neovim", "nvim", "my editor" → ASK for clarification
- ✅ "lazyvim" → Modify `shared/.config/nvim/`
- ✅ "astrovim", "astronvim" → Modify `shared/.config/astronvim/`

### AstroNvim-Specific Guidelines
When modifying AstroNvim config (`shared/.config/astronvim/`):
1. **Read** `shared/.config/astronvim/AGENTS.md` first (contains AstroVim-specific workflows)
2. Follow "AstroVim way": Prefer AstroCommunity plugins over custom specs
3. Use AstroCore/AstroLSP/AstroUI override pattern (see existing plugins)
4. Update `shared/.config/astronvim/README.md` with new keybindings/features

### CRITICAL: .config Symlinking Rules
**NEVER `stow` entire `.config/` directory** - symlink individual app configs only

```bash
# ✅ CORRECT
stow --target=~/.config/nvim shared/.config/nvim

# ❌ WRONG - includes local-only configs (.config/gh/, .config/1Password/, etc.)
stow --target=~/.config shared/.config
```

## Documentation Updates (Required for Config Changes)

### Update Triggers (Config Change → Documentation Update)
| Change Type | Update These Files |
|-------------|-------------------|
| Config file modified | `.config/{tool}/README.md` (mandatory) |
| Major tool added/removed | `/README.md` + `/shared/README.md` |
| Keybinding changed | `.config/{tool}/README.md` keybindings section |
| Theme/appearance changed | `/README.md` features + tool README |
| Shell support added | `/README.md` + `AGENTS.md` |
| Neovim config modified | `.config/{nvim|astronvim}/README.md` + `/README.md` (if affects "Dual Neovim Setup") |

### Update Workflow (Atomic Commits)
1. Make config changes → Test changes
2. Update `.config/{tool}/README.md` (if applicable)
3. Update `/README.md` (if major change affects Features/Core Tools/Repository Structure sections)
4. Update `/shared/README.md` (if affects installation/troubleshooting)
5. Update `AGENTS.md` (if changes agent workflow)
6. **Commit all together** (config + documentation in single commit)

### Documentation Standards
- **Tool READMEs**: Link to project homepage in first line: `Configuration for [Tool Name](url) - description`
- **Keybindings**: Keep tables/lists current
- **Examples**: Include "why" behind non-obvious settings
- **Cross-reference**: Link related tools and integrations

## Git Workflow (MANDATORY APPROVAL REQUIRED)

### Agent Commit Policy
**Agents MUST NOT auto-commit changes.** After completing work:
- Stage files and show `git status` + `git diff --staged`
- **STOP and WAIT** for user approval before committing
- User will either commit manually or use `/commit` skill
- Only commit after explicit user approval or `/commit` command

### Pre-Commit Checklist (Complete Before Requesting Approval)
1. Stage files: `git add <files>`
2. Show changes: `git status` + `git diff --staged`
3. Draft commit message in code block
4. List all files being committed
5. **STOP → WAIT FOR APPROVAL** (do not run `git commit` without explicit "yes"/"approve")
6. After approval → commit
7. Push only when explicitly requested

### Approval Request Format
```
Files to be committed:
- .config/fish/config.fish (modified)
- .config/fish/README.md (modified)

Proposed commit message:
```
Add zoxide integration to Fish shell

- Configure zoxide for smart directory jumping
- Update Fish README with new keybindings

🤖 Generated with [opencode](https://opencode.ai)
Co-Authored-By: opencode <noreply@opencode.ai>
```

Approve? (yes/no)
```