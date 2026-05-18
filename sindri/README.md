# Sindri

Generic implementation skill. Language-aware (Go, Python, TypeScript, React, Next.js, CSS), domain-aware via per-project skill memory. Covers plan → build → iterate → spike workflow with consistent quality gates.

## Installation

Copy or symlink into `.claude/skills/`:

```bash
ln -s /path/to/skills/sindri .claude/skills/sindri
```

Or personal install (available across all projects):

```bash
ln -s /path/to/skills/sindri ~/.claude/skills/sindri
```

Claude Code auto-discovers skills from `.claude/skills/` — no config needed.

Install alongside `rune` — Rune generates Sindri's skill memory automatically.

## Skill memory

Sindri reads per-project memory from `.claude/skill-memory/sindri/` in the target project. Without it, works on generic principles — with it, applies your domain conventions automatically.

**Recommended: use `rune` to generate these files.**
Rune grills you about the project then writes all memory files in one pass.

**Manual setup:** Copy templates from this skill's own `templates/` directory:

```bash
mkdir -p .claude/skill-memory/sindri

cp /path/to/skills/sindri/templates/sindri/domain.template.md \
   .claude/skill-memory/sindri/domain.md

cp /path/to/skills/sindri/templates/sindri/config.template.md \
   .claude/skill-memory/sindri/config.md

cp /path/to/skills/sindri/templates/sindri/patterns.template.md \
   .claude/skill-memory/sindri/patterns.md
```

| File | Purpose |
|---|---|
| `domain.md` | Domain invariants, rules, gotchas — Sindri's source of truth |
| `config.md` | Language, scope limits, quality overrides |
| `patterns.md` | Grows through use — hot spots, false positives, debt |

## What's in this skill

```
SKILL.md                        ← skill entrypoint
references/
  languages/
    go.md                       ← Go patterns
    python.md                   ← Python patterns
    typescript.md               ← TypeScript/JavaScript patterns
    react.md                    ← React patterns
    nextjs.md                   ← Next.js patterns
    css.md                      ← CSS patterns
  phases.md                     ← Plan / Build / Iterate / Spike discipline
  quality-gates.md              ← Universal quality bar
templates/
  sindri/
    domain.template.md          ← starter for domain.md
    config.template.md          ← starter for config.md
    patterns.template.md        ← starter for patterns.md
rune.md                         ← Rune manifest (memory path, question blocks, files)
```

## With a domain persona skill

If the project has a domain persona skill (e.g., `algo-trading-lead-dev`), Sindri defers to it for domain judgment calls. Set `domain_persona` in `config.md` to name it.
