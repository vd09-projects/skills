# Rune Manifest — Multi-Perspective Review

Rune reads this file to know how to set up MPR's skill memory.
Template paths are relative to this skill's root directory.

## memory_path

`.claude/skill-memory/multi-perspective-review/`

## question_blocks

required:
  - project-identity
  - tech-stack

recommended:
  - team-process

deferrable:
  - quality-bar
  - domain-rules
  - architecture
  - conventions
  - out-of-scope

## files

| output | template | description |
|---|---|---|
| `config.md` | `templates/multi-perspective-review/config.template.md` | Reviewer overrides, project context |

## notes

MPR config needs project identity, stack, and team context only.
Domain rules and architecture feed Sindri's domain.md — MPR consumes
the aggregate context from CLAUDE.md.
