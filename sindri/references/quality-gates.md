# Quality Gates

Every build must clear these before `Ready for review.` is declared. The gate applies regardless of urgency, scope, or how small the change is. If a gate can't be cleared, name it explicitly and get user sign-off before shipping anyway.

**Language-specific gate extensions** live in each language reference file (`references/languages/go.md`, etc.) under a "Quality gate extensions" section. Those stack on top of these generic gates.

**Domain-specific gates** (from `domain.md`) stack on top of both. If `domain.md` conflicts with this file, `domain.md` is the authority.

**Spike mode** skips the Tests and Decisions sections below. Happy path verification + basic error path coverage is sufficient. All output must be labeled spike-quality.

---

## Correctness

- **Happy path works** — code does what was asked.
- **Error paths handled** — errors are not swallowed silently. Every error either propagates to the caller with context, logs at an appropriate level, or is documented as intentionally ignored with a comment explaining why.
- **Errors carry context** — error messages identify the operation and the relevant variable (e.g., "loading config from path X" not just "loading failed"). Caller should be able to trace the failure origin without a debugger.
- **Partial failure is safe** — if a multi-step operation fails midway, the system is left in a consistent state. No half-written records, no leaked resources, no orphaned connections.
- **No crash on valid input** — if a caller can trigger an unhandled exception, panic, or crash by passing a zero value, null, empty collection, or other valid-but-edge input, that's a bug not their fault.

## Tests

- **New behavior has tests** — non-trivial logic is covered. "Non-trivial" means: a bug here would be hard to catch by reading the code alone. Config parsers, validators, business logic, error paths — all need tests.
- **Tests test behavior, not implementation** — a test that breaks on refactor without the behavior changing is a bad test. Test inputs and outputs, not intermediate steps.
- **Edge cases named** — zero values, empty inputs, maximum bounds, the thing that caused the original bug. If a test case exists because of a specific scenario, name the test case after the scenario.
- **Tests are deterministic** — no flakiness from timing, concurrency, or external state. Tests that depend on wall-clock time use a fake clock.

## Code quality

- **No magic values** — literals that encode business meaning are named constants or config. `86400` is not a timeout; a named constant `SessionTimeoutSeconds` is. Language-specific form in the language reference file.
- **No speculative code** — nothing in the diff wasn't asked for. No "might be useful later" helpers.
- **No leftover debug artifacts** — no commented-out code, no debug print statements (`print`, `console.log`, language-specific equivalents) left in.
- **TODOs are tracked** — any TODO left in the code has a corresponding ticket or tracking reference. "TODO: fix this" without a reference is a debt item with no owner.
- **Functions are focused** — a function does one thing at one level of abstraction. Mixing "validate input, compute result, persist, send notification" in one function is a signal to split.

## Decisions

- **Non-obvious choices are marked** — any structural decision, library pick, or tradeoff that would make a reader ask "why did they do it this way?" gets an inline decision mark. The test: would the diff alone explain it in three months? If not, mark it.
- **Format:**
  ```
  Decision: [convention | architecture | tradeoff] — [one sentence on what was decided]
  Why: [the reason the alternative was rejected or this approach was chosen]
  ```

## Scope

- **Change matches the task** — no additions beyond what was asked. If a related improvement was noticed, surface it as a suggestion rather than shipping it unrequested.
- **No silent behavior changes** — any change to existing observable behavior (return values, errors, side effects, performance characteristics) is called out in the response.
