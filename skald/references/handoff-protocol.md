# Handoff Protocol — v2

Generic cross-skill handoff contract. **Only one skill — `skald` — knows this protocol.** Every other skill (mimir, sindri, multi-perspective-review, future skills) produces natural markdown output and stays oblivious. Skald reads producer output, classifies it via a tiny title-line contract, wraps it with protocol-compliant frontmatter, and persists.

This file is the canonical spec. **It is documentation for skald and skill authors, not loaded at runtime.** Producer skills do not implement this protocol — they only owe the title contract (see below).

## Design principle

Each skill does what it's best at. Mimir is a strategist; sindri is a builder; multi-perspective-review is a critic; skald is a chronicler. None of the first three should know about scope dirs, role catalogs, canonical filenames, or YAML frontmatter — that's bookkeeping work, and bookkeeping belongs to skald.

## v2 changes (vs v1)

Breaking:

- Layout changed from flat `.claude/handoff/*.md` to per-scope directories: `.claude/handoff/{slug}/...`.
- Filenames changed from timestamped (`{date}-{plan_type}-{slug}.md`) to idempotent canonical (`{producer_role}-{plan_type}.md`).
- Iterations preserved in `_history/{canonical}-v{N}.md`, not by emitting new top-level files.
- Producer skills no longer emit any handoff fields — they produce plain markdown. Skald reads, classifies, wraps, writes.
- Two new index files at `.claude/handoff/` root: `INDEX.md` (per-scope table) and `LOG.md` (append-only chronology).

v1 artifacts (flat files) are not auto-migrated. They remain in place as audit trail. To upgrade an existing project, run a one-shot migration that reorganizes existing artifacts into scope dirs.

---

## Why this exists

- Skills must not know about each other or about the persistence layer. They produce output. Period.
- One scope = one directory. Answers "what happened on auth-redesign?" in a single `ls` + read.
- Indices answer "what's in flight?" and "what happened recently?" without scanning every file.
- Skald handles all bookkeeping — classification, slug resolution, frontmatter, iteration, indices.

---

## Layout

```
.claude/handoff/
├── README.md                              # team-readable schema doc (templated)
├── INDEX.md                               # per-scope status table
├── LOG.md                                 # append-only chronology
├── {slug}/                                # one dir per scope
│   ├── _thread.md                         # narrative log of every skill run on this scope
│   ├── {producer_role}-{plan_type}.md     # canonical artifact (latest version)
│   ├── ...
│   └── _history/
│       └── {producer_role}-{plan_type}-v{N}.md
└── {other-slug}/
    └── ...
```

### Filename convention

Canonical artifact filename within a scope dir:

```
{producer_role}-{plan_type}.md
```

Examples:

- `planner-architecture.md` — mimir's architecture artifact (mimir declares `producer_role: planner`).
- `planner-task.md` — mimir's task artifact for this scope.
- `implementation-build.md` — sindri's build summary (sindri declares `producer_role: implementation`).
- `review-findings.md` — multi-perspective-review's review artifact.

The filename is **role-derived**, not skill-derived. This preserves the no-skill-names-in-protocol invariant. Multiple skills implementing the same role write to the same canonical filename in a given scope — at most one such skill should be active per project to avoid clobbering.

### History (iterations)

When the same canonical filename already exists in a scope dir, skald:

1. Reads `version` from the existing file's frontmatter (default 1 if absent).
2. Moves the existing file to `_history/{canonical}-v{N}.md` where N = current version.
3. Writes the new content to the canonical filename with `version: N+1`.
4. Appends a `_thread.md` entry: date, role, new version, status, one-line summary.

`_history/` files are NEVER deleted. Full iteration log preserved forever.

### Scope dir structure

```
.claude/handoff/auth-redesign/
├── _thread.md                            # auto-maintained narrative
├── planner-architecture.md               # latest (v3)
├── planner-task.md                       # latest (v2)
├── implementation-build.md               # latest (v1)
├── review-findings.md                    # latest (v1)
└── _history/
    ├── planner-architecture-v1.md
    ├── planner-architecture-v2.md
    └── planner-task-v1.md
```

---

## Artifact schema (v2)

Markdown file with YAML frontmatter + freeform body.

```yaml
---
artifact_type: handoff
artifact_version: 2
producer_role: planner
consumer_role: implementation
plan_type: architecture
slug: auth-redesign
scope_hint: <one-line summary of scope>
canonical_name: planner-architecture       # producer suggests; skald enforces
status: draft | approved | consumed
version: 1                                 # bumped by skald on each iteration
created: YYYY-MM-DDTHH:MM:SSZ              # ISO-8601 UTC, set on first write
updated: YYYY-MM-DDTHH:MM:SSZ              # set on every (re)write
prior_versions: [v1, v2]                   # filenames in _history/
---
```

### Field definitions

| Field | Required | Values | Notes |
|---|---|---|---|
| `artifact_type` | yes | `handoff` | Identifies the protocol. |
| `artifact_version` | yes | `2` | Producers and consumers refuse mismatched versions. |
| `producer_role` | yes | role catalog | Identifies who wrote it (role, not skill name). |
| `consumer_role` | yes | role catalog or `none` | Routing target. |
| `plan_type` | yes | `architecture`, `task`, `review`, others | Producer-defined sub-type. |
| `slug` | yes | kebab-case, ≤40 chars | Matches the scope dir name. |
| `scope_hint` | yes | one-line free text | Cross-scope readability; consumers may use to disambiguate. |
| `canonical_name` | yes | `{role}-{type}` | Producer suggests; skald enforces consistency. |
| `status` | yes | `draft`, `approved`, `consumed` | Lifecycle gate. |
| `version` | yes | integer ≥ 1 | Skald bumps on each iteration. |
| `created` | yes | ISO-8601 UTC | First-write timestamp. |
| `updated` | yes | ISO-8601 UTC | Latest-write timestamp. |
| `prior_versions` | no | list of filenames | Skald maintains; references `_history/` entries. |

Producers may add additional frontmatter fields; consumers ignore unknown fields. Unknown fields are not errors.

### Body sections

Producer-defined. Protocol does not constrain body structure. Each producer documents its body format in its own references.

---

## Status lifecycle

```
draft → approved → consumed
```

Unchanged from v1:

- **`draft`** — producer just wrote it. Not safe to consume.
- **`approved`** — user (or approving agent) flipped status. Safe to consume.
- **`consumed`** — consumer used it as scope and finished. Future consumers skip.

Iteration interaction: when a new version is written (skald bumps `version`), `status` resets to `draft`. User must re-approve. Prior versions retain their final status in `_history/`.

### Who flips status?

| Transition | Who | How |
|---|---|---|
| `draft` → `approved` | User (MVP) | Edits the canonical file. |
| `approved` → `consumed` | Consumer | Writes back to the file after using as scope. |

Skald never writes `approved` to its own output.

---

## Role catalog (unchanged from v1)

Roles are domain functions, not skill names. Multiple skills can implement the same role; one skill may declare multiple roles.

| Role | Meaning | Typical artifact body |
|---|---|---|
| `planner` | Produces approach, options, or task breakdown. No code. | Problem, constraints, options or steps, recommendation, scope, risks, success metric. |
| `implementation` | Consumes a plan, produces code + tests. | Build summary, files modified, tests written, quality gate result. |
| `review` | Consumes code or design, produces findings. | Findings list, severity, recommendations. |
| `domain-expert` | Provides domain judgment (methodology, edge, safety calls). | Verdict, reasoning, conditions. |
| `task-manager` | Maintains task backlog / state. | Task records. |
| `decision-log` | Maintains decision journal. | Decision records. |
| `orchestrator` | Invokes other skills, persists output, maintains indices. | None (skald itself does not write artifacts; it writes the indices and persists others' artifacts). |
| `none` | Informational. No expected consumer. | N/A. |

---

## Skill Output Contract

This is what producer skills owe. Tiny. Title-only.

A skill that wants its output captured into the handoff layer MUST produce a markdown response whose first H1 line follows this shape:

```
# {ArtifactKind}: {one-line scope title}
```

Where `{ArtifactKind}` matches a known label that skald can classify:

| ArtifactKind prefix | → `plan_type` skald infers | Typical producer |
|---|---|---|
| `Architecture` | `architecture` | mimir |
| `Task plan` / `Task` | `task` | mimir |
| `Build summary` / `Build` | `build` | sindri |
| `Review findings` / `Review` | `findings` | multi-perspective-review |
| `Decision` | `decision` | future decision-log skill |

After the title, the body is the skill's natural output — sections, tables, prose, whatever the skill considers correct for its domain. No frontmatter. No YAML. No `status` field. No `producer_role` declaration.

**Optional side metadata** — skald reads the first ~5 lines below the title for these lightweight markers:

- `**Overlays:** slug-1, slug-2` — captured into the persisted frontmatter's `overlays` field.
- `**Owner:** name` — captured into INDEX.md's Owner column.

Unknown side-metadata lines are passed through unchanged.

That's the entire contract. A skill can be completely oblivious to the rest of this document and still participate in the handoff layer.

---

## Skald — the only protocol implementer

Skald is the skill that knows the handoff protocol. It reads producer skills' natural markdown output, classifies it via the title line, looks up the producer's role via its `skill_registry`, generates protocol-compliant frontmatter, computes the canonical filename, resolves the scope slug, handles iteration archive, writes the canonical file, and updates indices.

Skald's full behavior is documented in `skald/SKILL.md` and `skald/references/operations.md`. This protocol doc defines the on-disk schema; skald's docs define the runtime algorithm.

### Skill registry (in skald's config)

Skald maps skill names to producer roles via `.claude/skill-memory/skald/config.md`'s `skill_registry` section. Default entries cover `mimir`, `sindri`, `multi-perspective-review`. New skills are added on first invocation (user confirms registry entry).

### Slug Resolution

Skald derives a candidate slug from the title's `{one-line scope title}` portion, matches against the scope registry (`.claude/skill-memory/skald/scopes.md`), and prompts the user when ambiguous or new. The scope registry records reasoning so future readers can answer "why is this called X and not Y?".

---

## Consumer reading

Consumer skills do NOT scan `.claude/handoff/` on their own. Skald-mediated invocation passes the relevant scope brief (the body of the upstream approved artifact) directly to the consumer skill as part of the invocation context. The consumer treats the brief as authoritative scope; it never parses YAML frontmatter, never iterates over files, never knows about canonical naming.

When a consumer skill finishes its work, it tells skald "done"; skald handles updating `status: approved → consumed` on the upstream artifact. Consumers do not write to `.claude/handoff/`.

**Standalone invocation** (consumer without skald): the consumer interrogates the user from scratch. There's no automatic discovery of prior artifacts; that's intentional — handoff reading is bookkeeping, and bookkeeping requires skald.

### Programmatic / external readers

Tools, scripts, dashboards, or other agents that want to query the handoff layer directly (not through a producer/consumer skill flow) can read files at the canonical paths and parse YAML frontmatter — the on-disk schema is stable and grep-friendly. See `skald/templates/handoff-readme.template.md` for example queries.

---

## Index files

### `.claude/handoff/INDEX.md`

Per-scope table. Skald rewrites the relevant row on every write. Rows sorted by `updated` descending.

```markdown
# Handoff Index

| Slug | Title | Status | Last Skill | Version | Updated | Owner |
|------|-------|--------|------------|---------|---------|-------|
| auth-redesign | JWT rotation + session invalidation | review-requested | planner-architecture | v3 | 2026-05-21 | vd |
| payment-refund | Idempotent refund flow | build-in-progress | implementation-build | v2 | 2026-05-21 | vd |
```

- `Status` aggregates the scope's latest meaningful state — derived from the most recent artifact's status + role. (`review-requested` = a `review-findings.md` is `draft`, blocking; `build-in-progress` = an `implementation-build.md` exists at status `draft` etc.)
- One row per scope. Rewrite in place; don't append.

### `.claude/handoff/LOG.md`

Append-only chronology. Skald appends one row per artifact write.

```markdown
# Handoff Log

| Date | Scope | Role | Plan Type | Version | Status | Notes |
|------|-------|------|-----------|---------|--------|-------|
| 2026-05-20 14:30 | auth-redesign | planner | architecture | v1 | draft | initial ADR |
| 2026-05-20 16:00 | auth-redesign | planner | architecture | v2 | draft | recommendation flipped to Option B |
| 2026-05-21 09:00 | auth-redesign | implementation | build | v1 | draft | build complete, quality gate PASS |
| 2026-05-21 11:00 | auth-redesign | review | findings | v1 | draft | 2 blockers, 1 suggestion |
```

### `.claude/handoff/{slug}/_thread.md`

Narrative log for one scope. Skald appends one entry per artifact write. More detailed than `LOG.md`; includes one-paragraph summary if producer supplied one.

```markdown
# Thread — auth-redesign

JWT rotation + session invalidation.

---

## 2026-05-20 14:30 — planner architecture v1 (draft)

Initial ADR. Three options compared: rotating JWT, opaque session
tokens, hybrid. Recommendation: rotating JWT with short TTL.

## 2026-05-20 16:00 — planner architecture v2 (draft)

User pushed back on Option A. Recommendation flipped to Option B
(opaque session tokens) on the strength of revocation use cases.

## 2026-05-21 09:00 — implementation build v1 (draft)

Build complete on Option B. Quality gate PASS. 12 tests added.
Recommend multi-perspective-review.
```

---

## Conflict resolution

If multiple `approved` artifacts in the same scope match a consumer's role (shouldn't happen under canonical-name discipline, but possible if two skills implement the same role), the consumer surfaces ambiguity to the user and refuses to pick one autonomously.

If multiple scopes match a `scope_hint`-driven query (consumer invoked without explicit slug), consumer asks user to pick the scope.

Never auto-pick by recency, alphabetical order, or any other heuristic.

---

## Privacy / manual cleanup

The protocol provides no delete operation. If a user wants to delete an artifact (sensitive data, accidental commit), they delete the file manually outside the protocol. Skills MUST NOT offer that path.

Recommended: `.claude/handoff/` can be `.gitignore`d if artifacts contain sensitive data; or committed if audit trail in version control is desired. Project's choice.

---

## Versioning

`artifact_version` integer. Bumped on breaking changes (field removal, semantic shift, role catalog reduction). Producers and consumers refuse mismatched versions.

v1 → v2 is a breaking change. v1 artifacts (flat files) remain in place as audit trail; consumers refuse to consume them. A one-shot migration script can move v1 files into per-scope dirs and rewrite frontmatter to v2 if desired.

---

## Orchestration (informational)

The protocol governs the artifact exchange + persistence layer. Skald is the persistence orchestrator. A separate agent may sequence which producer / consumer skills run when (e.g., `.claude/agents/coordinator.md`).

Skald itself is invocable directly: `skald run mimir on auth-redesign` runs mimir as a subagent, captures output, persists per protocol. Or an outer agent can invoke skald for each step in a flow.

See `references/agent-pattern.md` for orchestration recipes.

---

## Anti-patterns

- **Producer skills emitting YAML frontmatter.** Producers emit title + body. Skald wraps.
- **Producer skills writing files.** Producers emit markdown to the caller. Skald persists.
- **Producer skills computing filenames, slugs, versions, timestamps.** All skald's job.
- **Consumer skills scanning `.claude/handoff/`.** Consumers receive a scope brief from skald. No scanning, no frontmatter parsing.
- **Auto-approving.** Status `approved` is user's decision; skald always writes `draft`.
- **Naming another skill by name in your skill's docs or behavior.** Use role names from the catalog.
- **Hardcoding the protocol in producer or consumer skills.** Only skald implements the protocol.
- **Offering a delete option.** Files are append-only by protocol.
- **Deleting `_history/` entries.** Iterations preserved forever — audit trail.
- **Reading another skill's memory.** Skills exchange work only via skald-mediated briefs and CLAUDE.md.
- **Updating INDEX.md, LOG.md, or `_thread.md` from a non-skald skill.** Only skald maintains those.

---

## Drift policy

This file is canonical and standalone. Skills do not mirror it. Each skill's SKILL.md encodes the behavior it needs (producer output shape, consumer scan/filter/match). When the spec changes, every implementing skill's SKILL.md must be reviewed and updated by humans — there is no runtime spec-loading.

Future tooling: a linter that walks every `*/SKILL.md`, looks for `producer_role` or `consumer_role` declarations, and flags any skill whose inline behavior diverges from the canonical spec.
