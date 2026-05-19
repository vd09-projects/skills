---
overlay: concurrency
applies_to: [architecture, task]
---

# Concurrency Overlay

Composable concern: change introduces or modifies shared state, locks, async coordination, transactions, or anything that fails differently under load than under a single-threaded test. Forces invariant enumeration and failure-mode discipline.

## Triggers

Activate when one or more present:

- Keywords: `lock`, `mutex`, `semaphore`, `channel`, `goroutine`, `thread`, `async`, `await`, `Promise`, `race condition`, `atomic`, `CAS`, `transaction`, `isolation level`, `deadlock`, `idempotent`, `at-least-once`, `exactly-once`
- File/import signals: `sync.Mutex`, `sync.WaitGroup`, `context`, `asyncio`, `threading`, `Promise.all`, `BEGIN TRANSACTION`, `SELECT ... FOR UPDATE`
- Phrases: "shared state", "background job", "queue worker", "concurrent requests", "race", "duplicate", "out of order"

Do not activate for: single-threaded sequential code, pure functions, stateless HTTP handlers that don't touch shared resources beyond a connection-pooled DB.

## Required Slots

1. **Shared state inventory.** What state is touched concurrently — DB rows, in-memory maps, files, cache entries, external resources? Listed by name. Concurrency reasoning is impossible without this list.
2. **Invariants that must hold.** What property must be true regardless of interleaving — "balance never negative", "no duplicate order ID", "writes always observed by subsequent reads in same session". State explicitly.
3. **Retry / idempotency stance.** Are operations idempotent? At-least-once or at-most-once delivery? What does duplicate execution produce? Drives whether retries are safe.
4. **Failure mode under partial completion.** If the operation crashes mid-flight, what does the world look like — partial write, orphaned row, dangling lock? Plan must name the state and the recovery path.
5. **Test environment.** Can races be reproduced — race detector, load test, fault injection, none? Determines confidence in correctness claims.

## Template Sections

Append to base body, after `## Constraints`, before terminal sections.

### Shared State Inventory

| State | Type | Accessors (read/write paths) | Protection mechanism |
|---|---|---|---|
| {DB table / map / file / cache} | {persistent / in-memory} | {functions or services that touch it} | {lock / transaction / lock-free + invariant} |

### Invariants Under Concurrency

- **{Invariant}** — must hold for any interleaving. How enforced: {DB constraint / lock scope / atomic op / monotonic counter}.
- {Repeat per invariant — 2-5 typical.}

### Failure Mode Enumeration

| Failure point | What partial state results | Detection | Recovery |
|---|---|---|---|
| {crash between step A and step B} | {orphaned row / dangling lock / lost message} | {monitor / scheduled reconciliation / manual} | {idempotent retry / cleanup job / human} |

### Idempotency Stance

- **Delivery semantics:** {at-least-once | at-most-once | exactly-once via X mechanism}
- **Idempotency key:** {request ID / hash / DB unique constraint — what makes duplicates safe}
- **Retry policy:** {bounded retries, backoff, dead-letter destination}

### Test Strategy for Races

- **Race detector / sanitizer:** {Go `-race`, ThreadSanitizer, etc. — does CI run it on this code path}
- **Concurrent load test:** {N workers hammering the path, asserting invariants — what tool, what duration}
- **Fault injection:** {kill mid-flight, drop messages, partition network — what scenarios are simulated}
- **Property tests:** {invariant expressed as property — "for any interleaving of these operations, X holds"}

## Discipline

- **Lock scope is part of the contract.** Acquiring two locks always in the same order, or use deadlock-free patterns (single-shot, try-lock with timeout). Document the order.
- **Transaction isolation level named explicitly.** "We use transactions" is not a plan. `READ COMMITTED` vs `SERIALIZABLE` vs `SNAPSHOT` changes correctness.
- **At-least-once is the safe default for messaging.** Exactly-once is a marketing claim; it's at-least-once plus idempotency.
- **Background workers without idempotency are bombs.** Retried jobs that aren't idempotent corrupt silently.
- **Test on multi-core in CI.** Single-core CI hides races by serializing scheduling.

## Common Failure Modes

- **"It works in tests" with no race detector.** Single-threaded test runs never observe the race.
- **Shared state inventory missing the implicit ones.** Connection pools, caches, package-level singletons, file system, environment variables — all shared state.
- **Invariants stated as code comments, not enforced.** If the DB doesn't enforce `balance >= 0`, the comment doesn't either.
- **Optimistic locking with no retry logic.** Conflict detection without conflict recovery is a 500 error to the user.
- **Distributed lock without lease/TTL.** A holder that crashes never releases — system wedges.
- **"It's only one writer" assumption.** Until the next feature adds a second writer.
