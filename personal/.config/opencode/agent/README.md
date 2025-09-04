# .ai/modes Directory

## Overview
This directory contains all custom chat mode files for AI agents. Each mode defines a unique persona or workflow, specifying which tools are enabled and what instructions the agent should follow.

## How It Works
- **Custom Chat Modes:** Each file describes a specific AI persona or workflow, tailored for tasks like planning, implementation, debugging, and more.
- **Frontmatter Configuration:** Mode files use YAML frontmatter to declare metadata such as description, enabled tools, and model selection. The body provides detailed instructions for the agent.
- **Source of Truth:** This directory is symlinked to other locations so all AI agents reference a single, canonical set of modes.

## Usage
- To add or modify a chat mode, edit or create a new file in this directory. Do not use the `.chatmode.md` suffix here; it will be added in symlinked locations for VS Code/Copilot compatibility.

**Note:** Symlinks are **not** created automatically. If you add a _new_ chat mode or want to support a new instructions file, you must manually create the symlink in the appropriate location for your editor or AI agent to consume.
- Use the [VS Code Copilot documentation](https://code.visualstudio.com/docs/copilot/chat/chat-modes#_chat-mode-file-example) as a reference for front matter and available tools, but keep the source files here as generic and AI-agnostic as possible for broader compatibility.

## Best Practices
- Keep mode instructions clear and focused for each persona or workflow.
- Explicitly declare all required tools in the frontmatter for each mode.
- Document any changes to modes or agent behavior in this README or a changelog.
