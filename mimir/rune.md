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

Mimir implements the generic handoff protocol (spec at `_shared/handoff-protocol.md`
in the skills repo — documentation for skill authors, not loaded at runtime).
Mimir declares `producer_role: planner` and never names a specific consumer skill.
Protocol behavior is encoded inline in Mimir's SKILL.md.

Mimir reads project context only from `CLAUDE.md` — never reaches into other
skills' memory directories. Cross-skill context (domain rules, conventions,
architecture, gotchas) lives in CLAUDE.md sections written by Rune.

Mimir does not invoke other skills. An orchestrator (agent in `.claude/agents/`,
or the user) sequences which skill runs after Mimir produces its artifact.
