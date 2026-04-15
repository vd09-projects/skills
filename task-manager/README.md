# task-manager

A lightweight, file-based task backlog skill for AI-assisted development workflows.

Tasks emerge organically from coding sessions, decisions, and discoveries. This skill captures
them, tracks their status, and always has an answer to **"What should I work on next?"**

## What this is

- A prioritized backlog in plain markdown (`tasks/BACKLOG.md`)
- An append-only changelog (`tasks/TASK-LOG.md`)
- Monthly archives for completed work (`tasks/archive/YYYY-MM.md`)
- Seven operating modes: Create, Harvest, Next, Status, Prioritize, Review, Decompose

## What this is NOT

- Not a Jira/Linear replacement — no sprints, story points, or velocity tracking
- Not a bug tracker — no reproduction steps or environment fields
- Not a decision log or session log — those belong in separate skills
- Not an auto-pilot — it suggests and organizes, humans decide

## Installation

This is a standalone skill repo. Link it into your project using one of these methods:

**Option A — Git submodule** (recommended if your project is a git repo):
```bash
git submodule add https://github.com/<you>/task-manager.git .claude/skills/task-manager
```

**Option B — Symlink** (good for local-only use):
```bash
ln -s /path/to/task-manager .claude/skills/task-manager
```

**Option C — Copy** (simplest, but you lose upstream updates):
```bash
cp -r /path/to/task-manager .claude/skills/task-manager
```

On first use, the skill creates a `tasks/` directory in your project root by copying the
bundled templates. This is where your actual task data lives — commit it to your project repo.

```
your-project/
├── .claude/skills/task-manager/   ← This skill (linked/submoduled)
│   ├── SKILL.md
│   ├── README.md
│   └── templates/
├── tasks/                          ← Your project's task data (created on first use)
│   ├── BACKLOG.md
│   ├── TASK-LOG.md
│   └── archive/
└── ...
```

## Usage Examples

### Quick capture mid-session

```
You: "task: add slippage model to engine config"
```

Creates TASK-0051 with inferred priority, source `session`, and minimal context from the
conversation. Fast — doesn't interrupt flow.

### Harvest at session end

```
Skill: "I found 3 potential tasks from this session:
  1. Handle partial candle data from Zerodha API (you said 'we should handle this')
  2. Add benchmark tests for the candle processing loop
  3. Create a CSV data provider for testing
  Which should I add?"
```

### What's next

```
You: "what should I work on?"
Skill: "Top priority: [TASK-0042] Implement DataProvider interface for Zerodha
  Priority: high | Created: 2026-03-29
  Context: Core data pipeline — engine can't run real backtests without this.
  
  Also: TASK-0038 was blocked by TASK-0035, which is now done — might be unblocked."
```

### Status update

```
You: "mark 42 as done"
Skill: "TASK-0042 has 3 acceptance criteria:
  - [ ] Implements DataProvider interface
  - [ ] Handles pagination for large date ranges  
  - [ ] Has mock-based tests
  Are all met?"
```

### Decompose

```
You: "break down TASK-0050"
Skill: "TASK-0050 is 'Implement full backtesting engine'. Proposed breakdown:
  1. Define BacktestRunner interface and config struct
  2. Implement candle iteration loop with strategy callbacks
  3. Add position tracking and P&L calculation
  4. Write integration test with CSV data provider
  Create these as subtasks?"
```

## Modes Reference

| Mode | Trigger phrases | What it does |
|------|----------------|--------------|
| **Create** | "task:", "add task", "we need to handle X" | Creates a new task with next sequential ID |
| **Harvest** | session end, "harvest tasks", "find tasks" | Mines conversation for implicit tasks |
| **Next** | "what's next?", "what should I work on?" | Surfaces top priority item + blocked/stale checks |
| **Status** | "mark X as done", "X is blocked" | Updates status, moves between sections, archives |
| **Prioritize** | "reprioritize", "move X above Y" | Changes priority level or positional order |
| **Review** | "show backlog", "how many tasks?" | Filtered/full views with summary stats |
| **Decompose** | "break down X", "X is too big" | Splits a task into 2-5 subtasks (max 1 level) |

## Integration with Other Skills

All integrations are optional — task-manager works standalone.

| Skill | Integration |
|-------|-------------|
| **session-continuity** | Begin: surface "Up Next" with session handoff. End: run Harvest after session summary, then prompt for in-progress updates. |
| **decision-journal** | Check if new decisions imply tasks. Tasks can reference decision IDs. |
| **project-context** | Suggest updating PROJECT-CONTEXT.md when in-progress work shifts significantly. |

## Priority Levels

| Level | When to use |
|-------|-------------|
| **critical** | Blocks other work or project is broken. Rare. |
| **high** | Important for current phase. Before new features. |
| **medium** | Valuable but not blocking. Default for most tasks. |
| **low** | Nice to have. Do when there's time. |

## Design Philosophy

1. **Capture is king** — tasks don't slip through the cracks
2. **Low friction** — one-liner creation, details later
3. **Single source of truth** — BACKLOG.md, nothing else
4. **User controls priority** — skill suggests, never overrides
5. **Archive aggressively** — backlog shows only actionable work
6. **No busywork** — system maintenance should never exceed its value
