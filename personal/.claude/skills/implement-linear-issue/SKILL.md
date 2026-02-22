---
name: implement-linear-issue
description: Implement a Linear issue. Use when the user wants to work on a Linear ticket, provides a Linear issue ID (e.g., JJS-78) or Linear URL.
argument-hint: <issue-id-or-url>
allowed-tools: mcp__claude_ai_Linear__*, Skill(commit-commands:commit-push-pr)
disable-model-invocation: true
---

# Implement Linear Issue

This skill helps you implement a Linear issue from start to finish, including creating a PR and linking it back to Linear.

## Instructions

### 1. Parse the Argument

The `$ARGUMENTS` variable contains either:
- A full URL like `https://linear.app/.../issue/JJS-78/...`
- An issue ID like `JJS-78`

**If it's a URL**: Extract the issue ID using regex pattern `/issue/([A-Z]+-\d+)/`
**If it's already an ID**: Use it directly

### 2. Fetch Issue Details

Use the `mcp__claude_ai_Linear__get_issue` tool with the parsed issue ID to retrieve:
- Issue title
- Issue description
- Priority
- Labels
- Any attachments or linked resources

Display the issue details to understand what needs to be implemented.

### 3. Understand and Implement

Read the issue requirements carefully. If the issue description contains images, use `mcp__claude_ai_Linear__extract_images` to view them.

Implement the feature/fix as described in the issue:
- Analyze the codebase to understand where changes need to be made
- Make the necessary code changes
- Test the implementation

### 4. After Implementation Complete

Once the implementation is done:

1. **Commit and Push PR**: Use the `/commit-commands:commit-push-pr` skill to:
   - Commit the changes
   - Push to a branch
   - Open a pull request

2. **Link PR to Linear**: After the PR is created, add it as a link on the Linear issue:
   ```
   mcp__claude_ai_Linear__update_issue with:
   - id: <issue-id>
   - links: [{ url: <pr-url>, title: "Pull Request" }]
   ```

3. **Update Issue Status**: Move the issue to "In Review":
   ```
   mcp__claude_ai_Linear__update_issue with:
   - id: <issue-id>
   - state: "In Review"
   ```

## Example Usage

```
/implement-linear-issue JJS-78
/implement-linear-issue https://linear.app/josephschmitt/issue/JJS-78/add-new-feature
```

## Notes

- If the issue has sub-issues or dependencies, consider implementing those first
- Include the Linear issue ID in your commit message for traceability
- The PR title should match or reference the Linear issue title
