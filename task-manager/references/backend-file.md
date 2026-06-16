# Backend — File (local markdown)

Tasks live in `tasks/BACKLOG.md`. A separate `tasks/TASK-LOG.md` records every operation.
Completed/cancelled tasks move to monthly archives.

## Storage layout

| File | Purpose |
|---|---|
| `tasks/BACKLOG.md` | Single source of truth — prioritized tasks grouped by status |
| `tasks/TASK-LOG.md` | Append-only changelog of every task operation with timestamps |
| `tasks/RUNE.md` | Repo-wide config (backend, default mode, sizing rubric, exceptions) |
| `tasks/archive/YYYY-MM.md` | Monthly archives for completed and cancelled tasks |

The bundled templates are copied into `tasks/` at init; the project edits its copies
directly (no symlinks). See `references/setup.md` for the init flow.

## Task block format

A task is a markdown block in `BACKLOG.md`:

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

## ID assignment

Sequential, zero-padded to 4 digits (TASK-0001, TASK-0002, ...). To find the next ID, scan
`BACKLOG.md` and all archive files for the highest existing ID, then increment by 1.

## BACKLOG.md structure

Tasks are organized into four sections, in this order. Priority ordering within each
section (critical → high → medium → low, and positional ordering within the same priority
level).

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

**Always update the header stats** (open count, next-up ID, last-updated date, rune
distribution) after any mutation.

## TASK-LOG.md format

Append-only changelog. Every operation gets one row:

```
| YYYY-MM-DD HH:MM | TASK-NNNN | <op> | <detail> | <optional note> |
```

Where `<op>` is `created`, `status → X`, `reprioritized`, `reclassified`, `merged`, etc.

## Per-mode steps

### Create (Mode 1)

1. Determine the next sequential task ID by scanning `BACKLOG.md` and archives for the
   highest existing ID.
2. Add the task to the appropriate section of BACKLOG.md based on priority:
   - critical/high → top of "Up Next" (or "In Progress" if user says they're starting it
     now)
   - medium → middle of "Up Next"
   - low → "Todo (Backlog)"
3. Append a creation entry to TASK-LOG.md:
   ```
   | YYYY-MM-DD HH:MM | TASK-NNNN | created | priority: X, rune: Y, source: Z | <optional note> |
   ```
4. Update BACKLOG.md header stats.
5. **Duplicate check:** before creating, scan `BACKLOG.md` and the current month's archive
   for similar titles/context. If a plausible duplicate exists, surface it and only create
   after user confirms.

### Status (Mode 4)

Parse target by ID (`TASK-0042`) or title keyword match.

| New status | Action |
|---|---|
| `in-progress` | Move task block to "In Progress". Warn if count would reach 3+. |
| `blocked` | Require blocker. Move to "Blocked". |
| `done` | Check acceptance criteria all ticked, move to archive after confirmation. |
| `cancelled` | Ask for reason, move to archive. |
| `todo` | Move back to "Up Next" / "Todo (Backlog)". |

Append a log entry: `| YYYY-MM-DD HH:MM | TASK-NNNN | status → X | reason or blocker | |`.

Update BACKLOG.md header stats.

**Archiving:** when a task is marked `done` or `cancelled`, move it from BACKLOG.md to
`tasks/archive/YYYY-MM.md` (current month). Create the archive file from template if it
doesn't exist. Prefix the task block with its completion/cancellation date.

### Next (Mode 3)

1. Read BACKLOG.md.
2. Present the top item from "Up Next" with its full task block.
3. **Newly unblockable items:** for each blocked task, check whether the blocker is now in
   archives.
4. **Stale in-progress:** last log entry older than 3 sessions / 7 days.

### Prioritize (Mode 5)

- **Level change:** update the task's priority field and reposition it in the correct
  section.
- **Positional reorder:** move the task up or down within its section.
- Log: `| YYYY-MM-DD HH:MM | TASK-NNNN | reprioritized | old → new priority, reason | |`.
- Update BACKLOG.md header stats.
