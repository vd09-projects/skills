# Mimir — Project Config

Planning preferences for this project. Mimir reads this file in Phase 0.
Edit freely — fields not set fall back to safe defaults.

Mimir never reads other skills' memory. Cross-skill project context lives in CLAUDE.md.

---

## default_depth

How Mimir should resolve ambiguous detection.

- `ask` — always ask if architecture vs task is unclear (default)
- `architecture` — assume architecture when ambiguous
- `task` — assume task when ambiguous

Recommendation: leave at `ask` unless one type dominates this project's planning needs.

```
default_depth: ask
```

---

## domain_expert_role

Whether this project has a `domain-expert`-role skill installed. Mimir uses this
signal to decide whether to set `consumer_role: domain-expert` on architecture
artifacts.

- `present` — project has a domain-expert skill installed; Mimir routes architecture
  artifacts to it via `consumer_role: domain-expert`. The orchestrator (you or an
  agent) picks which specific skill fills the role.
- `none` — no domain-expert skill configured. Mimir routes architecture artifacts
  with `consumer_role: none` (user reads and routes manually).

Mimir never writes a specific skill name — only the role. The orchestrator decides
which installed skill fills the `domain-expert` role.

```
domain_expert_role: none
```

---

## always_overlays

Overlay slugs that should activate on every plan in this project, regardless of trigger match. Use sparingly — only when the project's nature guarantees the concern.

Examples:
- A data-platform project might force `data-migration` always.
- A platform/SRE project might force `infra-blast` always.
- A multi-team monorepo might force `cross-team` always.

Available overlays (catalog at `references/overlays/`):

- **Shape:** `phased-delivery`
- **Backend / data:** `data-migration`, `public-api-change`, `perf-critical`, `auth-authz`, `observability`, `concurrency`, `infra-blast`
- **Frontend:** `accessibility`, `state-management`, `i18n-l10n`
- **Cross-cutting:** `feature-flag`, `cross-team`

Default: empty list.

```
always_overlays: []
```

---

## never_overlays

Overlay slugs that should NEVER activate, even if triggers match. Use when a concern is genuinely irrelevant to this project (e.g., solo project: `cross-team` is noise).

Default: empty list.

```
never_overlays: []
```

---

## Notes

- Mimir never writes `status: approved` to an artifact. User edits the file
  manually to approve.
- Mimir never writes code. If you find a snippet in an artifact, file a bug.
- Mimir never names a specific consumer skill. Routing is via roles in the
  handoff protocol's role catalog (`planner`, `implementation`, `domain-expert`,
  `review`, `task-manager`, `decision-log`, `none`).
- Mimir does not invoke other skills. Sequencing is the orchestrator's job (an
  agent in `.claude/agents/`, or the user).
- All prior handoffs are preserved in `.claude/handoff/` forever — files are never
  deleted by the protocol. This is the audit trail.
- Mimir reads only CLAUDE.md (cross-skill project context), this config file, and
  the handoff directory (for the Scope Collision Flow). It does not read other
  skills' memory.
