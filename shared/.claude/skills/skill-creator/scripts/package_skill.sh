#!/bin/bash

# Skill Packager - Creates a distributable .skill file of a skill folder
#
# Usage:
#    package_skill.sh <path/to/skill-folder> [output-directory]
#
# Example:
#    package_skill.sh skills/public/my-skill
#    package_skill.sh skills/public/my-skill ./dist

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the quick_validate.sh script
source "$SCRIPT_DIR/quick_validate.sh"

# Package a skill folder into a .skill file
package_skill() {
    local skill_path="$1"
    local output_dir="$2"

    # Resolve the skill path
    if [ ! -d "$skill_path" ]; then
        echo "❌ Error: Skill folder not found: $skill_path"
        return 1
    fi

    skill_path="$(cd "$skill_path" && pwd)"

    # Check if SKILL.md exists
    if [ ! -f "$skill_path/SKILL.md" ]; then
        echo "❌ Error: SKILL.md not found in $skill_path"
        return 1
    fi

    # Run validation before packaging
    echo "🔍 Validating skill..."
    if ! validate_skill "$skill_path"; then
        echo "   Please fix the validation errors before packaging."
        return 1
    fi
    echo "✅ Skill is valid!"
    echo ""

    # Determine output location
    local skill_name
    skill_name="$(basename "$skill_path")"

    if [ -n "$output_dir" ]; then
        mkdir -p "$output_dir"
        output_dir="$(cd "$output_dir" && pwd)"
    else
        output_dir="$(pwd)"
    fi

    local skill_filename="$output_dir/$skill_name.skill"

    # Create the .skill file (zip format)
    # Check if zip command exists
    if ! command -v zip &> /dev/null; then
        echo "❌ Error: 'zip' command not found. Please install zip utility."
        return 1
    fi

    # Remove existing file if it exists
    if [ -f "$skill_filename" ]; then
        rm "$skill_filename"
    fi

    # Create the zip file
    cd "$(dirname "$skill_path")" || return 1

    if zip -r -q "$skill_filename" "$skill_name"; then
        echo "✅ Successfully packaged skill to: $skill_filename"
        return 0
    else
        echo "❌ Error creating .skill file"
        return 1
    fi
}

main() {
    if [ $# -lt 1 ]; then
        echo "Usage: package_skill.sh <path/to/skill-folder> [output-directory]"
        echo ""
        echo "Example:"
        echo "  package_skill.sh skills/public/my-skill"
        echo "  package_skill.sh skills/public/my-skill ./dist"
        exit 1
    fi

    local skill_path="$1"
    local output_dir="$2"

    echo "📦 Packaging skill: $skill_path"
    if [ -n "$output_dir" ]; then
        echo "   Output directory: $output_dir"
    fi
    echo ""

    if package_skill "$skill_path" "$output_dir"; then
        exit 0
    else
        exit 1
    fi
}

main "$@"
