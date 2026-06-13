# Skald — Project Config

Persistence preferences for this project. Skald reads this file in Phase 0.
Edit freely — fields not set fall back to safe defaults.

Skald never reads other skills' memory. Cross-skill project context lives in CLAUDE.md.

---

## skill_registry

Maps producer-skill names to their handoff-protocol classification. Skald uses this to wrap a skill's natural markdown output with protocol-compliant frontmatter. Without an entry, Skald cannot classify the skill's output.

Default registry (auto-applied if this section is absent):

```yaml
skill_registry:
  mimir:
    producer_role: planner
    plan_types:
      - architecture
      - task
    default_consumer_role:
      architecture: domain-expert    # or 'none' if no domain-expert skill installed
      task: implementation
  sindri:
    producer_role: implementation
    plan_types:
      - build
    default_consumer_role:
      build: review
  multi-perspective-review:
    producer_role: review
    plan_types:
      - findings
    default_consumer_role:
      findings: implementation
```

Add new skills here as they're introduced. Each new entry needs:

- `producer_role` — from the role catalog in `skald/references/handoff-protocol.md`
- `plan_types` — list of artifact kinds this skill produces
- `default_consumer_role` — per plan_type, who should consume the result by role

Override `default_consumer_role` per project — e.g., set `architecture: none` if no domain-expert skill is installed; skald will skip the routing slot.

```yaml
skill_registry: {}
```

(Empty map means use defaults above. Override on a per-skill basis as needed.)

---

## default_owner

Default value for the `Owner` column in `INDEX.md` when an artifact does not declare one explicitly. Use the user's name, GitHub handle, or team initials.

```
default_owner: vd
```

Set to `_` to leave the column blank by default.

---

## slug_style

How candidate slugs are derived from `scope_hint`.

- `kebab` — lowercase, dashes (default, recommended). `auth redesign` → `auth-redesign`.
- `kebab-noun` — drop verbs and stop words, keep nouns. `Plan the auth redesign` → `auth-redesign`.
- `prefixed` — prepend a project-wide prefix (e.g., team or product code). Set `slug_prefix` below.

```
slug_style: kebab
slug_prefix: ""
```

---

## confirm_existing_match_threshold

String-similarity threshold (0.0 – 1.0) above which Skald treats a candidate slug as a close match to an existing scope and prompts for reuse. Default 0.7. Higher = stricter (only near-identical slugs prompted). Lower = more prompts.

```
confirm_existing_match_threshold: 0.7
```

---

## index_format

Format of `.claude/handoff/INDEX.md`. Default markdown table. YAML option for machine-readable workflows.

- `markdown` (default) — table with `| Slug | Title | Status | ... |` columns. Human-readable.
- `yaml` — YAML list at the top of `INDEX.md`. Programmatic parsing easier; humans can still read.

```
index_format: markdown
```

---

## status_overrides

Project-specific status names that override the default Status Aggregation table in Skald's SKILL.md. Use when the team has a preferred vocabulary (e.g., "blocked", "shipped", "deployed").

Default: empty, use Skald's built-in mapping.

```
status_overrides: {}
```

Example:

```
status_overrides:
  review-pending: "in-review"
  ready-for-review: "ready-for-review"
  build-in-progress: "wip"
```

---

## Notes

- Skald never writes `status: approved` to an artifact. User edits the canonical file
  manually to approve.
- Skald never edits the body of a producer's output. It persists as-given.
- Iterations are preserved forever in `{slug}/_history/`. There is no delete operation.
- The scope registry at `scopes.md` is grown by Skald; it should not be edited freehand
  by humans (unless renaming a slug, in which case both `scopes.md` AND the scope dir
  itself must be moved together).
- All prior handoffs are preserved in `.claude/handoff/{slug}/_history/` forever —
  files are never deleted by the protocol. This is the audit trail.
