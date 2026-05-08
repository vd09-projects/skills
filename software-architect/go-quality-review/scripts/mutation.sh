#!/bin/bash
# Run mutation testing on Go packages.
# Usage: bash mutation.sh [package-path]
# Example: bash mutation.sh ./pkg/auth/...
#
# Tries gremlins first (preferred), falls back to go-mutesting.
# Reports mutation score and surviving mutants.

set -euo pipefail

TARGET="${1:-./...}"

echo "Running mutation testing on: $TARGET"
echo "======================================"

# Check for gremlins (preferred)
if command -v gremlins &> /dev/null; then
    echo "Using gremlins..."
    echo ""
    gremlins unleash "$TARGET" 2>&1
    exit $?
fi

# Check for go-mutesting (fallback)
if command -v go-mutesting &> /dev/null; then
    echo "Using go-mutesting..."
    echo ""
    go-mutesting "$TARGET" 2>&1
    exit $?
fi

# Neither found
echo ""
echo "No mutation testing tool found. Install one:"
echo ""
echo "  Option 1 (preferred):"
echo "    go install github.com/go-gremlins/gremlins@latest"
echo ""
echo "  Option 2:"
echo "    go install github.com/zimmski/go-mutesting/cmd/go-mutesting@latest"
echo ""
echo "Then re-run this script."
exit 1
