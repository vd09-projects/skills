# Worked Examples

## Example 1: Small Hotfix — Fix null pointer in user lookup

**Diff:** 8 lines in `UserService.getById()`. Adds null check before `user.profile`.
**PR:** "Fix NPE when user has no profile set."

### Triage

```
Scope: trivial
Memory overrides: none

Selected:
- Naming & Clarity Guardian — new conditional; verify readability
- Error Handling & Resilience Inspector — core fix is null-safety

Skipped: All others — no signals for an 8-line null check
```

### Abbreviated Review

**Error Handling & Resilience Inspector** — Verdict: Suggestions
The null check prevents the crash, but `getById()` now returns a user with null profile silently. If `renderDashboard()` calls `user.profile.getAvatar()`, the NPE moves downstream.
- [SUGGESTION] Return `Optional<User>` or throw `MissingProfileException` so callers handle absence intentionally.
- [FYI] No regression test. A test with null profile would prevent recurrence.

**Naming & Clarity Guardian** — Verdict: LGTM. Reads clearly.

**Summary:** APPROVE. Suggestion for explicit result type is a good follow-up.

---

## Example 2: New Feature — Coupon validation endpoint

**Diff:** 180 lines, 5 files. `POST /api/v1/coupons/validate`, service, repo, DTOs, 12 tests.
**PR:** "Validate coupon codes at checkout. Returns discount and validity."

### Triage

```
Scope: medium
Memory overrides: config.md says always_include: Security & Trust Reviewer

Selected:
- API & Contract Reviewer — new public endpoint
- Security & Trust Reviewer — user input in DB query + config override
- Domain Logic Reviewer — coupon validity business rules
- Error Handling & Resilience Inspector — multiple failure modes
- Test Coverage Auditor — 12 tests, verify edge cases
- Naming & Clarity Guardian — new identifiers across 5 files
- Tech Debt Sentinel — baseline pattern check

Skipped: Performance (single lookup), Concurrency (no signals),
Observability (standard logging), Ripple Effect (new code, no edits),
Dependency (no new deps), Data Integrity (no schema change)
```

*(Each selected reviewer produces full review per output-format.md)*

---

## Example 3: Refactor — Extract payment module

**Diff:** 320 lines, 12 files. Code moved, interfaces extracted, no new logic.
**PR:** "Extract payment logic from OrderService into PaymentModule."

### Triage

```
Scope: large
Memory overrides: patterns.md flags OrderService as known hot spot

Selected:
- Ripple Effect Analyst — 12-file refactor, high ripple risk
- Naming & Clarity Guardian — new module/interface names
- Dependency & Coupling Reviewer — module boundary redesign
- Tech Debt Sentinel — refactors can introduce new debt patterns
- API & Contract Reviewer — extracted interfaces are new contracts
- Test Coverage Auditor — moved logic still covered?

Skipped: Security (no auth changes), Performance (no algo changes),
Domain Logic (identical logic), Error Handling (paths moved not changed),
Concurrency (no changes), Observability (logging moved with code),
Data Integrity (no schema)
```

*(Each selected reviewer produces full review per output-format.md)*
