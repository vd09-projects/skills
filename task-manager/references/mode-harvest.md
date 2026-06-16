# Mode 2 — Harvest

**Triggers:** End of a coding session, "harvest tasks", "find tasks from this session", or
when integrating with session-continuity's End mode.

This is the key differentiator — the AI actively mines the conversation for implicit tasks
so nothing slips through the cracks.

## Steps

1. Review the current session's conversation for implicit tasks. Look for:
   - Phrases: "we should also...", "TODO:", "this needs...", "later we'll need to...",
     "for now we're...", "we're hardcoding this...", "eventually..."
   - Edge cases discussed but not implemented
   - Technical debt introduced intentionally
   - Follow-up work implied by decisions made
   - Tests mentioned but not written
   - Error handling deferred
2. Compile a numbered list of discovered potential tasks, each with a proposed title,
   priority, and one-line context.
3. Present to the user: "I found N potential tasks from this session. Which should I add?"
4. For each item, the user can: **accept** (as-is), **modify** (change
   title/priority/context), **reject** (skip it), or **merge** (combine with an existing
   task).
5. Create only the tasks the user confirms, using Mode 1 Create (which routes through the
   active backend).
6. Also prompt for status updates on any in-progress tasks:
   - GitHub: `gh issue list --state open --label status:in-progress`
   - File: read the "In Progress" section of BACKLOG.md
   For each: "You had #42 in progress. Any update — still going, done, or blocked?"
