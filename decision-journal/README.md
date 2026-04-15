# Decision Journal — Claude Code Skill

A standalone, general-purpose Claude Code skill for tracking significant project decisions, rejected approaches, experiment outcomes, and reasoning trails.

## What it does

Every project accumulates decisions that are hard to reconstruct later: "Why did we choose Redis over Memcached?", "Did we already try LRU eviction?", "What tradeoffs did we accept when picking a monorepo?" Git tracks _what_ changed. This skill tracks **why**, **what else was considered**, and **when to revisit**.

It operates in four modes:

| Mode | Trigger | Output |
|------|---------|--------|
| **Record** | "Record a decision: we chose X because Y" | Creates a structured decision file + updates the index |
| **Query** | "Have we tried X?" / "Why did we choose Y?" | Summaries of matching decisions with file paths |
| **Review** | "What decisions need revisiting?" | Actionable list of stale, experimental, or triggered decisions |
| **Summarize** | "Give me the decision history for feature X" | Narrative summary connecting related decisions over time |

Claude will also gently nudge you to record a decision when it detects a significant choice being made in conversation (e.g., choosing between two libraries with explicit tradeoffs). Nudges are rare and non-intrusive — decline once and it won't ask again for the same decision.

## What it is NOT

- **Not a changelog.** Git logs track what changed. This tracks why.
- **Not a task tracker.** No work items, sprints, or TODOs.
- **Not a session log.** Session continuity belongs to skills like `project-historian`.

## Storage structure

All data lives in your project repo under a `decisions/` directory, organized by category:

```
your-project/
├── decisions/
│   ├── INDEX.md
│   ├── architecture/
│   │   └── 2026-03-15-event-driven-over-polling.md
│   ├── library-choice/
│   │   └── 2026-03-20-chose-redis-over-memcached.md
│   ├── performance/
│   └── tradeoff/
├── .decision-journal.yml  ← optional config
└── ... (your project files)
```

The skill repo contains only the skill definition and templates. Your project's decisions stay in your project.

## How to link it to a project

### Claude Code

Add the skill to your Claude Code configuration. The skill lives in its own repo and is referenced by path:

```bash
# If the skill is checked out locally
claude skill add /path/to/decision-journal

# Or reference it in your .claude/skills/ directory
cp -r /path/to/decision-journal ~/.claude/skills/decision-journal
```

### Claude Desktop / claude.ai

If using a skill-loading mechanism, point it at the `SKILL.md` file in this repo.

## Configuration (optional)

Create a `.decision-journal.yml` at your project root to customize behavior:

```yaml
# All fields are optional. Defaults shown.
decisions_dir: decisions
categories:
  - architecture
  - library-choice
  - algorithm
  - convention
  - infrastructure
  - performance
  - tradeoff
  - my-custom-category     # add your own
review_threshold_days: 90   # flag stale decisions after this many days
default_tags: []            # auto-applied to every new decision
```

If this file doesn't exist, sensible defaults apply. The skill will never create it for you.

## Usage examples

### Recording a decision

> **You:** We're going with k6 for load testing. Locust was the other option but our team knows JS better and we didn't want the Python dependency.
>
> **Claude:** This looks like a decision worth recording. Want me to log it to the decision journal?
>
> **You:** Yes.
>
> **Claude:** Created `decisions/library-choice/2026-03-25-k6-over-locust.md`. I also found a related decision about standardizing on JavaScript from February — want me to cross-link them?

### Querying past decisions

> **You:** Have we looked at Locust before?
>
> **Claude:** Yes — it was evaluated and rejected on 2026-03-25:
>
> **k6 over Locust** (rejected-alternative)
> Rejected due to Python dependency concerns and team's JS expertise.
> → `decisions/library-choice/2026-03-25-k6-over-locust.md`

### Reviewing decisions

> **You:** What needs revisiting?
>
> **Claude:** 2 decisions need attention:
> 1. **Redis eviction strategy** (experimental, 142 days) — no final status. Suggest benchmarking current hit rates.
> 2. **JWT 24h expiry** (accepted, 180 days) — revisit trigger was "if we add mobile clients", and you did last month.

### Summarizing history

> **You:** Summarize our caching decisions.
>
> **Claude:** Your caching strategy evolved through three phases: you started with Redis + TTL in October, experimented with LRU eviction in November (still marked experimental), and rejected an L1 local cache in February due to invalidation complexity…

## Cross-skill compatibility

This skill focuses exclusively on decisions and reasoning. It coexists cleanly with:

- **project-historian** — handles session-level context. Decision-journal won't duplicate session tracking.
- **ticket-architect** — handles per-ticket ADRs. If a ticket-level ADR is significant enough for long-term reference, the skill may suggest also recording it in the decision journal.

These integrations only activate if you've explicitly configured those skills alongside decision-journal.

## File overview

```
decision-journal/
├── SKILL.md                    # Main skill instructions for Claude
├── README.md                   # This file
└── templates/
    ├── decision.md             # Template for individual decision files
    └── INDEX.md                # Template for the decision index
```
