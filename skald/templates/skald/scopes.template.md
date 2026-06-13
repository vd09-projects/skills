# Skald — Scope Registry

Append-only registry of every scope Skald has touched in this project. Maintained by Skald — humans should not edit freehand except for slug-rename operations (which require moving the scope dir AND renaming this entry together).

Each entry records WHY the slug was chosen so future readers can answer "why is this called X and not Y?".

---

```yaml
scopes:
  # Example — replace with real entries as Skald creates them.
  #
  # - slug: auth-redesign
  #   title: "JWT rotation + session invalidation"
  #   created: 2026-05-20
  #   created_by: vd
  #   reasoning: |
  #     Broader than just JWT — also covers session invalidation and
  #     logout coherence. User considered 'jwt-rotation' but it didn't
  #     capture the session-mgmt half.
  #   aliases: [jwt-rotation, session-redesign]
  #   status: active   # active | done | archived
```

---

## Field definitions

| Field | Required | Notes |
|---|---|---|
| `slug` | yes | Kebab-case, lowercase, ≤40 chars, alphanumeric + dashes. Matches the scope dir name. |
| `title` | yes | One-line title for INDEX.md display. |
| `created` | yes | ISO date (YYYY-MM-DD) of first creation. |
| `created_by` | yes | Skald's `default_owner` config value, or whatever the user supplied. |
| `reasoning` | yes | Multi-line explanation of WHY this slug over alternatives. Required at creation. The "why this name?" answer. |
| `aliases` | no | Other slugs Skald should treat as equivalent (matched on next resolution). Grown when user picks `[a] add candidate as alias` during slug resolution. |
| `status` | yes | `active` (work ongoing), `done` (no further iteration expected), `archived` (scope dir moved out of `.claude/handoff/`). |

---

## How Skald uses this file

- On every slug resolution (Phase 1), Skald reads this file PLUS the `.claude/handoff/` directory listing. Both are sources of truth; this file holds the reasoning, the dir holds the artifacts.
- New entries are appended at the END of the list (newest at bottom). Do not reorder — newer entries near the bottom is the only ordering rule.
- Skald never deletes entries. If a scope becomes irrelevant, mark `status: archived` and (optionally) move its dir to `.claude/handoff/_archive/{slug}/` outside the protocol.

---

## Manual edits

Safe:

- Add an alias to an existing entry. (Skald will pick it up on next resolution.)
- Update `status` field (e.g., `active` → `done`).
- Correct typos in `title` or `reasoning`.

Risky:

- Renaming a `slug` — must also rename the scope directory `.claude/handoff/{old-slug}/` → `.claude/handoff/{new-slug}/` AND update any inter-scope cross-references in `_thread.md` files. Skald has no tooling for this; do it manually with care.

Forbidden:

- Removing entries. Even archived scopes stay in the registry — audit trail.
- Reordering entries. Append-only.
