---
name: decision-journal
description: >
  Track significant project decisions, rejected approaches, experiment outcomes, and reasoning trails.
  Use this skill whenever someone records a decision, asks "have we tried X?", "why did we choose Y?",
  wants to review stale or experimental decisions, or needs a narrative summary of decision history.
  Also trigger with a gentle nudge when you detect a significant architectural, library, algorithm,
  or infrastructure choice being made mid-conversation — but only for choices someone might question
  or revisit months later. Do NOT trigger for trivial choices (variable names, formatting preferences,
  routine config). This skill is NOT a changelog, task tracker, or session log.
---

# Decision Journal

Track every significant decision, rejected approach, experiment outcome, and reasoning trail across a project's lifetime. The goal: prevent re-exploring dead ends, preserve the "why" behind choices, and make it possible — months later — to answer "Did we already try X? Why did we choose Y over Z?"

## What belongs here (and what doesn't)

Record a decision when:
- Someone might ask "why did we do it this way?" in 3 months
- An approach was evaluated and rejected (especially with data or reasoning)
- A tradeoff was consciously made between competing options
- An experiment produced results worth preserving
- A convention or standard was established that affects future work

Do NOT record:
- Routine, obvious, or trivial choices
- Git-level changes (that's what commits are for)
- Session-level context (that belongs to session-continuity skills like project-historian)
- Task/work-item tracking (that belongs to ticket-management skills like ticket-architect)

## Storage structure

Decisions live in a `decisions/` directory at the project root, organized by category:

```
decisions/
├── INDEX.md              # YAML-based lookup index
├── architecture/
│   └── 2026-03-15-event-driven-over-polling.md
├── library-choice/
│   └── 2026-03-20-chose-redis-over-memcached.md
├── algorithm/
├── convention/
├── infrastructure/
├── performance/
└── tradeoff/
```

The category subdirectories above are defaults. Projects can define custom categories via `.decision-journal.yml` (see Configuration section). Create subdirectories on demand — don't pre-create empty ones.

File naming: `YYYY-MM-DD-short-slug.md`

## Configuration

If a `.decision-journal.yml` file exists at the project root, read it for overrides. If it doesn't exist, use defaults. Never create this file unless the user asks.

```yaml
# .decision-journal.yml (all fields optional)
decisions_dir: decisions          # default: decisions
categories:                       # default: architecture, library-choice, algorithm, convention, infrastructure, performance, tradeoff
  - architecture
  - library-choice
  - algorithm
  - custom-category
review_threshold_days: 90         # flag decisions older than this for review (default: 90)
default_tags: []                  # tags auto-applied to every decision
```

## Decision template

Read the template from `templates/decision.md` in the skill directory. When creating a new decision, only three fields are required: **Title**, **Context**, and **Decision**. Fill in everything you can infer from the conversation, leave the rest blank or omit optional sections entirely. The user can flesh out details later.

## INDEX.md format

INDEX.md uses a YAML-based format for machine-friendly querying. Read the template from `templates/INDEX.md` in the skill directory.

Each entry looks like:

```yaml
- id: 2026-03-15-event-driven-over-polling
  title: "Chose event-driven architecture over polling"
  date: 2026-03-15
  status: accepted
  category: architecture
  tags: [events, rabbitmq, polling, scalability]
  path: architecture/2026-03-15-event-driven-over-polling.md
  summary: "Adopted event-driven pattern with RabbitMQ for real-time updates instead of periodic polling."
```

When updating INDEX.md, preserve the existing YAML structure. Add new entries at the top (most recent first). Always include the one-line `summary` field.

---

## Modes of operation

### 1. Record

**Triggers**: User says "record a decision", "log this decision", "we decided to…", or you detect a significant choice in conversation.

**Proactive nudge behavior**: If you detect a significant decision being made (e.g., "let's go with Redis over Memcached because..."), offer a brief nudge:
> "This looks like a decision worth recording. Want me to log it to the decision journal?"

Only nudge when the choice is non-trivial and involves rejected alternatives or explicit tradeoffs. Don't nudge more than once per conversation unless the user is making clearly distinct decisions. If the user declines, move on — don't ask again for the same decision.

**Steps**:

1. Read `.decision-journal.yml` if it exists to get config overrides.
2. Extract from conversation context: the decision, alternatives considered, reasoning, and any data/metrics mentioned.
3. Determine the category. If ambiguous, ask the user (suggest your best guess).
4. Generate a filename: `YYYY-MM-DD-short-slug.md` using today's date.
5. Create the decision file in `decisions/<category>/`, filling in all fields you can infer. Required: Title, Context, Decision. Leave optional sections blank if not inferrable.
6. Auto-suggest related decisions: scan INDEX.md for entries with overlapping tags or similar titles. If matches are found, present them to the user and ask whether to add cross-links. Only insert Related Decisions links after user approval.
7. Update INDEX.md with the new entry at the top.
8. If this decision supersedes an existing one:
   - Automatically update the old decision's status to `superseded`
   - Add a forward-link in the old decision's Related Decisions section pointing to the new one
   - Update the old entry's status in INDEX.md

**Example interaction**:
```
User: "We decided to use k6 for load testing instead of Locust. k6 has better JS scripting support, 
       and our team already knows JavaScript. Locust's Python dependency was a concern."

Claude: I'll record that. A couple of related decisions I found:
  - 2026-02-10-javascript-as-primary-scripting (architecture) — your earlier choice to standardize on JS
  
  Should I link this new decision to that one?

User: Yes, link it.

Claude: Done. Created decisions/library-choice/2026-03-25-k6-over-locust.md and updated INDEX.md.
```

### 2. Query

**Triggers**: "Have we tried…?", "Why did we choose…?", "Show me all decisions about…", "What did we reject for…?", any question about past decisions.

**Search strategy**: Start with INDEX.md. Parse the YAML entries and filter by the relevant combination of tags, category, status, title, and summary text. Only open individual decision files if:
- The INDEX.md summary doesn't contain enough detail to answer the question
- The user asks for full context, pros/cons, or experiment data
- Fewer than 3 matches are found (cheap to open them all)

**Response format**: Brief summaries with file paths. For each matching decision, show:
- Title, date, status
- The one-line summary from INDEX.md
- File path for the user to dig deeper

If a decision was rejected, prominently highlight the rejection reason so the user doesn't re-explore a dead end.

**Example interaction**:
```
User: "Have we considered Locust for load testing?"

Claude: Yes — we evaluated and rejected it:

  **k6 over Locust** (2026-03-25, rejected-alternative)
  Locust was rejected due to Python dependency concerns and the team's JS expertise.
  → decisions/library-choice/2026-03-25-k6-over-locust.md

  Want me to pull up the full pros/cons analysis?
```

### 3. Review

**Triggers**: "What decisions need revisiting?", "Show me stale decisions", "Decision review", or periodically when the user asks for a project health check.

**What to surface** (as an actionable list with concrete next steps):

1. **Revisit-later**: Decisions with status `revisit-later` — show the revisit trigger condition if set.
2. **Stale experimentals**: Decisions with status `experimental` that are older than `review_threshold_days` (default 90) and never got updated to a final status.
3. **Triggered revisits**: Decisions with a `revisit_trigger` field whose conditions may now be relevant (use your judgment based on project context).
4. **Aging decisions**: Accepted decisions older than `review_threshold_days` with revisit triggers — flag if the trigger condition might be met.

**Response format**: An actionable list. For each decision, show the title, age, why it's flagged, and a suggested next action (e.g., "Confirm this is still the right approach", "Run updated benchmarks", "Promote to accepted or reject").

**Example interaction**:
```
User: "What decisions need revisiting?"

Claude: Found 3 decisions that need attention:

  1. **Redis cache eviction strategy** (experimental, 142 days old)
     → No final status set. Suggested action: benchmark current hit rates and promote to accepted or reject.
     → decisions/performance/2025-11-10-redis-eviction-lru.md

  2. **Monorepo structure** (revisit-later)
     → Revisit trigger: "Reconsider if team grows beyond 5 engineers"
     → decisions/architecture/2025-12-01-monorepo-structure.md

  3. **JWT token expiry at 24h** (accepted, 180 days old)
     → Revisit trigger: "Revisit if we add mobile clients" — you added mobile support last month.
     → decisions/convention/2025-10-15-jwt-24h-expiry.md
```

### 4. Summarize

**Triggers**: "Summarize all decisions about…", "Decision history for…", "Give me context on…", onboarding-style requests.

**Response format**: A narrative summary — a coherent story of how decisions evolved over time, not just a list. Connect the dots: show how early decisions influenced later ones, where the team changed direction and why, and what the current state of thinking is.

**Example interaction**:
```
User: "Summarize the decision history for our caching layer"

Claude: Your caching strategy evolved through three phases:

  In October 2025, you initially chose Redis with a simple TTL-based approach 
  (decisions/infrastructure/2025-10-05-redis-for-caching.md). The primary driver 
  was team familiarity and the need for pub/sub alongside caching.

  By November, cache hit rates were lower than expected, so you experimented with 
  LRU eviction (decisions/performance/2025-11-10-redis-eviction-lru.md). That 
  experiment is still marked as experimental — it might be worth finalizing.

  In February 2026, you evaluated adding a local L1 cache in front of Redis but 
  rejected it due to invalidation complexity with your event-driven architecture
  (decisions/tradeoff/2026-02-15-l1-cache-rejected.md).

  Current state: Redis with LRU eviction (experimental). No local caching layer.
```

---

## Cross-skill awareness

This skill may coexist with other skills in the same project. It focuses exclusively on decisions and their reasoning — not session continuity, task decomposition, or operational context.

If the user has explicitly configured one of these skills alongside decision-journal:
- **project-historian**: Handles session-level context and project knowledge. Decision-journal does NOT duplicate session tracking. If a user asks "what happened in my last session?", that's project-historian's job. If they ask "why did we choose X?", that's decision-journal's job.
- **ticket-architect**: Handles per-ticket ADRs and task decomposition. If a ticket-level ADR represents a significant, reusable project decision (not just a ticket-scoped choice), suggest that the user also record it in the decision journal for long-term discoverability.

Only reference these skills if the user has mentioned them or they're visibly present in the project. Don't assume they exist.

---

## Maintenance notes

- When editing any decision file, always keep INDEX.md in sync.
- When a decision is superseded, update both the old file and INDEX.md in the same operation.
- If a category subdirectory doesn't exist yet, create it when writing the first decision in that category.
- Never delete decision files. Rejected and superseded decisions are valuable history.
- Keep INDEX.md entries in reverse chronological order (newest first).
