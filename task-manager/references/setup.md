# Setup — first-init bootstrap

Triggered when `tasks/` does not exist in the project root.

## Bootstrap

Initialize `tasks/` from this skill's bundled `templates/` directory. **Confirm with the
user before writing.**

- Always copy: `tasks/RUNE.md`.
- File backend only: `tasks/BACKLOG.md`, `tasks/TASK-LOG.md`, `tasks/archive/`.

## Setup prompts (ask once)

### 1. Backend

> Where should tasks live?
>
> - **github** (default) — GitHub issues in this repo. Recommended when the repo has a
>   GitHub remote and `gh` CLI is authenticated.
> - **file** — local markdown in `tasks/BACKLOG.md`. Use when offline-first or no GitHub
>   remote.

Write the answer to `backend:` in `tasks/RUNE.md`.

If `github` is chosen, **eagerly create the label set** defined in
`references/backend-github.md`. `gh label create --force` is idempotent — run it for every
label in the scheme (priority × 4, rune × 4, source × 4, status × 3).

### 2. Default coding mode

> What's this repo's default coding mode?
>
> - **dev** — tasks are 3-4 day chunks that ship meaningful problem slices
> - **vibe** — tasks are 1-subchunk atomic edits, no scaffolding, no speculative interfaces
> - **mixed** — both, classify per task

Write the answer to `default_mode:` in `tasks/RUNE.md`. Inherited by new tasks unless the
user overrides per-task. If `mixed`, the Rune gate asks every time.

## Switching backend mid-project

Not auto-migrated. If the user wants to move tasks from file → GitHub or vice-versa, run a
one-shot migration:

1. Enumerate tasks in the source backend.
2. Create equivalents in the target (preserving title / body / labels / status).
3. Have the user delete the source.

Refuse to operate in two backends simultaneously.
