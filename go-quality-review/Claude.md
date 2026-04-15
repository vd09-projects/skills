# Go Quality Review Skill — Complete Notes

## Problem statement

AI-generated (vibe-coded) Go code often has gaps: tests that hit lines but don't verify behavior, missing error handling, no TDD discipline, non-idiomatic patterns. Existing tools (linters, coverage) only catch surface-level issues. We need layered code review that goes from syntax to architecture.

---

## Solution: A reusable Claude Code skill

Instead of maintaining configs per-repo, a single skill carries all the knowledge and standards. It's portable across any Go repo.

---

## Skill structure

```
go-quality-review/
├── SKILL.md                          ← orchestrator (113 lines, always loaded)
├── references/
│   ├── review-levels.md              ← level × dimension matrix
│   ├── lint.md                       ← blocker/warning/suggestion severity
│   ├── test-quality.md               ← coverage + mutation + table-driven patterns
│   ├── best-practices.md             ← error handling, context, interfaces, naming
│   ├── behavior.md                   ← concurrency, channels, resource lifecycle
│   ├── architecture.md               ← dep direction, coupling, god-packages
│   └── golangci-config.md            ← why each linter is on/off
├── scripts/
│   ├── bootstrap.sh                  ← one-command repo setup
│   └── mutation.sh                   ← mutation testing wrapper
└── assets/
    ├── .golangci.yml                 ← golden lint config
    ├── CLAUDE.md.template            ← repo-level template with override slots
    └── go-quality.yml                ← GitHub Actions CI workflow
```

### Design principles

- **SKILL.md is the orchestrator** — always loaded, stays lean (<500 lines), decides which reference files to load
- **Each dimension is a standalone reference file** — self-contained, independently maintainable
- **Scripts handle deterministic tasks** — linting, mutation testing (same input → same output, every time)
- **Assets are template files** — copied into target repos during bootstrap
- **Repo's CLAUDE.md provides overrides** — skill carries universal standards, repo adds context

---

## Two modes

### Mode 1: Bootstrap
Sets up a Go repo with quality tooling:
1. Copies `.golangci.yml` to repo root
2. Generates `CLAUDE.md` from template with repo-specific context
3. Copies CI workflow to `.github/workflows/go-quality.yml`

### Mode 2: Review
Analyzes Go code against five dimensions at a chosen depth level.

---

## Five dimensions

| Dimension | Reference file | What it checks |
|-----------|---------------|----------------|
| Lint | `lint.md` | golangci-lint rules, static analysis, severity classification |
| Test quality | `test-quality.md` | Coverage, mutation testing, table-driven patterns, behavioral vs implementation tests |
| Best practices | `best-practices.md` | Error handling, context threading, interface design, naming, no init(), no globals |
| Behavior | `behavior.md` | Goroutine lifecycle, channel ownership, mutex usage, context flow, resource cleanup |
| Architecture | `architecture.md` | Dependency direction, package design, coupling, god-package detection, testability |

---

## Four review levels

### Quick (on save / commit, <30 sec)
| Dimension | Depth |
|-----------|-------|
| Lint | run + fix |
| Race detection | run |
| Test quality | skip |
| Best practices | skip |
| Behavior | skip |
| Architecture | skip |

### Standard (PR review, 1-3 min)
| Dimension | Depth |
|-----------|-------|
| Lint | run + fix |
| Race detection | run |
| Test quality | coverage check (70% threshold) |
| Best practices | error handling only |
| Behavior | skip |
| Architecture | skip |

### Deep (critical paths, 3-10 min)
| Dimension | Depth |
|-----------|-------|
| Lint | run + fix |
| Race detection | run |
| Test quality | coverage + mutation testing |
| Best practices | full checklist |
| Behavior | full analysis |
| Architecture | dep direction only |

### Pre-merge (release gate, 5-15 min)
| Dimension | Depth |
|-----------|-------|
| Lint | run + fix |
| Race detection | run |
| Test quality | coverage + mutation + pattern analysis |
| Best practices | full checklist |
| Behavior | full analysis |
| Architecture | full analysis (deps, coupling, god-packages) |

---

## Repo-level overrides

A repo's `CLAUDE.md` can override any cell in the matrix:

```markdown
## Review overrides
- behavior: always run at full depth, even for standard review
- architecture: skip for all levels (this is a CLI tool)
- test-quality: minimum coverage threshold is 85% (not 70%)
```

---

## How to extend

To add a new dimension (e.g., security):
1. Create `references/security.md` with the checklist
2. Add a row to the matrix in `references/review-levels.md`
3. Register it in SKILL.md's dimension table

Three touches, zero disruption to existing dimensions.

---

## Severity levels for findings

- **blocker** — must fix before merge (data races, silent error drops, security issues)
- **warning** — should fix, creates future problems (missing tests, high complexity, tight coupling)
- **suggestion** — would improve quality (naming, documentation, minor idiom violations)

---

## VS Code setup (companion tooling)

### golangci-lint in VS Code
```json
{
  "go.lintTool": "golangci-lint",
  "go.lintOnSave": "workspace",
  "go.lintFlags": ["--path-mode=abs", "--fast-only"]
}
```

### Claude Code VS Code extension
- Install from VS Code marketplace (official Anthropic extension)
- @-mention files for review
- Inline diffs for accept/reject
- Reads CLAUDE.md automatically

---

## Command reference

### Bootstrap — set up a new repo
```
set up go quality for this repo
bootstrap this Go project with linting and CI
add golangci-lint config and GitHub Actions workflow
initialize quality standards — it handles payments via Stripe
```

### Review — quick
```
quick check on this repo
just lint and race check pkg/auth
fast quality check before I commit
```

### Review — standard
```
review this PR
code review on the auth package
check the quality of this Go code
what's wrong with this service?
```

### Review — deep
```
deep review on pkg/payments
thorough review of the order processing pipeline
check for concurrency issues in the worker package
are my tests actually testing behavior?
run mutation testing on pkg/auth
```

### Review — pre-merge
```
pre-merge review — we're releasing this week
full review before merging to main
is this codebase ready to ship?
```

### Targeted — single dimension
```
check error handling across the whole repo
review the architecture and dependency direction
check if there are any goroutine leaks
are there any god packages in this project?
check test coverage and find weak tests
```

### Explain — understand the config
```
why is errcheck enabled in our golangci config?
explain the golangci-lint config choices
what review levels are available?
```

---

## Key decisions and rationale

1. **Dimensions over monolithic levels** — each dimension is independent, so adding/removing one doesn't affect others
2. **Levels are presets, not hard rules** — they just select which dimensions run at what depth
3. **Repo overrides via CLAUDE.md** — the skill sets the floor, repos customize on top
4. **Scripts for deterministic work** — linting and mutation testing shouldn't be "vibe-decided" by AI
5. **Reference files loaded on demand** — quick review loads almost nothing (fast, cheap), deep review loads everything (thorough)
6. **CI workflow included** — bootstrap generates a GitHub Actions workflow that runs lint, race detection, coverage with threshold, and formatting checks
7. **Explain why, not just what** — every finding includes the consequence, not just "this is wrong"

---

## Go best practices the skill enforces (summary)

### Error handling
- Every error must be handled (no silent discards)
- Errors wrapped with context using `fmt.Errorf("...: %w", err)`
- Never panic for expected errors
- Sentinel errors for `errors.Is`, custom types for `errors.As`

### Concurrency
- Every goroutine has a shutdown path
- Channels closed by sender, never receiver
- No mutex held during I/O
- Prefer errgroup over raw WaitGroup

### Context
- First parameter for any I/O function
- Thread through entire call chain (never `context.Background()` mid-chain)
- Every outgoing network call has a deadline

### Design
- Accept interfaces, return concrete types
- Define interfaces at consumer, not implementer
- No package-level mutable state
- No init() functions (except driver registration)
- Functions under 50 lines, max 3-4 parameters

### Testing
- Table-driven tests with named cases
- Cover happy path, empty input, boundary, error cases
- Test behavior, not implementation
- Use t.Helper() for test helpers
- t.Parallel() for independent tests

### Architecture
- Dependencies flow inward (handlers → domain ← store)
- No god packages (15+ files, 20+ exported types)
- No utils/helpers/common packages
- Package names describe what it does, not what it contains

---

## Files included in the skill

| File | Purpose | Lines |
|------|---------|-------|
| `SKILL.md` | Orchestrator, mode detection, review flow | 113 |
| `references/review-levels.md` | Level × dimension matrix, override format | 87 |
| `references/lint.md` | Lint finding severity, auto-fix, false positives | 69 |
| `references/test-quality.md` | Coverage, mutation testing, test patterns | 131 |
| `references/best-practices.md` | Error handling, context, interfaces, naming | 204 |
| `references/behavior.md` | Concurrency, channels, resources, context flow | 179 |
| `references/architecture.md` | Deps, coupling, god-packages, testability | 109 |
| `references/golangci-config.md` | Config rationale, override examples | 90 |
| `assets/.golangci.yml` | Golden lint config | 83 |
| `assets/CLAUDE.md.template` | Repo-level template | 46 |
| `assets/go-quality.yml` | GitHub Actions workflow | 56 |
| `scripts/bootstrap.sh` | One-command repo setup | 47 |
| `scripts/mutation.sh` | Mutation testing wrapper | 35 |