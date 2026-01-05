#!/bin/bash

# Quick validation script for skills - minimal version

# Validate a skill folder
validate_skill() {
    local skill_path="$1"

    # Check if SKILL.md exists
    if [ ! -f "$skill_path/SKILL.md" ]; then
        echo "❌ SKILL.md not found"
        return 1
    fi

    # Read the SKILL.md file
    local content
    content=$(cat "$skill_path/SKILL.md")

    # Check if it starts with ---
    if [[ ! "$content" =~ ^--- ]]; then
        echo "❌ No YAML frontmatter found"
        return 1
    fi

    # Extract frontmatter (between first and second ---)
    local frontmatter
    frontmatter=$(echo "$content" | sed -n '/^---$/,/^---$/p' | tail -n +2 | head -n -1)

    if [ -z "$frontmatter" ]; then
        echo "❌ Invalid frontmatter format"
        return 1
    fi

    # Check if yq is available for YAML parsing (preferred)
    if command -v yq &> /dev/null; then
        return _validate_with_yq "$skill_path" "$frontmatter"
    else
        return _validate_with_grep "$skill_path" "$frontmatter"
    fi
}

# Validate using yq (preferred YAML parser)
_validate_with_yq() {
    local skill_path="$1"
    local frontmatter="$2"

    # Create temporary file with frontmatter
    local temp_file
    temp_file=$(mktemp)
    echo "$frontmatter" > "$temp_file"

    # Check for required fields using yq
    if ! yq -e '.name' "$temp_file" > /dev/null 2>&1; then
        echo "❌ Missing 'name' in frontmatter"
        rm "$temp_file"
        return 1
    fi

    if ! yq -e '.description' "$temp_file" > /dev/null 2>&1; then
        echo "❌ Missing 'description' in frontmatter"
        rm "$temp_file"
        return 1
    fi

    # Get name value
    local name
    name=$(yq -r '.name' "$temp_file")

    if [ "$name" = "null" ] || [ -z "$name" ]; then
        echo "❌ Name is empty"
        rm "$temp_file"
        return 1
    fi

    # Validate name (hyphen-case: lowercase with hyphens)
    if [[ ! "$name" =~ ^[a-z0-9-]+$ ]]; then
        echo "❌ Name '$name' should be hyphen-case (lowercase letters, digits, and hyphens only)"
        rm "$temp_file"
        return 1
    fi

    # Check for leading/trailing hyphens or consecutive hyphens
    if [[ "$name" =~ ^- ]] || [[ "$name" =~ -$ ]] || [[ "$name" =~ -- ]]; then
        echo "❌ Name '$name' cannot start/end with hyphen or contain consecutive hyphens"
        rm "$temp_file"
        return 1
    fi

    # Check name length (max 64 characters)
    if [ ${#name} -gt 64 ]; then
        echo "❌ Name is too long (${#name} characters). Maximum is 64 characters."
        rm "$temp_file"
        return 1
    fi

    # Get description value
    local description
    description=$(yq -r '.description' "$temp_file")

    if [ "$description" = "null" ] || [ -z "$description" ]; then
        echo "❌ Description is empty"
        rm "$temp_file"
        return 1
    fi

    # Check for angle brackets in description
    if [[ "$description" =~ \< ]] || [[ "$description" =~ \> ]]; then
        echo "❌ Description cannot contain angle brackets (< or >)"
        rm "$temp_file"
        return 1
    fi

    # Check description length (max 1024 characters)
    if [ ${#description} -gt 1024 ]; then
        echo "❌ Description is too long (${#description} characters). Maximum is 1024 characters."
        rm "$temp_file"
        return 1
    fi

    rm "$temp_file"
    echo "✅ Skill is valid!"
    return 0
}

# Validate using grep (fallback when yq is not available)
_validate_with_grep() {
    local skill_path="$1"
    local frontmatter="$2"

    # Check for name field
    if ! echo "$frontmatter" | grep -q "^name:"; then
        echo "❌ Missing 'name' in frontmatter"
        return 1
    fi

    # Check for description field
    if ! echo "$frontmatter" | grep -q "^description:"; then
        echo "❌ Missing 'description' in frontmatter"
        return 1
    fi

    # Extract name value
    local name
    name=$(echo "$frontmatter" | grep "^name:" | head -1 | sed 's/^name:[[:space:]]*//; s/[[:space:]]*$//' | tr -d '"' | tr -d "'")

    if [ -z "$name" ]; then
        echo "❌ Name is empty"
        return 1
    fi

    # Validate name (hyphen-case: lowercase with hyphens)
    if [[ ! "$name" =~ ^[a-z0-9-]+$ ]]; then
        echo "❌ Name '$name' should be hyphen-case (lowercase letters, digits, and hyphens only)"
        return 1
    fi

    # Check for leading/trailing hyphens or consecutive hyphens
    if [[ "$name" =~ ^- ]] || [[ "$name" =~ -$ ]] || [[ "$name" =~ -- ]]; then
        echo "❌ Name '$name' cannot start/end with hyphen or contain consecutive hyphens"
        return 1
    fi

    # Check name length
    if [ ${#name} -gt 64 ]; then
        echo "❌ Name is too long (${#name} characters). Maximum is 64 characters."
        return 1
    fi

    echo "✅ Skill is valid!"
    return 0
}

# If script is run directly (not sourced)
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    if [ $# -ne 1 ]; then
        echo "Usage: quick_validate.sh <skill_directory>"
        exit 1
    fi

    if validate_skill "$1"; then
        exit 0
    else
        exit 1
    fi
fi
