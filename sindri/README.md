# Sindri

Generic implementation skill. Language-aware (Go, Python, TypeScript, React, Next.js, CSS), domain-aware via per-project skill memory. Covers plan → build → iterate → spike workflow with consistent quality gates.

## Installation

Link this directory as a skill in the target project's `.claude/settings.json`:

```json
{
  "skills": [
    "/path/to/skills/sindri"
  ]
}
```

## Skill memory (optional but recommended)

The skill reads per-project memory from `.claude/skill-memory/sindri/` in the target project repo. Without it the skill works fine on generic principles — with it, it applies your project's domain conventions automatically.

Three files, all optional. Copy from `templates/` and fill in:

| Template | Copy to (in project repo) | Purpose |
|---|---|---|
| `templates/sindri/domain.template.md` | `.claude/skill-memory/sindri/domain.md` | Domain invariants, architectural rules, known gotchas. The skill reads this before writing any code. |
| `templates/sindri/config.template.md` | `.claude/skill-memory/sindri/config.md` | Language version, scope limits, quality overrides, interrogation defaults. |
| `templates/sindri/patterns.template.md` | `.claude/skill-memory/sindri/patterns.md` | Grows over time — learned patterns, known hot spots, accepted debt. |

### Setup for a new project

```bash
mkdir -p .claude/skill-memory/sindri

cp /path/to/skills/sindri/templates/sindri/domain.template.md \
   .claude/skill-memory/sindri/domain.md

cp /path/to/skills/sindri/templates/sindri/config.template.md \
   .claude/skill-memory/sindri/config.md

cp /path/to/skills/sindri/templates/sindri/patterns.template.md \
   .claude/skill-memory/sindri/patterns.md
```

Then fill in the domain and config files. Leave patterns.md mostly empty — it grows through use.

## What's in this skill

```
SKILL.md                        ← skill entrypoint (loaded on activation)
references/
  languages/
    go.md                       ← Go patterns (loaded when Go detected)
    python.md                   ← Python patterns
    typescript.md               ← TypeScript/JavaScript patterns
    react.md                    ← React patterns (loaded alongside typescript.md)
    nextjs.md                   ← Next.js patterns (loads react.md too)
    css.md                      ← CSS patterns (loaded on styling changes)
  phases.md                     ← Plan / Build / Iterate / Spike discipline
  quality-gates.md              ← Universal quality bar
templates/
  sindri/
    domain.template.md          ← starter for domain.md
    config.template.md          ← starter for config.md
    patterns.template.md        ← starter for patterns.md
```

## With a domain persona skill

If the project also has a domain persona skill (e.g., `algo-trading-lead-dev`), the implement skill defers to it for domain judgment calls. Set `domain_persona` in `config.md` to name it.
