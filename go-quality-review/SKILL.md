---
name: go-quality-review
description: "Go code quality review and repository bootstrapping skill. Runs multi-level code reviews (quick, standard, deep, pre-merge) across five dimensions: linting, test quality, best practices, behavior verification, and architecture. Also bootstraps new Go repos with golangci-lint config, CI workflows, and review standards. Use this skill whenever the user asks to review Go code, check Go test quality, set up a Go project with linting, run a Go code review, improve Go code quality, check Go best practices, analyze Go test coverage, or bootstrap a Go repository. Also trigger when the user mentions golangci-lint config, Go mutation testing, Go race detection, Go error handling review, or Go concurrency review."
metadata:
  version: "1.0"
  created: "2026-04"
---

# Go Quality Review

A multi-level code review and repo bootstrapping skill for Go projects.

---

## Two modes

Identify which mode the user needs, then follow that section.

### Mode 1: Bootstrap

Trigger phrases: "set up", "bootstrap", "initialize", "add quality checks", "configure linting", "set up CI for Go"

Bootstrap sets up a Go repository with quality tooling. It does three things:
1. Copies `.golangci.yml` from `assets/.golangci.yml` to the repo root
2. Generates a `CLAUDE.md` from `assets/CLAUDE.md.template`, customized with any repo context the user provides
3. Copies the CI workflow from `assets/go-quality.yml` to `.github/workflows/go-quality.yml`

Before bootstrapping, ask the user:
- What does this service/library do? (one sentence — goes into CLAUDE.md)
- Any repo-specific rules? (e.g., "no direct DB access outside the store package")
- Do they use GitHub Actions? (skip CI workflow if not)

Read `references/golangci-config.md` to explain the config choices if the user asks why specific linters are enabled.

### Mode 2: Review

Trigger phrases: "review", "check", "analyze", "audit", "what's wrong with", "improve", "run quality check"

Review analyzes Go code against five dimensions at a chosen depth level.

**Step 1 — Determine the review level**

If the user specifies a level, use it. Otherwise, infer:
- Mentioned "quick" / "fast" / "just lint" → **quick**
- Mentioned "PR" / "review this PR" / "code review" → **standard**
- Mentioned "deep" / "thorough" / "critical" / specific package → **deep**
- Mentioned "release" / "merge" / "pre-merge" / "ship" → **pre-merge**
- Ambiguous → default to **standard**, mention you can go deeper

**Step 2 — Load the review level preset**

Read `references/review-levels.md` to determine which dimensions are active and at what depth for the chosen level.

**Step 3 — Check for repo overrides**

Look for a `CLAUDE.md` in the project root. If it exists, read it. It may:
- Override dimension depths (e.g., "always run behavior at full depth")
- Add repo-specific checks (e.g., "handlers must be idempotent")
- Disable dimensions (e.g., "skip architecture — this is a CLI tool")

Repo overrides take precedence over the default level matrix.

**Step 4 — Execute each active dimension**

For each active dimension, read the corresponding reference file and execute its checklist. The reference files are:

| Dimension | Reference file | What it checks |
|-----------|---------------|----------------|
| Lint | `references/lint.md` | golangci-lint rules, static analysis |
| Test quality | `references/test-quality.md` | Coverage, mutation testing, test patterns |
| Best practices | `references/best-practices.md` | Go idioms, error handling, naming |
| Behavior | `references/behavior.md` | Concurrency, context, error types |
| Architecture | `references/architecture.md` | Dependencies, coupling, package design |

Read only the reference files for active dimensions — do not load inactive ones.

For dimensions with tool-based steps (lint, race detection, mutation), run the tools first and collect output before applying judgment-based checks.

**Step 5 — Produce the review report**

Structure the output as a findings report. Group findings by dimension. For each finding:
- State what was found (the specific code location and issue)
- Explain why it matters (not just "this is wrong" — explain the consequence)
- Suggest a fix (concrete, with code when possible)

Severity levels:
- **blocker** — must fix before merge (data races, silent error drops, security issues)
- **warning** — should fix, creates future problems (missing tests, high complexity, tight coupling)
- **suggestion** — would improve quality (naming, documentation, minor idiom violations)

End with a summary: total findings by severity, overall assessment, and whether the code is merge-ready at the requested review level.

**Step 6 — Write quality-gate sentinel (on pass)**

If the review concludes with no blocker-level findings, record the pass so the Stop and PreToolUse hooks can verify the gate was run:

```bash
mkdir -p .quality-gate && date -u +"%Y-%m-%dT%H:%M:%SZ" > .quality-gate/last-pass
```

Run this command via the Bash tool immediately after delivering the review report. Do not run it if there are any blocker findings — the gate is only stamped when the code is clean. Add one line to the review summary confirming whether the sentinel was written or skipped.

---

## Adding new dimensions

This skill is designed to be extended. To add a new review dimension:

1. Create a new reference file in `references/` (e.g., `security.md`)
2. Add a row to the matrix in `references/review-levels.md`
3. Add the dimension to the table in Step 4 above

No other files need to change. Each dimension is self-contained.

---

## Important principles

- Run deterministic tools (linters, tests) before applying judgment. Tool output grounds the review in facts.
- Never say "this looks fine" without actually running the checks. If a tool can verify something, run it.
- Explain the *why* behind every finding. A developer who understands the reasoning will write better code next time, not just fix this instance.
- Respect repo-specific context. A CLI tool has different quality standards than a payment service. Read the repo's CLAUDE.md and adjust accordingly.
- When in doubt about severity, err toward warning rather than blocker. Reserve blocker for things that will cause runtime failures or data corruption.
