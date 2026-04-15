# Lint dimension

This dimension runs static analysis via golangci-lint and interprets the results.

## Execution

Run golangci-lint on the target scope:

```bash
golangci-lint run ./...              # whole repo
golangci-lint run ./pkg/auth/...     # specific package
```

If the repo has a `.golangci.yml`, golangci-lint uses it automatically. If not, flag this — the repo should be bootstrapped first.

## Interpreting results

Not all lint findings are equal. Prioritize by impact:

### Blocker-level lint findings

These indicate real bugs or serious risks:

- **errcheck** — an error return value is silently discarded. This hides failures and makes debugging impossible. Every error must be handled or explicitly ignored with `_ =` and a comment explaining why.
- **govet** — catches misuse of sync primitives, printf format mismatches, struct tag errors, unreachable code. These are almost always real bugs.
- **staticcheck SA**** — the SA-series checks from staticcheck find real bugs: nil dereferences, impossible conditions, deprecated API usage, incorrect sync usage.
- **bodyclose** — HTTP response bodies that are never closed cause connection leaks.
- **sqlclosecheck** — unclosed SQL rows cause connection pool exhaustion.
- **durationcheck** — incorrect time.Duration arithmetic (e.g., `time.Sleep(n)` where n is already a Duration).

### Warning-level lint findings

These create maintenance burden or indicate code smell:

- **gosimple** — code that has a simpler equivalent. Not a bug, but makes code harder to read.
- **ineffassign** — assignments to variables that are never read. Usually leftover from refactoring.
- **unused** — unexported functions/types/variables that nothing references.
- **cyclop / gocognit** — function complexity exceeds threshold. Functions over 15 cyclomatic complexity are hard to test and understand.
- **gocritic** — anti-patterns like unnecessary type assertions, suboptimal range loops, non-idiomatic nil checks.
- **exhaustive** — switch statements on enum types that don't cover all cases. Missing cases often mean missing logic.

### Suggestion-level lint findings

These improve code quality but aren't urgent:

- **revive** — style and convention violations: exported function without doc comment, package naming, receiver naming consistency.
- **gofumpt** — formatting beyond what gofmt enforces. Consistent formatting reduces diff noise.
- **godot** — comment formatting (periods at end of sentences).
- **misspell** — typos in comments and strings.

## Auto-fix

When the depth is "run + fix", attempt to fix findings automatically:

```bash
golangci-lint run --fix ./...
```

This auto-fixes formatting, import ordering, and some simple code transformations. Report what was auto-fixed and what remains for manual attention.

## Common false positives

Some findings are legitimate but intentional:

- `errcheck` on `fmt.Fprintf` to stdout/stderr — often acceptable in CLI tools
- `unused` on functions that are only called via reflection or code generation
- `exhaustive` on switches with a `default` case that intentionally catches future enum values

When flagging these, note them as "verify if intentional" rather than demanding a fix. If the repo's `.golangci.yml` has `nolint` directives with comments, respect the developer's judgment.
