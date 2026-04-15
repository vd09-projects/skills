#!/bin/bash
# Bootstrap a Go repository with quality tooling.
# Usage: bash bootstrap.sh [project-name] [project-description]
#
# This script:
# 1. Copies .golangci.yml to the repo root
# 2. Generates CLAUDE.md from template
# 3. Copies CI workflow to .github/workflows/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$SKILL_DIR/assets"
REPO_ROOT="${REPO_ROOT:-.}"

PROJECT_NAME="${1:-$(basename "$(cd "$REPO_ROOT" && pwd)")}"
PROJECT_DESC="${2:-A Go project.}"

echo "Bootstrapping Go quality tooling for: $PROJECT_NAME"
echo "=================================================="

# 1. Copy golangci-lint config
if [ -f "$REPO_ROOT/.golangci.yml" ]; then
    echo "[skip] .golangci.yml already exists. Remove it first to regenerate."
else
    cp "$ASSETS_DIR/.golangci.yml" "$REPO_ROOT/.golangci.yml"
    echo "[done] Created .golangci.yml"
fi

# 2. Generate CLAUDE.md from template
if [ -f "$REPO_ROOT/CLAUDE.md" ]; then
    echo "[skip] CLAUDE.md already exists. Remove it first to regenerate."
else
    sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
        -e "s/{{PROJECT_DESCRIPTION}}/$PROJECT_DESC/g" \
        "$ASSETS_DIR/CLAUDE.md.template" > "$REPO_ROOT/CLAUDE.md"
    echo "[done] Created CLAUDE.md"
fi

# 3. Copy CI workflow
WORKFLOW_DIR="$REPO_ROOT/.github/workflows"
if [ -f "$WORKFLOW_DIR/go-quality.yml" ]; then
    echo "[skip] .github/workflows/go-quality.yml already exists."
else
    mkdir -p "$WORKFLOW_DIR"
    cp "$ASSETS_DIR/go-quality.yml" "$WORKFLOW_DIR/go-quality.yml"
    echo "[done] Created .github/workflows/go-quality.yml"
fi

echo ""
echo "Bootstrap complete. Next steps:"
echo "  1. Edit CLAUDE.md to add repo-specific rules and architecture docs"
echo "  2. Run 'golangci-lint run ./...' to see current lint status"
echo "  3. Commit the new files"
