# Plan

Standalone planning skill. Declares role `planner` in the handoff protocol. Produces handoff artifacts at `.claude/handoff/{timestamp}-{plan_type}-{slug}.md` for any consumer skill (implementation, domain-expert, or none) to read.

Two depth levels: `architecture` (option compare) and `task` (ordered breakdown). No code, ever.

Decoupled by design: plan does not know which skill will consume the artifact, does not read other skills' memory, does not invoke other skills. It writes per protocol, declares `consumer_role`, and stops. Orchestration (an agent in `.claude/agents/`, or the user) sequences what runs next.

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
ln -s /path/to/skills/plan .claude/skills/plan
```

Or personal install (available across all projects):

```bash
ln -s /path/to/skills/plan ~/.claude/skills/plan
```

Claude Code auto-discovers skills from `.claude/skills/` — no config needed.

Install alongside `rune` to generate `config.md` automatically.

## Skill memory

Plan reads per-project preferences from `.claude/skill-memory/plan/config.md`. Fields: `default_depth`, `domain_expert_role`. Without it, safe defaults apply.

Plan reads project context only from `CLAUDE.md` (the Claude Code platform convention). It never reaches into other skills' memory directories — that would be cross-skill coupling. Domain knowledge, architecture rules, conventions: all live in CLAUDE.md as structured sections.

**Recommended: use `rune` to generate the config and CLAUDE.md.**

**Manual setup:**

```bash
mkdir -p .claude/skill-memory/plan

cp /path/to/skills/plan/templates/plan/config.template.md \
   .claude/skill-memory/plan/config.md
```

## Handoff protocol

Plan implements the generic handoff protocol. The protocol spec lives at `_shared/handoff-protocol.md` in the skills repo as documentation for skill authors. Plan does not load the spec at runtime — protocol behavior is encoded inline in plan's SKILL.md. Plan declares `producer_role: planner` and sets `consumer_role` per artifact based on plan content and configuration.

Any consumer skill that declares a matching role and obeys the protocol can consume plan's artifacts. Plan does not name or invoke consumer skills.

## Artifact layout

```
.claude/handoff/
├── 20260520-143022-architecture-auth-redesign.md   (status: approved)
├── 20260520-150155-task-payment-refund.md          (status: consumed)
├── 20260521-091012-task-rate-limiter.md            (status: draft)
└── 20260521-110000-architecture-data-model.md      (status: approved)
```

- One file per artifact. Filename: `{YYYYMMDD-HHMMSS}-{plan_type}-{slug}.md`.
- Multiple artifacts coexist (parallel work on different tasks).
- Files are never deleted by the protocol. Directory listing IS the history.
- Consumers scan the directory, filter by `consumer_role` + `status: approved`, match by `scope_hint`.

## Artifact lifecycle

1. Plan writes a new file with `status: draft`, `producer_role: planner`, and a derived `consumer_role`.
2. User reviews. Edits `status: draft` → `status: approved` manually when ready.
3. A consumer skill scans `.claude/handoff/`, finds approved artifacts matching its role + current scope, and uses one as scope.
4. Consumer writes `status: consumed` back to the file after use.
5. File stays in the directory forever — audit trail.

Plan never auto-approves its own output.

## Parallel work

Two task plans in flight = two files. Two architectural decisions under review = two files. Filenames make them distinct by timestamp + slug. The directory holds all of them simultaneously. No singleton bottleneck.

When plan detects a scope overlap with an existing `draft`/`approved` artifact (same `plan_type` + similar `scope_hint`), it prompts the user via the Scope Collision Flow: update existing, create new alongside, or cancel.

## Terminal states

- `Plan ready.` — artifact written, filename announced, routing in frontmatter.
- `Needs discussion.` — options exist but no clear winner; artifact written with `consumer_role: none`.
- `Blocked — need input.` — cannot produce sensible plan without specified info. No artifact written.

No skill names appear in plan output.

## Orchestration

Plan does not orchestrate. After `Plan ready.`, the orchestrator decides what runs next:

- An agent in `.claude/agents/` (e.g., `coordinator.md`, `build-session.md`) reads the artifact, waits for user approval, then invokes the matching consumer skill.
- User invokes a consumer skill manually; the consumer scans `.claude/handoff/` and finds the approved artifact via `scope_hint` matching.
- User reads the artifact and decides manually.

Plan is agnostic to which path is taken. See `_shared/agent-pattern.md` for orchestrator recipes.
