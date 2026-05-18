# Design Commentary

## Why Progressive Disclosure (v2 vs v1)

v1 was a 667-line monolith. Every reviewer loaded every time — even if triage skipped 10 of 13. This violates how skills actually work: the agent sees only `name` + `description` at startup. SKILL.md loads on activation. References load on demand.

v2: SKILL.md is ~120 lines (the orchestrator). Each reviewer is a separate file in `references/reviewers/`. Only selected reviewers get loaded. A 3-reviewer hotfix loads ~210 lines total vs 667. A 7-reviewer feature loads ~370. The ceiling dropped and scales with actual need.

## Why These 13 Reviewers

The 12 from the original spec plus Data Integrity & Migration (#13) — schema changes are high-risk, low-visibility, and no other reviewer covers them.

Accessibility, i18n, Cloud Cost, Documentation, DX are listed as extensibility examples, not built-in. They're domain-specific — not every team needs them. Including them by default creates noise.

## Triage Design

The triage table is deliberately simple: signal → reviewer. No ML-flavored classification — the LLM reads the diff and matches patterns directly. Panel size limits (1-2 for trivial, 2-4 for small, etc.) are guardrails, not hard rules.

Two always-on reviewers for non-trivial changes: Tech Debt Sentinel and Naming & Clarity Guardian. Lowest cost, highest signal.

## Extensibility

Adding a reviewer = 2 steps: create one file, add one table row. No structural changes to SKILL.md. The file-per-reviewer pattern means the registry scales without bloating the orchestrator.

## Skill Memory Architecture

Three files with distinct lifespans:
- **config.md** — mostly static, set once, updated rarely
- **patterns.md** — grows slowly as reviews reveal recurring issues
- **accepted-debt-ledger.md** — event-driven, updated per review

Critical constraint: never write without user confirmation. The skill suggests updates; the user approves.

## v2 Ideas

- Reviewer cross-references ("Security flagged raw SQL — I'll note the missing index too")
- Confidence calibration (low/medium/high based on available context)
- Auto-severity escalation (Security BLOCKING → escalate Ripple Effect to check elsewhere)
- Review-of-review (re-run only affected reviewers after author fixes)
- Metrics tracking in skill memory (which reviewers find the most blocking issues?)
