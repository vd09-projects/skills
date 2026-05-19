---
overlay: data-migration
applies_to: [architecture, task]
---

# Data Migration Overlay

Composable concern: schema change, data shape change, backfill, migration. Adds required slots and template sections to whichever base level (architecture or task) is active.

## Triggers

Activate when one or more present in problem text, constraints, or pasted ticket:

- Keywords: `migration`, `schema`, `ALTER`, `ADD COLUMN`, `DROP COLUMN`, `RENAME`, `backfill`, `dual-write`, `expand/contract`
- ORM/DB signals: `Prisma model`, `migrations/`, `db/`, `alembic`, `flyway`, `liquibase`, `sequelize`
- Phrases: "move data from X to Y", "change the table", "split the column", "new field on existing rows"

Do not activate for: pure read-side changes, query optimization without schema change (use `perf-critical` overlay instead), greenfield tables with no existing rows.

## Required Slots

Get before producing artifact. If missing, ask.

1. **Row scale.** Approximate row count and table size. Drives online-vs-offline strategy. A 10k-row table tolerates an `ALTER TABLE`; a 50M-row table does not.
2. **Online or offline.** Is downtime acceptable? If yes, how much? If no, force expand/contract.
3. **Source of truth for backfill.** Where do filled values come from — existing column, joined table, external system, computed default? Affects correctness risk.
4. **Rollback window.** How long must rollback be possible after deploy? Drives whether the old shape stays readable.
5. **Downstream consumers.** Reporting, replicas, CDC pipelines, search indexes, caches. Each one's expectations must survive the migration.

## Template Sections

Append to base body, after `## Constraints`, before terminal sections (`## Out of Scope`, `## Risks`, `## Open Questions`, `## Handoff Notes`).

### Migration Strategy

- **Pattern:** {expand-contract | dual-write | offline migration | shadow table + cutover}
- **Phases:** {ordered list — expand schema → backfill → switch reads → switch writes → contract}
- **Reversibility per phase:** {which phases are reversible without data loss}

### Backfill Plan

- **Source:** {column, query, external system, computed}
- **Batch size:** {rows per batch and pacing — protect production load}
- **Idempotency:** {can the backfill re-run safely if interrupted}
- **Verification:** {how completion is confirmed — row count match, checksum, sampled comparison}

### Rollback Plan

- **Rollback window:** {time after deploy during which rollback is supported}
- **What rollback restores:** {schema state, data state — explicit about what is NOT recoverable}
- **Trigger conditions:** {what observation triggers a rollback decision}

### Data Validation

- **Pre-migration:** {assertions that must hold before starting — e.g., no NULLs in source column}
- **Mid-migration:** {invariants checked during backfill — e.g., new column matches computed value for sampled rows}
- **Post-migration:** {acceptance — e.g., 100% of rows have non-NULL new column, dual-write divergence is zero}

### Consumer Impact

| Consumer | Reads/Writes | Action required | Owner |
|---|---|---|---|
| {service or pipeline} | {R/W} | {update query, redeploy, no-op} | {team} |

## Discipline

- **No `ALTER TABLE` on a hot table without expand-contract** unless row scale slot confirms it's safe (small table or offline window).
- **Backfill always idempotent.** Mid-flight crash must not corrupt or duplicate.
- **NOT NULL columns added in two steps.** Add nullable → backfill → enforce NOT NULL. One-shot `ADD COLUMN NOT NULL DEFAULT ...` on large tables locks for the duration of the default fill.
- **Read consumers updated before write consumers.** Otherwise readers see partial state.
- **Name the cutover moment.** "Switch reads to new column at T+24h after backfill completes and verification passes."

## Common Failure Modes

- **"It's a small table" without checking.** Row scale slot must be filled with a number, not a vibe.
- **Rollback plan = `git revert`.** Reverting code does not restore dropped columns or unwind a backfill. Rollback must address the data layer too.
- **Backfill that re-derives "current value" mid-flight.** If the source changes during backfill, the new column drifts. Snapshot or freeze the source.
- **Forgetting CDC / replicas / search index.** Schema migration succeeds; downstream pipeline silently breaks the next morning.
- **Online migration claim with no expand-contract phases.** Either it's online with expand-contract, or it has downtime. There is no third option.
