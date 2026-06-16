#!/usr/bin/env bash
# Detection logic from SKILL.md "Backend" section, extracted for testing.
# Echoes the resolved backend ("github" or "file") on stdout.
# Warnings go to stderr.
#
# Usage: detect_backend.sh <path-to-tasks/RUNE.md>
#
# Exit codes:
#   0 — resolved (read stdout for backend)
#   2 — RUNE.md missing (caller must run setup)

set -u

rune_md="${1:-tasks/RUNE.md}"

if [[ ! -f "$rune_md" ]]; then
  echo "RUNE.md not found at $rune_md — run setup-time prompts" >&2
  exit 2
fi

# Parse `backend:` line. Tolerate whitespace and inline comments.
configured="$(grep -E '^[[:space:]]*backend:' "$rune_md" \
  | head -1 \
  | sed -E 's/^[[:space:]]*backend:[[:space:]]*//; s/[[:space:]]*#.*$//; s/[[:space:]]*$//')"

# Empty or missing → default github.
if [[ -z "$configured" ]]; then
  configured="github"
fi

# Unknown values → treat as github (default) per SKILL.md.
case "$configured" in
  github|file) ;;
  *)
    echo "warn: unknown backend '$configured' in $rune_md — defaulting to github" >&2
    configured="github"
    ;;
esac

if [[ "$configured" == "file" ]]; then
  echo "file"
  exit 0
fi

# configured=github → verify gh CLI + github remote.
if ! command -v gh >/dev/null 2>&1; then
  echo "warn: gh CLI not available — falling back to file backend" >&2
  echo "file"
  exit 0
fi

if ! gh repo view --json nameWithOwner >/dev/null 2>&1; then
  echo "warn: no GitHub remote detected — falling back to file backend" >&2
  echo "file"
  exit 0
fi

echo "github"
