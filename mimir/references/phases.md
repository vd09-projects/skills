# Phases — Load / Detect / Produce

Authority for SKILL.md's three-phase flow. SKILL.md summarizes; this file is the source of truth for discipline.

Mimir implements the handoff protocol as a producer with `producer_role: planner`. Protocol behavior is encoded inline below and in SKILL.md (the spec lives at `_shared/handoff-protocol.md` for skill authors; not loaded at runtime).

---

## Phase 0 — Load Context

Goal: gather all context needed before asking the user anything. Cheap, always runs.

**Load order (matters):**

1. **CLAUDE.md** — project root. The only cross-skill context source. Read always if present. Contains project type, stack, conventions, domain rules, invariants, gotchas. If absent, note once: "No CLAUDE.md found — working on generic principles. Run `rune` to set up project context."
2. **`.claude/skill-memory/mimir/config.md`** — Mimir's own preferences. Fields: `default_depth`, `domain_expert_role`, `always_overlays`, `never_overlays`.
3. **`.claude/handoff/*.md`** — directory scan. Used for the Scope Collision Flow in Phase 2. Reading frontmatter only at this stage is fine (cheap).
4. **`references/overlays/`** — directory listing only. Catalog membership defines which overlays exist. Do not read overlay file bodies yet — Phase 1 Overlay Selection reads each candidate's `## Triggers` section, then full body only for confirmed overlays.

**One read per session per file.** Do not re-read mid-conversation unless the user signals a context change.

**Conflict rule:** if two sections of CLAUDE.md disagree on the same convention, surface explicitly. Never silently merge.

**Mimir reads no other skill's memory.** Per the agent-pattern in `_shared/agent-pattern.md`, cross-skill knowledge lives in CLAUDE.md (Claude Code platform convention) or in handoff artifacts. Mimir never reaches into `.claude/skill-memory/{other-skill}/`.

---

## Phase 1 — Detect + Select Overlays + Interrogate

Goal: classify depth, select active overlays, fill all required slots (core + level + overlay). No artifact produced yet.

### Depth detection

Single source = the table in SKILL.md. Do not duplicate the table here.

**Detection rules:**
- If signals point to one level unambiguously → proceed without asking.
- If both architecture and task signals present → ask which.
- If `config.md` has `default_depth` set to non-`ask` AND signals ambiguous → use default.
- If user explicitly names a depth ("architectural plan", "task breakdown") → honor regardless of signals.

### Overlay selection

Source of truth = the Overlay Selection section in SKILL.md. Do not duplicate.

**Order of operations:**
1. Trigger-scan the catalog using each overlay's `## Triggers` section only.
2. Apply `config.md` overrides: add `always_overlays`, remove `never_overlays`.
3. If user named overlays explicitly, force-activate those.
4. If candidate set is non-empty, prompt user with one-line justifications. Default `y`. User may edit list. If set is empty AND user named none, proceed with no overlays.
5. Load full body of confirmed overlays only.

**Anti-patterns:**
- Pre-loading overlay bodies before triage — wastes context window.
- Activating overlays the user declined.
- Silently dropping an overlay whose slot can't be answered. Terminate `Blocked — need input.` instead.

### Core slots (both levels)

Required before producing any plan. If missing, ask. Do not guess.

1. **Problem** — one sentence. Restate back to user for confirmation.
2. **Constraints** — at minimum one of: deadline, blast radius, team, compatibility, performance. "No constraints" is unacceptable — push back: every plan needs at least one boundary.
3. **Success Metric** — observable, quantified, time-bounded. Renders as `## Success Metric` section in the artifact (not just a slot). Required fields: primary metric, counter-metric, evaluation window, evaluator. "Faster" is not a metric. "P95 < 200ms sustained 7d, error rate ≤ 0.1%, evaluated by SRE on-call" is. If unfilled, terminate `Blocked — need input.`
4. **Known unknowns** — what user knows they don't know. Surfaces investigation work that must precede planning.

### Level-specific slots

Load matching reference for full discipline:
- `architecture` → `architecture.md`
- `task` → `task.md`

Do not load both. Do not load before detection completes.

### Overlay-specific slots

For each active overlay, gather slots from its `## Required Slots` section. Consolidate with core + level slots into one interrogation round — do not ask per overlay. If a required overlay slot is unanswerable, terminate `Blocked — need input.` naming the slot and its overlay.

### When to block

Block (terminal: `Blocked — need input.`) when:
- Any core slot unanswered and user can't supply.
- Constraint stated but contradicts another constraint (e.g., "no downtime" + "drop the table").
- User asks for a plan in a domain that requires expert judgment user doesn't have AND no `domain_expert_role: present` configured.
- CLAUDE.md sections conflict and user can't resolve.

Be specific. "Blocked — need more context" is wrong. "Blocked — need to know whether X or Y, because the recommended approach changes depending" is right.

---

## Phase 2 — Produce Artifact

Goal: write a new file (or revise an existing one) in `.claude/handoff/` per the handoff protocol and route via `consumer_role`.

### Steps

1. **Compute slug.** Derive from scope: kebab-case, lowercase, ≤40 chars, alphanumeric + dashes only. Examples: `auth-redesign`, `payment-refund-flow`, `rate-limiter-redis`.

2. **Scope Collision Flow** (per protocol). Scan `.claude/handoff/*.md`. For each file, read frontmatter (stop after the `---` block). Find matches where:
   - `status` is `draft` or `approved` (not `consumed`), AND
   - `scope_hint` overlaps the new scope (string similarity, exact slug match, or human judgment), AND
   - `plan_type` matches.

   If matches found, prompt user with this menu:

   ```
   Existing handoff(s) cover similar scope:

     [1] {filename}
         status: {status} | scope: {scope_hint}
     ...

   [u] update existing (pick by number)
   [n] create new alongside (will be a fresh file; old ones preserved)
   [c] cancel
   ```

   Default: `c` (cancel — user reviews and decides). Options: `u` (update existing — pick by number), `n` (create new alongside), `c` (cancel). There is NO delete option. All artifacts preserved.

   If user picks `u`: open the chosen file, regenerate body, preserve `created` and original `status`, rewrite.

   If user picks `n` or no collisions found: proceed to step 3.

3. **Compute filename.** `{YYYYMMDD-HHMMSS}-{plan_type}-{slug}.md` using UTC timestamp at the moment of writing. Filename collisions (same timestamp + slug) extremely unlikely; if they occur, append `-2`, `-3`, etc.

4. **Render body** using the template inlined in the matching level reference (`architecture.md` or `task.md`). For each active overlay (in catalog order — see SKILL.md `Overlay Merge Order`), append its `## Template Sections` at the `<!-- OVERLAY INSERTION POINT -->` marker in the base template. Strip the marker comment from the final artifact. If two overlays contribute a section with the same heading, merge content under one heading — do not duplicate.

5. **Compose frontmatter** per the protocol schema:
   - `artifact_type: handoff`
   - `artifact_version: 1`
   - `producer_role: planner`
   - `consumer_role`: derived per the table in SKILL.md
   - `plan_type`: from detected level
   - `overlays`: YAML list of active overlay slugs in catalog order. Empty list `[]` if none.
   - `created`: ISO-8601 UTC, matches the timestamp in the filename
   - `status: draft` (always; user flips to `approved` manually)
   - `scope_hint`: one-line summary
   - `slug`: matches filename slug (redundant for safety against renames)

6. **Write file** at `.claude/handoff/{filename}`.

7. **State terminal status** with filename included so user knows what to approve.

### `consumer_role` derivation

| Plan content signal | → `consumer_role` |
|---|---|
| Task-level plan with clear ordered steps and constraints met | `implementation` |
| Architecture plan with recommendation AND `domain_expert_role: present` in config | `domain-expert` |
| Architecture plan with open questions or no clear recommendation | `none` (informational; user decides next step) |
| Architecture plan with recommendation, no domain expert configured | `none` (user routes manually) |

Mimir never writes a consumer-skill name.

### Approval flow (MVP — manual)

Mimir writes `status: draft`. User must edit the artifact and change to `status: approved` before any consumer treats it as authoritative. No skill auto-flips. No slash command in v1.

### Files are never deleted

The protocol forbids a delete option. All prior artifacts stay in `.claude/handoff/` indefinitely. This is the audit trail.

If a user wants to delete (sensitive data, accidental commit), they do it manually outside the protocol — Mimir never offers that path.

### Anti-patterns

- **Writing code anywhere in the artifact.** Even one snippet. Convert to description.
- **Burying constraints.** Constraints get their own section, always.
- **Single-option "comparison".** If only one option exists, it's not an architecture plan — escalate to "Needs discussion." or convert to task plan.
- **Plans without test strategy.** Test strategy must be named specifically. "Tests will be written" is not a strategy.
- **Plans that span depths.** One artifact = one depth. Chain artifacts (architecture → task) by writing separate files.
- **Naming a specific consumer skill in the artifact or output.** Use `consumer_role` only.
- **Auto-approving.** Mimir never writes `status: approved`.
- **Silently overwriting an existing artifact.** Scope Collision Flow handles overlap. Updating an existing file requires user `[u]` choice.
- **Offering a delete option.** Files preserved by protocol.
- **Activating overlays without user confirmation.** Trigger match is a candidate, not a decision. Only `config.md`'s `always_overlays` bypasses the prompt.
- **Pre-loading overlay file bodies before triage.** Read only `## Triggers` until candidate set is confirmed. Saves context window on irrelevant overlays.
- **Inlining overlay content into the base level reference.** Overlays stay in `references/overlays/`. Do not absorb them into `architecture.md` / `task.md` — that re-creates the generic-template trap.
- **Inventing overlays inline.** Overlays exist as files in the catalog or they don't exist. No ad-hoc "this plan also has a security overlay" without a file backing it.
- **Empty `## Success Metric`.** The section renders unconditionally. If it has no content, the plan is not ready — terminate `Blocked — need input.` Do not write a placeholder like "TBD" and proceed.

### Terminal states (full definitions)

- **`Plan ready.`** Artifact written at known filename. All required frontmatter present. `consumer_role` set. User reads artifact, flips `status: draft` → `approved` when ready, orchestrator (or user) invokes the matching consumer.
- **`Needs discussion.`** Options laid out but no recommendation possible without user judgment call. Artifact still written with `consumer_role: none` (captures the analysis). User decides path forward.
- **`Blocked — need input.`** No artifact written. State exactly what's needed and why it blocks.

Terminal output always names the filename so the user knows what to approve.
