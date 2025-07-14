# OpenCode Configuration

This directory contains the configuration for [OpenCode AI](https://opencode.ai), an AI coding agent built for the terminal.

## Persona-Based Development Modes

This setup implements a persona-based approach to AI-assisted development, based on [Nicholas C. Zakas' methodology](https://humanwhocodes.com/blog/2025/06/persona-based-approach-ai-assisted-programming/) from his article ["A persona-based approach to AI-assisted software development"](https://humanwhocodes.com/blog/2025/06/persona-based-approach-ai-assisted-programming/). Each mode has specialized prompts and tool restrictions to optimize for specific development phases.

**Credit**: This approach was developed by [Nicholas C. Zakas](https://humanwhocodes.com/blog/2025/06/persona-based-approach-ai-assisted-programming/) and adapted for OpenCode. The original methodology treats AI as a team of specialized personas rather than a single assistant, dramatically improving productivity for complex development tasks.

### Available Modes

#### 🎯 `pm` (Product Manager)
**Purpose**: Requirements gathering and PRD creation
- **Focus**: Functional requirements, user stories, acceptance criteria
- **Tools**: Read-only analysis + documentation writing
- **Restrictions**: Cannot edit code or run system commands
- **Use when**: Starting a new feature, clarifying requirements

#### 🏗️ `architect` (Software Architect)  
**Purpose**: Technical design and implementation planning
- **Focus**: System design, architecture decisions, step-by-step implementation guides
- **Tools**: Read-only analysis + specification writing
- **Restrictions**: Cannot edit code or run system commands
- **Use when**: Designing how to implement a feature

#### ⚙️ `implementer` (Software Engineer)
**Purpose**: Code implementation following specifications
- **Focus**: Building features according to architect's design
- **Tools**: Full development access (all tools enabled)
- **Use when**: Actually writing the code

#### 🔍 `solver` (Problem Solver)
**Purpose**: Debugging and creative problem-solving
- **Focus**: Investigation, root cause analysis, fixing issues
- **Tools**: Full development access (all tools enabled)
- **Use when**: Things aren't working as expected

### Workflow

The typical development flow follows this pattern:
```
pm → architect → implementer → solver (as needed)
```

1. **Start with `pm`** to gather requirements and create user stories
2. **Switch to `architect`** to design the technical implementation
3. **Use `implementer`** to build the feature following the design
4. **Switch to `solver`** when debugging issues or investigating problems

### Switching Modes

- Use **Tab** key to cycle through modes during a session
- Or use your configured `switch_mode` keybind
- Each mode has different capabilities and behavior optimized for its role

## MCP Servers

### Context7
- **Purpose**: Provides up-to-date code documentation for LLMs
- **Type**: Local MCP server via pnpm dlx
- **Usage**: Automatically available for documentation queries

### CircleCI
- **Purpose**: CI/CD pipeline management and debugging
- **Type**: Local MCP server via pnpm dlx
- **Usage**: Pipeline status, build logs, test results

### GitHub
- **Purpose**: GitHub API integration
- **Type**: Remote MCP server
- **Usage**: Repository management, issues, pull requests

## Usage Examples

### Using Persona Modes
```bash
# Start in PM mode to gather requirements
opencode --mode pm
> "I need to add user authentication to my app"

# Switch to architect mode (Tab key)
> "Design the technical implementation for the authentication PRD"

# Switch to implementer mode
> "Implement the authentication system following the technical spec"

# Switch to solver mode if issues arise
> "The login isn't working, debug this issue"
```

### Using MCP Tools
1. **Natural language prompts**:
   - "Get me the latest Next.js documentation"
   - "Show me React hooks examples use context7"
   - "Check the status of my CircleCI pipeline"

2. **Direct tool usage**:
   - The AI will automatically call appropriate MCP tools when needed

## File Structure

```
.config/opencode/
├── config.json           # Main configuration file
├── README.md             # This documentation
└── prompts/              # Persona-specific prompts
    ├── product-manager.txt
    ├── architect.txt
    ├── implementer.txt
    └── problem-solver.txt
```

## Configuration Location

This config is symlinked from `~/dotfiles/shared/.config/opencode/` to `~/.config/opencode/` via GNU Stow.

## Customization

### Adding Custom Modes

You can create additional persona modes by:

1. **Creating a prompt file** in `prompts/your-mode.txt`
2. **Adding mode configuration** to `config.json`:

```json
{
  "mode": {
    "your-mode": {
      "prompt": "{file:./prompts/your-mode.txt}",
      "tools": {
        "read": true,
        "write": false,
        "edit": false,
        "bash": false
      }
    }
  }
}
```

### Tool Configuration

Each mode can enable/disable specific tools:

| Tool | Description |
|------|-------------|
| `read` | Read file contents |
| `write` | Create new files |
| `edit` | Modify existing files |
| `bash` | Execute shell commands |
| `patch` | Apply patches to files |
| `grep` | Search file contents |
| `glob` | Find files by pattern |
| `list` | List directory contents |
| `todoread`/`todowrite` | Manage todo lists |
| `webfetch` | Fetch web content |

### Adding More MCP Servers

To add additional MCP servers, edit `config.json` and add them under the `mcp` section:

#### Local MCP Servers
```json
{
  "mcp": {
    "your-local-server": {
      "type": "local",
      "command": ["pnpm", "dlx", "your-mcp-package"],
      "environment": {
        "ENV_VAR": "value"
      },
      "enabled": true
    }
  }
}
```

#### Remote MCP Servers
```json
{
  "mcp": {
    "your-remote-server": {
      "type": "remote",
      "url": "https://your-mcp-server.com",
      "enabled": true
    }
  }
}
```

## Tips

- **Start with `pm` mode** for new features to ensure clear requirements
- **Use `architect` mode** to avoid implementation details creeping into design
- **Stay in `implementer` mode** when actively coding to maintain focus
- **Switch to `solver` mode** when debugging to leverage problem-solving capabilities
- **Each mode has different "personalities"** - let them guide the conversation style