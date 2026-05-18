---
name: multi-perspective-review
description: >
  This skill should be used when reviewing a PR, MR, diff, or code change.
  It simulates a panel of expert reviewers — each with a distinct domain and voice —
  selected adaptively based on the change. Triggers: "review this PR", "code review",
  "review this diff", "review my changes", "multi-perspective review".
---

# Multi-Perspective Code Review

Simulate a review panel of expert personas. Not all reviewers run every time — a triage phase selects only those relevant to the change.

## Inputs

| Input | Required | Notes |
|---|---|---|
| Diff / Code Change | Yes | The actual diff or changed files |
| PR Description | Recommended | What the author says the change does |
| Ticket / Spec | Optional | Feature spec, bug report, or task context |
| Urgency Flag | Optional | `hotfix` · `normal` · `exploratory` |

If PR description or ticket is absent, note the gap. Do not hallucinate intent.

## Phase 0 — Load Skill Memory

Check `.claude/skill-memory/multi-perspective-review/` for project overrides:

1. **config.md** — Reviewer overrides (`always_include`, `always_exclude`), custom triage rules, project context. Takes priority over default triage.
2. **patterns.md** — Learned patterns, false positive suppressions, known hot spots.
3. **accepted-debt-ledger.md** — Open debt items. If diff touches code with open debt, Tech Debt Sentinel checks if it's being addressed or worsened.

If no memory exists, proceed with defaults. Never create memory files without user confirmation.

## Phase 1 — Triage

### Step 1: Apply memory overrides (if loaded)
Add `always_include` reviewers. Remove `always_exclude`. Apply custom path-based rules.

### Step 2: Classify scope
- `trivial` — 1–10 lines, no logic (config, typo, version bump)
- `small` — 10–50 lines, single concern (bug fix, minor tweak)
- `medium` — 50–200 lines, multi-file (new feature, refactor)
- `large` — 200+ lines, cross-cutting (major feature, architecture change)

### Step 3: Detect signals and match reviewers

| Signal in diff | Reviewer to activate |
|---|---|
| TODOs, workarounds, hardcoded values | Tech Debt Sentinel |
| Multi-file changes, shared util edits | Ripple Effect Analyst |
| New/renamed identifiers, comments | Naming & Clarity Guardian |
| Tests added/modified/deleted | Test Coverage Auditor |
| Input parsing, auth, secrets, env vars | Security & Trust Reviewer |
| DB queries, loops, caching, hot paths | Performance & Scalability Critic |
| Public API/endpoint/interface changes | API & Contract Reviewer |
| Try/catch, error returns, service calls | Error Handling & Resilience Inspector |
| Logging, metrics, tracing additions | Observability & Debuggability Reviewer |
| Business rules, domain model changes | Domain Logic Reviewer |
| Locks, channels, async/await, threads | Concurrency & State Safety Reviewer |
| New imports, deps, module boundaries | Dependency & Coupling Reviewer |
| Schema changes, migrations, ORM models | Data Integrity & Migration Reviewer |

### Step 4: Apply panel size limits
- `trivial`: 1–2 reviewers
- `small`: 2–4 reviewers
- `medium`: 4–7 reviewers
- `large`: 5–10 reviewers

Baseline: unless scope is `trivial`, always include **Tech Debt Sentinel** and **Naming & Clarity Guardian**.

### Step 5: Output triage decision

```
## Triage Decision
Scope: [scope]
Memory overrides: [any applied, or "none"]

Selected Reviewers:
- [Name] — [one-line justification]

Skipped:
- [Name] — [reason]
```

## Phase 2 — Review Execution

**For each selected reviewer, read their reference file:**
`references/reviewers/{reviewer-slug}.md`

Each file contains the reviewer's tagline, voice, and full checklist. Load only the files for selected reviewers — do not load skipped reviewers.

Read `references/output-format.md` for the per-reviewer template and review rules.

Then execute each reviewer's analysis against the diff, using their voice and checklist.

## Phase 3 — Summary

After all reviews, produce:

```
## Review Summary

| Reviewer | Verdict | Blocking | Suggestions | FYI |
|---|---|---|---|---|
| [Name] | [Verdict] | [n] | [n] | [n] |

**Overall Recommendation:** APPROVE | REQUEST CHANGES | NEEDS DISCUSSION

**Rationale:** [One paragraph synthesis]

**Blocking Items:** [numbered list with file/function refs]
**Top Suggestions:** [numbered list]
**Accepted Debt:** [item — follow-up action + timeline]
```

**Recommendation logic:**
- **APPROVE** — Zero blocking issues.
- **REQUEST CHANGES** — One or more blocking issues.
- **NEEDS DISCUSSION** — Design questions the panel can't resolve unilaterally.

### Memory update suggestions

If the review found new accepted debt, recurring patterns, or convention discoveries, suggest appended entries for the relevant memory file. Never write without user confirmation.

## Adding a New Reviewer

1. Create `references/reviewers/{slug}.md` following the template in any existing reviewer file
2. Add a row to the signal-matching table in Phase 1 Step 3 above
3. Done — no other files need editing

See `references/reviewer-template.md` for the blank template.

Future reviewer ideas: Accessibility, i18n/l10n, Cloud Cost, Migration Safety, Documentation, DX (Developer Experience).
