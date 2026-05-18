# Domain Knowledge — [Project Name]

Copy this file to `.claude/skill-memory/sindri/domain.md` in your project repo.
Sindri reads it on every activation. Keep it current — stale conventions
mislead more than no conventions.

---

## Domain Context

<!-- What is this project? What does it do in business terms?
     One paragraph. Sindri uses this to calibrate what "correct" means
     for domain decisions that aren't in CLAUDE.md. -->

## Core Invariants

<!-- Properties that must hold in all implementations. Non-negotiable.
     Sindri blocks and asks before violating these.

     Examples:
     - "All monetary values use Decimal, never float"
     - "Every write operation is idempotent"
     - "Engine outputs are the source of truth — never recompute in the consumer layer"
-->

## Architectural Rules

<!-- Structural decisions already made. Don't relitigate them; apply them.

     Examples:
     - "Engine is source of truth. Python layer reads engine outputs only."
     - "Services communicate via events, not direct calls"
     - "No business logic in HTTP handlers — handlers delegate to service layer"
-->

## Conventions

<!-- Naming, file structure, patterns in use.
     Focus on things that differ from language defaults.

     Examples:
     - "Repository methods return (entity, error), never (nil, nil)"
     - "Config loaded once at startup, passed via dependency injection"
     - "All times stored and passed as UTC; convert at display boundary only"
-->

## Known Gotchas

<!-- Domain-specific traps. What has broken before. What looks right but isn't.

     Examples:
     - "Map iteration in the event loop — always sort keys before iterating"
     - "Session boundaries are exchange-local, not UTC midnight"
     - "The cache layer is eventually consistent — don't read-after-write through it"
-->

## Out of Scope

<!-- What Sindri should NOT build in this project, even if asked.
     Block and surface to user instead.

     Examples:
     - "Live trading concerns — backtest and research only"
     - "Admin UI — handled by separate service team"
-->

## Quality Additions

<!-- Domain-specific quality gates stacked on top of quality-gates.md.
     These must pass before "Ready for review." in this project.

     Examples:
     - "Golden test required for any change to the event loop or accounting"
     - "Property test required for any accounting invariant"
     - "Determinism check: same input → byte-identical output across two runs"
-->
