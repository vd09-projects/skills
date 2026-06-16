---
name: task-manager
description: >
  Maintain a living, prioritized task backlog for any project — automatically generating tasks from
  coding sessions, tracking status, surfacing what to work on next, and re-prioritizing based on
  user input. Use this skill whenever the user mentions tasks, backlogs, "what should I work on",
  tracking work items, harvesting TODOs from a session, prioritizing work, decomposing tasks,
  reviewing open items, or any phrase like "add a task", "task:", "mark X as done", "what's next",
  "show backlog", "reprioritize", or "break this task down". Also trigger when a session is ending
  and there may be implicit tasks to capture, or when the user asks about blocked or stale work.
  This is NOT a Jira/Linear replacement — it's a lightweight task system for AI-assisted
  development workflows where tasks emerge organically from coding sessions. Default backend is
  GitHub issues in the repo where the skill is imported; falls back to local markdown files when
  no GitHub remote or `gh` CLI is available, configurable via `tasks/RUNE.md`.
---

# Task Manager

A lightweight task backlog for AI-assisted development. Answers two questions:
**"What should I do next?"** and **"What's the current state of all pending work?"**

Two backends: **GitHub issues** (default) and **local markdown files**. The backend is selected
in `tasks/RUNE.md`. Everything else (modes, rune classification, priorities) is identical across
backends — only the storage layer changes.

## Backend

`tasks/RUNE.md` holds a `backend:` field. Allowed values:

- `github` (default) — tasks are GitHub issues in the repo where this skill is imported. Issue
  number = task ID (`#42`). Status / priority / rune / source are encoded as labels. Acceptance
  criteria are GitHub task-list checkboxes in the issue body. Audit history comes from the
  issue timeline — no separate task log.
- `file` — tasks live in `tasks/BACKLOG.md` with the format defined below. A separate
  `tasks/TASK-LOG.md` records every operation.

**Detection on every invocation:**

1. Read `tasks/RUNE.md` `backend:` field. If missing, assume `github`.
2. If `github`: verify `gh` CLI is installed (`command -v gh`) AND `gh repo view --json nameWithOwner`
   succeeds in the project root. If both pass → use GitHub. If either fails → warn the user
   ("gh CLI not available / no GitHub remote — falling back to file backend") and proceed with the
   file backend.
3. If `file`: use the file backend. Do not touch `gh` even if installed.

This detection logic is mirrored in `tests/detect_backend.sh` and exercised by
`tests/test_backend_detection.sh`. Run that harness whenever the Backend section is edited.

If `tasks/` does not exist yet, initialize it from this skill's bundled `templates/` directory
(`tasks/RUNE.md` always; `BACKLOG.md`, `TASK-LOG.md`, `archive/` only when running in the file
backend). Confirm with the user before writing.

### GitHub backend — label scheme

Tasks are GitHub issues. The skill creates these labels on first use if they don't exist
(`gh label create --force` is idempotent):

| Axis | Labels |
|---|---|
| Priority | `priority:critical`, `priority:high`, `priority:medium`, `priority:low` |
| Rune | `rune:dev`, `rune:vibe`, `rune:research`, `rune:analysis` |
| Source | `source:session`, `source:decision`, `source:user`, `source:discovery` |
| Status (open issues only) | `status:in-progress`, `status:blocked` |
| Status (closed) | `status:cancelled` (otherwise = done) |

Status decoding:

- `todo` — open, no `status:*` label
- `in-progress` — open, `status:in-progress`
- `blocked` — open, `status:blocked` (plus `Blocked by #N` reference in the body)
- `done` — closed, no `status:cancelled` label
- `cancelled` — closed, `status:cancelled` label

### GitHub backend — issue body template

```
**Context:** <1-2 sentences on why this task exists>

**Acceptance criteria:**
- [ ] Specific, verifiable condition

**Blocked by:** #N or free-text reason (only when status:blocked)

**Notes:** optional extra context, links to decisions
```

Parent/child references live in Notes as `Parent: #N` and `Children: #N, #M`.

### File backend — storage layout

| File | Purpose |
|---|---|
| `tasks/BACKLOG.md` | Single source of truth — prioritized tasks grouped by status |
| `tasks/TASK-LOG.md` | Append-only changelog of every task operation with timestamps |
| `tasks/RUNE.md` | Repo-wide config (backend, default mode, sizing rubric, exceptions) |
| `tasks/archive/YYYY-MM.md` | Monthly archives for completed and cancelled tasks |

In the file backend, copy the bundled templates into `tasks/`; don't symlink — the project's
copies are edited directly.

**Reference files (loaded on demand, not auto-read):**

| File | Load when |
|---|---|
| `references/RUBRIC.md` | Mode 8 Rune does anything beyond default-and-go; Mode 7 Decompose-merge checks a cluster; Mode 6 Review backfills missing classes |

Reference files live alongside this SKILL.md inside the skill directory. They are not part of
`tasks/`. Read them explicitly when the procedure says to — don't preload.

**Setup-time prompts (run once on initialization):** After copying templates, ask the user:

1. **Backend** — "Where should tasks live?
   - **github** (default) — GitHub issues in this repo. Recommended when the repo has a GitHub
     remote and `gh` CLI is authenticated.
   - **file** — local markdown in `tasks/BACKLOG.md`. Use when offline-first or no GitHub remote."

   Write the answer to `backend:` in `tasks/RUNE.md`. If `github` is chosen, eagerly create the
   label set defined above.

2. **Default coding mode** — "What's this repo's default coding mode?
   - **dev** — tasks are 3-4 day chunks that ship meaningful problem slices
   - **vibe** — tasks are 1-subchunk atomic edits, no scaffolding, no speculative interfaces
   - **mixed** — both, classify per task"

   Write the answer to `default_mode:` in `tasks/RUNE.md`. Inherited by new tasks unless the user
   overrides per-task. If `mixed`, the Rune mode (below) asks every time.

## Task Format

**GitHub backend.** A task is a GitHub issue. ID = issue number (`#42`). Title = issue title.
Status / priority / rune / source are labels (see Backend section). Body uses the template above:
Context, Acceptance criteria (GitHub task-list checkboxes), Blocked by, Notes.

**File backend.** A task is a markdown block in `BACKLOG.md`:

```
### [TASK-NNNN] Short descriptive title

- **Status:** todo | in-progress | blocked | done | cancelled
- **Priority:** critical | high | medium | low
- **Rune:** dev | vibe | research | analysis
- **Created:** YYYY-MM-DD (Session NNN if session-continuity is linked, otherwise just the date)
- **Source:** session | decision | user | discovery
- **Blocked by:** [TASK-XXXX] or free-text reason (only when status is blocked)
- **Context:** 1-2 sentences on WHY this task exists
- **Acceptance criteria:**
  - [ ] Specific, verifiable condition
- **Notes:** Optional additional context, links to decisions, gotchas
```

**ID assignment:**
- GitHub backend — GitHub assigns the issue number; reuse it as the task ID. No padding.
- File backend — sequential, zero-padded to 4 digits (TASK-0001, TASK-0002, ...). To find the next
  ID, scan BACKLOG.md and all archive files for the highest existing ID, then increment by 1.

**Source values:**
- `session` — emerged during a coding session
- `decision` — spawned from a decision journal entry
- `user` — explicitly created by the user
- `discovery` — found during code review, testing, or exploration

## BACKLOG.md Structure (file backend only)

Tasks are organized into four sections, in this order. Priority ordering within each section
(critical → high → medium → low, and positional ordering within the same priority level).
The GitHub backend has no BACKLOG.md — `gh issue list` plus label filters serve the same role.

```
# Project Task Backlog
**Last updated:** YYYY-MM-DD | **Open tasks:** N | **Next up:** TASK-NNNN | **Runes:** D dev / V vibe / R research / A analysis

---

## In Progress       ← Currently being worked on (cap: 2-3 tasks)
## Up Next           ← Priority queue; top item = "what to work on next"
## Blocked           ← Each must state its blocker
## Todo (Backlog)    ← Lower-priority items, ordered by priority

---
_Completed and cancelled tasks are moved to tasks/archive/YYYY-MM.md_
```

**Always update the header stats** (open count, next-up ID, last-updated date, rune distribution)
after any mutation.

## GitHub backend — operation cheatsheet

Every mutating mode maps to a single `gh` invocation. Read-only modes use `gh issue list/view`
with label filters. Always pass `--repo $(gh repo view --json nameWithOwner -q .nameWithOwner)`
when running outside a checkout to avoid ambiguity; inside the checkout, omit `--repo`.

| Op | Command |
|---|---|
| Create task | `gh issue create --title "<t>" --body "<body>" --label "priority:<p>,rune:<r>,source:<s>"` |
| Set in-progress | `gh issue edit <N> --add-label status:in-progress` |
| Mark blocked | `gh issue edit <N> --add-label status:blocked --remove-label status:in-progress` (and edit body to add `Blocked by #M`) |
| Unblock / back to todo | `gh issue edit <N> --remove-label status:in-progress,status:blocked` |
| Mark done | `gh issue close <N> --reason completed` (acceptance criteria checkboxes must be ticked first) |
| Cancel | `gh issue close <N> --reason "not planned"` then `gh issue edit <N> --add-label status:cancelled` |
| Reopen | `gh issue reopen <N>` |
| Change priority | `gh issue edit <N> --remove-label priority:<old> --add-label priority:<new>` |
| Reclassify rune | `gh issue edit <N> --remove-label rune:<old> --add-label rune:<new>` |
| Add note | `gh issue comment <N> --body "<text>"` |
| List "Up Next" | `gh issue list --state open --label priority:critical,priority:high --search "-label:status:in-progress -label:status:blocked"` |
| List in-progress | `gh issue list --state open --label status:in-progress` |
| List blocked | `gh issue list --state open --label status:blocked` |
| Audit history | `gh issue view <N> --comments` plus `gh api repos/{owner}/{repo}/issues/<N>/events` |

`gh issue list` defaults to 30 results — pass `--limit 200` when scanning for grooming or stats.

## Modes

This skill operates in eight modes. Detect the mode from the user's intent — they won't always
name the mode explicitly. Every step below has two paths: **GitHub** and **File**. Pick the one
matching the active backend (see top of file).

---

### 1. Create

**Triggers:** "task:", "add a task", "create task for", "we need to handle X", or any mid-session
request that implies a new work item.

**Steps (shared):**

1. **Run Rune classification (Mode 8).** Pick `dev` / `vibe` / `research` / `analysis` from
   `tasks/RUNE.md` default + the request shape. If classification is ambiguous, ask. If the
   proposed scope contradicts the chosen rune (e.g. user says "vibe" but task is "design DataProvider
   interface"), refuse and propose the right rune — usually `research`, `analysis`, or `dev`.
2. Infer or ask for: title, priority, context, acceptance criteria. If the user gives a one-liner
   like `task: handle nil pointer in ParseCandle`, that's enough — infer medium priority, mark
   source as `session`, write a minimal context line from conversation, and add a single acceptance
   criterion. Speed matters here; don't interrupt flow.

**GitHub backend:**

3. Build the body using the issue template (Context, Acceptance criteria checkboxes, Notes).
4. `gh issue create --title "<title>" --body "<body>" --label "priority:<p>,rune:<r>,source:<s>"`.
   Capture the returned issue number — that's the task ID.
5. If the user said they're starting it now, immediately `gh issue edit <N> --add-label
   status:in-progress`.
6. No separate log — the issue's creation event is the audit record.

**File backend:**

3. Determine the next sequential task ID by scanning `BACKLOG.md` and archives for the highest
   existing ID.
4. Add the task to the appropriate section of BACKLOG.md based on priority:
   - critical/high → top of "Up Next" (or "In Progress" if user says they're starting it now)
   - medium → middle of "Up Next"
   - low → "Todo (Backlog)"
5. Append a creation entry to TASK-LOG.md:
   ```
   | YYYY-MM-DD HH:MM | TASK-NNNN | created | priority: X, rune: Y, source: Z | <optional note> |
   ```
6. Update BACKLOG.md header stats.

**Duplicate check (both backends):** Before creating, scan existing tasks for similar titles or
context. GitHub: `gh issue list --search "<keywords>" --state all`. File: scan `BACKLOG.md` and
the current month's archive. If a plausible duplicate exists, surface it ("This looks similar to
#23 — duplicate or separate?") and only create after the user confirms.

---

### 2. Harvest

**Triggers:** End of a coding session, "harvest tasks", "find tasks from this session", or when
integrating with session-continuity's End mode.

This is the key differentiator — the AI actively mines the conversation for implicit tasks so
nothing slips through the cracks.

**Steps:**

1. Review the current session's conversation for implicit tasks. Look for:
   - Phrases: "we should also...", "TODO:", "this needs...", "later we'll need to...",
     "for now we're...", "we're hardcoding this...", "eventually..."
   - Edge cases discussed but not implemented
   - Technical debt introduced intentionally
   - Follow-up work implied by decisions made
   - Tests mentioned but not written
   - Error handling deferred
2. Compile a numbered list of discovered potential tasks, each with a proposed title, priority,
   and one-line context.
3. Present to the user: "I found N potential tasks from this session. Which should I add?"
4. For each item, the user can: **accept** (as-is), **modify** (change title/priority/context),
   **reject** (skip it), or **merge** (combine with an existing task).
5. Create only the tasks the user confirms, using the Create flow above (which routes through
   the active backend).
6. Also prompt for status updates on any in-progress tasks. GitHub: `gh issue list --state open
   --label status:in-progress`. File: read the "In Progress" section of BACKLOG.md. For each:
   "You had #42 in progress. Any update — still going, done, or blocked?"

---

### 3. Next

**Triggers:** "what should I work on?", "what's next?", "what's the priority?", "next task"

**Steps:**

1. Load the current backlog:
   - **GitHub:** `gh issue list --state open --limit 200 --json
     number,title,labels,body,updatedAt,assignees`. Compute "Up Next" by filtering out
     `status:in-progress` and `status:blocked`, then sort by priority label
     (critical > high > medium > low) then by `updatedAt` desc.
   - **File:** read BACKLOG.md.
2. Present the top item from "Up Next" with its full task block (context, acceptance criteria,
   notes). GitHub: pull body via `gh issue view <N>`.
3. Also check for:
   - **Newly unblockable items:** GitHub — for each issue with `status:blocked`, parse `Blocked
     by #M` from the body and check whether #M is closed; if so, surface it. File — same logic
     across BACKLOG.md and archives.
   - **Critical items anywhere:** Mention any `priority:critical` open item not currently
     in-progress.
   - **Stale in-progress:** GitHub — `updatedAt` older than 7 days. File — last log entry older
     than 3 sessions / 7 days.
4. If the user says "not that, something else", show the next few items and offer to reprioritize.

---

### 4. Status

**Triggers:** "mark X as done", "X is blocked", "move X to in-progress", "start working on X",
"cancel X", or any status-change language referencing a task ID or title.

**Steps:**

1. Parse the target task (by ID like `42`, `#42`, `TASK-0042`, or by title keyword match). For
   GitHub, resolve title matches with `gh issue list --search "<keywords>"`.
2. Apply the status change:

   | New status | GitHub | File |
   |---|---|---|
   | `in-progress` | `gh issue edit <N> --add-label status:in-progress --remove-label status:blocked` | Move task block to "In Progress" |
   | `blocked` | Ask for blocker. `gh issue edit <N> --add-label status:blocked --remove-label status:in-progress`. Edit body to add `Blocked by #M` | Require blocker, move to "Blocked" |
   | `done` | Verify all `- [ ]` are `- [x]` in body (ask user about any unchecked). `gh issue close <N> --reason completed` | Check acceptance criteria, move to archive after confirmation |
   | `cancelled` | Ask for reason. `gh issue comment <N> --body "Cancelled: <reason>"` then `gh issue close <N> --reason "not planned"` and `gh issue edit <N> --add-label status:cancelled` | Ask for reason, move to archive |
   | `todo` | `gh issue edit <N> --remove-label status:in-progress,status:blocked` (reopen if closed) | Move back to "Up Next" / "Todo (Backlog)" |

   For both backends: warn if marking in-progress would push the count to 3+.

3. Record the change:
   - **GitHub:** the label change event is the audit record. Add a `gh issue comment` only when
     the reason is non-obvious (cancellations, force-unblocks).
   - **File:** append to TASK-LOG.md `| YYYY-MM-DD HH:MM | TASK-NNNN | status → X | reason or blocker | |`.
4. **File only:** update BACKLOG.md header stats.

**Archiving:**
- **GitHub:** closed issues stay where they are; no move. Use `gh issue list --state closed` for history.
- **File:** when a task is marked `done` or `cancelled`, move it from BACKLOG.md to
  `tasks/archive/YYYY-MM.md` (current month). Create the archive file from template if it doesn't
  exist. Prefix the task block with its completion/cancellation date.

---

### 5. Prioritize

**Triggers:** "reprioritize", "move X above Y", "X is now critical", "reorder tasks",
"change priority of X"

**Steps:**

1. Apply the requested change:
   - **Level change:**
     - GitHub: `gh issue edit <N> --remove-label priority:<old> --add-label priority:<new>`.
     - File: update the task's priority field and reposition it in the correct section.
   - **Positional reorder:**
     - GitHub: ordering is derived from labels + `updatedAt`; to force an item to the top of its
       priority bucket, `gh issue edit <N> --body "<unchanged-body>"` (touches updatedAt). Note
       this in the comment so reviewers know.
     - File: move the task up or down within its section.
   - **Bulk review:** show all tasks in a priority group and let the user reorder.
2. Record:
   - GitHub: the label change is the audit record.
   - File: append `| YYYY-MM-DD HH:MM | TASK-NNNN | reprioritized | old → new priority, reason | |` to TASK-LOG.md.
3. **File only:** update BACKLOG.md header stats.

**Priority inflation guard:** After any priority change, check the distribution. If >30% of open
tasks are critical or high, flag it: "You have N high/critical items out of M total. Want to do a
quick reprioritization pass?"

The user's explicit prioritization always wins. Suggest but never silently override.

---

### 6. Review

**Triggers:** "show backlog", "how many tasks?", "show blocked tasks", "show all high priority",
"backlog review", "any stale tasks?"

**Steps:**

1. Load the backlog and present the requested view. Filter syntax:

   | Filter | GitHub | File |
   |---|---|---|
   | `show blocked` | `gh issue list --state open --label status:blocked` | grep "Blocked" section |
   | `show in-progress` | `gh issue list --state open --label status:in-progress` | grep "In Progress" section |
   | `show critical tasks` | `gh issue list --state open --label priority:critical` | filter on priority field |
   | `show session tasks` | `gh issue list --state open --label source:session` | filter on source field |
   | `show tasks about <keyword>` | `gh issue list --state open --search "<keyword>"` | grep BACKLOG.md |
   | `show backlog` | `gh issue list --state open --limit 200` | read full BACKLOG.md |

2. Generate summary stats when doing a full review:
   - Tasks by status (in-progress / up-next / blocked / backlog)
   - Tasks by priority
   - Number of tasks with no acceptance criteria (GitHub: no `- [ ]` or `- [x]` in body)
   - Oldest open task (GitHub: lowest `createdAt`)

3. Proactively flag issues:
   - **Stale in-progress:** GitHub — `updatedAt` older than 7 days on a `status:in-progress`
     issue. File — last log entry older than 3 sessions / 7 days.
   - **Missing acceptance criteria:** Tasks with no criteria defined.
   - **Missing Rune classification:** Open issues with no `rune:*` label / tasks where the field
     is absent. Load `references/RUBRIC.md`, then prompt the user to backfill in a single batch.
     Suggest a class per task from its context; user confirms or edits.
   - **Undersized cluster:** 2+ adjacent `vibe` tasks under the same parent or touching the same
     module that together fit one `dev` chunk. Load `references/RUBRIC.md` for the cluster check,
     then flag and offer Decompose-merge (see Mode 7).
   - **Large backlog:** If open tasks exceed 30, suggest grooming.
   - **Blocked chains:** If A is blocked by B which is blocked by C, show the full chain.

---

### 7. Decompose

**Triggers:** "break down X", "X is too big", "decompose X", "split X into subtasks", "merge X
and Y", "X and Y are too small", "fold X into Y"

This mode is bidirectional: it splits oversized tasks AND merges undersized siblings. The same
rune sizing rubric drives both directions.

**Split flow (oversized → subtasks):**

1. Read the target task's full block.
2. Propose a breakdown: 2-5 smaller, independently actionable subtasks, each with a title,
   suggested priority, suggested rune class, and brief context.
3. Present to user for approval/modification.
4. For each approved subtask, create a new task using the Create flow. Each subtask gets:
   - A reference to the parent in Notes — GitHub: `Parent: #<N>`; File: `**Parent:** [TASK-NNNN]`.
   - Source: same as parent
   - Priority: inherited from parent unless user overrides
   - Rune: classified per subtask — a `dev` parent often splits into mixed `vibe` + `research`
     children
5. Update the parent task's Notes with the child IDs. GitHub: `gh issue edit <parent> --body
   "<body with Children: #a, #b appended>"`. File: edit the parent block in BACKLOG.md.
6. Max 1 level of decomposition. If a subtask needs further splitting, it becomes an independent
   task with a reference — not a grandchild.

**Merge flow (undersized → one task):**

1. Load `references/RUBRIC.md` for the cluster-sizing criteria. Identify candidate cluster: 2+ tasks
   that share a parent, touch the same module, or were seeded from the same architectural noun, AND
   pass all four cluster-merge checks in the rubric.
2. Propose the merged task: combined title, union of acceptance criteria, rune `dev`, priority
   = max of children's.
3. Present to user. If approved:
   - Create the merged task via Create flow.
   - Cancel each child with reason `merged into #<N>` (GitHub) / `merged into TASK-NNNN` (file).
   - File only: append merge entries to TASK-LOG.md. GitHub: the comment + close events suffice.
4. Refuse to merge across reviewable boundaries — if children already passed review or shipped
   commits (GitHub: any linked PR is closed/merged), do not retroactively merge; just note the
   cluster in the merged task's Notes.

---

### 8. Rune

**Triggers:** runs automatically as Step 2 of Create. Also fires standalone on "classify X",
"is this vibe or dev?", "rune for TASK-NNNN", and during Review when backfilling missing classes.

**Purpose:** size-and-shape gate. Forces every task to declare what kind of work it is BEFORE it
inherits the orchestration tax. Closes the gap between architecture-driven seeding and
effort-based ticket sizing.

**The four runes (one-line each):**

- **dev** — big problem-slice, 3-4 day chunk, may include scaffolding.
- **vibe** — one subchunk, atomic diff, no interface design.
- **research** — unknown facts, bounded timebox, no shipped code.
- **analysis** — unknown best approach, bounded timebox, no shipped code.

**Decision flow:**

1. Read repo default from `tasks/RUNE.md` `default_mode:`. If `dev` or `vibe`, that's the starting
   guess. If `mixed`, ask.
2. If the starting guess matches the obvious shape of the task → use it. Done.
3. If the requested rune contradicts the proposed scope, OR the user explicitly asks "is this vibe
   or dev?", OR Decompose-merge needs the cluster check, OR Review is backfilling a batch:
   **Read `references/RUBRIC.md`** for the full sizing table, override triggers, refusal cases,
   and cluster-merge criteria. Apply those rules.
4. Update the task's rune:
   - GitHub: `gh issue edit <N> --remove-label rune:<old> --add-label rune:<new>`. The label
     event is the audit record.
   - File: edit the `Rune:` field; on standalone reclassify, append to TASK-LOG.md
     `| YYYY-MM-DD HH:MM | TASK-NNNN | reclassified | old → new rune, reason | |`.
5. If reclassifying to `research` or `analysis`, also strip production-code acceptance criteria
   and replace them with research/analysis deliverables. GitHub: edit the issue body; File: edit
   the task block.

**Refusal short-form (no rubric read needed):** if user requests `vibe` but the work is interface
design, scaffolding, or open-ended exploration, refuse: "That's not vibe — it's
`research`/`analysis`/`dev`. Reclassify or rescope." Don't silently downgrade.

---

## Priority Definitions

Use these definitions to infer priority when the user doesn't specify one. When uncertain, default
to medium — it's the safest bet and avoids priority inflation.

| Level | Meaning | Examples |
|---|---|---|
| **critical** | Blocks other work or the project is broken without it. Rare. | Build is broken, core interface is wrong, data corruption. |
| **high** | Important for the current phase. Do before new features. | Implementing a core component, significant bug, completing an in-progress feature. |
| **medium** | Valuable but not blocking. Default for most tasks. | Edge-case tests, better error messages, refactoring for clarity. |
| **low** | Nice to have. Do when there's time. | Doc improvements, non-critical perf optimizations, speculative features. |

**Priority vs Rune — they answer different questions.** Priority = *how urgent*. Rune = *what
shape of work*. A `critical vibe` task (urgent one-line bugfix) and a `low dev` task (nice-to-have
3-day feature) are both legal. Never collapse the two axes.

---

## Integration with Other Skills

These integrations are optional. Only activate them if the referenced skill is actually linked
to the project.

### session-continuity

- **Begin mode:** After session-continuity loads the previous session, surface the top "Up Next"
  item alongside the handoff. One seamless prompt, not two separate ones.
- **End mode:** After session-continuity captures the session summary, run Harvest. Then prompt
  for in-progress task updates. The sequence is: session summary → harvest → status check.

### decision-journal

- When a decision is recorded, check if it implies new tasks (e.g., "decided to use approach X"
  may mean "implement approach X"). Suggest task creation with source `decision`.
- Tasks can reference decision IDs in their Notes field.

### project-context

- When in-progress tasks shift significantly (many reprioritizations, new critical items),
  suggest updating PROJECT-CONTEXT.md's "Current State" section.

---

## Edge Cases

**Duplicate detection:** Before every Create, scan for similar titles/context. Surface potential
duplicates; only create after user confirmation.

**Blocked chains:** When showing a blocked task, follow the chain (A blocked by B blocked by C)
and surface the root blocker.

**Priority inflation:** If >30% of open tasks are critical or high, flag it and offer a
reprioritization pass.

**Stale in-progress:** In-progress for 3+ sessions or 7+ days without update → flag during Next
and Review.

**Large backlog:** Open tasks >30 → suggest a grooming/review session.

**Missing acceptance criteria:** Allowed at creation (low friction), but flagged during Review.

**No tasks/ directory:** Initialize from the `templates/` directory bundled alongside this
SKILL.md. Copy `RUNE.md` always; copy `BACKLOG.md`, `TASK-LOG.md`, `archive/` only when running
in the file backend. Confirm with the user before writing.

**Backend mismatch:** If `tasks/RUNE.md` says `backend: github` but `gh` CLI is missing or the
repo has no GitHub remote, warn ("gh CLI not available / no GitHub remote — falling back to
file backend") and proceed with the file backend for this invocation only. Do not silently
rewrite `tasks/RUNE.md`; the user fixes the underlying issue or changes the field explicitly.

**Switching backend mid-project:** Not auto-migrated. If the user wants to move tasks from file →
GitHub or vice-versa, run a one-shot migration: enumerate tasks in the source, create equivalents
in the target (preserving title / body / labels / status), then have the user delete the source.
Refuse to operate in two backends simultaneously.

---

## Design Principles (for the AI following this skill)

1. **Capture is king.** The #1 job is making sure tasks don't get forgotten. If in doubt, suggest
   capturing it — the user can always reject.
2. **Low friction.** A one-line task creation mid-session should take 10 seconds, not 2 minutes.
   Details can be backfilled later.
3. **Single source of truth.** BACKLOG.md is it. Never store task state anywhere else.
4. **User controls priority.** Suggest, but never silently reorder or override. The user's word
   is final.
5. **Archive aggressively.** Done/cancelled tasks leave the backlog immediately. Keep it clean.
6. **No busywork.** If maintaining the system takes more effort than the value it provides,
   something is wrong. Adapt to the user's level of detail.
