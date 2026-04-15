---
name: software-architect
description: "Use this skill whenever a user has a problem to solve, a feature to build, or a large ambiguous task. Triggers include: I want to build X, help me design this, break this into tasks, plan this feature, I have this problem, architect this solution. This skill runs through three phases — problem framing, architecture design, and ticket breakdown — with explicit user gates between phases. Always use this skill before coding begins on any non-trivial feature."
---

# Software Architect

Three-phase skill that takes a rough idea from problem to actionable tickets.

```
Phase 1 — Problem Framing      → PROPOSED-SOLUTIONS.md → SOLUTION.md
Phase 2 — Architecture Design  → ARCHITECTURE.md
Phase 3 — Ticket Breakdown     → TASK.md + TASK-REASONING.md
```

Each phase produces a file. Each phase ends with a gate — the user confirms before the next phase begins. The discussion log (DISCUSSION.md) is maintained across all three phases.

## Output folder structure

```
{ticket-slug}/
├── DISCUSSION.md           ← questions asked, answers given, all versions
├── PROPOSED-SOLUTIONS.md   ← all options explored, written during Step 1.2 (Phase 1 draft)
├── SOLUTION.md             ← chosen solution only, written after user decides (Phase 1 final)
├── ARCHITECTURE.md         ← system design, repo decisions, open questions (Phase 2 output)
├── TASK.md                 ← milestones + ordered subtasks (Phase 3 output)
└── TASK-REASONING.md       ← decisions, assumptions, risks (updated across all phases)
```

---

## DISCUSSION.md — the conversation log

This file is written across all phases. It never gets reset — only appended to.

Every question session gets a versioned block. When priorities shift or the conversation tilts, a new version block is added with a note explaining why the previous direction changed.

See `references/discussion-template.md` for the full format.

**Rules:**
- Every question asked must be logged here before being asked
- Every answer must be logged when received
- If a priority shift causes previously-answered questions to become stale, mark them `[SUPERSEDED]` and add a new block explaining the shift
- Keep all versions — the audit trail is the point

---

## Phase 1 — Problem Framing

**Goal:** Understand the problem clearly. Explore solution options. Pick one with the user.

**Output:** `PROPOSED-SOLUTIONS.md` (draft, Step 1.2) → `SOLUTION.md` (final, Step 1.4)

### Step 1.1 — Ask clarifying questions (interactive)

Before proposing anything, understand what you're dealing with.

**Grouping rule:** Group 2–4 related questions together. Ask them in one message. Based on answers, decide if follow-up questions are needed or if you have enough to proceed. Never dump more than 4 questions at once — it feels like a form. Never ask one question at a time unless a single answer has significant branching implications.

**Log every question and answer in DISCUSSION.md before moving on.**

**Before asking anything:** If the user provided a PRD, problem statement, brief, or any written context, read it first and extract what's already answered. Only ask about what's genuinely missing or ambiguous. If the written context is thorough, you may be able to skip straight to Step 1.2. If something important is unclear or missing even after reading it, ask — don't stay silent to avoid asking questions.

Questions to cover (group 2–4 related ones per message, skip any already answered in provided context):

- What is the desired end state? What changes in the world when this is done?
- What currently happens without this? Who or what is affected?
- Is there a deadline, dependency, or sequencing constraint with other work?
- Is there an existing system/repo this connects to or replaces?
- What's the most important constraint: speed, reliability, cost, simplicity?
- Are there non-obvious stakeholders (other teams, external systems, users)?

After each answer round, assess:
- Do you have enough to propose solutions? → proceed to Step 1.2
- Are there critical unknowns that block even scoping? → ask one more focused round

### Step 1.2 — Propose solution options and write PROPOSED-SOLUTIONS.md

Produce 2–3 solution approaches. **Write `PROPOSED-SOLUTIONS.md` immediately** using the template in `references/solution-template.md` — all options go in with `Status: DRAFT`. Then present a concise summary in chat.

For each option in PROPOSED-SOLUTIONS.md:

```
### Option {N}: {Name}

**How it works:** {1–3 sentences}

**Fits well when:** {condition}

**Tradeoffs:**
- Pro: {reason}
- Pro: {reason}
- Con: {reason}
- Con: {reason}

**Key risks:** {what could go wrong}

**Architectural implication:** {Few sentences — e.g., "Requires new service; touches auth-service and user-db" or "All in existing repo, no new infra"}

**Status:** DRAFT
```

After writing PROPOSED-SOLUTIONS.md, present a brief summary in chat and end with a recommendation: "I'd go with Option N because..." — but make clear the user decides.

**The file is the record, not the chat.**

### Step 1.3 — User picks a direction

User selects or modifies an option. Log their choice in DISCUSSION.md.

If they have modifications or a hybrid, incorporate them and confirm understanding before writing SOLUTION.md.

### Step 1.4 — Write SOLUTION.md

Write `SOLUTION.md` with only the chosen solution — a clean, final record of what was decided and why. It should be readable without needing to reference PROPOSED-SOLUTIONS.md.

Include:
- The chosen option (full detail)
- `**Why this over the others:**` — direct comparison against what was rejected
- User modifications to the base option
- What this does NOT solve
- Open questions carrying into Phase 2

PROPOSED-SOLUTIONS.md is the exploration record. SOLUTION.md is the decision record. Both are kept.

**Gate:** Before proceeding to Phase 2, explicitly state:
> "SOLUTION.md is written. Ready to move to Phase 2 (Architecture Design)? Or do you want to adjust anything first?"

Do not start Phase 2 until the user confirms.

---

## Phase 2 — Architecture Design

**Goal:** Given the chosen solution, design the system. Decide what's new, what's reused, what's unknown.

**Output:** `ARCHITECTURE.md`

### Step 2.1 — Load known repos

Look for `repos.yaml` in this order:
1. `./{ticket-slug}/repos.yaml` — project-local (overrides global)
2. `~/.claude/repos.yaml` — global registry

If found, list the repos with their descriptions and ask: "Are any of these relevant to this solution? Should any others be added?"

If not found, ask the user to describe existing systems/repos that might be relevant. Offer to help them create a `repos.yaml` — see `references/repos-yaml-schema.md`.

### Step 2.2 — Design the system (interactive)

Produce an initial architecture proposal:

**For each existing repo that is relevant:**
1. Read its contents — look for: problem statement, README, ARCHITECTURE.md, TASK.md, any docs that describe what it does, what it's achieved, and what's coming next
2. Summarise your understanding: what problem it solves, its current architecture/flow, what it has built so far, and any upcoming work (open tickets, TODOs, planned features)
3. Produce an updated context doc for it inside the ticket folder: `{ticket-slug}/repos/{repo-name}-context.md` — so this understanding is durable and doesn't need to be re-derived next time

**For each new repo that needs to be created:**
1. Propose a name, home location, and initial structure
2. Create a starter doc: `{ticket-slug}/repos/{repo-name}-proposal.md` — covering the problem it solves, its scope, and what it should NOT do

Then address:
- What components are needed across all repos?
- What's the data/event flow between components?
- What are the integration points and their contracts?

Apply placement rules from `references/decision-framework.md` to classify each component.

Surface **open questions** explicitly — anything the architecture depends on but hasn't been resolved. Log them in DISCUSSION.md with category `OPEN` or `TO_OWNER`.

### Step 2.3 — User iterates

The user may:
- Change a placement decision
- Add/remove components
- Answer open questions
- Shift priorities

Log each iteration in DISCUSSION.md as a new version block. Update the architecture accordingly. Repeat until the user signals the design is stable.

### Step 2.4 — Write ARCHITECTURE.md

Use template in `references/architecture-template.md`.

Include:
- Component map (what exists, what's new)
- Repo placement decisions with rationale
- Data/event flow
- Open questions still unresolved
- What is explicitly out of scope for this architecture

**Gate:** Before proceeding to Phase 3, explicitly state:
> "ARCHITECTURE.md is written. Ready to move to Phase 3 (Ticket Breakdown)? Or do you want to iterate on the architecture first?"

Do not start Phase 3 until the user confirms.

---

## Phase 3 — Ticket Breakdown

**Goal:** Split the finalized architecture into milestones and trackable subtasks.

**Output:** `TASK.md` + `TASK-REASONING.md`

### Step 3.1 — Identify milestones

Read SOLUTION.md and ARCHITECTURE.md (and PROPOSED-SOLUTIONS.md if alternatives need revisiting). Group the work into milestones — logical phases where each milestone delivers something tangible (a working component, an integration, a deployed feature).

Rule: A milestone should be demonstrable. If you can't demo or test it independently, it's not a milestone yet.

### Step 3.2 — Decompose into subtasks

Within each milestone, decompose into subtasks. Apply these rules:

**Sizing:** Each subtask = one focused session. If you can't write a done-condition in one sentence, it's still too big.

**Dependency ordering:** Order by actual dependency graph, not by what "feels logical". The subtask with the fewest dependencies comes first.

**Ambiguity rule:** If a subtask has an unknown shape, replace it with a RESEARCH task that produces a decision document. The real implementation task follows.

**Communication rule:** Subtasks communicate via defined artifacts/events, not direct calls. Each has a clear OUTPUT the next one consumes as INPUT.

**Language rule:** If two subtasks use the same word to mean different things, they belong in different contexts.

### Step 3.3 — Apply placement and type classification

For every subtask, classify:

**Type:**
- `RESEARCH` — produces a decision or document, not code
- `SKILL` — LLM-invokable, stateless, reusable capability
- `MCP_SERVER` — wraps external system or maintains state
- `CODE` — deterministic transformation, job, or glue logic
- `ORCHESTRATOR` — sequences/routes other skills or steps
- `CONFIG` — environment, credentials, deployment

**Placement:**
- `NEW_REPO` — independent lifecycle, 2+ real consumers, different runtime
- `EXISTING_REPO:{name}` — same domain, same owner, meaningless without surrounding context
- `NEW_MODULE:{repo/path}` — distinct concern but not yet reusable outside this repo
- `EXTRACT_LATER` — keep in current repo, mark for future extraction

Full logic in `references/decision-framework.md`.

### Step 3.4 — Write TASK.md

Use template in `references/task-template.md`.

Subtasks are grouped under milestone headers. The dependency map spans across milestones. Parallel opportunities are called out explicitly.

### Step 3.5 — Write TASK-REASONING.md

Use template in `references/reasoning-template.md`.

Populate with decisions made across all three phases. Pull architecture decisions from ARCHITECTURE.md into ADR blocks. Pull open questions from DISCUSSION.md into the Questions Log.

### Step 3.6 — Pre-handoff checklist

Before outputting, verify:

- [ ] Every subtask has a done-condition expressible in one sentence without "and"
- [ ] No subtask does two unrelated things
- [ ] The first subtask in each milestone has no unmet dependencies
- [ ] All ambiguous areas have a RESEARCH task, not a fake implementation task
- [ ] Every architecture decision has an alternative considered
- [ ] All assumptions are explicitly listed
- [ ] Questions are categorised and have an owner or status
- [ ] Milestones are demonstrable independently

---

## Updating files after requirement changes

When requirements change after files are written:

**In DISCUSSION.md:**
- Add a new version block noting the priority shift and what changed
- Mark superseded questions `[SUPERSEDED by v{N}]`
- Never delete old versions

**In SOLUTION.md / ARCHITECTURE.md:**
- Add a changelog entry at the top
- Update affected sections, mark them `[CHANGED v{N}]`
- Keep previous reasoning visible with a note
- If a previously-rejected option from PROPOSED-SOLUTIONS.md becomes relevant again, note it explicitly

**In TASK.md:**
- Increment version header
- Mark changed subtasks `[CHANGED v{N}]` or `[ADDED v{N}]`

**In TASK-REASONING.md:**
- Add new Requirement History entry (never edit old ones)
- Re-evaluate affected architecture decisions
- Move invalidated assumptions to RESOLVED with a note

---

## Reference files

- `references/discussion-template.md` — DISCUSSION.md format
- `references/solution-template.md` — PROPOSED-SOLUTIONS.md and SOLUTION.md format
- `references/architecture-template.md` — ARCHITECTURE.md format
- `references/task-template.md` — TASK.md format with milestone groupings
- `references/reasoning-template.md` — TASK-REASONING.md format
- `references/decision-framework.md` — placement and classification logic
- `references/repos-yaml-schema.md` — repos.yaml format and examples
