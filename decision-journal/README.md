# Decision Journal — Claude Skill

A standalone, general-purpose Claude skill for tracking significant project decisions, rejected approaches, experiment outcomes, and reasoning trails. Operates both as a direct-use skill and as the harvest infrastructure for inline decision marks made by other producer skills.

## What it does

Every project accumulates decisions that are hard to reconstruct later: "Why did we choose Redis over Memcached?", "Did we already try LRU eviction?", "What tradeoffs did we accept when picking a monorepo?" Git tracks _what_ changed. This skill tracks **why**, **what else was considered**, and **when to revisit**.

It operates in five modes:

| Mode | Trigger | Output |
|------|---------|--------|
| **Record** | "Record a decision: we chose X because Y" | Creates a structured decision file + updates the index |
| **Query** | "Have we tried X?" / "Why did we choose Y?" | Summaries of matching decisions with file paths |
| **Review** | "What decisions need revisiting?" | Actionable list of stale, experimental, or triggered decisions |
| **Summarize** | "Give me the decision history for feature X" | Narrative summary connecting related decisions over time |
| **Harvest** | "Harvest decisions" / end of conversation with inline marks present | Extracts inline decision marks from the conversation and converts each to a decision file |

The journal will gently nudge in two cases: when it detects a significant choice being made in conversation that wasn't recorded (Record nudge), or when inline decision marks are present at end of conversation but haven't been harvested (Harvest nudge). Each is offered once per conversation; declining stops the nudge for that conversation.

## What it is NOT

- **Not a changelog.** Git logs track what changed. This tracks why.
- **Not a task tracker.** No work items, sprints, or TODOs.
- **Not a session log.** Session continuity belongs elsewhere.

## Two ways the journal gets used

**Standalone** — the user records and queries decisions directly through the modes above.

**As infrastructure** — other skills (developers, researchers, reviewers, anyone making decisions worth preserving) mark decisions inline in their responses using the format spec in `references/inline-format.md`. At end of conversation, the journal's Harvest mode extracts those marks and turns them into decision files.

Both modes coexist. Producer skills do not need to know the journal is installed; their inline marks are valuable conversation-level annotations even without harvest. Conversely, the journal does not need to know which producer skills are installed; any inline mark matching the format spec is harvestable.

## Inline decision marking — the format

Producer skills mark decisions inline using a format like this:

```
**Decision (2026-04.1.0) — convention: experimental**
scope: engine/accounting
tags: money, types, decimal
owner: priya

All money values use shopspring/decimal; float64 is reserved for statistics 
and indicators.
```

The full format specification — including the lead-in regex, metadata keys, parsing algorithm, and versioning policy — lives in `references/inline-format.md`. Producer skills that want to honor the format can either reference this file directly or maintain a compact local subset. The format is producer-agnostic; any skill following the spec can have its marks harvested.

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
│   ├── algorithm/
│   ├── convention/
│   ├── infrastructure/
│   ├── performance/
│   └── tradeoff/
├── .decision-journal.yml  ← optional config
└── ... (your project files)
```

The skill repo contains only the skill definition, the format spec, and templates. Your project's decisions stay in your project.

## How to install

### Claude Code

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

If this file doesn't exist, sensible defaults apply. The skill will never create it for you. Categories not in the list are accepted on demand — the config defines defaults, not hard constraints.

## Usage examples

### Recording a decision (standalone)

> **You:** We're going with k6 for load testing. Locust was the other option but our team knows JS better and we didn't want the Python dependency.
>
> **Claude:** This looks like a decision worth recording. Want me to log it to the decision journal?
>
> **You:** Yes.
>
> **Claude:** Created `decisions/library-choice/2026-03-25-k6-over-locust.md`. I also found a related decision about standardizing on JavaScript from February — want me to cross-link them?

### Harvesting inline marks (after a conversation with producer skills)

> **You:** That conversation has a few decisions in it. Harvest them.
>
> **Claude:** I found 3 inline decision marks in this conversation:
>
> 1. [convention/experimental] scope: engine/accounting — "All money values use shopspring/decimal..." (owner: priya)
> 2. [algorithm/experimental] scope: sizing — "Half-Kelly with drawdown scaling..." (owner: marcus)
> 3. [architecture/experimental] (no scope) — "CPCV will live at internal/cv/cpcv as a sibling..."
>
> Should I write all of these as decision files?
>
> **You:** Yes.
>
> **Claude:** Harvested 3 decisions:
> - `decisions/convention/2026-04-15-money-as-decimal.md` (new)
> - `decisions/algorithm/2026-04-15-half-kelly-drawdown-scaling.md` (new)
> - `decisions/architecture/2026-04-15-cpcv-package-location.md` (new)
>
> Updated INDEX.md.

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

## File overview

```
decision-journal/
├── SKILL.md                    # Main skill instructions for Claude
├── README.md                   # This file
├── references/
│   └── inline-format.md        # Canonical inline decision-mark format spec (loaded by Harvest mode)
└── templates/
    ├── decision.md             # Template for individual decision files
    └── INDEX.md                # Template for the decision index
```

## License

See `LICENSE` if present in the repo.
