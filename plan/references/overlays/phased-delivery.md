---
overlay: phased-delivery
applies_to: [architecture, task]
---

# Phased Delivery Overlay

Composable concern: the plan unfolds in distinct phases rather than landing all at once. Each phase ships independently, has its own **Exit Criteria** and **Success Metric**, and may be a public **Milestone** when it represents an external commitment. Forces explicit gates so "we'll do it in stages" doesn't decay into "we'll figure it out as we go".

**Vocabulary used in this overlay:**

| Term | Meaning |
|---|---|
| **Phase** | A self-contained slice of work that ships and stands on its own. |
| **Exit Criteria** | Observable conditions that must hold to declare the phase complete and advance. |
| **Success Metric** | Quantified outcome the phase aims to move (subset of the plan's overall success metric). |
| **Milestone** | A phase whose completion is an external commitment (announced, on a roadmap, contractually due). Not every phase is a milestone. |
| **Definition of Done (DoD)** | Synonym for "Exit Criteria + Success Metric met". Use when communicating with stakeholders who already speak Agile/Scrum. Internally prefer Exit Criteria. |

## Triggers

Activate when one or more present:

- Keywords: `phase 1`, `phase 2`, `stage`, `iteration`, `milestone`, `incremental`, `gradual`, `evolve over`, `in stages`, `MVP then`, `pilot`, `expand later`
- Phrases: "we'll do this in steps", "ship a minimum first", "roll out by team / region / cohort", "later phases will…", "first prove the concept"
- Structural: scope is too large to ship atomically; reversibility risk demands intermediate checkpoints; multiple stakeholder sign-offs expected at distinct moments

Do not activate for: single-phase work, simple linear task lists with no decision points between steps (use base `task` Steps section), spike/exploration with no deliverable.

## Required Slots

Get before producing artifact. If missing, ask.

1. **Phase count and shape.** How many phases, what is the rough cut of work in each? "Three phases: behind a flag, opt-in beta, default-on" beats "we'll figure out the phases as we go".
2. **Per-phase success metric.** Each phase must move a measurable thing. Without this slot, phases are vibes.
3. **Exit Criteria per phase.** What observable conditions gate advancement to the next phase. Includes both positive (metric hit) and negative (no regression in X) criteria.
4. **Phase ownership.** Who owns advancing each phase, who can declare it done. Single name or role per phase.
5. **Rollback / rollforward stance per phase.** If a phase fails its exit criteria, do we roll back, hold, or fix-forward? Drives risk profile.
6. **Milestone designation.** Which phases (if any) are external Milestones — promised to stakeholders or on a public roadmap. Drives communication cadence.

## Template Sections

Append to base body at overlay insertion point.

### Phases

| # | Phase | Scope | Milestone? | Owner | Target date |
|---|---|---|---|---|---|
| 1 | {name} | {what ships} | {yes/no} | {role/name} | {date or relative} |
| 2 | {name} | {what ships} | {yes/no} | {role/name} | {date or relative} |
| 3 | {name} | {what ships} | {yes/no} | {role/name} | {date or relative} |

### Phase 1 — {name}

- **Scope:** {what is built / changed / shipped in this phase}
- **Success Metric:** {quantified outcome — e.g., "10% of users on new flow", "p95 latency on new path < 200ms over 7d"}
- **Exit Criteria:**
  - {positive criterion — metric, sign-off, observed behavior}
  - {negative criterion — no regression in X, no incident of class Y}
- **Definition of Done (alias):** Exit Criteria above, evaluated by {owner} at {evaluation cadence}.
- **Rollback stance:** {roll back to phase 0 / hold and patch / fix forward} — trigger: {what observation}
- **Out of phase:** {what is explicitly NOT in this phase to prevent scope creep into phase 1}

### Phase 2 — {name}

{Same structure as Phase 1. If this phase is a Milestone, also list:}

- **External communication:** {who hears about it, in what channel, when}
- **Stakeholder sign-off required:** {names/roles}

### Phase N — {name}

{Same structure.}

### Phase Sequencing & Dependencies

- **Hard sequencing:** {phases that cannot reorder}
- **Parallel-safe:** {phases that could run concurrently if capacity allowed}
- **Cross-phase dependencies:** {phase X requires data/decision from phase Y}

### Gate Decision Log Plan

Where the phase-advancement decision gets recorded for the audit trail:

- **Location:** {decision log file, PR description, doc — name it}
- **Format per gate:** evaluated date, evaluator, exit criteria status (per bullet), advance/hold/rollback decision, rationale

## Discipline

- **Every phase has a Success Metric, not just the final phase.** Otherwise "we shipped phase 1" means nothing.
- **Exit Criteria are observable, not aspirational.** "Users love it" is not an exit criterion. "NPS ≥ 40 in survey of N users" is.
- **A phase that has no rollback stance has no risk plan.** Even "fix forward only, no rollback" is a stance — but it has to be stated.
- **Milestones are a subset of phases, not a synonym.** A phase that nobody outside the team cares about is not a Milestone — don't promote it.
- **Each phase ships something usable on its own.** A phase that requires phase 2 to "make sense" is not a phase, it's a checkpoint inside one big phase.
- **Phase boundaries are decision points, not deadlines.** The team decides to advance based on exit criteria, not based on calendar.
- **A plan with 8+ phases is suspicious.** Either each phase is too thin (collapse), or the plan should be split into multiple plans chained by handoff artifacts.

## Common Failure Modes

- **"Phase 2: TBD"** — phase 2 exists in the artifact but has no scope, metric, or criteria. Either commit to a shape or strike it from this plan and write phase 2 as a separate plan later.
- **Exit criteria = "phase 1 is done"** — circular. Criteria must reference observable system or business state.
- **Milestone with no external communication plan** — internal teams treat it as a milestone, external stakeholders learn by surprise.
- **No gate decision recorded** — six months later, no one remembers why phase 2 was skipped. Decision log section is non-optional.
- **Phases too tightly coupled** — phase 1 leaves system in a partially-migrated state for weeks because phase 2 was needed to complete the shape. Means phase 1 is not a real shippable phase.
- **Skipping the Out-of-Phase bullets** — "while we're in here for phase 1, let's also do phase 3's work." The whole point of phases is to NOT do that.
