# Git-spice Command Reference

Quick reference for git-spice commands.

## Setup

```bash
# Initialize repository (one-time)
gs repo init

# Authenticate with GitHub
gs auth login
```

## Branch Management

```bash
# Create new branch stacked on current
gs branch create <name>
gs bc <name>                    # Shorthand

# Track existing branch
gs branch track

# Checkout branch (interactive)
gs branch checkout
gs bco                          # Shorthand

# Delete branch
gs branch delete <name>
gs bd <name>                    # Shorthand
```

## Stack Operations

```bash
# View stack structure
gs log short
gs log long                     # With full details

# Rebase operations
gs stack restack               # Rebase all branches
gs sr                          # Shorthand
gs upstack restack            # Rebase current + above
gs branch restack             # Rebase single branch
```

## Submitting PRs

```bash
# Submit as PRs
gs stack submit               # All branches
gs ss                         # Shorthand
gs upstack submit             # Current + above
gs uss                        # Shorthand
gs downstack submit           # Current + below
gs dss                        # Shorthand
gs branch submit              # Single branch
gs bs                         # Shorthand

# Options
gs ss --draft                 # Submit as draft PRs
gs bs --fill                  # Interactive PR details
```

## Sync Operations

```bash
# Sync with remote
gs repo sync                  # Update trunk, clean merged branches
gs rs                         # Shorthand
```

## Configuration

```bash
# View config
gs config list

# Set config
gs config set <key> <value>

# Common settings
gs config set navigationComments multiple
gs config set branchCreate.commit false
```

## Common Workflows

### Start New Stack
```bash
gs rs                         # Sync with trunk
gs bc feature/part1          # Create first branch
# Make changes, commit with git
gs bc feature/part2          # Stack next branch
# Make changes, commit
gs log short                 # Verify
gs ss                        # Submit all
```

### Update After Feedback
```bash
git checkout <branch>        # Go to branch
# Make changes, commit
gs upstack restack          # Rebase above branches
git push --force-with-lease # Push changes
gs upstack submit           # Update PRs
```

### After Merges
```bash
gs rs                        # Sync and clean up
gs sr                        # Restack remaining
gs ss                        # Update PRs
```

## Conflict Resolution

During restack, if conflicts occur:

```bash
# Fix conflicts in editor
git add <files>              # Mark resolved
git rebase --continue        # Continue rebase

# Or abort
git rebase --abort
```

## Integration with Git

Use regular git for commits:

```bash
git add .
git commit -m "message"
git status
git log
```

Use git-spice for stack management:

```bash
gs bc <name>                 # Create branches
gs sr                        # Restack
gs ss                        # Submit PRs
```

## Integration with GitHub CLI

```bash
# View PRs
gh pr list --author @me
gh pr view <number>

# Edit PRs
gh pr edit <number> --title "New title"
gh pr edit <number> --add-label "stack"

# Manage reviews
gh pr review <number> --approve
gh pr comment <number> --body "LGTM"

# Check status
gh pr status
gh pr checks <number>
```

## Tips

- Use shorthands: `gs bc`, `gs ss`, `gs sr`, `gs rs`
- Run `gs log short` frequently
- Always use `--force-with-lease` not `--force`
- Let git-spice handle rebasing, not `git rebase`
- Sync regularly with `gs rs`

## Getting Help

```bash
gs help
gs <command> --help
gs version
```

## Useful Aliases

Add to your shell config:

```bash
alias gbc='gs bc'
alias gss='gs ss'
alias gsr='gs sr'
alias grs='gs rs'
alias gls='gs log short'
```
