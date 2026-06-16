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

Lightweight backlog for AI-assisted development. Answers **"what should I do next?"** and
**"what's the current state of pending work?"** Two backends: GitHub issues (default) and local
markdown. The backend is selected in `tasks/RUNE.md`. Modes and rune classification are identical
across backends — only storage changes.

## Backend detection (every invocation)

1. Read `tasks/RUNE.md` `backend:` field. If missing, assume `github`.
2. If `github`: verify `gh` CLI is installed (`command -v gh`) AND `gh repo view --json
   nameWithOwner` succeeds in the project root. If both pass → use GitHub. If either fails → warn
   ("gh CLI not available / no GitHub remote — falling back to file backend") and use file.
3. If `file`: use file. Don't touch `gh` even if installed.
4. If `tasks/` doesn't exist → load `references/setup.md` and run the init flow.

Do NOT silently rewrite `tasks/RUNE.md` on fallback; the user fixes the underlying issue or
changes the field explicitly.

After detection, load the active backend's reference file for all storage-layer details:

- `github` → `references/backend-github.md` (label scheme, issue body template, `gh` cheatsheet,
  per-mode commands)
- `file` → `references/backend-file.md` (BACKLOG.md structure, task-block format, TASK-LOG
  format, archive rollup, per-mode steps)

## Task fields (shared vocabulary)

Elicit these from the user before consulting the backend reference for encoding:

- **Status:** `todo` | `in-progress` | `blocked` | `done` | `cancelled`
- **Priority:** `critical` | `high` | `medium` | `low` (see Priority Definitions below)
- **Rune:** `dev` | `vibe` | `research` | `analysis` (see Rune gate below)
- **Source:** `session` | `decision` | `user` | `discovery`
- **Context:** 1-2 sentences on why this task exists
- **Acceptance criteria:** specific, verifiable conditions

## Dispatch table

Detect the mode from user intent. Core modes (Create / Next / Status / Prioritize) live in this
file. Rarer flows are loaded only when their trigger fires.

| Trigger | Load |
|---|---|
| End of session, "harvest tasks", "find tasks from this session" | `references/mode-harvest.md` |
| "show backlog", "grooming", "stale tasks", "show blocked/critical/session tasks" | `references/mode-review.md` |
| "break down X", "decompose", "merge X and Y", "X is too big/small" | `references/mode-decompose.md` |
| Rune override, reclassify, cluster check, override triggers | `references/RUBRIC.md` |
| session-continuity / decision-journal / project-context skill linked | `references/integrations.md` |
| `tasks/` does not exist (first init) | `references/setup.md` |

---

## Mode 1 — Create

**Triggers:** "task:", "add a task", "create task for", "we need to handle X", or any
mid-session request implying a new work item.

**Steps:**

1. **Rune classification** (see Rune gate below). Pick `dev` / `vibe` / `research` /
   `analysis` from `tasks/RUNE.md` default + request shape. If the proposed scope contradicts
   the requested rune (e.g. user says "vibe" but task is "design DataProvider interface"),
   refuse and propose the right rune.
2. Infer or ask for: title, priority, context, acceptance criteria. A one-liner like `task:
   handle nil pointer in ParseCandle` is enough — infer medium priority, source `session`,
   write a minimal context line, add a single acceptance criterion. Speed matters; don't
   interrupt flow.
3. **Duplicate check.** Scan existing tasks for similar titles or context. If a plausible
   duplicate exists, surface it ("This looks similar to #23 — duplicate or separate?") and
   only create after user confirms. (Backend-specific search command is in the loaded backend
   reference.)
4. Execute the create per the active backend reference (`backend-github.md` or
   `backend-file.md`).
5. If the user says they're starting it now, transition to `in-progress` immediately (Mode 4).

---

## Mode 3 — Next

**Triggers:** "what should I work on?", "what's next?", "what's the priority?", "next task"

**Steps:**

1. Load the current backlog via the active backend reference.
2. Present the top "Up Next" item with its full context, acceptance criteria, notes.
3. Also surface:
   - **Newly unblockable items** — for each blocked task, check whether its blocker has been
     closed/completed; if so, surface it.
   - **Critical items anywhere** — any `critical` open item not currently in-progress.
   - **Stale in-progress** — flag items that haven't moved in 7+ days / 3+ sessions.
4. If the user says "not that, something else", show the next few items and offer to
   reprioritize.

---

## Mode 4 — Status

**Triggers:** "mark X as done", "X is blocked", "move X to in-progress", "start working on
X", "cancel X", or any status-change language referencing a task ID or title.

**Steps:**

1. Parse the target task (by ID like `42`, `#42`, `TASK-0042`, or by title keyword match).
2. Apply the status change per the active backend reference. Transition rules (shared):

   | New status | Required input | Side effects |
   |---|---|---|
   | `in-progress` | none | warn if in-progress count would reach 3+ |
   | `blocked` | ask for blocker | record `Blocked by` reference |
   | `done` | verify all acceptance criteria ticked (ask about any unchecked) | archive (file backend) |
   | `cancelled` | ask for reason | archive (file backend); record reason |
   | `todo` | none | clears in-progress / blocked state |

3. The backend reference handles the audit record (label event for GitHub, log row for file).

---

## Mode 5 — Prioritize

**Triggers:** "reprioritize", "move X above Y", "X is now critical", "reorder tasks", "change
priority of X"

**Steps:**

1. Apply the requested change per the active backend reference (level change or positional
   reorder within a bucket).
2. **Priority inflation guard:** after any priority change, check the distribution. If >30%
   of open tasks are critical or high, flag it: "You have N high/critical items out of M
   total. Want to do a quick reprioritization pass?"
3. The user's explicit prioritization always wins. Suggest but never silently override.

---

## Rune gate (Mode 8 — runs automatically inside Create)

**Purpose:** size-and-shape gate. Every task declares what kind of work it is BEFORE it
inherits the orchestration tax.

**The four runes:**

- **dev** — big problem-slice, 3-4 day chunk, may include scaffolding.
- **vibe** — one subchunk, atomic diff, no interface design.
- **research** — unknown facts, bounded timebox, no shipped code.
- **analysis** — unknown best approach, bounded timebox, no shipped code.

**Default-and-go:** read `default_mode:` from `tasks/RUNE.md`. If `dev` or `vibe` and matches
the obvious shape of the task → use it. If `mixed`, ask.

**Refusal short-form:** if the user requests `vibe` but the work is interface design,
scaffolding, or open-ended exploration, refuse: "That's not vibe — it's
`research`/`analysis`/`dev`. Reclassify or rescope." Don't silently downgrade.

**Override / reclassify / cluster check:** load `references/RUBRIC.md` for the full sizing
table, override triggers, refusal cases, and cluster-merge criteria.

If reclassifying to `research` or `analysis`, also strip production-code acceptance criteria
and replace them with research/analysis deliverables.

---

## Priority Definitions

Use these to infer priority when the user doesn't specify one. When uncertain, default to
medium.

| Level | Meaning | Examples |
|---|---|---|
| **critical** | Blocks other work or the project is broken without it. Rare. | Build is broken, core interface is wrong, data corruption. |
| **high** | Important for the current phase. Do before new features. | Implementing a core component, significant bug, completing an in-progress feature. |
| **medium** | Valuable but not blocking. Default. | Edge-case tests, better error messages, refactoring for clarity. |
| **low** | Nice to have. | Doc improvements, non-critical perf optimizations, speculative features. |

**Priority vs Rune — they answer different questions.** Priority = *how urgent*. Rune = *what
shape of work*. A `critical vibe` task (urgent one-line bugfix) and a `low dev` task
(nice-to-have 3-day feature) are both legal. Never collapse the two axes.
