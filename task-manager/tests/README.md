# task-manager tests

Verify behaviors documented in `SKILL.md`. Pure shell, no project dependencies.

## What's covered

- `detect_backend.sh` — extracted detection logic from the `## Backend` section of `SKILL.md`.
  Reads `backend:` from a `tasks/RUNE.md`-style file and resolves to `github` or `file`
  following the same rules an agent would apply (default github; fallback to file when `gh`
  CLI is missing or no GitHub remote; unknown values default to github with a warning;
  missing RUNE.md exits 2 so the caller knows to run setup).
- `test_backend_detection.sh` — matrix of fixtures × gh-CLI states.

| Case | Fixture | gh state | Expected |
|---|---|---|---|
| T1 | backend=github | present + remote | `github`, no warning |
| T2 | backend=github | absent | `file`, warning |
| T3 | backend=github | present, no remote | `file`, warning |
| T4 | backend=file | present + remote | `file`, no warning (gh not consulted) |
| T4b | backend=file | absent | `file`, no warning |
| T5 | no backend field | present + remote | `github` (default), no warning |
| T6 | backend=jira (invalid) | present + remote | `github` (default), warning |
| T7 | RUNE.md missing | any | exit 2, warning |

`gh` is stubbed via `stubs/gh_ok` and `stubs/gh_no_remote`; "absent" simply removes `gh` from
PATH for that case. No real GitHub calls are made.

## Run

```
bash tests/test_backend_detection.sh
```

Exit code 0 = all pass. Non-zero lists failed case names.

## Not covered (yet)

- Mode-specific flows (Create / Status / etc.) — those issue `gh` mutations against a live repo;
  exercise manually or wire up a sandbox repo.
- Migration between backends — manual.
