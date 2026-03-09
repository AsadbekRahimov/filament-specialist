#!/bin/bash

# Install Filament v5 Specialist skills for Claude Code
#
# This script creates symlinks from the skill folders in this repo
# to ~/.claude/skills/ so Claude Code can discover them.
#
# Usage: bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"

echo "=== Installing Filament v5 Specialist Skills ==="
echo ""

# Create skills directory if it doesn't exist
mkdir -p "$SKILLS_DIR"

# Find and symlink all skill directories (those containing SKILL.md)
INSTALLED=0
for skill_dir in "$SCRIPT_DIR"/filament-*/; do
    skill_name=$(basename "$skill_dir")
    if [ -f "$skill_dir/SKILL.md" ]; then
        if [ -L "$SKILLS_DIR/$skill_name" ]; then
            echo "  Updating: $skill_name"
            rm "$SKILLS_DIR/$skill_name"
        elif [ -d "$SKILLS_DIR/$skill_name" ]; then
            echo "  Skipping: $skill_name (directory already exists, not a symlink)"
            continue
        else
            echo "  Installing: $skill_name"
        fi
        ln -s "$skill_dir" "$SKILLS_DIR/$skill_name"
        INSTALLED=$((INSTALLED + 1))
    fi
done

echo ""
echo "Installed $INSTALLED skills to $SKILLS_DIR"
echo ""
echo "Available slash commands:"
echo "  /filament-resource    - Generate CRUD resources"
echo "  /filament-form        - Create form schemas"
echo "  /filament-table       - Create table configurations"
echo "  /filament-action      - Generate actions with modals"
echo "  /filament-widget      - Create dashboard widgets"
echo "  /filament-infolist    - Generate read-only displays"
echo "  /filament-test        - Generate Pest tests"
echo "  /filament-notification - Create notifications"
echo "  /filament-dashboard   - Create dashboard pages"
echo "  /filament-docs        - Search documentation"
echo "  /filament-diagnose    - Diagnose Filament issues"
echo ""
echo "To uninstall, run: bash uninstall.sh"
