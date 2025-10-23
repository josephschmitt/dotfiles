#!/usr/bin/env bash
# Create a test .env file for performance testing

set -e

cat > "$HOME/.env" <<'EOF'
# Fake environment variables for CI performance testing
# This file is used to test .env parsing performance in shell startup

# Development environment
NODE_ENV=development
DEBUG=true
LOG_LEVEL=info

# API keys (fake values for testing)
GITHUB_TOKEN=ghp_1234567890abcdefghijklmnopqrstuvwxyz
OPENAI_API_KEY=sk-proj-abcdefghijklmnopqrstuvwxyz1234567890
ANTHROPIC_API_KEY=sk-ant-api03-1234567890abcdefghijklmnopqrstuvwxyz

# Editor and tool configuration
EDITOR=nvim
VISUAL=nvim
PAGER=less

# Shell configuration
SHELL_PERFORMANCE_TEST=enabled
EOF

echo "Test .env file created at $HOME/.env"
