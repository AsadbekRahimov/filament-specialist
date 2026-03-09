#!/bin/bash

# Uninstall Filament v5 Specialist skills from Claude Code

set -e

SKILLS_DIR="$HOME/.claude/skills"

echo "=== Uninstalling Filament v5 Specialist Skills ==="
echo ""

REMOVED=0
for link in "$SKILLS_DIR"/filament-*/; do
    link_name=$(basename "$link")
    if [ -L "$SKILLS_DIR/$link_name" ]; then
        echo "  Removing: $link_name"
        rm "$SKILLS_DIR/$link_name"
        REMOVED=$((REMOVED + 1))
    fi
done

echo ""
echo "Removed $REMOVED skills from $SKILLS_DIR"
