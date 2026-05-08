# Review levels

This file defines four review level presets. Each level specifies which dimensions are active and at what depth.

## Level definitions

### quick

When to use: on save, on commit, quick sanity check.
Typical runtime: under 30 seconds.

| Dimension | Depth | What to do |
|-----------|-------|------------|
| Lint | run + fix | Run `golangci-lint run ./...` on the target scope. Report and auto-fix where possible. |
| Race detection | run | Run `go test -race ./...` on the target scope. |
| Test quality | skip | — |
| Best practices | skip | — |
| Behavior | skip | — |
| Architecture | skip | — |

### standard

When to use: PR review, regular code review.
Typical runtime: 1-3 minutes.

| Dimension | Depth | What to do |
|-----------|-------|------------|
| Lint | run + fix | Full golangci-lint run. |
| Race detection | run | Full race detection. |
| Test quality | coverage | Check coverage with `go test -coverprofile`. Flag packages below 70% coverage. Check if new code has corresponding tests. Do NOT run mutation testing. |
| Best practices | error handling | Focus only on the error handling checklist from best-practices.md. Skip other sections. |
| Behavior | skip | — |
| Architecture | skip | — |

### deep

When to use: reviewing critical paths, complex packages, services handling sensitive data.
Typical runtime: 3-10 minutes.

| Dimension | Depth | What to do |
|-----------|-------|------------|
| Lint | run + fix | Full golangci-lint run. |
| Race detection | run | Full race detection. |
| Test quality | full | Coverage check + mutation testing. Analyze whether tests verify behavior or just execute code. |
| Best practices | full | Run the complete checklist from best-practices.md. |
| Behavior | full | Full analysis from behavior.md — concurrency, context threading, error types, goroutine lifecycle. |
| Architecture | dep direction | Check dependency direction only — are dependencies flowing the right way? Skip coupling and package design analysis. |

### pre-merge

When to use: final gate before merging to main, release preparation.
Typical runtime: 5-15 minutes.

| Dimension | Depth | What to do |
|-----------|-------|------------|
| Lint | run + fix | Full golangci-lint run. |
| Race detection | run | Full race detection. |
| Test quality | full | Coverage + mutation + test pattern analysis. |
| Best practices | full | Complete checklist. |
| Behavior | full | Complete analysis. |
| Architecture | full | Full analysis — dependency direction, coupling metrics, package design, god-package detection. |

---

## How repo overrides work

A repo's `CLAUDE.md` can override any cell in the matrix above. The format is:

```markdown
## Review overrides
- behavior: always run at full depth, even for standard review
- architecture: skip for all levels (this is a CLI tool)
- test-quality: minimum coverage threshold is 85% (not 70%)
```

When overrides exist, they replace the corresponding cell. Dimensions not mentioned in overrides keep their default depth from the level preset.

---

## Extending this matrix

To add a new dimension:
1. Choose a name (e.g., `security`)
2. Decide which levels activate it and at what depth
3. Add a row to each level table above
4. Create the corresponding reference file (e.g., `references/security.md`)
5. Register it in SKILL.md's dimension table
