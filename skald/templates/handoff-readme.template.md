# Handoff Directory

This directory holds the audit trail of every meaningful planning, building, and reviewing event in this project. Skald (the orchestrator skill) maintains it. Humans read it.

If you joined the team and someone said "go read the handoff dir to get up to speed" — this README explains how.

**One thing to know up front:** producer skills (mimir, sindri, multi-perspective-review, etc.) don't know about this directory. They produce natural markdown output. Skald reads their output, classifies it by the title line (`# Architecture: ...`, `# Task plan: ...`, `# Build summary: ...`, `# Review findings: ...`), wraps it with metadata, and writes the canonical file here. The on-disk format is skald's concern; producer skills stay focused on their craft.

---

## How to navigate

### "What's in flight right now?"

Open `INDEX.md`. One row per scope. Sorted by most recently updated. Status column tells you what state each scope is in.

### "What happened recently across the project?"

Open `LOG.md`. Append-only chronology. One row per skill invocation. Newest at bottom.

### "What's the full story of one piece of work?"

Open `{slug}/_thread.md`. Narrative log for one scope. Dated entries with summaries. Reads like a project journal for that one piece of work.

### "I want to see the actual plan / build / review artifact"

Open the canonical file in the scope dir:

- `{slug}/planner-architecture.md` — architecture-level plan (option compare, tradeoffs, recommendation, success metric, switch trigger)
- `{slug}/planner-task.md` — task-level breakdown (ordered steps, test strategy, success metric)
- `{slug}/implementation-build.md` — what was built (files changed, tests added, quality gate result)
- `{slug}/review-findings.md` — review findings from multi-perspective review

Each file is the LATEST version. Prior versions are in `{slug}/_history/`.

### "I want to see how this plan evolved"

Open `{slug}/_history/`. Every prior version of every canonical artifact is preserved as `{canonical}-v{N}.md`. Files never deleted.

---

## Directory layout

```
.claude/handoff/
├── README.md                              # this file
├── INDEX.md                               # per-scope status table
├── LOG.md                                 # append-only chronology
├── {slug-1}/
│   ├── _thread.md                         # narrative log for this scope
│   ├── planner-architecture.md            # canonical, latest version
│   ├── planner-task.md
│   ├── implementation-build.md
│   ├── review-findings.md
│   └── _history/
│       ├── planner-architecture-v1.md
│       └── planner-architecture-v2.md
├── {slug-2}/
│   └── ...
└── ...
```

---

## How artifacts are named

Filename = `{producer_role}-{plan_type}.md`. This is "canonical" — there is exactly one of each per scope at any time. Iteration archives the prior to `_history/`.

| Producer role | Plan type | Canonical filename | Title line skald looks for |
|---|---|---|---|
| `planner` | `architecture` | `planner-architecture.md` | `# Architecture: ...` |
| `planner` | `task` | `planner-task.md` | `# Task plan: ...` |
| `implementation` | `build` | `implementation-build.md` | `# Build summary: ...` |
| `review` | `findings` | `review-findings.md` | `# Review findings: ...` |

The role is generic. Multiple skills may implement the same role (e.g., both `mimir` and a future `mimir-light` could produce architecture artifacts). The on-disk filename does NOT encode the skill name — that keeps the persistence layer decoupled from specific producers.

Skald uses its `skill_registry` (in `.claude/skill-memory/skald/config.md`) to map skill name → producer role + supported plan types. When a new skill is added to the project, its registry entry must be set so skald can classify its output.

---

## Status lifecycle

Every artifact has a `status` field in its frontmatter:

- **`draft`** — just written. Not yet safe to consume. User must review and approve.
- **`approved`** — user (or an approving agent) flipped status to `approved`. Safe to consume.
- **`consumed`** — a downstream skill used this as scope and finished. Future consumers skip.

To approve an artifact: edit the file, change `status: draft` to `status: approved`, save. That's it. No magic commands.

Iteration: when a producer re-runs (e.g., reviewer asked for changes), the prior version moves to `_history/` and the new version starts at `status: draft` again. Re-approve.

---

## Scope (slug) registry

Every scope has a slug like `auth-redesign`, `payment-refund`, `rate-limiter`. The reasoning for each slug — why this name vs alternatives — is recorded in `.claude/skill-memory/skald/scopes.md`.

When someone asks "why is this called `auth-redesign` and not `jwt-rotation`?", read `scopes.md`.

---

## Don'ts

- **Don't delete files.** Everything is audit trail. If a scope is dead, mark it `status: archived` in the scope registry. The dir stays.
- **Don't rename canonical files freehand.** They are computed deterministically. Renaming breaks consumers.
- **Don't edit `_history/` files.** Frozen.
- **Don't write to `INDEX.md` or `LOG.md` by hand.** Skald maintains them. Manual edits will be overwritten.
- **Don't move scope dirs without also updating `scopes.md`.** They must stay in sync.

---

## Common questions

### "How do I know if the plan is up to date?"

`updated` timestamp in the frontmatter. Latest version always at the canonical path; older versions in `_history/`.

### "There are 5 versions of `planner-architecture.md` in _history. Which one did we ship?"

The version that was `status: approved` AND then `status: consumed`. Walk `_history/` newest-first; the one with `status: consumed` is what the implementation used as scope.

### "What if two skills tried to write the same canonical file at the same time?"

Skald handles iteration atomically: read current version → archive → write new. Concurrent writes are serialized by skald. If two skills declare the same role in the same project (e.g., two `planner` skills), one will always lose to the other — fix this by configuring one to be the project's planner in skald config.

### "Can I add my own files to this dir?"

Anything outside the protocol-managed files is technically allowed. But it's strongly discouraged — the dir's value is its predictability. Use `decisions/` (separate dir) for cross-cutting decision records; use `tasks/` for backlog tracking. Keep `.claude/handoff/` clean.

### "Where do decisions live?"

A future `decisions/` directory at the project root (NOT under `.claude/handoff/`) will hold cross-cutting decision records, categorized by type (architecture, convention, tradeoff, etc.). Not part of v2 MVP — coming in a separate change.

---

## For tooling / scripts

Programmatic readers can rely on:

- Filename: `.claude/handoff/{slug}/{producer_role}-{plan_type}.md` is stable.
- Frontmatter: YAML, required fields per `skald/references/handoff-protocol.md` schema.
- `INDEX.md` if `index_format: yaml` is set in skald's config — machine-readable.

For grep-able queries across the whole project:

```bash
# what's approved but not yet consumed?
grep -l "status: approved" .claude/handoff/*/*.md \
  | xargs grep -l "consumer_role:" \
  | xargs grep -L "status: consumed"

# what's the latest version of each canonical?
find .claude/handoff -name "*.md" -not -path "*/_history/*"

# what's the iteration count for a given scope?
ls .claude/handoff/{slug}/_history/ | wc -l
```
