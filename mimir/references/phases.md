# Phases — Load / Detect / Produce

Authority for SKILL.md's three-phase flow. SKILL.md summarizes; this file is the source of truth for discipline.

Mimir produces natural markdown output, emits it to the caller, and stops. It does not write files.

---

## Phase 0 — Load Context

Goal: gather all context needed before asking the user anything. Cheap, always runs.

**Load order (matters):**

1. **CLAUDE.md** — project root. The only cross-skill context source. Read always if present. Contains project type, stack, conventions, domain rules, invariants, gotchas. If absent, note once: "No CLAUDE.md found — working on generic principles. Run `rune` to set up project context."
2. **`.claude/skill-memory/mimir/config.md`** — Mimir's own preferences. Fields: `default_depth`, `domain_expert_role`, `always_overlays`, `never_overlays`.
3. **Prior artifacts in a scope dir** — ONLY when the caller passes a scope dir path. Read top-level markdown files in that dir. Read-only. If no scope dir is supplied, skip.
4. **`references/overlays/`** — directory listing only. Catalog membership defines which overlays exist. Do not read overlay file bodies yet — Phase 1 Overlay Selection reads each candidate's `## Triggers` section, then full body only for confirmed overlays.

**One read per session per file.** Do not re-read mid-conversation unless the user signals a context change.

**Conflict rule:** if two sections of CLAUDE.md disagree on the same convention, surface explicitly. Never silently merge.

**Mimir reads no other skill's memory.** Cross-skill knowledge lives in CLAUDE.md. Mimir never reaches into `.claude/skill-memory/{other-skill}/`.

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

## Phase 2 — Produce Output

Goal: render natural markdown output that satisfies the title format. Return to caller. Do NOT write files. Do NOT emit YAML frontmatter.

### Output format

Title format is mimir's output contract. First H1 must follow one of these shapes.

- Architecture plans: `# Architecture: {one-line scope title}`
- Task plans: `# Task plan: {one-line scope title}`

If a different ArtifactKind label is more accurate (rare), document it in mimir's references and update the output format documentation. Default is the two labels above.

### Steps

1. **Render body** using the template inlined in the matching level reference (`architecture.md` or `task.md`). For each active overlay (in catalog order — see SKILL.md `Overlay Merge Order`), append its `## Template Sections` at the `<!-- OVERLAY INSERTION POINT -->` marker in the base template. Strip the marker comment from the final output. If two overlays contribute a section with the same heading, merge content under one heading — do not duplicate.

2. **Confirm title** follows the format. If active overlays exist, include a `**Overlays:** {slug-1}, {slug-2}` line directly below the title if overlays are active. Omit the line if no overlays.

3. **Return** the full markdown output to the caller. No YAML. No frontmatter. No `status` field. No filename computation.

### Anti-patterns

- **Writing code anywhere in the artifact.** Even one snippet. Convert to description.
- **Burying constraints.** Constraints get their own section, always.
- **Single-option "comparison".** If only one option exists, it's not an architecture plan — escalate to "Needs discussion." or convert to task plan.
- **Plans without test strategy.** Test strategy must be named specifically. "Tests will be written" is not a strategy.
- **Plans that span depths.** One artifact = one depth. Chain by emitting separate outputs.
- **Naming a specific consumer skill in the body.** Mimir doesn't know consumers.
- **Emitting YAML frontmatter, role declarations, version numbers, or `status` fields.** Mimir produces title + body, full stop.
- **Writing files of any kind.** Mimir does not write files.
- **Computing filenames, timestamps, slugs, or versions.**
- **Activating overlays without user confirmation.** Trigger match is a candidate, not a decision. Only `config.md`'s `always_overlays` bypasses the prompt.
- **Pre-loading overlay file bodies before triage.** Read only `## Triggers` until candidate set is confirmed. Saves context window on irrelevant overlays.
- **Inlining overlay content into the base level reference.** Overlays stay in `references/overlays/`. Do not absorb them into `architecture.md` / `task.md` — that re-creates the generic-template trap.
- **Inventing overlays inline.** Overlays exist as files in the catalog or they don't exist. No ad-hoc "this plan also has a security overlay" without a file backing it.
- **Empty `## Success Metric`.** The section renders unconditionally. If it has no content, the plan is not ready — terminate `Blocked — need input.` Do not write a placeholder like "TBD" and proceed.

### Terminal states (full definitions)

- **`Plan ready.`** Output emitted to caller. User approves when ready.
- **`Needs discussion.`** Options laid out but no recommendation possible without user judgment call. User decides path forward.
- **`Blocked — need input.`** No output emitted. State exactly what's needed and why it blocks.
