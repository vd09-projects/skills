# Mode 6 — Review

**Triggers:** "show backlog", "how many tasks?", "show blocked tasks", "show all high
priority", "backlog review", "any stale tasks?"

## Steps

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
   - **Missing Rune classification:** Open issues with no `rune:*` label / tasks where the
     field is absent. Load `references/RUBRIC.md`, then prompt the user to backfill in a
     single batch. Suggest a class per task from its context; user confirms or edits.
   - **Undersized cluster:** 2+ adjacent `vibe` tasks under the same parent or touching the
     same module that together fit one `dev` chunk. Load `references/RUBRIC.md` for the
     cluster check, then flag and offer Decompose-merge (see `references/mode-decompose.md`).
   - **Large backlog:** If open tasks exceed 30, suggest grooming.
   - **Blocked chains:** If A is blocked by B which is blocked by C, show the full chain.
