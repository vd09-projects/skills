# Rune Manifest — Sindri

Rune reads this file to know how to set up Sindri's skill memory.
Template paths are relative to this skill's root directory.

## memory_path

`.claude/skill-memory/sindri/`

## question_blocks

required:
  - project-identity
  - tech-stack

recommended:
  - domain-rules
  - architecture
  - out-of-scope

deferrable:
  - quality-bar
  - conventions
  - team-process

## files

| output | template | description |
|---|---|---|
| `config.md` | `templates/sindri/config.template.md` | Sindri-specific: language, scope, quality overrides |
| `patterns.md` | `templates/sindri/patterns.template.md` | Sindri-specific: hot spots, false positives, debt |

## notes

Sindri owns only its own preferences and learned patterns. Domain knowledge,
architecture rules, conventions, and other cross-skill context belong in
`CLAUDE.md` (Rune's primary output, read by every skill via Claude Code's
platform convention).

Earlier versions generated a per-skill `domain.md`. That concept is removed —
domain content lives in `CLAUDE.md` as structured sections instead. Projects
upgrading from prior versions should move any `.claude/skill-memory/sindri/domain.md`
content into `CLAUDE.md` sections (e.g., `## Domain Rules`, `## Invariants`,
`## Gotchas`) and delete the legacy file. Sindri no longer reads it.
