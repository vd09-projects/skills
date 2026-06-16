# Rune Configuration

**Last updated:** YYYY-MM-DD

## Backend

```
backend: github
```

Allowed values:

- `github` — tasks stored as GitHub issues in the repo where this skill is imported. Default. Requires the `gh` CLI authenticated and a GitHub remote.
- `file` — tasks stored as markdown in `tasks/BACKLOG.md`. Used when no GitHub remote / `gh` CLI is available, or when the project explicitly prefers local files.

If this field is missing, the skill assumes `github`. If `github` is selected but `gh` CLI is missing or the repo has no GitHub remote, the skill warns and falls back to `file`.

## Default mode

```
default_mode: mixed
```

Allowed values:

- `dev` — every new task defaults to `dev` rune. Suits repos shipping multi-day feature slices.
- `vibe` — every new task defaults to `vibe` rune. Suits repos in maintenance / small-edit mode.
- `mixed` — Rune mode asks per task. Suits repos doing both.

## Sizing rubric

| Rune | Solves | Output | Sizing | Forbidden |
|---|---|---|---|---|
| **dev** | Big chunk of the problem; an end-to-end feature slice. | Shipped code + tests + integration. | 3-4 days of focused work. | Splitting itself into vibe siblings to dodge review weight. |
| **vibe** | One subchunk of an already-understood problem. | Concrete code edit, atomic and reviewable. | Hours, one focused diff. | Interfaces, scaffolding, speculative abstractions, "set up the structure for". |
| **research** | Unknown — how does X work, what library to use, what does the API return. | Written findings or decision-journal entry. | Bounded timebox. | Shipping production code. |
| **analysis** | Best approach unclear — known problem, unknown solution. | Tradeoff comparison + recommendation. | Bounded timebox. | Shipping production code. |

## Exceptions

<!-- Per-area overrides if some part of the repo follows a different default. -->
<!-- Example: -->
<!-- - path: src/experimental/* → default_mode: vibe -->
<!-- - path: src/core/* → default_mode: dev -->

_No exceptions defined._

## Notes

- Rune is set at task creation by Mode 8 (Rune) of the task-manager skill.
- Reclassify any task with "rune for TASK-NNNN" or "is this vibe or dev?".
- Decompose (Mode 7) uses this rubric in both directions: split oversized tasks, merge undersized
  clusters.
