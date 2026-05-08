# go-quality-review

A multi-level code review and repo bootstrapping skill for Go projects. Operates in two modes — Bootstrap (initial repo setup with quality tooling) and Review (analyze code against five dimensions at a chosen depth level: quick, standard, deep, or pre-merge).

## What it does

**Bootstrap mode:** Sets up a Go repo with quality tooling — `.golangci.yml`, a `CLAUDE.md` template, and an optional GitHub Actions CI workflow.

**Review mode:** Analyzes Go code against five dimensions at four depth levels:

| Dimension | Reference file | Checks |
|-----------|---------------|--------|
| Lint | `references/lint.md` | golangci-lint, static analysis |
| Test quality | `references/test-quality.md` | Coverage, mutation testing, test patterns |
| Best practices | `references/best-practices.md` | Idioms, error handling, naming |
| Behavior | `references/behavior.md` | Concurrency, context, error types |
| Architecture | `references/architecture.md` | Dependencies, coupling, package design |

Review levels (`quick`, `standard`, `deep`, `pre-merge`) determine which dimensions are active and at what depth — see `references/review-levels.md` for the full matrix. Repo-level overrides via `CLAUDE.md` in the project root take precedence.

## What it is NOT

- **Not a persona skill.** This is a tool — a checklist runner with depth levels. No voice, no examples calibration, no judgment about whether code *should* exist (that's the developer's call).
- **Not an orchestrator.** Run it independently against code that's already been written. Other skills (e.g., `algo-trading-lead-dev` / Priya) write to its bar but don't invoke it.

## How it pairs with other skills

This skill is one piece of a larger workflow:

- **`algo-trading-lead-dev` (Priya)** — writes Go code to the bar this skill checks at the pre-merge level. Priya does not invoke this skill; the user (or a parent orchestrator) runs the reviewer independently.
- **`decision-journal`** — if a reviewer finding leads to an explicit override or tradeoff (e.g., "this function is intentionally 67 lines because splitting it harms readability"), the developer can mark that decision inline using the format in the journal's `references/inline-format.md`. The reviewer itself does not produce decision marks; it reports findings.

## Repo structure

```
go-quality-review/
├── SKILL.md                          # main skill file — modes, levels, dimension dispatch
├── README.md                         # this file
├── assets/
│   ├── .golangci.yml                 # golangci-lint config (Bootstrap copies this)
│   ├── CLAUDE.md.template            # repo-context template (Bootstrap customizes this)
│   └── go-quality.yml                # GitHub Actions CI workflow (Bootstrap copies this)
├── references/
│   ├── review-levels.md              # the level matrix (quick/standard/deep/pre-merge)
│   ├── lint.md                       # lint dimension checklist
│   ├── test-quality.md               # test quality dimension
│   ├── best-practices.md             # best practices dimension
│   ├── behavior.md                   # behavior dimension
│   ├── architecture.md               # architecture dimension
│   └── golangci-config.md            # explanation of golangci-lint choices (loaded on demand)
└── scripts/
    ├── bootstrap.sh                  # convenience script for Bootstrap mode
    └── mutation.sh                   # mutation testing helper
```

### Reference file loading

Reference files load on demand based on what the user is doing:

- **Bootstrap mode:** loads `golangci-config.md` if the user asks why specific linters are enabled.
- **Review mode:** loads `review-levels.md` to determine which dimensions are active at the chosen level, then loads only the reference files for active dimensions. Inactive dimensions are not loaded.

This means a `quick` review loads only `review-levels.md` + `lint.md`; a `pre-merge` review loads all five dimension files.

## Installation

Place the `go-quality-review/` folder wherever your project loads skills from. The `name` and `description` in the SKILL.md frontmatter handle triggering.

## Adding new dimensions

The skill is designed to be extended. To add a new review dimension (e.g., `security`):

1. Create `references/security.md` with the dimension's checklist.
2. Add a row to the matrix in `references/review-levels.md`.
3. Register the dimension in the table in `SKILL.md`'s Step 4.

No other files need to change. Each dimension is self-contained.
