# Golangci-lint configuration reference

This file explains the choices in `assets/.golangci.yml` so that developers understand why each linter is enabled and can make informed decisions about overrides.

## Linters enabled and why

### Bug detection (non-negotiable)

| Linter | Why it's on |
|--------|-------------|
| `govet` | Catches printf format mismatches, struct tag errors, unreachable code, sync misuse. These are real bugs. |
| `errcheck` | Finds unchecked error returns. Silent error drops are the #1 source of "it worked in dev, broke in prod." |
| `staticcheck` | The most comprehensive Go static analyzer. Finds nil dereferences, deprecated API usage, impossible conditions. |
| `bodyclose` | Unclosed HTTP response bodies leak connections. Hard to notice in testing, causes outages under load. |
| `sqlclosecheck` | Unclosed sql.Rows exhaust connection pools. Same category as bodyclose. |
| `durationcheck` | Catches `time.Sleep(5)` (5 nanoseconds) vs `time.Sleep(5 * time.Second)`. Common mistake. |
| `exportloopref` | Catches loop variable capture bugs in goroutines. Go 1.22+ fixed the default behavior, but older code still has this. |

### Code quality (strongly recommended)

| Linter | Why it's on |
|--------|-------------|
| `gosimple` | Suggests simpler equivalents. Simpler code has fewer bugs. |
| `ineffassign` | Dead assignments indicate refactoring leftovers. Cleaning them up makes code easier to read. |
| `unused` | Dead code is confusing and increases cognitive load. |
| `gocritic` | Catches anti-patterns: unnecessary type assertions, suboptimal slice operations, non-idiomatic nil checks. |
| `exhaustive` | Switch statements on enums should cover all cases. Missing cases often mean missing logic. |
| `cyclop` | Flags functions over 15 cyclomatic complexity. Complex functions are hard to test and understand. |

### Style and consistency (recommended)

| Linter | Why it's on |
|--------|-------------|
| `gofumpt` | Stricter formatting than gofmt. Reduces style-related diff noise across the team. |
| `revive` | Checks for exported functions without doc comments, receiver naming consistency, package naming. |
| `misspell` | Catches typos in comments and strings. Small thing, but typos erode trust in code quality. |

### Deliberately NOT enabled

| Linter | Why it's off |
|--------|-------------|
| `gochecknoglobals` | Too strict for most projects. Package-level constants and read-only config are fine. The best-practices dimension handles this with more nuance. |
| `wsl` | Whitespace linting is too opinionated and generates noise. |
| `nlreturn` | Requiring blank lines before returns is personal preference, not quality. |
| `gomnd` | Magic number detection has too many false positives (HTTP status codes, array indices). |
| `depguard` | Off by default because it requires project-specific configuration. Repos should enable it in their override with their specific banned packages. |

## Configuration structure

The config file uses golangci-lint v2 format. Key sections:

- `run.timeout` — set to 5 minutes. Complex projects need time. If linting times out, this should be increased, not the checks disabled.
- `linters.enable` — explicit list of enabled linters. No `enable-all` because that enables experimental and noisy linters.
- `linters-settings` — per-linter configuration (complexity thresholds, error-checking exclusions).
- `issues.exclude-rules` — targeted exclusions for known false positives (e.g., errcheck on test files using `t.Fatal`).
- `issues.max-same-issues` — set to 0 (no limit). Showing all issues is better than hiding them.

## How to override

Repos can override settings by modifying the `.golangci.yml` that bootstrap copies. Common overrides:

**Increase complexity threshold** (for legacy code being migrated):
```yaml
linters-settings:
  cyclop:
    max-complexity: 25  # default is 15, temporarily raised
```

**Add depguard rules** (repo-specific banned packages):
```yaml
linters:
  enable:
    - depguard
linters-settings:
  depguard:
    rules:
      main:
        deny:
          - pkg: "log"
            desc: "Use our structured logger (pkg/logger) instead"
          - pkg: "github.com/pkg/errors"
            desc: "Use stdlib errors and fmt.Errorf with %w"
```

**Disable a linter for the whole repo** (with justification):
```yaml
linters:
  disable:
    - exhaustive  # this repo uses open enums by design
```
