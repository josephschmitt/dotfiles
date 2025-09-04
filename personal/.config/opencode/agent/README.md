# OpenCode Agents

## Overview

This directory contains all custom agent definition files for OpenCode AI agents. Each agent defines a unique persona or workflow, specifying which tools are enabled and what instructions the agent should follow.

## How It Works

- **Custom Agents:** Each file describes a specific AI persona or workflow, tailored for tasks like planning, implementation, debugging, and more.
- **Configuration:** Agent files use YAML frontmatter to declare metadata such as description, enabled tools, and model selection. The body provides detailed instructions for the agent.
- **Source of Truth:** This directory serves as the canonical source for all agent definitions used in OpenCode configurations.

## Available Agents

The following agents are available, each with their own specialized personas:

- **Spec-ify (Primary Agent)**: Orchestrates the complete Spec-Driven Development workflow using other subagents. This is the main entry point for structured development.
- **Product Manager**: Gathers requirements and creates user-focused product requirements documents (PRDs).
- **Architect**: Designs technical solutions and implementation plans based on PRDs—focuses on architecture, data flow, and integration points.
- **Code Researcher**: Analyzes the codebase and generates technical documentation to inform PM and Architect decisions.
- **Code Reviewer**: Provides thorough, constructive code reviews focusing on security, performance, maintainability, and best practices.
- **Planner**: Breaks down technical specs into actionable implementation plans.
- **Implementer**: Handles the core development tasks for different sections of the plan.
- **Unit Tester**: Designs and runs comprehensive tests for business logic, APIs, error handling, etc.
- **Solver**: Proactively identifies and helps resolve issues during development.

## How to Use

### In OpenCode

- **Primary Agent**: Use the Tab key to access the Spec-ify orchestrator agent, or switch agents using the agent selector
- **Subagents**: Use @-mentions to access specific agents directly:
  ```
  @Code Reviewer give me some feedback on my changes
  @Architect design an implementation for user authentication
  ```
- **Agent Configuration**: Agents are configured in `opencode.json` with references to these agent definition files

## The Spec-Driven Development Workflow

The Spec-ify (Spec-Driven Development) primary agent uses a structured approach:

1. **Requirements Gathering** (using Product Manager)
2. **Technical Design** (using Architect)
3. **Implementation Planning** (using Planner)
4. **Development** (using Implementer subagents)
5. **Testing** (using Unit Tester subagents)
6. **Problem Resolution** (using Solver as needed)

This orchestrated approach ensures systematic, high-quality software development from initial idea to finished, tested code.

## Configuration

### Adding New Agents

1. Create a new `.md` file in this directory with the agent definition
2. Use YAML frontmatter to configure the agent:
   ```yaml
   ---
   description: Brief description of the agent's role
   model: preferred-model-name
   tools: ['tool1', 'tool2', 'tool3']
   ---
   ```
3. Add the agent to your `opencode.json` configuration file:
   ```json
   {
     "agent": {
       "Agent Name": {
         "description": "Brief description",
         "mode": "subagent",
         "prompt": "{file:./agent/filename.md}",
         "tools": { "read": true, "write": true }
       }
     }
   }
   ```

### Agent Types

- **Primary Agent** (`mode: "primary"`): The main orchestrator agent (typically Spec-ify)
- **Subagent** (`mode: "subagent"`): Specialized agents called by the primary agent or used directly

## Best Practices

- Keep agent instructions clear and focused for each persona or workflow
- Make instructions technology-agnostic when possible for broader applicability  
- Explicitly declare all required tools in both the agent file frontmatter and `opencode.json`
- Test agent configurations after making changes
- Document any changes to agent behavior in this README
