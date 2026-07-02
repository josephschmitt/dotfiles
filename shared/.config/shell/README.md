# Shell Configuration Organization

This directory contains shared shell configuration files that follow Unix best practices while accounting for macOS Terminal.app quirks.

## File Structure

```
shared/
├── .profile              # POSIX environment variables (sourced by all shells)
├── .profile.d/          # Profile-specific .profile extensions (*.sh)
├── .bashrc              # Bash interactive configuration
├── .bashrc.d/           # Profile-specific .bashrc extensions (*.sh)
├── .bash_profile        # Bash login shell (sources .profile + .bashrc)
├── .zshenv              # Zsh environment (sources .profile)
├── .zshrc               # Zsh interactive configuration
├── .zshrc.d/            # Profile-specific .zshrc extensions (*.sh)
├── .zprofile            # Zsh login shell (minimal, macOS Terminal.app compatibility)
├── .zprofile.d/         # Profile-specific .zprofile extensions (*.sh)
└── .config/
    ├── shell/
    │   ├── exports.sh   # Shared environment variables
    │   ├── aliases.sh   # Shared aliases
    │   └── functions.sh # Shared functions
    └── fish/
        └── config.fish  # Fish configuration (self-contained)
```

## File Purposes

### `.profile`
- **Purpose**: POSIX-compliant environment setup
- **When sourced**: Login shells (bash, zsh, sh)
- **Contents**: Environment variables, PATH, exports
- **Sources**: `~/.config/shell/exports.sh`

### `.zshenv`
- **Purpose**: Zsh environment setup for all zsh invocations
- **When sourced**: Every zsh session (login, non-login, interactive, non-interactive)
- **Contents**: Sources `.profile`
- **Keep minimal**: Only essential environment variables

### `.zshrc`
- **Purpose**: Zsh interactive shell configuration
- **When sourced**: Interactive zsh sessions
- **Contents**: Plugins, completions, keybindings, prompt, aliases

### `.zprofile`
- **Purpose**: Zsh login shell setup
- **When sourced**: Zsh login shells (macOS Terminal.app always uses login shells)
- **Contents**: Minimal - macOS-specific integrations only

### `.bash_profile`
- **Purpose**: Bash login shell setup
- **When sourced**: Bash login shells
- **Contents**: Sources `.profile` and `.bashrc`

### `.bashrc`
- **Purpose**: Bash interactive shell configuration
- **When sourced**: Interactive bash sessions (via `.bash_profile`)
- **Contents**: Bash-specific interactive configuration

### `fish/config.fish`
- **Purpose**: Fish shell configuration
- **When sourced**: Fish shell sessions
- **Contents**: Self-contained Fish configuration (Fish doesn't follow POSIX conventions)

## macOS Considerations

- **Terminal.app**: Always runs shells as login shells, so `.zprofile` and `.bash_profile` are always sourced
- **iTerm2/other terminals**: May run non-login shells, so `.zshrc` and `.bashrc` handle interactive configuration
- **OrbStack integration**: Handled in appropriate shell-specific files

## Shared Configuration

### `exports.sh`
- Environment variables that work across all POSIX shells
- PATH configuration
- Tool-specific environment variables

### `aliases.sh`
- Aliases that work across bash and zsh
- Git workflow shortcuts
- System management aliases

### `functions.sh`
- Shell functions that work across bash and zsh
- Custom utilities

## Profile-Specific Overrides (`.d/` directories)

Each root shell init file has a companion `.d/` directory that sources `*.sh` files via glob. Profiles add their extensions as files in those directories — Stow merges the directories without conflict, since each profile contributes its own uniquely-named file.

| Init File | Override Directory | Example |
|-----------|-------------------|---------|
| `.profile` | `.profile.d/` | `work/.profile.d/work.sh` |
| `.bashrc` | `.bashrc.d/` | `rca/.bashrc.d/rca.sh` |
| `.zshrc` | `.zshrc.d/` | `work/.zshrc.d/work.sh` |
| `.zprofile` | `.zprofile.d/` | `personal/.zprofile.d/personal.sh` |

The `shared/` profile establishes each `.d/` directory (with a `.gitkeep`). The globs are no-ops when no `*.sh` files are present.

This complements the existing `.config/shell/` pattern (`aliases.*.sh`, `exports.*.sh`, `functions.*.sh`) for cases where profile-specific logic needs to live in the root init files rather than the shared shell config directory.

## inshellisense (IDE-style autocomplete)

[inshellisense](https://github.com/microsoft/inshellisense) provides fig-like,
IDE-style inline command autocompletion for all three shells. It works by
auto-starting a session that *wraps* the interactive shell, so the integration
has a few non-obvious requirements that are baked into this repo:

- **Must be the last command.** The source line is appended to the very end of
  `.bashrc`, `.zshrc`, and `fish/config.fish` (after the profile `.d/` and
  `config.*.fish` loops). inshellisense recurses into a child shell guarded by
  the `ISTERM` env var, so anything after it in the rc file would not run in the
  outer shell. If you add new startup logic, keep it *above* this block.
- **Skipped in IDE/editor terminals.** The block is gated behind
  `is_integrated_terminal`, mirroring `auto_start_tmux`, so it stays out of
  VS Code / Neovim / Emacs / Zed terminals where a nested PTY is unwanted.
- **No-op until provisioned.** Each shell sources
  `~/.inshellisense/init/<shell>/init.<ext>` only if that file exists. The file
  is created by `is init` (see below), so shells on un-provisioned machines and
  the non-interactive CI startup-time harness are unaffected.

### Installing / enabling

The `is` binary is declared for macOS in
`shared/.config/nix-darwin/darwin.nix` (`environment.systemPackages`). On
Ubuntu / remote sandboxes install it via npm:

```sh
npm install -g @microsoft/inshellisense
```

Then generate the per-shell init files once (regenerate after upgrades):

```sh
is init                 # detects the current shell, or pass bash|zsh|fish
```

`is init` writes `~/.inshellisense/init/<shell>/init.<ext>`, which the rc files
already source. No changes to the rc files themselves are needed — do **not**
run `is init <shell> >> ~/.<shell>rc` (the upstream instructions), as that would
duplicate the source line this repo already manages. Run `is doctor` to verify.

## Benefits

1. **No duplication**: Shared configuration is centralized
2. **Shell-specific optimizations**: Each shell can have its own optimizations
3. **POSIX compliance**: Core configuration works across shells
4. **macOS compatibility**: Handles Terminal.app's login shell behavior
5. **Maintainable**: Clear separation of concerns