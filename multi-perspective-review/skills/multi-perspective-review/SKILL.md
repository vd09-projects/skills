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

### Step 3: Detect change partition

Scan changed file paths and extensions:

| Partition | File signals |
|---|---|
| `frontend` | `.tsx` `.jsx` `.css` `.scss` `.module.css` `.vue` `.svelte`; paths: `components/` `pages/` `styles/` `app/` |
| `backend` | `.go` `.py` `.java` `.rs` `.rb` `.sql` `.prisma`; paths: `migrations/` `api/` `handlers/` `services/` `models/` `controllers/` `db/` |
| `infra` | `Dockerfile` `docker-compose*` `.yml`/`.yaml` (CI); paths: `k8s/` `terraform/` `.github/workflows/` |
| `fullstack` | Both `frontend` and `backend` signals present |

If no clear signal, treat as `fullstack` (safe fallback — all reviewers eligible).

### Step 4: Pre-filter reviewer pool by partition

| Detected partition | Eligible reviewer partitions |
|---|---|
| `frontend` | common + frontend |
| `backend` | common + backend |
| `infra` | common + infra |
| `fullstack` | common + frontend + backend |
| `frontend` + `infra` | common + frontend + infra |
| `backend` + `infra` | common + backend + infra |
| Ambiguous / unknown | All partitions |

### Step 5: Detect signals and match reviewers

Within the pre-filtered pool only:

#### Common

| Signal in diff | Reviewer to activate |
|---|---|
| TODOs, workarounds, hardcoded values | Tech Debt Sentinel |
| Multi-file changes, shared util edits | Ripple Effect Analyst |
| New/renamed identifiers, comments | Naming & Clarity Guardian |
| Tests added/modified/deleted | Test Coverage Auditor |
| Input parsing, auth, secrets, env vars | Security & Trust Reviewer |
| Try/catch, error returns, service calls | Error Handling & Resilience Inspector |
| New imports, deps, module boundaries | Dependency & Coupling Reviewer |
| Removed/renamed public symbols, signature changes, breaking removals | Backward Compatibility Reviewer |
| New public functions/interfaces/modules, CLI flags, config schema | Developer Experience Reviewer |
| New public APIs, changed behavior, architecture changes, config additions | Documentation Reviewer |

#### Backend

| Signal in diff | Reviewer to activate |
|---|---|
| DB queries, loops, caching, hot paths | Performance & Scalability Critic |
| Public API/endpoint/interface changes | API & Contract Reviewer |
| Logging, metrics, tracing additions | Observability & Debuggability Reviewer |
| Business rules, domain model changes | Domain Logic Reviewer |
| Locks, channels, async/await, threads | Concurrency & State Safety Reviewer |
| Schema changes, migrations, ORM models | Data Integrity & Migration Reviewer |

#### Frontend

| Signal in diff | Reviewer to activate |
|---|---|
| HTML/JSX/TSX, ARIA, form/modal/interactive UI changes | Accessibility Reviewer |
| useState/useReducer/useContext, Redux/Zustand/Jotai, React Query/SWR/Apollo | State Management Reviewer |
| Component re-renders, useMemo/useCallback, dynamic imports, image assets, list rendering | FE Performance & Rendering Reviewer |
| CSS/SCSS/module.css, className changes, theme tokens, animations, responsive layout | CSS & Styling Reviewer |

#### Infrastructure

| Signal in diff | Reviewer to activate |
|---|---|
| Dockerfile, CI/CD config, k8s/infra manifests, env var additions | Infrastructure & Deployment Reviewer |

### Step 6: Apply panel size limits
- `trivial`: 1–2 reviewers
- `small`: 2–4 reviewers
- `medium`: 4–8 reviewers
- `large`: 5–12 reviewers

Baseline: unless scope is `trivial`, always include **Tech Debt Sentinel** and **Naming & Clarity Guardian**.

### Step 7: Output triage decision

```
## Triage Decision
Scope: [scope]
Partition: [frontend | backend | infra | fullstack | ambiguous]
Memory overrides: [any applied, or "none"]

Selected Reviewers:
- [Name] ([partition]) — [one-line justification]

Skipped:
- [Name] — [reason]
```

## Phase 2 — Review Execution

**For each selected reviewer, read their reference file:**
`references/reviewers/{reviewer-slug}.md`

Each file contains the reviewer's tagline, voice, and full checklist. Load only the files for selected reviewers — do not load skipped reviewers.

Read `references/output-format.md` for the per-reviewer template and review rules.

Then execute each reviewer's analysis against the diff, using their voice and checklist.

### Cross-Reviewer Escalation

After each reviewer completes, check: does their finding implicate another reviewer's domain? If so, note it inline. Common escalation paths:

- **Security BLOCKING** (e.g., raw SQL, auth bypass) → flag for **Ripple Effect Analyst** to check if same pattern exists elsewhere
- **Data Integrity BLOCKING** (schema change) → flag for **Backward Compatibility Reviewer** to check consumers
- **API Contract BLOCKING** (interface change) → flag for **Backward Compatibility Reviewer**
- **Concurrency BLOCKING** (shared state) → flag for **Observability** to verify the race is detectable in production
- **Infrastructure BLOCKING** (secrets in image) → flag for **Security** to check other exposure vectors

If an escalation fires for a skipped reviewer, promote them to active and run their checklist. Note the escalation in triage output.

## Phase 3 — Summary

After all reviews, produce:

```
## Review Summary

| Reviewer | Verdict | Blocking | Suggestions | FYI | Confidence |
|---|---|---|---|---|---|
| [Name] | [Verdict] | [n] | [n] | [n] | HIGH/MED/LOW |

**Overall Recommendation:** APPROVE | REQUEST CHANGES | NEEDS DISCUSSION

**Rationale:** [One paragraph synthesis]

**Blocking Items:** [numbered list with file/function refs]
**Top Suggestions:** [numbered list]
**Corroborated Findings:** [issues flagged by 2+ reviewers — highest signal, act first]
**Accepted Debt:** [item — follow-up action + timeline]
```

**Confidence rating per reviewer:**
- **HIGH** — diff provides full context; reviewer could identify specific line/function
- **MED** — diff present but missing PR description, ticket, or surrounding code
- **LOW** — reviewer activated but lacked enough context to be specific (note what context would help)

**Recommendation logic:**
- **APPROVE** — Zero blocking issues.
- **REQUEST CHANGES** — One or more blocking issues.
- **NEEDS DISCUSSION** — Design questions the panel can't resolve unilaterally.

### Memory update suggestions

If the review found new accepted debt, recurring patterns, or convention discoveries, suggest appended entries for the relevant memory file. Never write without user confirmation.

## Adding a New Reviewer

1. Create `references/reviewers/{slug}.md` following the template in `references/reviewer-template.md`
2. Set `Partition:` to `common`, `backend`, `frontend`, or `infra`
3. Add a row to the relevant signal table in Phase 1 Step 5 above
4. Done — no other files need editing

See `references/reviewer-template.md` for the blank template.

Possible future extensions: i18n/l10n, Cloud Cost, Migration Safety.
