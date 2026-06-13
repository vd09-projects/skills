# Skald

Norse chronicler. Orchestrator + persistence layer for the handoff protocol v2.

Invoke a named producer skill, capture its output, persist into the per-scope handoff layout. Maintains scope dirs, idempotent canonical filenames, `_history/` archive for iterations, `INDEX.md` table, `LOG.md` chronology, and a scope registry with reasoning.

Skills produce content. Skald records.

## When to use

- "Run mimir on auth-redesign and persist the output."
- "Iterate the architecture plan — bump version, archive prior."
- "Capture sindri's build output under the existing scope."
- "Show me the current INDEX of in-flight work."

## Skip if

- The work is throwaway in-session scratch. No durable artifact wanted.
- The target skill is not a producer under the handoff protocol (no `producer_role` declared).

## Installation

```bash
ln -s /path/to/skills/skald .claude/skills/skald
```

## Skill memory

Skald reads per-project preferences from `.claude/skill-memory/skald/config.md` and the scope registry from `.claude/skill-memory/skald/scopes.md`.

Bootstrap with `rune` or copy the templates manually:

```bash
mkdir -p .claude/skill-memory/skald
cp /path/to/skills/skald/templates/skald/config.template.md \
   .claude/skill-memory/skald/config.md
cp /path/to/skills/skald/templates/skald/scopes.template.md \
   .claude/skill-memory/skald/scopes.md
```

## Handoff layout (v2)

```
.claude/handoff/
├── README.md                      # team-readable schema doc
├── INDEX.md                       # per-scope table
├── LOG.md                         # append-only chronology
└── {slug}/
    ├── _thread.md                 # narrative
    ├── planner-architecture.md    # canonical, latest version
    ├── planner-task.md
    ├── implementation-build.md
    ├── review-findings.md
    └── _history/
        └── planner-architecture-v1.md
```

Canonical filename = `{producer_role}-{plan_type}.md`. Re-running the same role on the same scope archives the prior version into `_history/` and writes a new canonical.

## How it differs from v1

- v1 wrote flat files: `.claude/handoff/{date}-{plan_type}-{slug}.md`. Hard to answer "what happened on scope X?" without scanning many files.
- v2 organizes by scope dir. One scope = one dir. Indices answer cross-scope queries.
- v1 had producers write their own files. v2 producers emit content; skald writes.
- v1 had no canonical iteration history. v2 keeps every version under `_history/` forever.

## Direct invocation

```
skald run mimir "plan the auth redesign — JWT vs opaque tokens"
skald run sindri --scope auth-redesign "build the rotating JWT path"
skald run multi-perspective-review --scope auth-redesign "review the current diff"
```

## Agent invocation

An outer orchestrator agent invokes skald per step, never writes handoff files directly. See `references/agent-pattern.md`.

## Status aggregation

`INDEX.md` shows a derived status per scope (e.g., `arch-approved`, `build-in-progress`, `review-pending`). See `SKILL.md` Status Aggregation table.
