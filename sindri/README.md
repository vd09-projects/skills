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

Sindri reads per-project memory from `.claude/skill-memory/sindri/` in the target project. Project context (domain rules, conventions, gotchas) lives in CLAUDE.md — Sindri reads that as the cross-skill context source. Sindri's own memory holds only sindri-specific preferences and learned patterns.

**Recommended: use `rune` to generate CLAUDE.md and Sindri's memory files.**
Rune grills you about the project then writes CLAUDE.md plus per-skill memory in one pass.

**Manual setup:** Copy templates from this skill's own `templates/` directory:

```bash
mkdir -p .claude/skill-memory/sindri

cp /path/to/skills/sindri/templates/sindri/config.template.md \
   .claude/skill-memory/sindri/config.md

cp /path/to/skills/sindri/templates/sindri/patterns.template.md \
   .claude/skill-memory/sindri/patterns.md
```

| File | Purpose |
|---|---|
| `CLAUDE.md` (project root) | Domain rules, conventions, gotchas — cross-skill context |
| `config.md` | Sindri-specific: language, scope limits, quality overrides |
| `patterns.md` | Sindri-specific: grows through use — hot spots, false positives, debt |

Per-skill `domain.md` is no longer used. Domain content moved to CLAUDE.md sections (Domain Rules, Invariants, Conventions, Gotchas) — read by every skill via Claude Code's platform convention. If your project has a legacy `.claude/skill-memory/sindri/domain.md`, move its content into CLAUDE.md sections and delete the legacy file. Sindri no longer reads it.

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
    config.template.md          ← starter for config.md
    patterns.template.md        ← starter for patterns.md
rune.md                         ← Rune manifest (memory path, question blocks, files)
```

## With a domain persona skill

If the project has a domain persona skill (e.g., `algo-trading-lead-dev`), Sindri defers to it for domain judgment calls. Set `domain_persona` in `config.md` to name it.
