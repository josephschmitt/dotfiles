# OpenCode Configuration

This directory contains the configuration for [OpenCode AI](https://opencode.ai), an AI coding agent built for the terminal.

## Current Setup

### MCP Servers
- **Context7**: Provides up-to-date code documentation for LLMs
  - Type: Remote MCP server
  - URL: `https://mcp.context7.com/mcp`

## Usage

After starting OpenCode with `opencode`, Context7 tools are automatically available. You can:

1. **Natural language prompts**:
   - "Get me the latest Next.js documentation"
   - "Show me React hooks examples use context7"
   - "use context7 to find PostgreSQL aggregation docs"

2. **Direct tool usage**:
   - The AI will automatically call Context7's `resolve-library-id` and `get-library-docs` tools when needed

## Configuration Location

This config is symlinked from `~/dotfiles/.config/opencode/config.json` to `~/.config/opencode/config.json` via GNU Stow.

## Adding More MCP Servers

To add additional MCP servers, edit `config.json` and add them under the `mcp` section:

### Local MCP Servers
```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp"
    },
    "your-local-server": {
      "type": "local",
      "command": ["your", "command"],
      "environment": {
        "ENV_VAR": "value"
      }
    }
  }
}
```

### Remote MCP Servers
```json
{
  "your-remote-server": {
    "type": "remote",
    "url": "https://your-mcp-server.com"
  }
}
```