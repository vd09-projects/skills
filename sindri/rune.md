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
| `domain.md` | `templates/sindri/domain.template.md` | Domain invariants, rules, gotchas |
| `config.md` | `templates/sindri/config.template.md` | Language, scope, quality overrides |
| `patterns.md` | `templates/sindri/patterns.template.md` | Hot spots, false positives, debt |
