# Backend — GitHub issues

Tasks are GitHub issues in the repo where this skill is imported. Issue number = task ID
(`#42`). Status / priority / rune / source are encoded as labels. Acceptance criteria are
GitHub task-list checkboxes in the issue body. Audit history comes from the issue timeline —
no separate task log.

## Label scheme

The skill creates these labels on first use if they don't exist (`gh label create --force` is
idempotent — handled in `references/setup.md`).

| Axis | Labels |
|---|---|
| Priority | `priority:critical`, `priority:high`, `priority:medium`, `priority:low` |
| Rune | `rune:dev`, `rune:vibe`, `rune:research`, `rune:analysis` |
| Source | `source:session`, `source:decision`, `source:user`, `source:discovery` |
| Status (open issues only) | `status:in-progress`, `status:blocked` |
| Status (closed) | `status:cancelled` (otherwise = done) |

## Status decoding

- `todo` — open, no `status:*` label
- `in-progress` — open, `status:in-progress`
- `blocked` — open, `status:blocked` (plus `Blocked by #N` reference in the body)
- `done` — closed, no `status:cancelled` label
- `cancelled` — closed, `status:cancelled` label

## Issue body template

```
**Context:** <1-2 sentences on why this task exists>

**Acceptance criteria:**
- [ ] Specific, verifiable condition

**Blocked by:** #N or free-text reason (only when status:blocked)

**Notes:** optional extra context, links to decisions
```

Parent/child references live in Notes as `Parent: #N` and `Children: #N, #M`.

## Operation cheatsheet

Every mutating mode maps to a single `gh` invocation. Read-only modes use `gh issue
list/view` with label filters. Always pass `--repo $(gh repo view --json nameWithOwner -q
.nameWithOwner)` when running outside a checkout to avoid ambiguity; inside the checkout,
omit `--repo`.

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

`gh issue list` defaults to 30 results — pass `--limit 200` when scanning for grooming or
stats.

## Per-mode steps

### Create (Mode 1)

1. Build the body using the issue template (Context, Acceptance criteria checkboxes, Notes).
2. `gh issue create --title "<title>" --body "<body>" --label "priority:<p>,rune:<r>,source:<s>"`.
   Capture the returned issue number — that's the task ID.
3. If the user said they're starting it now, immediately `gh issue edit <N> --add-label
   status:in-progress`.
4. No separate log — the issue's creation event is the audit record.
5. **Duplicate check:** before creating, `gh issue list --search "<keywords>" --state all`.
   If a plausible duplicate exists, surface it ("This looks similar to #23 — duplicate or
   separate?") and only create after the user confirms.

### Status (Mode 4)

Resolve title matches with `gh issue list --search "<keywords>"`.

| New status | Command |
|---|---|
| `in-progress` | `gh issue edit <N> --add-label status:in-progress --remove-label status:blocked` |
| `blocked` | Ask for blocker. `gh issue edit <N> --add-label status:blocked --remove-label status:in-progress`. Edit body to add `Blocked by #M`. |
| `done` | Verify all `- [ ]` are `- [x]` in body (ask user about any unchecked). `gh issue close <N> --reason completed`. |
| `cancelled` | Ask for reason. `gh issue comment <N> --body "Cancelled: <reason>"` then `gh issue close <N> --reason "not planned"` and `gh issue edit <N> --add-label status:cancelled`. |
| `todo` | `gh issue edit <N> --remove-label status:in-progress,status:blocked` (reopen if closed). |

The label change event is the audit record. Add a `gh issue comment` only when the reason is
non-obvious (cancellations, force-unblocks).

**Archiving:** closed issues stay where they are; no move. Use `gh issue list --state
closed` for history.

### Next (Mode 3)

1. `gh issue list --state open --limit 200 --json
   number,title,labels,body,updatedAt,assignees`.
2. Compute "Up Next" by filtering out `status:in-progress` and `status:blocked`, then sort
   by priority label (critical > high > medium > low) then by `updatedAt` desc.
3. Pull body via `gh issue view <N>` for the top item.
4. **Newly unblockable items:** for each issue with `status:blocked`, parse `Blocked by #M`
   from the body and check whether #M is closed; if so, surface it.
5. **Stale in-progress:** `updatedAt` older than 7 days.

### Prioritize (Mode 5)

- **Level change:** `gh issue edit <N> --remove-label priority:<old> --add-label
  priority:<new>`.
- **Positional reorder within a bucket:** ordering is derived from labels + `updatedAt`; to
  force an item to the top of its priority bucket, `gh issue edit <N> --body
  "<unchanged-body>"` (touches updatedAt). Note this in the comment so reviewers know.
- The label change is the audit record.
