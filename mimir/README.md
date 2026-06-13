# Mimir

Named after the Norse god of wisdom whose well Odin consulted before fateful decisions — Mimir charged a price for wisdom and refused cheap answers. This skill keeps that character: asks before recommending, refuses to plan without constraints.

Standalone planning skill. Produces markdown plans and stops. Caller handles what happens next.

Two depth levels: `architecture` (option compare) and `task` (ordered breakdown). No code, ever.

Decoupled by design: Mimir does not know which skill (if any) will consume the plan, does not read other skills' memory, does not invoke other skills. It produces markdown output and stops.

## When to use

- "How should we approach X?" (architecture)
- "Plan refactor of {module}" (task)
- "Break down this ticket: {paste}" (task)
- "Compare options for Y" (architecture)
- Pasting a multi-task initiative that needs scoping

**Skip if:** you already know the approach and want to build (use an implementation skill directly). You want to review existing code (use a review skill). You're mid-build and need to re-plan one task (use the implementation skill's own plan mode).

## Installation

Copy or symlink into `.claude/skills/`:

```bash
ln -s /path/to/skills/mimir .claude/skills/mimir
```

Or personal install (available across all projects):

```bash
ln -s /path/to/skills/mimir ~/.claude/skills/mimir
```

Claude Code auto-discovers skills from `.claude/skills/` — no config needed.

Install alongside `rune` to generate `config.md` automatically.

## Skill memory

Mimir reads per-project preferences from `.claude/skill-memory/mimir/config.md`. Fields: `default_depth`, `domain_expert_role`, `always_overlays`, `never_overlays`. Without it, safe defaults apply.

Mimir reads project context only from `CLAUDE.md` (the Claude Code platform convention). It never reaches into other skills' memory directories — that would be cross-skill coupling. Domain knowledge, architecture rules, conventions: all live in CLAUDE.md as structured sections.

**Recommended: use `rune` to generate the config and CLAUDE.md.**

**Manual setup:**

```bash
mkdir -p .claude/skill-memory/mimir

cp /path/to/skills/mimir/templates/mimir/config.template.md \
   .claude/skill-memory/mimir/config.md
```

## Handoff awareness — none

Mimir produces markdown output and stops. It does not write files, does not emit structured metadata, does not manage scope or filenames.

## Parallel work

Mimir produces one plan per invocation. Multiple concurrent plans are independent conversations.

## Terminal states

- `Plan ready.` — output emitted to caller. User approves when ready.
- `Needs discussion.` — options exist but no clear winner; output still emitted.
- `Blocked — need input.` — cannot produce sensible plan without specified info. No output emitted.

No skill names appear in Mimir's output.

## Orchestration

Mimir does not orchestrate. After plan is ready, caller decides what to do next.
