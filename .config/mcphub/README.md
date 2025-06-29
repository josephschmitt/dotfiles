# MCP Hub Configuration

This directory contains the MCP (Model Context Protocol) server configurations for mcphub.nvim.

## Current Servers

### Context7
- **Purpose**: Up-to-date code documentation for LLMs
- **Type**: Remote MCP server
- **URL**: `https://mcp.context7.com/mcp`
- **Auto-approve**: Enabled for all Context7 tools

## Usage in Avante

After setup, you can:
1. Use "use context7" in your prompts to fetch up-to-date documentation
2. Use slash commands like `/mcp:context7:get-library-docs`
3. Ask for specific library documentation: "Get me the latest Next.js documentation"

## Adding More Servers

Add new MCP servers to `servers.json` following these patterns:

### Local (stdio) Servers
```json
{
  "mcpServers": {
    "local-server": {
      "command": "command-to-run",
      "args": ["arg1", "arg2"],
      "autoApprove": true|false|["specific", "tools"]
    }
  }
}
```

### Remote Servers
```json
{
  "mcpServers": {
    "remote-server": {
      "url": "https://your-mcp-server.com/mcp",
      "headers": {
        "Authorization": "Bearer ${API_TOKEN}"
      },
      "autoApprove": true|false|["specific", "tools"]
    }
  }
}
```