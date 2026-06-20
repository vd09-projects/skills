# Rune Manifest — Note Builder

Rune reads this file to know how to set up Note Builder's skill memory.
Template paths are relative to this skill's root directory.

## memory_path

`.claude/skill-memory/note-builder/`

## question_blocks

required:
  - notes-system

recommended:
  - project-identity
  - out-of-scope

deferrable:
  - team-process

## files

| output | template | description |
|---|---|---|
| `config.md` | `templates/note-builder/config.template.md` | Notes destination, MCP/markdown mode, concept buckets, depth bias, freshness format |

## notes

Note Builder owns only its own filing config. The notes themselves live in Notion
(or markdown), never in skill-memory. Domain knowledge belongs in the notes, not here.

`memory_path` is project-level (Rune's model). Note Builder also reads an optional
global default at `~/.claude/skill-memory/note-builder/config.md` — the project
config, when present, overrides the global one field-by-field. Set the global file
once (Notion destination rarely changes per-project); run Rune per-project only when
a project files notes somewhere different.
