# Domain Knowledge — [Project Name]

<!-- rune-generated: [DATE] | git: [GIT_SHA] | rune: 1.0 -->
<!-- Sindri checks this header for staleness. Re-run `rune` if the project has significantly changed. -->

Copy this file to `.claude/skill-memory/sindri/domain.md` in your project repo.
Sindri reads it on every activation. Keep it current — stale conventions mislead more than no conventions.

**Confidence levels:**
- `HIGH` — verified in code or confirmed by team. Sindri applies without asking.
- `MED` — from grilling session, not yet confirmed in code. Sindri asks once before gating a decision on this.

---

## Domain Context
<!-- confidence: HIGH | MED -->

<!-- What is this project in business terms. Who uses it. What it must do correctly. One paragraph. -->

---

## Core Invariants
<!-- confidence: HIGH | MED -->

<!-- Things that must NEVER be violated. Sindri blocks before violating HIGH-confidence invariants.
     MED-confidence invariants trigger a one-time confirmation.

     Examples:
     - "All monetary values use Decimal, never float" (HIGH)
     - "Every write operation is idempotent" (HIGH)
     - "Engine outputs are the source of truth" (MED — assumed, not yet verified in full codebase)
-->

---

## Architectural Rules
<!-- confidence: HIGH | MED -->

<!-- Structural decisions already final. Sindri applies without relitigating.

     Examples:
     - "Engine is source of truth. Python layer reads outputs only." (HIGH)
     - "Services communicate via events, not direct calls" (MED)
-->

---

## Domain Terminology

<!-- Terms that mean something specific in this project's context.
     No confidence needed — these are definitions, not constraints.

     Examples:
     - **Bar**: a single OHLCV data point at a fixed time interval
     - **Fill**: an executed order with price and quantity confirmed
-->

---

## Known Gotchas
<!-- confidence: HIGH | MED -->

<!-- What has broken before. What looks right but isn't.

     Examples:
     - "Map iteration in the event loop — always sort keys before iterating" (HIGH)
     - "Cache layer is eventually consistent — don't read-after-write" (MED)
-->

---

## Out of Scope

<!-- What Sindri should NOT build here, even if asked. Block and surface to user instead.

     Examples:
     - "Live trading concerns — backtest and research only"
     - "Admin UI — handled by separate team"
-->

---

## Quality Additions
<!-- confidence: HIGH | MED -->

<!-- Domain-specific quality gates stacked on top of Sindri's generic gates.
     Must pass before "Ready for review." in this project.

     Examples:
     - "Golden test required for any change to the event loop" (HIGH)
     - "Property test required for accounting invariants" (HIGH)
-->
