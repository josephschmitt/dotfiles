# Creating and Building Stacks

Step-by-step guide for creating stacks of related PRs.

## Before You Start

Ensure:
- Repository initialized: `gs repo init` (one-time setup)
- Clean working directory: `git status`
- On trunk branch: `git checkout main`
- Latest changes: `git pull`

## Planning Your Stack

Think through logical layers:

**Example: User Authentication Feature**
```
1. feature/auth-models       (database models)
2. feature/auth-api          (API endpoints, uses models)
3. feature/auth-ui           (UI components, uses API)
```

**Guidelines:**
- Each branch = one reviewable unit
- Order by dependency (foundation first)
- Use descriptive names with prefixes (`feature/`, `fix/`, `refactor/`)

## Creating the Stack

### 1. Create First Branch

```bash
# From trunk (main)
gs bc feature/auth-models

# Make your changes
# ...

# Commit with regular git
git add .
git commit -m "feat: add authentication models"
```

### 2. Stack Next Branch

```bash
# This creates a branch based on current branch
gs bc feature/auth-api

# Make changes for this layer
# ...

# Commit
git add .
git commit -m "feat: add authentication API"
```

### 3. Continue Stacking

```bash
gs bc feature/auth-ui
# Make changes
git add .
git commit -m "feat: add authentication UI"
```

### 4. Verify Structure

```bash
gs log short
```

Expected output:
```
● feature/auth-ui (1 commit)
│
● feature/auth-api (1 commit)
│
● feature/auth-models (1 commit)
│
● main
```

## Making Changes to a Branch

### Add More Commits

```bash
# Checkout the branch
git checkout feature/auth-api

# Make changes
git add .
git commit -m "feat: add rate limiting"

# Restack branches above it
gs upstack restack
```

### Insert Branch in Middle

```bash
# Checkout the branch that should be the base
git checkout feature/auth-models

# Create new branch here
gs bc feature/auth-validation

# Make changes
git add .
git commit -m "feat: add validation layer"

# Stack continues: models → validation → api → ui
```

## Testing

Test each branch independently:

```bash
git checkout feature/auth-api
npm test
```

## Common Patterns

### Multiple Commits per Branch

```bash
git add file1.ts
git commit -m "feat: add endpoint"

git add file2.ts
git commit -m "test: add endpoint tests"

git add file3.ts
git commit -m "docs: update API docs"
```

### Switching Between Branches

```bash
# Use regular git
git checkout feature/auth-models

# Or git-spice checkout (interactive)
gs bco
```

### View Full Log

```bash
# See all commits in stack
gs log long

# Or use git
git log --oneline --graph
```

## Best Practices

✅ **Commit frequently** - Small commits are easier to review

✅ **Test each layer** - Ensure each branch works independently

✅ **Descriptive names** - Branch names should explain what they do

✅ **Keep focused** - Each branch should have one purpose

❌ **Don't rebase manually** - Use `gs upstack restack` instead

❌ **Don't make branches too large** - Keep them reviewable

## Next Steps

Once your stack is created:
- Review structure: `gs log short`
- Ready to submit? See [handling-changes.md](handling-changes.md)
