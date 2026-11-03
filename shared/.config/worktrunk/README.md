# Worktrunk

Configuration for [Worktrunk](https://worktrunk.dev) (`wt`) - git worktree management with lifecycle hooks.

Here it is the worktree engine behind the Herdr worktree picker (TUI `prefix+w` / `prefix+shift+w` / `prefix+shift+d`, Mac app leader `w` / `W` / `D`). `shared/bin/herdr-wt` calls `wt switch` / `wt remove` and does the Herdr side itself (focusing, opening, closing workspaces). `wt` works standalone too.

Installed by Homebrew via nix-darwin (`"worktrunk"` in `shared/.config/nix-darwin/darwin.nix`, applied with `nix_rebuild`). `stow shared` links this directory to `~/.config/worktrunk/`.

## Why Worktrunk

Herdr creates worktrees but has no hooks for setting them up. workmux has hooks but needs tmux/WezTerm/Kitty/Zellij and always creates a window in one, so it can't sit under Herdr. Worktrunk has no multiplexer dependency, takes non-interactive flags (`--no-cd --yes --format json`), and has blocking and background hooks.

## Where worktrees go

`worktree-path = "~/.herdr/worktrees/{{ repo }}/{{ branch | sanitize }}"`, which is Herdr's own default (`[worktrees] directory`), so checkouts made by `wt`, the picker, or Herdr's native commands all sit together and Herdr groups them under the repo. `feature/x` becomes `feature-x`.

## Hooks

| Hook | Blocking? | What it does here |
|------|-----------|-------------------|
| `pre-start` `node-modules` | yes (runs before the worktree is handed to Herdr) | Symlinks the primary checkout's `node_modules` into the new worktree, if it exists there and the worktree has none. The port of workmux's `files.symlink: [node_modules]` |
| `post-start` `copy-ignored` | no (background, logs in `.git/wt/logs/`) | `wt step copy-ignored --require-include`: copies gitignored files (`.env`, ...) from the primary checkout, only those a repo lists in a `.worktreeinclude` file. Without that file it does nothing, so build output and caches are never copied by accident |
| `post-start` on `github.com/UrbanCompass/*` | no | `compass repo init` (was workmux's `post_create` in `work/.config/workmux/config.yaml`), skipped where the `compass` CLI isn't installed |
| `pre-remove` | yes | Nothing; a commented example is in `config.toml` |

Notes:

- **Why `ln -s` in a hook:** Worktrunk has no symlink setting (`copy-ignored` copies). A shell one-liner with `{{ primary_worktree_path }}` / `{{ worktree_path }}` does the job. The guard keeps it a no-op in repos without `node_modules` and on re-runs.
- **Per-repo hooks:** add a `[projects."<host>/<owner>/<repo>"]` table (`*` matches any run of characters, `/` included). Run `wt config show` inside the repo to see its identifier. Hooks there run **after** the global ones; scalar settings replace the global value. A repo can also ship its own `.config/wt.toml` (project hooks, which ask for approval once; approvals go to `approvals.toml` here, gitignored).
- User hooks (this file) never ask for approval, so `--yes` runs are not blocked.
- A failing `pre-*` hook aborts the operation; `post-*` failures only show in the logs.
- Template variables: `{{ worktree_path }}`, `{{ primary_worktree_path }}`, `{{ branch }}`, `{{ repo }}`, ... (see [hook docs](https://worktrunk.dev/hook/#template-variables)).

## Branching from a fresh default branch

`wt switch --create` branches from the local default branch and doesn't fetch. `herdr-wt create` runs `git fetch origin <default>` first and passes `--base origin/<default>` (falling back to the local branch when offline), which replaces workmux's `fresh-worktree` plugin. Existing local or remote-only branches are checked out as they are (a remote-only one gets a tracking branch).

## Why the picker doesn't use `wt list`

`wt list --format json` computes status, ahead/behind and diffs per worktree, which takes seconds on the big monorepos. The picker only needs names, paths and which ones are open, so `herdr-wt` reads `git worktree list --porcelain` and `herdr worktree list` instead.

## Removing

`herdr-wt delete` / the picker's `ctrl-d` run `wt remove --yes --foreground`: the folder goes, and the branch is deleted only if it's merged (else it's kept and the message says so; `wt remove -D <branch>` deletes it anyway). Dirty worktrees need confirmation (they're removed with `--force`). The main checkout is never removed.

## Checking the config

```sh
wt config show        # parsed config, project identifier, hook list
wt hook show          # hooks that would run in this repo
```
