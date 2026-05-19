# Handoff Protocol — v1

Generic cross-skill handoff contract. Skills implementing this protocol exchange work via slug-named files in a well-known directory. **No skill names appear in this protocol.** Skills declare *roles*, not identities.

Inspired by the session-per-task pattern: one artifact = one file = one named piece of work. Multiple artifacts coexist for parallel work. Directory listing IS the history. Files are never deleted.

This file is the canonical spec. **It is documentation for skill authors, not loaded at runtime by any skill.** Each implementing skill encodes the relevant protocol behavior INLINE in its own SKILL.md (producers know how to write artifacts; consumers know how to scan/filter/match). Skills do not mirror this file. Drift between skill behavior and the spec is caught by human review of the spec, not by runtime spec-loading.

---

## Why this exists

Skills must not depend on each other by name. If skill A reads from skill B's output by hardcoding B's path or behavior, swapping B for B' breaks A. The protocol fixes this:

- Producers write per protocol, declaring only their *role*.
- Consumers read per protocol, accepting any artifact matching their expected role.
- Skills can be added, swapped, or removed without touching others.

An orchestrator agent (project-specific) sequences which skills run. The protocol governs only the artifact exchange.

---

## Well-known location

```
.claude/handoff/
```

Flat directory. One file per artifact. No subdirectories. No `current.md` singleton. No `history/` subdir — the directory IS the history.

### Filename convention

```
{YYYYMMDD-HHMMSS}-{plan_type}-{slug}.md
```

- `YYYYMMDD-HHMMSS` — UTC timestamp at creation. Lexicographic sort = chronological order.
- `plan_type` — artifact subtype: `architecture`, `task`, `review`, `decision`, etc. Lets directory scans filter by name prefix.
- `slug` — derived from `scope_hint`: lowercase, dashes only, ≤40 chars, alphanumeric + dashes.

Examples:
```
20260520-143022-architecture-auth-redesign.md
20260520-150155-task-payment-refund.md
20260521-091012-task-rate-limiter.md
20260522-100000-review-payment-refund-findings.md
```

### Why this shape

- **Parallel work:** each artifact is its own file. Two task plans in flight = two files. No singleton bottleneck.
- **History built-in:** files are never deleted. Directory listing answers "what plans have we written?", "what was approved when?", "what got built vs what didn't?".
- **Resume by scanning:** an agent can list the directory, filter by status, find the next pending artifact, and continue. No separate session-state file needed for the protocol layer (project agents may still keep their own session state).
- **Forensics:** grep `.claude/handoff/*.md` for any frontmatter field across the entire project history.

---

## Artifact schema (v1)

Markdown file with YAML frontmatter + freeform body.

```yaml
---
artifact_type: handoff
artifact_version: 1
producer_role: planner          # role of skill that wrote this
consumer_role: implementation   # role of skill expected to consume
plan_type: architecture | task  # extensible; producers may add new types
created: YYYY-MM-DDTHH:MM:SSZ   # ISO-8601 UTC, matches filename timestamp
status: draft | approved | consumed
scope_hint: <one line>          # consumer matches against current request
slug: <kebab-slug>              # matches filename slug, redundant for safety
---
```

### Field definitions

| Field | Required | Values | Notes |
|---|---|---|---|
| `artifact_type` | yes | `handoff` (only value in v1) | Identifies the protocol. |
| `artifact_version` | yes | `1` | Producers and consumers refuse mismatched versions. |
| `producer_role` | yes | see role catalog | Identifies who wrote it (role, not skill name). |
| `consumer_role` | yes | see role catalog or `none` | Identifies who should read it. `none` = informational, no auto-consume. |
| `plan_type` | yes | `architecture`, `task`, others | Producer-defined sub-type. Consumers filter by this AND `consumer_role`. |
| `created` | yes | ISO-8601 UTC | Matches the timestamp in the filename. |
| `status` | yes | `draft`, `approved`, `consumed` | Lifecycle gate. See below. |
| `scope_hint` | yes | one-line free text | Consumer matches this against current request to decide relevance. |
| `slug` | yes | kebab-case | Matches the slug in the filename. Redundant on purpose — robustness if file gets renamed. |

Producers may add additional frontmatter fields; consumers ignore fields they don't recognize. Unknown fields are not errors.

### Body sections

Producer-defined. Protocol does not constrain body structure. Each producer documents its body format in its own references. Consumers parse body per the producer's documented format if needed, or rely on frontmatter alone for routing.

---

## Status lifecycle

```
draft → approved → consumed
```

- **`draft`**: producer wrote it. Not safe to consume.
- **`approved`**: user (or an approving agent) flipped status. Safe to consume.
- **`consumed`**: consumer used it as scope and finished. Future consumers skip.

Files are NEVER deleted. An `approved` artifact that never gets consumed stays `approved` forever — visible in the directory as planned-but-not-built work. Audit trail by construction.

### Who flips status?

| Transition | Who | How |
|---|---|---|
| `draft` → `approved` | User (MVP) | Edits the file manually. No skill auto-approves. |
| `approved` → `consumed` | Consumer | Writes back to the file after using as scope. |

No skill writes `approved` to its own output. Producer always writes `draft`.

---

## Role catalog

Roles are domain functions, not skill names. Multiple skills can implement the same role; one skill may declare multiple roles.

| Role | Meaning | Typical artifact body |
|---|---|---|
| `planner` | Produces approach, options, or task breakdown. No code. | Problem, constraints, options or steps, recommendation, scope, risks. |
| `implementation` | Consumes a plan and produces code + tests. | N/A (consumer). |
| `review` | Consumes code or design and produces findings. | Findings list. |
| `domain-expert` | Provides domain judgment (methodology, edge, safety calls). | Verdict, reasoning, conditions. |
| `task-manager` | Maintains task backlog / state. | Task records. |
| `decision-log` | Maintains decision journal. | Decision records. |
| `none` | Informational. No expected consumer. | N/A. |

Producers and consumers MUST use these role names verbatim. To add a new role, update this protocol document; bump `artifact_version` only if breaking.

---

## Producer obligations

A skill that writes handoff artifacts MUST:

1. Compute filename per the convention: `{YYYYMMDD-HHMMSS}-{plan_type}-{slug}.md` in `.claude/handoff/`.
2. Run the Scope Collision Flow before writing (see below). Never silently overwrite an existing artifact with similar scope.
3. Include all required frontmatter fields. `created` timestamp MUST match the filename timestamp. `slug` MUST match the filename slug.
4. Set `status: draft` on creation. Never write `approved`.
5. Document its body format in its own references so consumers can parse if needed.
6. Declare its role accurately. Do not lie about `producer_role` to game routing.

### Scope Collision Flow

Before writing, producer scans `.claude/handoff/*.md` for existing artifacts where:
- `status` is `draft` or `approved` (not `consumed`), AND
- `scope_hint` matches or substantially overlaps the new request, AND
- `plan_type` matches.

If matches found, prompt user:

```
Existing handoff(s) cover similar scope:

  [1] 20260520-143022-task-payment-refund.md
      status: approved | scope: Add idempotent refund flow

  [2] 20260519-100000-task-payment-refund.md
      status: draft    | scope: Refund flow design

[u] update existing (pick by number)
[n] create new alongside (will be a fresh file; old ones preserved)
[c] cancel
```

- `u` lets user pick which existing artifact to revise in place. Status stays whatever it was.
- `n` creates a brand-new file. Existing files untouched. Use when work has genuinely diverged.
- `c` cancels.

Producers MUST NOT offer a delete option. All handoffs are preserved.

If zero matches: write the new file directly, no prompt.

---

## Consumer obligations

A skill that reads handoff artifacts MUST:

1. List `.claude/handoff/*.md`. Read frontmatter of each (cheap; stop after frontmatter block).
2. **No-op if directory empty or absent.** Consumer must work identically when no handoffs exist.
3. Filter candidates: `artifact_type: handoff` AND `artifact_version: 1` AND `consumer_role` matches the consumer's declared role AND `status: approved`. Skip everything else.
4. Match `scope_hint` against current request:
   - Exactly one match → use it.
   - Multiple matches → ask user: list each with filename + scope_hint, let user pick.
   - Zero matches → no handoff for this consumer right now. Proceed normally (or note draft artifacts if relevant: "Draft artifacts exist but none approved — confirm approval before using.").
5. After using as scope, write `status: consumed` back to the chosen file. Preserve all other fields.

Consumers MUST NOT depend on which skill wrote the artifact. The only routing signals are `consumer_role` and `scope_hint`.

### Why scan, not read a single file

Scanning the directory enables:
- Parallel work (multiple artifacts for different scopes coexist).
- Resume (consumer can be invoked any time; finds whatever is pending).
- Audit (history is just listing the dir, not a separate `history/` subdir).
- Multi-consumer flows (different consumer roles read different artifacts from the same dir).

Reading a single `current.md` would prevent all of these.

---

## Conflict resolution

If multiple `approved` artifacts match a consumer's scope, the consumer MUST surface the ambiguity to the user and refuse to pick one autonomously. List filename + `scope_hint` + `created` for each, let user choose.

Never auto-pick by recency, alphabetical order, or any other heuristic. Ambiguity is the user's call.

---

## Privacy / manual cleanup

The protocol provides no delete operation. If a user wants to delete an artifact (sensitive data, accidental commit), they delete the file manually outside the protocol. Skills MUST NOT offer that path.

Recommended: `.claude/handoff/` can be `.gitignore`d if artifacts contain sensitive scope hints; or committed if audit trail in version control is desired. Project's choice.

---

## Versioning

`artifact_version` integer. Bumped on breaking changes (field removal, semantic shift, role catalog reduction). Producers and consumers refuse mismatched versions.

Non-breaking changes (new optional fields, new roles, new status values that consumers can safely ignore) do not bump the version.

When `artifact_version` bumps:
1. Update this canonical spec.
2. Update every implementing skill's SKILL.md inline behavior to emit (producers) or accept (consumers) the new version.
3. Document the breaking change at top of this file.
4. Provide migrator (script or doc) for existing v(N-1) artifacts. Existing artifacts in projects' `.claude/handoff/` stay as-is — consumers refuse to consume mismatched versions and the files remain as audit trail.

---

## Orchestration (informational)

The protocol governs the artifact exchange only. It does NOT specify who invokes which skill in what order. That is the job of:

- An orchestrator agent (project-specific), typically at `.claude/agents/coordinator.md` or similar.
- Or the user / main thread, invoking skills sequentially.

The orchestrator is external to the skills. Skills declare their role and obey the protocol. Anything more = orchestration concern, not skill concern.

See `_shared/agent-pattern.md` for a recipe for building orchestrator agents that sequence skills via the handoff bus.

---

## Anti-patterns

- **Naming another skill by name in your skill's docs or behavior.** Use role names from the catalog.
- **Auto-approving your own draft.** Status `approved` is user's decision.
- **Reading from `.claude/handoff/current.md`.** That path is not part of v1. Scan the directory.
- **Hardcoding `producer_role` checks.** Consumers route by `consumer_role` and `scope_hint`. Producer identity is informational.
- **Skipping the no-op contract.** Consumer skills MUST work identically when handoff dir empty or absent.
- **Offering a delete option.** Files are append-only by protocol.
- **Reading another skill's memory.** Skills exchange work only via the handoff bus and CLAUDE.md. No reaching into `.claude/skill-memory/{other-skill}/`.

---

## Drift policy

This file is canonical and standalone. Skills do not mirror it. Each skill's SKILL.md encodes the behavior it needs (producer steps, consumer scan/filter/match). When the spec changes, every implementing skill's SKILL.md must be reviewed and updated by humans — there is no runtime spec-loading to keep them in sync automatically.

Future tooling: a script that walks every `*/SKILL.md`, looks for `producer_role` or `consumer_role` declarations, and flags any skill whose inline behavior diverges from the canonical spec. Pure linter; no runtime impact.
