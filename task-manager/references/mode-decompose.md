# Mode 7 — Decompose

**Triggers:** "break down X", "X is too big", "decompose X", "split X into subtasks",
"merge X and Y", "X and Y are too small", "fold X into Y"

This mode is bidirectional: it splits oversized tasks AND merges undersized siblings. The
same rune sizing rubric drives both directions.

## Split flow (oversized → subtasks)

1. Read the target task's full block.
2. Propose a breakdown: 2-5 smaller, independently actionable subtasks, each with a title,
   suggested priority, suggested rune class, and brief context.
3. Present to user for approval/modification.
4. For each approved subtask, create a new task using Mode 1 Create. Each subtask gets:
   - A reference to the parent in Notes — GitHub: `Parent: #<N>`; File: `**Parent:**
     [TASK-NNNN]`.
   - Source: same as parent.
   - Priority: inherited from parent unless user overrides.
   - Rune: classified per subtask — a `dev` parent often splits into mixed `vibe` +
     `research` children.
5. Update the parent task's Notes with the child IDs:
   - GitHub: `gh issue edit <parent> --body "<body with Children: #a, #b appended>"`.
   - File: edit the parent block in BACKLOG.md.
6. Max 1 level of decomposition. If a subtask needs further splitting, it becomes an
   independent task with a reference — not a grandchild.

## Merge flow (undersized → one task)

1. Load `references/RUBRIC.md` for the cluster-sizing criteria. Identify candidate cluster:
   2+ tasks that share a parent, touch the same module, or were seeded from the same
   architectural noun, AND pass all four cluster-merge checks in the rubric.
2. Propose the merged task: combined title, union of acceptance criteria, rune `dev`,
   priority = max of children's.
3. Present to user. If approved:
   - Create the merged task via Mode 1 Create.
   - Cancel each child with reason `merged into #<N>` (GitHub) / `merged into TASK-NNNN`
     (file).
   - File only: append merge entries to TASK-LOG.md. GitHub: the comment + close events
     suffice.
4. Refuse to merge across reviewable boundaries — if children already passed review or
   shipped commits (GitHub: any linked PR is closed/merged), do not retroactively merge;
   just note the cluster in the merged task's Notes.
