# Rune Manifest — Mimir

Rune reads this file to know how to set up Mimir's skill memory.
Template paths are relative to this skill's root directory.

## memory_path

`.claude/skill-memory/mimir/`

## question_blocks

required:
  - project-identity

recommended:
  - team-process
  - out-of-scope

deferrable:
  - architecture
  - domain-rules

## files

| output | template | description |
|---|---|---|
| `config.md` | `templates/mimir/config.template.md` | Planning preferences — default depth, domain-expert routing, overlay preferences |

## notes

Mimir produces natural markdown output and stops. It does not write files,
does not emit structured metadata, does not manage scopes or filenames.
Mimir's output format is its own published interface — see Mimir's SKILL.md
Output section.

Mimir reads project context only from `CLAUDE.md` — never reaches into other
skills' memory directories. Cross-skill context (domain rules, conventions,
architecture, gotchas) lives in CLAUDE.md sections written by Rune.

Mimir does not invoke other skills. Caller sequences whatever happens after
Mimir produces its plan.
