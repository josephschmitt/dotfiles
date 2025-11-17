# TWM - Tmux Workspace Manager

Configuration for [TWM](https://github.com/vinnymeller/twm) - an intelligent tmux session manager that automatically creates project-specific workspaces based on directory contents.

## Features

- **Automatic workspace detection** - Identifies project types from directory contents
- **Custom layouts per project type** - Different tmux layouts for different workflows
- **Project discovery** - Automatically searches configured paths for projects
- **Smart filtering** - Excludes common directories like `node_modules`, `.git`, etc.
- **Layout inheritance** - Reuse and extend layouts across workspace types

## Workspace Definitions

TWM automatically detects project types and creates appropriate workspaces:

### Docker Projects
- **Detection**: `docker-compose.yaml` OR `docker-compose.yml` + `Dockerfile` + `.git`
- **Layout**: `nvim-project` (Neovim + horizontal/vertical splits)
- **Use case**: Docker-based applications and services

### Node Projects
- **Detection**: `package.json`, `pnpm-lock.yaml`, `package-lock.json`, OR `yarn.lock`
- **Layout**: `nvim-project` (Neovim + horizontal/vertical splits)
- **Use case**: JavaScript/TypeScript projects

### Other Projects
- **Detection**: `.git`, `flake.nix`, OR `.twm.yaml`
- **Layout**: `nvim` (Simple Neovim-only layout)
- **Use case**: General development projects, Git repos, Nix flakes

## Layouts

### `nvim` Layout
Simple single-pane layout with Neovim:
```
┌─────────────┐
│             │
│    nvim     │
│             │
└─────────────┘
```

### `nvim-project` Layout
Full project layout with Neovim + terminal splits:
```
┌─────────────┬──────┐
│             │      │
│    nvim     │ term │
│             │      │
│             ├──────┤
│             │ term │
└─────────────┴──────┘
```
- Main pane (left): Neovim with project root open
- Right top pane: Terminal (resized to 100 columns)
- Right bottom pane: Terminal (resized to 20 rows)
- Focus returns to Neovim pane

## Configuration

### Search Paths
```yaml
search_paths:
  - "~/development"
  - "~/dotfiles"
```
Directories where TWM looks for projects.

### Exclusions
```yaml
exclude_path_components:
  - .git
  - .direnv
  - node_modules
  - venv
  - target
```
Directory names to skip during project discovery.

## Usage

### Starting a Workspace

```bash
# Launch TWM to select a project
twm

# TWM will:
# 1. Search configured paths for projects
# 2. Detect project type based on files
# 3. Create tmux session with appropriate layout
# 4. Start Neovim and set up terminal panes
```

### Project-Specific Overrides

Create a `.twm.yaml` file in any project to override the default configuration:

```yaml
# .twm.yaml in project root
workspace_type: docker
layout: custom-layout
```

### Custom Layouts

Add custom layouts to `twm.yaml`:

```yaml
layouts:
  - name: my-layout
    commands:
      - tmux send-keys -t 1 'nvim .' C-m
      - tmux split-window -h
      - tmux send-keys -t 2 'npm run dev' C-m
```

**Note**: Avoid using the `inherits` directive for layouts - TWM may concatenate commands instead of executing them sequentially. Explicitly list all commands in each layout definition.

## Integration

### With Sesh
TWM-created sessions appear in sesh's session picker, allowing quick navigation between project workspaces.

### With tmux
TWM creates standard tmux sessions, so all tmux commands and keybindings work normally.

## Workflow Example

1. Press `prefix + o` to open sesh
2. Switch to config sessions mode (`Ctrl-g`)
3. Select a project - TWM creates the workspace automatically
4. Work in the pre-configured environment
5. Detach and return anytime - layout persists

## Related Tools

- **tmux** - Terminal multiplexer that TWM configures
- **sesh** - Session manager for navigating TWM workspaces
- **Neovim** - Editor launched in TWM layouts
- **fzf** - Used by TWM for project selection

## Installation

```bash
# Install TWM via cargo
cargo install twm

# Configuration is loaded from ~/.config/twm/twm.yaml
# This dotfiles repo provides the config automatically
```
