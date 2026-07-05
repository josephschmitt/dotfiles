# Tmux is My IDE

## How I realized my text editor is just one piece of a larger system

A few months ago, I wrote about [the tools that make my terminal work](https://joe.sh/terminal-tools). That post covered the utilities I use day-to-day: Neovim, LazyGit, Zoxide, FZF, and a handful of others that make working in the terminal feel cohesive and fast.

But there was something I didn't fully articulate in that piece, something that only became clear to me after I'd been using this setup for a while longer:

**I didn't replace VS Code with Neovim. I replaced it with Tmux.**

Neovim is just my text editor. It's one component in a larger system. The thing that actually manages my projects, integrates my tools, and orchestrates my entire workflow—that's Tmux.

This realization changed how I think about my development environment entirely.

## What an IDE Actually Is

An Integrated Development Environment isn't just a text editor. It's a coordinated system that brings together multiple tools into a single, cohesive interface. When you think about it, an IDE typically provides:

- **Project management** – Quick switching between projects and workspaces
- **File navigation** – Fuzzy finding, tree views, recent files
- **Code search** – Full-text search with previews and filters
- **Version control integration** – Visual diffs, staging, commit history
- **Terminal integration** – Embedded shells and command runners
- **Layout management** – Splits, tabs, and persistent window arrangements
- **Extension ecosystem** – Plugins and integrations for language-specific tools

When I first switched to terminal-based development, I thought I was just swapping text editors. But what I actually built was something that handles all of these IDE features—just using different components.

## The Tmux IDE: Architecture

Here's how my Tmux-based IDE is structured:

```
┌─────────────────────────────────────────────────────────────────┐
│  Tmux (IDE Framework)                                           │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│  │ Session Manager  │  │ Popup System     │  │ Smart Layouts│  │
│  │ (Sesh + TWM)     │  │ (Standardized)   │  │ (Adaptive)   │  │
│  └──────────────────┘  └──────────────────┘  └──────────────┘  │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Main Workspace (Panes + Windows)                        │   │
│  │                                                          │   │
│  │  ┌───────────────────┬────────────┐                     │   │
│  │  │                   │            │                     │   │
│  │  │   Neovim          │  OpenCode  │                     │   │
│  │  │   (Editor)        │  (AI)      │                     │   │
│  │  │                   │            │                     │   │
│  │  │                   ├────────────┤                     │   │
│  │  │                   │            │                     │   │
│  │  │                   │  Shell     │                     │   │
│  │  └───────────────────┴────────────┘                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Integrated Tools (Popups + RPC)                          │  │
│  │                                                           │  │
│  │  • LazyGit (Ctrl-s G)    • Yazi (Ctrl-s Z)              │  │
│  │  • Television (Ctrl-s g/f/d/o) • Quick Shell (Ctrl-s c) │  │
│  │  • SSH Manager (Ctrl-s @)                                │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

Everything lives inside Tmux. The editor is just one pane. The real power comes from how everything is integrated and orchestrated.

## How Tmux Provides IDE Features

Here's how my setup maps typical IDE features to terminal-based tools:

| IDE Feature | My Setup |
|-------------|----------|
| **Project Switcher** | `Ctrl-s o` → Television (Sesh) |
| **Branch Workspace** | `workmux add <branch>` |
| **File Explorer** | `Ctrl-s Z` → Yazi popup |
| **Fuzzy File Search** | `Ctrl-s f` → Television (files) |
| **Full-Text Search** | `Ctrl-s g` → Television (ripgrep) |
| **Git Panel** | `Ctrl-s G` → LazyGit popup |
| **Integrated Terminal** | Tmux panes (native) |
| **Split Editor** | `Ctrl-s V/S` → Adaptive layouts |
| **Quick Command** | `Ctrl-s c` → Quick shell |
| **Remote SSH** | `Ctrl-s @` → SSH manager |
| **Directory Jumper** | `Ctrl-s d` → Television (dirs) |

The key insight is that these aren't tied to Neovim at all. They're all Tmux integrations that happen to work alongside Neovim.

## The Popup System: A Universal Command Palette

One of the most powerful parts of my setup is the **standardized popup system**. It's essentially a command palette for my entire development environment, built from composable scripts.

### How It Works

Every popup in my setup uses a centralized `tmux-popup` script that provides standardized sizing:

```bash
# ~/.config/tmux/tmux-popup

Preset Sizes:
├─ xsmall  → 60% width, 15 lines (quick commands)
├─ small   → 80% width, 70% height (pickers/menus)
├─ medium  → 90% width, 90% height (max 250 cols × 100 lines)
├─ large   → 90% width, 90% height (full apps)
└─ full    → 100% width, 100% height (maximum space)
```

This means every tool that uses a popup behaves consistently. The size adapts to my terminal, and the experience is uniform whether I'm opening LazyGit, Yazi, or a fuzzy finder.

### Visual: Popup in Action

```
┌─────────────────────────────────────────────────────────────┐
│ Main Tmux Window (Your workspace)                          │
│                                                              │
│   ┌─────────────────┬──────┐                                │
│   │                 │      │                                │
│   │    Neovim       │ Pane │                                │
│   │                 │      │                                │
│   │      ┌─────────────────────────────────┐                │
│   │      │ ╔═══════════════════════════╗   │                │
│   │      │ ║   LazyGit Popup           ║   │                │
│   │      │ ║                           ║   │                │
│   │      │ ║  • Staged Changes         ║   │                │
│   │      │ ║  • Unstaged Changes       ║   │                │
│   │      │ ║  • Recent Commits         ║   │                │
│   │      │ ║                           ║   │                │
│   └──────┤ ║  [Press 'e' to edit]      ║   │                │
│          │ ╚═══════════════════════════╝   │                │
│          └─────────────────────────────────┘                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

When you press a keybinding like `Ctrl-s G`, a popup appears *over* your current workspace. You interact with the tool (LazyGit, in this case), and when you're done, it disappears and you're right back where you were.

No context switching. No new windows. Just a clean overlay that handles one task and gets out of the way.

## The Magic: Popup-Aware Editing

This is where things get interesting.

One of the biggest pain points with popups is what happens when you select a file. In a naive implementation, the file would open *inside the popup*, which is clunky and breaks the flow. You'd have to close the editor, close the popup, and then open the file in your main editor.

That's terrible UX.

Instead, I built a **popup-aware editor** system that automatically opens files in an existing Neovim pane via RPC.

### How It Works

```
┌──────────────────────────────────────────────────────────────┐
│ 1. Launch popup (e.g., Yazi file browser)                   │
│    Environment: TMUX_IN_POPUP=1                             │
└──────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│ 2. Select a file to edit                                     │
│    Yazi calls: popup-aware-editor /path/to/file.js           │
└──────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│ 3. popup-aware-editor detects:                              │
│    • Running in tmux popup? ✓                                │
│    • Neovim with RPC in current window? ✓                   │
│    • Socket: /var/folders/.../nvim.12345.sock               │
└──────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│ 4. Send RPC command to Neovim:                              │
│    nvim --server <socket> --remote-send ":e file.js<CR>"    │
└──────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│ 5. File opens in Neovim pane                                │
│    • Focus switches to Neovim                                │
│    • Popup automatically closes                              │
└──────────────────────────────────────────────────────────────┘
```

This works in:
- **Yazi** – Select a file in the file browser
- **LazyGit** – Press `e` to edit a changed file
- **Ripgrep** – Select a search result
- **Any custom popup** that uses `popup-aware-editor` as `$EDITOR`

The experience is seamless. You open a tool, find what you need, and the file just *appears* in your editor. No intermediate steps, no friction.

### The Technical Implementation

The system relies on three components:

1. **Neovim RPC Server** – Automatically started on launch:
   ```lua
   -- ~/.config/nvim/lua/config/options.lua
   local socket_file = vim.fn.stdpath("run") .. "/nvim." .. vim.fn.getpid() .. ".sock"
   vim.fn.serverstart(socket_file)
   ```

2. **popup-aware-editor Script** – Detects popup context and finds Neovim socket:
   ```bash
   # ~/.local/bin/popup-aware-editor
   if [ -n "$TMUX_IN_POPUP" ] && [ -n "$TMUX" ]; then
     # Find nvim socket in current tmux window
     # Send file-open command via RPC
     # Focus nvim pane and close popup
   fi
   ```

3. **TMUX_IN_POPUP Environment Variable** – Set by `tmux-popup` script:
   ```bash
   tmux display-popup -e "TMUX_IN_POPUP=1" ...
   ```

This is the kind of integration that makes the setup feel like a real IDE rather than a collection of separate tools.

## Project Management: Sesh + TWM + Workmux

The **session management** layer is what makes Tmux work as a project-centric IDE.

In VS Code, you open a project folder, and the IDE configures itself around that workspace. In Tmux, each **session** represents a project, and I have two tools that manage them:

### Sesh: The Session Switcher

**Sesh** is my primary way of moving between projects. It integrates with:
- Existing Tmux sessions
- Tmux windows in the current session
- Zoxide directories (frequently visited paths)
- Config-based sessions

Press `Ctrl-s o`, and I get a unified picker:

```
⚡ All Sessions

  dotfiles            󰥻  tmux session
  my-app              󰥻  tmux session
  ~/development/blog  📁  zoxide directory
  infra               📁  zoxide directory
  notes               🪟  tmux window
```

Select any entry, and Sesh either:
- Switches to the existing session
- Creates a new session in that directory
- Jumps to the window

It's the closest thing to VS Code's "Open Recent" workflow.

### TWM: The Workspace Generator

**TWM (Tmux Workspace Manager)** takes this a step further by automatically creating project-specific layouts.

It scans directories I've configured and detects project types:

```yaml
# ~/.config/twm/twm.yaml

workspace_definitions:
  - name: node
    has_any_file:
      - package.json
      - pnpm-lock.yaml
    default_layout: nvim
    
  - name: docker
    has_all_files:
      - docker-compose.yaml
      - Dockerfile
    default_layout: nvim
```

When I launch TWM with `Ctrl-s t`, it shows me a picker of detected projects. Select one, and it automatically:
1. Creates a Tmux session named after the project
2. Applies the appropriate layout (Neovim + terminal splits)
3. Changes to the project directory
4. Starts Neovim in the main pane

It's like having project templates in an IDE, except they're defined once and work everywhere.

### Workmux: Git Worktrees Meet Tmux

Recently, I've added **[Workmux](https://github.com/raine/workmux)** to this workflow, and it's a game-changer for managing parallel work within the same project.

The core idea: **git worktrees + tmux windows = isolated development environments**.

#### The Problem Workmux Solves

In a typical Git workflow, you can only have one branch checked out at a time. If you want to work on multiple features simultaneously, you either:
1. Constantly `git stash` and switch branches (slow, error-prone)
2. Clone the repo multiple times (wasteful, hard to manage)
3. Use **git worktrees** manually (powerful but tedious)

Workmux automates option 3 and pairs each worktree with a tmux window.

#### What Are Git Worktrees?

Git worktrees let you check out multiple branches from the same repository into different directories simultaneously:

```
~/projects/
├── my-app/                    # Main repository (main branch)
│   ├── src/
│   └── package.json
│
└── my-app__worktrees/         # Worktrees directory
    ├── feature-auth/          # Feature branch in isolated directory
    │   ├── src/
    │   └── package.json
    │
    └── bugfix-api/            # Another branch, completely isolated
        ├── src/
        └── package.json
```

Each directory is a full working copy, but they all share the same Git database. No repo duplication.

#### The Workmux Workflow

My `.workmux.yaml` config defines the environment setup:

```yaml
window_prefix: wm-

panes:
  - command: nvim .
    focus: true
  - command: <agent>      # OpenCode/Claude
    split: horizontal
  - split: vertical
    size: 15

files:
  symlink:
    - node_modules

agent: claude
```

**Creating a worktree:**

```bash
# Create feature branch worktree with full tmux layout
workmux add feature-auth

# This automatically:
# 1. Creates git worktree at ../my-app__worktrees/feature-auth
# 2. Creates tmux window named "wm-feature-auth"
# 3. Sets up 3-pane layout (Neovim + AI agent + shell)
# 4. Symlinks node_modules from main repo
# 5. Switches you to the new window
```

**The result:**

```
Tmux Session: my-app
├─ Window 1: main (your main branch)
├─ Window 2: wm-feature-auth
│   ├─ Pane 1: Neovim (editing feature-auth code)
│   ├─ Pane 2: Claude/OpenCode (AI assistant)
│   └─ Pane 3: Shell (15-line height)
└─ Window 3: wm-bugfix-api
    └─ (same layout for bugfix work)
```

Each worktree is completely isolated:
- Different code checked out
- Different git state
- Different tmux window
- Can run different dev servers simultaneously

**Merging and cleanup:**

```bash
# When done, merge into main and clean everything up
workmux merge feature-auth

# This automatically:
# 1. Switches to main branch
# 2. Merges feature-auth
# 3. Deletes the tmux window (even if you're in it!)
# 4. Removes the worktree directory
# 5. Deletes the local branch
```

One command. Everything cleaned up.

#### Why This Is Powerful

1. **Parallel AI Workflows** – Run multiple AI agents on different features simultaneously without conflicts
2. **Context Preservation** – Switch between tasks without losing work-in-progress state
3. **Zero Friction** – Creating and destroying environments is instant
4. **IDE-Like Experience** – Each worktree gets a full, configured environment automatically

This is especially useful when working with AI coding assistants. I can have:
- One worktree where Claude is refactoring the auth system
- Another where OpenCode is adding a new API endpoint
- A third where I'm manually fixing a bug

All running in parallel, all isolated, all managed through tmux windows.

Workmux takes TWM's "project templates" concept and applies it to **branch-level workflows** within a single project. It's the final piece that makes tmux feel like a true multi-workspace IDE.

### Visual: Session Management Flow

```
┌─────────────────────────────────────────────────────────────┐
│ Current Session: "dotfiles"                                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   Press Ctrl-s o → Sesh Picker Opens                        │
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  Search: my-a█                                      │   │
│   ├─────────────────────────────────────────────────────┤   │
│   │  ⚡ my-app        (tmux session)                     │   │
│   │  📁 my-api        (zoxide directory)                │   │
│   │  📁 my-infra      (zoxide directory)                │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
│   Select "my-app" → Switch to existing session              │
│                 OR                                           │
│   Select "my-api" → Create new session in that directory    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ New Session: "my-api"                                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   Layout automatically applied:                             │
│                                                              │
│   ┌───────────────────┬────────────┐                        │
│   │                   │            │                        │
│   │   Neovim          │  Terminal  │                        │
│   │   (auto-started)  │            │                        │
│   │                   │            │                        │
│   └───────────────────┴────────────┘                        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

This is the core of the "IDE" experience. Projects are first-class citizens, and switching between them is instantaneous.

## Smart Layouts: Adaptive Splits

One underrated feature of my Tmux setup is **adaptive layouts** that respond to terminal width.

I have a custom keybinding `Ctrl-s V` that creates a vertical split layout, but the proportions change based on how wide my terminal is:

### Layout Breakpoints

```
Terminal Width < 210 columns:
┌────────────────────┬────────────────────┐
│                    │                    │
│   Main Pane        │   Right Pane       │
│   (50%)            │   (50%)            │
│                    │                    │
└────────────────────┴────────────────────┘


Terminal Width ≥ 210 and < 310 columns:
┌──────────────────────────┬──────────┐
│                          │          │
│   Main Pane              │  Right   │
│   (flexible)             │  (100    │
│                          │  cols)   │
└──────────────────────────┴──────────┘


Terminal Width ≥ 310 columns:
┌─────────────────────────────┬─────────────┐
│                             │             │
│   Main Pane                 │   Right     │
│   (67%)                     │   (33%)     │
│                             │             │
└─────────────────────────────┴─────────────┘
```

This means my layout *always* feels right, whether I'm on a laptop screen or an ultrawide monitor. The main editor pane gets the bulk of the space, but secondary panes remain usable.

The implementation is surprisingly simple—it's just a conditional Tmux command:

```tmux
bind-key V if-shell '[ $(tmux display -p "#{window_width}") -ge 310 ]' \
    'select-layout main-vertical; resize-pane -t 2 -x 33%' \
    'if-shell "[ $(tmux display -p \"#{window_width}\") -ge 210 ]" \
        "select-layout main-vertical; resize-pane -t 2 -x 100" \
        "select-layout main-vertical; resize-pane -t 1 -x 50%"'
```

It checks the terminal width and applies the appropriate layout automatically. No guesswork, no manual resizing.

## Integrated Tools: The Component Ecosystem

The rest of the "IDE" is made up of purpose-built tools that handle specific tasks. Each one is accessible via a single keybinding, and most open in popups to keep the workflow fast and focused.

### Quick Shell (Ctrl-s c)

A lightweight popup shell that runs a single command and exits on success.

Use case: Quick one-off commands without cluttering your workspace.

```
Press Ctrl-s c → Popup shell appears
⚡ npm install
(Command runs, popup auto-closes on success)
```

If the command fails, the shell stays open so you can see the error and retry. Press Ctrl-c twice within 2 seconds to close it manually.

### LazyGit (Ctrl-s G)

Full Git UI in a popup. Stage changes, commit, rebase, manage branches—all without leaving Tmux.

Uses `popup-aware-editor` so pressing `e` on a file opens it in your Neovim pane, not inside LazyGit.

### Yazi (Ctrl-s Z)

Terminal-based file browser. Great for exploring unfamiliar codebases or moving files around.

Like LazyGit, selecting a file opens it in Neovim via RPC.

### Television: The Universal Fuzzy Finder (Ctrl-s g/f/d/o)

I use **[Television](https://github.com/alexpasmantier/television)** as my primary fuzzy finder for most workflows:

- `Ctrl-s g` → Full-text code search (ripgrep integration)
- `Ctrl-s f` → Find files
- `Ctrl-s d` → Jump to directories  
- `Ctrl-s o` → Session picker (custom Sesh integration)

**Full-text search example:**

```
🔍 > search term

Results:
  src/main.js:42:  const result = search term here
  lib/utils.js:18: // Handle search term edge case
  
Preview (bat):
───────┬────────────────────────────────────────────
  40   │ function processQuery(query) {
  41   │   // Search implementation
  42 → │   const result = search term here
  43   │   return result
───────┴────────────────────────────────────────────
```

Television supports interactive filtering, multi-select, and syntax-highlighted previews. It's essentially a batteries-included replacement for the custom FZF-based pickers I used to maintain.

**A note on FZF:** If you read my [previous post on terminal tools](https://joe.sh/terminal-tools), you'll notice I talked extensively about FZF. That post still reflects how I was working at the time—with custom FZF-based scripts for ripgrep search, Sesh session switching, and file finding. Since then, I've migrated most of those workflows to Television. It provides similar functionality but with better defaults, built-in preview support, and a more extensible channel system. The underlying concepts are the same—fast fuzzy finding with composable scripts—just with a more polished tool.

### SSH Manager (Ctrl-s @)

Smart SSH connection manager that:
- Parses `~/.ssh/known_hosts` and `~/.ssh/config`
- Shows recent connections with a ⭐ indicator
- Tests connection status in the preview pane
- Avoids tmux-in-tmux nesting by detaching before connecting

```
 SSH Connect

  🏠  homelab-server      ⭐ recent
  ☁️  aws-prod-instance
  🐧  ubuntu-dev
  🍎  mac-mini
  🐳  docker-host

Preview:
=== SSH Configuration ===
Hostname       : 192.168.1.50
User           : joe
Port           : 22
Identityfile   : ~/.ssh/id_rsa

=== Connection Status ===
✓ Reachable
```

When you connect, it attempts to attach to an existing Tmux session on the remote machine, or creates a new one if needed. This means your remote environment is also Tmux-based, and the workflow is identical whether you're local or remote.

## Why This Works For Me

This setup has become second nature, and there are a few things about it that make it particularly well-suited to how I work.

### 1. Speed

Everything is native, keyboard-driven, and optimized for terminal use. Tools like Ripgrep, Yazi, and Television are written in Rust and are *fast*.

Popups open instantly. Searches are near-instantaneous. File navigation is snappy even in huge codebases.

### 2. Composability

Each tool does one thing well and integrates cleanly with the rest. I can replace any component without breaking the system.

Don't like Yazi? Use `nnn` or `lf` instead. Want a different fuzzy finder? Swap Television for FZF. Prefer a different Git UI? Use `tig` or raw Git commands.

The integration points are simple scripts and environment variables, not proprietary APIs.

### 3. Remote-First

Because the entire setup runs in the terminal, it works identically over SSH.

I can connect to a remote server, attach to a Tmux session, and have full access to Neovim, LazyGit, popups, RPC-based editing—everything. The experience is indistinguishable from local development.

### 4. Session Persistence

Tmux sessions survive terminal crashes, network drops, and machine reboots (if configured with tmux-resurrect/tmux-continuum).

I can close my laptop, open it hours later, and everything is exactly where I left it. Every pane, every window, every working directory—preserved.

### 5. Flexibility

Want a three-column layout? Done. Want a floating popup terminal? Done. Want to SSH into a remote server and spawn a local popup on your machine to edit a file? Okay, that one's tricky, but probably doable with some scripting.

The point is: there are no artificial constraints. Tmux is a framework, not a product, and I can bend it to work however I want.

## The Tradeoffs

This setup works great for me, but it's definitely not a universal solution.

### Learning Curve

Tmux has its own conceptual model (sessions, windows, panes) that takes time to internalize. Add Neovim's modal editing on top of that, plus a dozen other CLI tools, and the onboarding is steep.

If you're coming from a GUI IDE, the first few weeks will feel slow and awkward. That's normal. But once the muscle memory sets in, it's hard to go back.

### Configuration Overhead

Nothing works out of the box. Every tool needs configuration, keybindings need to be mapped, and integrations need to be scripted.

My dotfiles repo is hundreds of files. That's the cost of customization.

The upside is that it's *my* system, tuned exactly how I want it. But it's not a "download and go" experience.

### Limited Debugging UI

Tmux doesn't have a graphical debugger. If you rely heavily on breakpoints, watch windows, and visual call stacks, you'll need to use a language-specific debugger (which can run in a Tmux pane) or use a traditional GUI tool for that workflow.

I mostly work in JavaScript/TypeScript and do most debugging via logs and tests, so this hasn't been a blocker for me. But it's worth noting.

### Not Great for Non-Terminal Work

If your workflow involves a lot of GUI tools (design software, database clients, API testing tools), this setup won't integrate them as seamlessly as a traditional IDE might.

That said, most of those tools have terminal equivalents or can be run in a browser, so it's often solvable.

## Conclusion

When I first switched to terminal-based development, I thought I was just changing my text editor. But what I actually did was rebuild my entire development environment from first principles, using Tmux as the foundation.

Neovim handles text editing. LazyGit handles version control. Yazi handles file browsing. Ripgrep handles search. Sesh and TWM handle project management. Workmux handles parallel workflows. Tmux orchestrates all of it.

It's not a single application. It's a system—one that's fast, composable, remote-friendly, and entirely under my control.

This setup isn't for everyone. It took time to build, requires maintenance, and has a steep learning curve. But for me, it's transformed how I work. The realization that Tmux—not my text editor—is my actual IDE changed everything.

And that's why Tmux is my IDE.

---

Want to see the full configuration? Check out [my dotfiles repo](https://github.com/josephschmitt/dotfiles).

Questions or comments? [Ping me on Twitter](https://twitter.com/intent/tweet?screen_name=josephschmitt&text=Re%3A%20Tmux%20is%20My%20IDE).
