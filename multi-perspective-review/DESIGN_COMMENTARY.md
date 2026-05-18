# Design Commentary

## Why Progressive Disclosure (v2 vs v1)

v1 was a 667-line monolith. Every reviewer loaded every time — even if triage skipped 10 of 13. This violates how skills actually work: the agent sees only `name` + `description` at startup. SKILL.md loads on activation. References load on demand.

v2: SKILL.md is ~120 lines (the orchestrator). Each reviewer is a separate file in `references/reviewers/`. Only selected reviewers get loaded. A 3-reviewer hotfix loads ~210 lines total vs 667. A 7-reviewer feature loads ~370. The ceiling dropped and scales with actual need.

## Why These 18 Reviewers

Original 12 plus:
- **Data Integrity & Migration** (#13) — schema changes are high-risk, low-visibility, and no other reviewer covers them.
- **Infrastructure & Deployment** (#14) — Dockerfile, CI/CD, k8s manifests are frequent sources of production incidents. Zero overlap with existing reviewers.
- **Backward Compatibility** (#15) — API Contract covers *quality* of new contracts; Backward Compat covers *breakage to existing consumers*. Distinct concern, distinct voice.
- **Accessibility** (#16) — blocking a11y regressions matter for any UI-touching change. Triage triggers only on HTML/JSX/CSS signals.
- **Developer Experience** (#17) — reviews the ergonomics and safety of what developers build against, not just what end users see.
- **Documentation** (#18) — the only reviewer that asks "will the person maintaining this in 6 months understand why it was built this way?"

i18n, Cloud Cost, Migration Safety remain as future extensions — domain-specific enough to warrant explicit team decision to include.

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

## Implemented in v2

- **5 new reviewers** — Infrastructure & Deployment, Backward Compatibility, Accessibility, DX, Documentation
- **Cross-reviewer escalation** — Security/DataIntegrity/APIContract BLOCKING can promote skipped reviewers to active
- **Confidence calibration** — HIGH/MED/LOW per reviewer in summary table
- **Corroborated Findings** — Phase 3 explicitly surfaces issues flagged by 2+ reviewers

## Future Ideas

- Review-of-review (re-run only affected reviewers after author fixes)
- Metrics tracking in skill memory (which reviewers find the most blocking issues?)
- i18n/l10n reviewer, Cloud Cost reviewer, Migration Safety reviewer
