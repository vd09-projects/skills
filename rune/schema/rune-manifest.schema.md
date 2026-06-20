# rune.md Schema

Every skill that wants Rune support adds a `rune.md` at its root.

Rune discovers skills by scanning `~/.claude/skills/` and `.claude/skills/` (and parent directories
up to repo root) for directories containing `SKILL.md`. For each found skill directory, it checks
for `rune.md`. If present, reads it. No central registry — pure filesystem discovery.

Template paths are relative to the skill's own directory (the same directory `rune.md` lives in).

---

## Required fields

### `memory_path`
Relative path from project root where Rune writes memory files. Must end in `/`.
```
## memory_path
`.claude/skill-memory/sindri/`
```

---

### `question_blocks`
Which question blocks Rune asks for this skill. Three tiers:

```
## question_blocks

required:
  - project-identity    ← must answer before Phase 2; block on unanswered criticals
  - tech-stack

recommended:
  - domain-rules        ← asked in Phase 1; TBD acceptable → confidence: MED
  - architecture

deferrable:
  - quality-bar         ← skipped in Phase 1; Sindri surfaces these during use
  - conventions
```

**Valid block IDs** (from `rune/references/questions.md`):

| ID | Topic |
|---|---|
| `project-identity` | What is this project? Greenfield or existing? |
| `domain-rules` | Invariants, business rules, terminology, gotchas |
| `tech-stack` | Languages, frameworks, DB, infra, key libraries |
| `architecture` | Modules, boundaries, data flow, forbidden patterns |
| `quality-bar` | Test strategy, done definition, performance targets |
| `conventions` | Error handling, logging, config, naming |
| `team-process` | Team size, reviewers, urgency, domain persona |
| `out-of-scope` | What this project and skill should NOT do |
| `notes-system` | Notes destination, MCP/markdown, concept buckets, depth bias (knowledge skills) |

Unknown IDs → `Unknown block ID: [id] in {skill_path}/rune.md` — Rune skips that block.

---

### `files`
Table declaring output files and their templates.

```
## files

| output | template | description |
|---|---|---|
| `config.md` | `templates/sindri/config.template.md` | Per-skill config |
```

- `output` — filename written inside `memory_path`. Per-skill only — files are scoped to the owning skill. Cross-skill knowledge belongs in `CLAUDE.md` (rune's primary output), not in any skill's memory directory.
- `template` — path to template **relative to this skill's root** (Rune reads from `{skill_path}/{template}`)
- `description` — shown in draft output header

Template must exist. Rune errors with `Template not found: {skill_path}/{template}` if missing.

**Why per-skill only:** skills are independent. A skill's memory is its private state (preferences, learned patterns). Domain knowledge, conventions, and architecture context that multiple skills need go into `CLAUDE.md` — the platform-level convention that every skill already reads. No skill should reach into another skill's memory directory.

---

## Optional fields

### `notes`
Free text. Shown in Rune's Phase 0 summary for that skill.

---

## Validation errors

| Error | Cause |
|---|---|
| `Missing memory_path` | Field absent |
| `Template not found: {path}` | Template file missing from skill directory |
| `Unknown block ID: {id}` | ID not in valid list |
| `Missing files table` | `rune.md` has no files declared |

---

## Minimal valid rune.md

```markdown
# Rune Manifest — My Skill

## memory_path
`.claude/skill-memory/my-skill/`

## question_blocks
required:
  - project-identity
  - tech-stack

recommended:
  - team-process

deferrable:
  - quality-bar

## files
| output | template | description |
|---|---|---|
| `config.md` | `templates/my-skill/config.template.md` | Project config |
```
