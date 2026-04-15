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
  This is NOT a Jira/Linear replacement — it's a lightweight, file-based system for AI-assisted
  development workflows where tasks emerge organically from coding sessions.
---

# Task Manager

A lightweight, file-based task backlog for AI-assisted development. Answers two questions:
**"What should I do next?"** and **"What's the current state of all pending work?"**

Tasks live in readable markdown. No database, no hidden state, no sprint ceremonies.

## Storage

All task data lives in `tasks/` at the project root (or a path configured by the user).

| File | Purpose |
|---|---|
| `tasks/BACKLOG.md` | Single source of truth — prioritized tasks grouped by status |
| `tasks/TASK-LOG.md` | Append-only changelog of every task operation with timestamps |
| `tasks/archive/YYYY-MM.md` | Monthly archives for completed and cancelled tasks |

If the `tasks/` directory doesn't exist yet, initialize it from the templates bundled alongside
this SKILL.md file (in `templates/` within this skill's own directory — NOT the project root).
Copy the template files into the project's `tasks/` directory. Don't symlink — the project's
copies will be edited directly.

## Task Format

Every task in BACKLOG.md is a structured markdown block:

```
### [TASK-NNNN] Short descriptive title

- **Status:** todo | in-progress | blocked | done | cancelled
- **Priority:** critical | high | medium | low
- **Created:** YYYY-MM-DD (Session NNN if session-continuity is linked, otherwise just the date)
- **Source:** session | decision | user | discovery
- **Blocked by:** [TASK-XXXX] or free-text reason (only when status is blocked)
- **Context:** 1-2 sentences on WHY this task exists
- **Acceptance criteria:**
  - [ ] Specific, verifiable condition
- **Notes:** Optional additional context, links to decisions, gotchas
```

**ID assignment:** Sequential, zero-padded to 4 digits (TASK-0001, TASK-0002, ...). To find the
next ID, scan BACKLOG.md and all archive files for the highest existing ID, then increment by 1.

**Source values:**
- `session` — emerged during a coding session
- `decision` — spawned from a decision journal entry
- `user` — explicitly created by the user
- `discovery` — found during code review, testing, or exploration

## BACKLOG.md Structure

Tasks are organized into four sections, in this order. Priority ordering within each section
(critical → high → medium → low, and positional ordering within the same priority level).

```
# Project Task Backlog
**Last updated:** YYYY-MM-DD | **Open tasks:** N | **Next up:** TASK-NNNN

---

## In Progress       ← Currently being worked on (cap: 2-3 tasks)
## Up Next           ← Priority queue; top item = "what to work on next"
## Blocked           ← Each must state its blocker
## Todo (Backlog)    ← Lower-priority items, ordered by priority

---
_Completed and cancelled tasks are moved to tasks/archive/YYYY-MM.md_
```

**Always update the header stats** (open count, next-up ID, last-updated date) after any mutation.

## Modes

This skill operates in seven modes. Detect the mode from the user's intent — they won't always
name the mode explicitly.

---

### 1. Create

**Triggers:** "task:", "add a task", "create task for", "we need to handle X", or any mid-session
request that implies a new work item.

**Steps:**

1. Determine the next sequential task ID.
2. Infer or ask for: title, priority, context, acceptance criteria. If the user gives a one-liner
   like `task: handle nil pointer in ParseCandle`, that's enough — infer medium priority, mark
   source as `session`, write a minimal context line from conversation, and add a single acceptance
   criterion. Speed matters here; don't interrupt flow.
3. Add the task to the appropriate section of BACKLOG.md based on priority:
   - critical/high → top of "Up Next" (or "In Progress" if user says they're starting it now)
   - medium → middle of "Up Next"
   - low → "Todo (Backlog)"
4. Append a creation entry to TASK-LOG.md:
   ```
   | YYYY-MM-DD HH:MM | TASK-NNNN | created | priority: X, source: Y | <optional note> |
   ```
5. Update BACKLOG.md header stats.

**Duplicate check:** Before creating, scan existing tasks for similar titles or context. If a
plausible duplicate exists, surface it: "This looks similar to TASK-0023 — is this a duplicate or
a separate item?" Only create after the user confirms it's new.

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
5. Create only the tasks the user confirms, using the Create flow above.
6. Also prompt for status updates on any in-progress tasks: "You had TASK-0042 in progress.
   Any update — still going, done, or blocked?"

---

### 3. Next

**Triggers:** "what should I work on?", "what's next?", "what's the priority?", "next task"

**Steps:**

1. Read BACKLOG.md.
2. Present the top item from "Up Next" with its full task block (context, acceptance criteria,
   notes).
3. Also check for:
   - **Newly unblockable items:** If a blocked task's blocker was recently marked done, surface it:
     "TASK-0038 was blocked by TASK-0035, which is now done. It might be unblocked."
   - **Critical items anywhere:** If there are critical-priority tasks outside "In Progress",
     mention them regardless of position.
   - **Stale in-progress:** If any in-progress task hasn't been updated in 3+ sessions (or 7+
     days if session-continuity is not linked), flag it.
4. If the user says "not that, something else", show the next few items and offer to reprioritize.

---

### 4. Status

**Triggers:** "mark X as done", "X is blocked", "move X to in-progress", "start working on X",
"cancel X", or any status-change language referencing a task ID or title.

**Steps:**

1. Parse the target task (by ID like `42` or `TASK-0042`, or by title keyword match).
2. Apply the status change:

   | New status | Actions |
   |---|---|
   | `in-progress` | Move to "In Progress" section. Warn if already 3+ tasks in progress. |
   | `blocked` | Require a blocker (task ID or free-text reason). Move to "Blocked" section. |
   | `done` | Check acceptance criteria. If any are unchecked, ask which are met. Move to archive after confirmation. |
   | `cancelled` | Ask for brief reason. Move to archive after confirmation. |
   | `todo` | Move back to "Up Next" or "Todo (Backlog)" based on priority. |

3. Append status change to TASK-LOG.md:
   ```
   | YYYY-MM-DD HH:MM | TASK-NNNN | status → X | reason or blocker | |
   ```
4. Update BACKLOG.md header stats.

**Archiving:** When a task is marked `done` or `cancelled`, move it from BACKLOG.md to
`tasks/archive/YYYY-MM.md` (current month). Create the archive file from template if it doesn't
exist. Prefix the task block with its completion/cancellation date.

---

### 5. Prioritize

**Triggers:** "reprioritize", "move X above Y", "X is now critical", "reorder tasks",
"change priority of X"

**Steps:**

1. Apply the requested change:
   - **Level change:** Update the task's priority field and reposition it in the correct section.
   - **Positional reorder:** Move the task up or down within its section.
   - **Bulk review:** Show all tasks in a priority group and let the user reorder.
2. Append to TASK-LOG.md:
   ```
   | YYYY-MM-DD HH:MM | TASK-NNNN | reprioritized | old → new priority, reason | |
   ```
3. Update BACKLOG.md header stats.

**Priority inflation guard:** After any priority change, check the distribution. If >30% of open
tasks are critical or high, flag it: "You have N high/critical items out of M total. Want to do a
quick reprioritization pass?"

The user's explicit prioritization always wins. Suggest but never silently override.

---

### 6. Review

**Triggers:** "show backlog", "how many tasks?", "show blocked tasks", "show all high priority",
"backlog review", "any stale tasks?"

**Steps:**

1. Read BACKLOG.md and present the requested view. Support filters:
   - By status: `show blocked`, `show in-progress`
   - By priority: `show critical tasks`, `show all high priority`
   - By source: `show session tasks`
   - By keyword: `show tasks about authentication`
   - Full view: `show backlog`

2. Generate summary stats when doing a full review:
   - Tasks by status (in-progress / up-next / blocked / backlog)
   - Tasks by priority
   - Number of tasks with no acceptance criteria
   - Oldest open task

3. Proactively flag issues:
   - **Stale in-progress:** In-progress for 3+ sessions or 7+ days without update.
   - **Missing acceptance criteria:** Tasks with no criteria defined.
   - **Large backlog:** If open tasks exceed 30, suggest grooming.
   - **Blocked chains:** If A is blocked by B which is blocked by C, show the full chain.

---

### 7. Decompose

**Triggers:** "break down X", "X is too big", "decompose X", "split X into subtasks"

**Steps:**

1. Read the target task's full block.
2. Propose a breakdown: 2-5 smaller, independently actionable subtasks, each with a title,
   suggested priority, and brief context.
3. Present to user for approval/modification.
4. For each approved subtask, create a new task using the Create flow. Each subtask gets:
   - A reference to the parent: `**Parent:** [TASK-NNNN]`
   - Source: same as parent
   - Priority: inherited from parent unless user overrides
5. Update the parent task's Notes field with a list of child task IDs.
6. Max 1 level of decomposition. If a subtask needs further splitting, it becomes an independent
   task with a reference — not a grandchild.

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
SKILL.md. Copy templates into the project's `tasks/` directory and confirm with the user.

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
