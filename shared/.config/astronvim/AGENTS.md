# Agent Guidelines for AstroVim Configuration

## Core Philosophy: The "AstroVim Way"

When working on AstroVim configuration, **always prioritize doing things the "AstroVim way"**. This means following AstroVim's conventions, using its built-in features, and leveraging the AstroCommunity plugin ecosystem.

## Documentation First

**ALWAYS refer to the latest AstroVim documentation when making configuration changes:**
- Official Docs: https://docs.astronvim.com/
- Configuration: https://docs.astronvim.com/configuration/
- AstroCommunity: https://docs.astronvim.com/astrocommunity/
- Recipes: https://docs.astronvim.com/recipes/

## Plugin Installation Hierarchy

Follow this strict order when adding plugins:

### 1. AstroCommunity First (PREFERRED)
**Always check AstroCommunity before writing custom plugin specs.**

- Browse available plugins: https://docs.astronvim.com/astrocommunity/
- AstroCommunity plugins are pre-configured, tested, and follow AstroVim conventions
- Example categories: language packs, colorschemes, motion, editing-support, utility, etc.

```lua
-- ✅ PREFERRED: Use AstroCommunity plugin
return {
  { import = "astrocommunity.colorscheme.tokyonight-nvim" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.motion.flash-nvim" },
}
```

### 2. Custom Plugin Specs (FALLBACK)
Only use custom plugin specs when:
- The plugin is not available in AstroCommunity
- You need customization beyond what AstroCommunity provides
- You've confirmed with the user that a custom approach is acceptable

```lua
-- ⚠️ FALLBACK: Custom plugin spec (use only when necessary)
return {
  "username/plugin-name",
  opts = {
    -- custom configuration
  },
}
```

## Required Workflow for Non-Standard Approaches

If you cannot accomplish a task using AstroCommunity or standard AstroVim patterns:

1. **Search AstroCommunity first**: Check https://docs.astronvim.com/astrocommunity/ thoroughly
2. **Check AstroVim recipes**: Look for similar patterns at https://docs.astronvim.com/recipes/
3. **If no standard solution exists**: Use the `AskUserQuestion` tool to confirm:
   - Explain what you're trying to accomplish
   - Note that AstroCommunity doesn't have this plugin/feature
   - Ask if they want to proceed with a custom plugin spec
   - Suggest any alternative AstroCommunity plugins that might work

Example:
```
I couldn't find an AstroCommunity plugin for [feature]. I can add it as a custom plugin spec,
but this means we'll need to maintain the configuration ourselves.

Alternatives:
- [AstroCommunity plugin X] provides similar functionality
- [AstroCommunity plugin Y] might work differently but achieve the same goal

Would you like to:
1. Proceed with a custom plugin spec
2. Try one of the AstroCommunity alternatives
```

## AstroVim Configuration Patterns

### File Organization
```
astronvim/
├── init.lua              # Main entry point
├── lua/
│   ├── plugins/          # Plugin specifications
│   │   ├── astrocommunity.lua  # AstroCommunity imports
│   │   ├── core.lua      # Core overrides
│   │   └── *.lua         # Custom plugin specs
│   └── polish.lua        # Final customizations
└── AGENTS.md            # This file
```

### Configuration Structure
Follow AstroVim's configuration structure:
- Use `opts` for plugin configuration
- Use `config` function for complex setup
- Override AstroCore for keymaps, autocmds, and options
- Use `polish.lua` for final tweaks after plugins load

### Keybindings
Use AstroCore's keybinding system:
```lua
{
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        ["<Leader>tf"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      },
    },
  },
}
```

### LSP and Language Support
Prefer AstroCommunity language packs:
```lua
-- ✅ Use language packs
{ import = "astrocommunity.pack.typescript" },
{ import = "astrocommunity.pack.rust" },
```

## Version Compatibility

- AstroNvim is a rapidly evolving project
- Always verify configuration against the latest documentation
- Test changes before committing
- Note any version-specific behavior in comments

## When in Doubt

1. Check the official documentation first
2. Look for AstroCommunity solutions
3. Review existing configuration patterns in this repo
4. Ask the user before implementing non-standard solutions

## Summary

**The golden rule: AstroCommunity > AstroVim patterns > Custom specs**

Always exhaust AstroCommunity options before writing custom plugin configurations. When you must deviate from the standard approach, confirm with the user first.
