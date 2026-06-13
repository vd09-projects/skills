# Rune Manifest — Skald

Rune reads this file to know how to set up Skald's skill memory.
Template paths are relative to this skill's root directory.

## memory_path

`.claude/skill-memory/skald/`

## question_blocks

required:
  - project-identity

recommended:
  - team-process

deferrable:
  - scope-conventions

## files

| output | template | description |
|---|---|---|
| `config.md` | `templates/skald/config.template.md` | Skald preferences — default owner, scope-naming style, index format overrides |
| `scopes.md` | `templates/skald/scopes.template.md` | Scope registry — slugs, titles, reasoning, aliases. Auto-grown by Skald; bootstrap empty |

Also seeds (one-shot):

| output | template | description |
|---|---|---|
| `.claude/handoff/README.md` | `templates/handoff-readme.template.md` | Team-readable schema doc placed at the handoff dir root. Lives at project level, not skill memory |
| `.claude/handoff/INDEX.md` | (generated empty header) | Per-scope table, populated as Skald runs |
| `.claude/handoff/LOG.md` | (generated empty header) | Append-only chronology |

## notes

Skald implements the handoff protocol v2 as the **orchestrator** role
(spec at `references/handoff-protocol.md` — documentation for skill
authors, not loaded at runtime). Protocol behavior is encoded inline
in Skald's SKILL.md.

Skald never names another skill in its output; it is invoked WITH a target
skill name as an argument. The target skill must declare `producer_role`
in its output frontmatter so Skald can compute the canonical filename.

Skald reads project context only from `CLAUDE.md` — never reaches into other
skills' memory directories. Cross-skill context lives in CLAUDE.md sections
written by Rune.
