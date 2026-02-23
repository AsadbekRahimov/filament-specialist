#!/bin/bash

# Rebuild Filament v5 Documentation References
# This script clones the official FilamentPHP v5 documentation
# from GitHub and organizes it into the references/ directory.
#
# Usage: bash rebuildFilamentDocs.sh
#
# Requirements: git, find

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFERENCES_DIR="$SCRIPT_DIR/references"
TEMP_DIR=$(mktemp -d)
BRANCH="5.x"

echo "=== Rebuilding Filament v5 Documentation ==="
echo "Branch: $BRANCH"
echo "Target: $REFERENCES_DIR"
echo ""

# Clean existing references
echo "Cleaning existing references..."
rm -rf "$REFERENCES_DIR"
mkdir -p "$REFERENCES_DIR"

# Clone the repository (shallow clone for speed)
echo "Cloning filamentphp/filament ($BRANCH branch)..."
git clone --depth 1 --branch "$BRANCH" https://github.com/filamentphp/filament.git "$TEMP_DIR/filament"

echo "Organizing documentation..."

# Copy main docs as 'general'
if [ -d "$TEMP_DIR/filament/docs" ]; then
    cp -r "$TEMP_DIR/filament/docs" "$REFERENCES_DIR/general"
    echo "  - Copied docs/ -> general/"
fi

# Copy package-specific docs
for package_dir in "$TEMP_DIR/filament/packages"/*/; do
    package_name=$(basename "$package_dir")
    if [ -d "$package_dir/docs" ]; then
        cp -r "$package_dir/docs" "$REFERENCES_DIR/$package_name"
        echo "  - Copied packages/$package_name/docs/ -> $package_name/"
    fi
done

# Remove non-markdown files (keep only .md files)
echo "Removing non-markdown files..."
find "$REFERENCES_DIR" -type f ! -name "*.md" -delete

# Remove .github directories
find "$REFERENCES_DIR" -type d -name ".github" -exec rm -rf {} + 2>/dev/null || true

# Remove empty directories
find "$REFERENCES_DIR" -type d -empty -delete 2>/dev/null || true

# Clean up temp directory
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

# Report results
echo ""
echo "=== Documentation Rebuild Complete ==="
echo ""
echo "Directory structure:"
find "$REFERENCES_DIR" -type d | sort | head -30
echo ""
MD_COUNT=$(find "$REFERENCES_DIR" -name "*.md" -type f | wc -l)
echo "Total markdown files: $MD_COUNT"
echo ""
echo "Top-level directories:"
ls -1 "$REFERENCES_DIR"
