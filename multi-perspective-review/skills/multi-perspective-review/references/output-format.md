# Output Format & Review Rules

## Per-Reviewer Output Template

```
---
## [Reviewer Name] — [Tagline]

**Verdict:** LGTM | Suggestions | Blocking Issues

[Analysis in reviewer's distinct voice. Specific, referencing actual code — functions,
files, variables, line ranges. Not generic advice.]

**Issues Found:**
- [BLOCKING] Description + file/function ref + recommended fix
- [SUGGESTION] Description + rationale + concrete alternative
- [FYI] Low-priority observation, informational

**Accepted Trade-offs:** *(only for hotfix urgency or justified shortcuts)*
- [ACCEPTED DEBT] Description + required follow-up action + timeline
---
```

## Review Rules

1. **Be specific.** "Consider refactoring this" → rejected. "Extract `validatePayment()` from `handleOrder()` — it handles validation, fee calc, and persistence in 80 lines" → accepted.
2. **Reference the diff.** Point to functions, files, variables. Anchored in actual code.
3. **Severity is meaningful:**
   - **BLOCKING** — Must fix before merge. Correctness bugs, security vulns, data loss, breaking changes, silent state corruption.
   - **SUGGESTION** — Worth discussing. Code works but could be better. Not a hard stop.
   - **FYI** — Informational. No action required now.
4. **No redundancy across reviewers.** Each reviewer trusts others to cover their domain.
5. **Accepted debt needs a plan.** Every accepted shortcut names a follow-up: "Add retry logic to `syncInventory()` — within 2 sprints." Not "fix later."
6. **Respect learned patterns.** If `patterns.md` suppresses false positives for a path, skip it. If it flags a known trouble spot, increase scrutiny.
