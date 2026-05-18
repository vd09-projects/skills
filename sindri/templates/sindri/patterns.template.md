# Learned Patterns — [Project Name]

Copy to `.claude/skill-memory/sindri/patterns.md` in your project repo.
Grows over time as Sindri notices recurring issues, false positives,
and project-specific patterns. Update after each session where something new was learned.

---

## Known Hot Spots

<!-- Files, packages, or modules that require extra caution.
     Sindri increases scrutiny when touching these.

     Format: path — reason — what to watch for

     Examples:
     - internal/accounting/ — financial correctness — every change needs golden test
     - pkg/config/ — public API — changes need backward compat check
     - cmd/sweep/ — concurrency-sensitive — review goroutine lifecycle on every change
-->

## Recurring False Positives

<!-- Patterns that look like problems but are intentional in this codebase.
     Sindri skips flagging these.

     Examples:
     - Long functions in internal/engine/engine.go — sequential event loop is intentionally monolithic
     - Global var in pkg/metrics/registry.go — prometheus global registry, intentional
-->

## Established Conventions (Not in domain.md)

<!-- Smaller, discovered-in-practice conventions that don't rise to domain-level rules
     but should be consistent.

     Examples:
     - Error message format: "verb noun: detail" (e.g., "load config: field X missing")
     - Test file for X lives at X_test.go in same package (not separate test package)
     - All new packages get a doc.go with package comment
-->

## Accepted Debt

<!-- Known shortcuts with a plan to address them. Format:
     - [item] — location — follow-up: [what + when]

     Examples:
     - No retry logic on inventory sync — internal/sync/inventory.go — follow-up: add with backoff before Q3 release
     - Hardcoded exchange timezone — internal/data/session.go — follow-up: make configurable when adding second exchange
-->
