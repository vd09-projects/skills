# Architecture Level

For high-level design decisions: solution options, tradeoffs, recommended path. ADR-style output. Spans one or more future implementation tasks.

## When this level applies

- "How should we approach X?"
- "What are the options for Y?"
- "Design an approach to Z"
- "Compare A vs B for our use case"
- User pastes a goal with multiple plausible solutions

Not this level: single ticket already scoped, single obvious solution, "should we use library X" (that's a research task — different).

## Required slots (in addition to core)

Get these before producing artifact. If missing, ask.

1. **Alternatives already ruled out.** What did the user already consider and reject? Prevents re-proposing dead options.
2. **Reversibility tolerance.** Is this a one-way door (DB schema, public API) or a two-way door (internal refactor)? Changes the bar for evidence.
3. **Decision deadline.** When must the architecture be locked in? Drives depth of analysis vs speed.
4. **Stakeholders.** Who else needs to weigh in (security, infra, domain expert)? Drives `consumer_role` selection.

## Discipline

- **Always present ≥ 2 options.** Single-option "comparison" is not architecture. If only one option exists, the work is not architectural — convert to task plan or block.
- **Tradeoffs concrete.** Not "this is more flexible". Instead: "this lets us swap database engines without touching service code; cost is one extra abstraction layer (~200 LOC)".
- **Recommendation must name what would change the recommendation.** "Option B because we expect read volume to dominate. Switch to Option A if write volume rises above N qps."
- **No code, no pseudocode.** Diagrams (ASCII or described) allowed. "It would call `service.foo()`" allowed. Actual function bodies not allowed.
- **Out of scope explicit.** Name what this architecture does NOT decide.

## Output template

Render this into `.claude/handoff/{YYYYMMDD-HHMMSS}-architecture-{slug}.md` with the frontmatter shown below prepended.

```markdown
---
artifact_type: handoff
artifact_version: 1
producer_role: planner
consumer_role: {domain-expert | none}
plan_type: architecture
overlays: {YAML list of active overlay slugs, e.g. [data-migration, cross-team]. Empty list [] if none}
created: {ISO-8601 UTC, matches filename timestamp}
status: draft
scope_hint: {one-line summary of what this plan covers}
slug: {kebab-slug, matches filename}
---

# {Short title — what is being decided}

## Problem

{One paragraph. What needs deciding and why now.}

## Constraints

- {Deadline, blast radius, team, compat, perf — bullets, terse}

## Success Metric

REQUIRED — every plan declares a measurable outcome that means this plan succeeded. Not aspirational. Observable, time-bounded.

- **Primary metric:** {quantified outcome — e.g., "p95 checkout latency drops below 500ms, sustained over 7d", "support ticket volume on auth flow drops 50% within one quarter", "all consumers migrated off v1 by 2026-Q3"}
- **Counter-metric (must not regress):** {what would make this win pyrrhic — error rate, cost, adjacent feature perf}
- **Evaluation window:** {how long the metric is observed before declaring success}
- **Evaluator:** {role or person who calls success/failure}

If this section is empty, the plan is not ready — the producer interrogated for "Success criteria" but failed to render it. Either fill the section or terminate `Blocked — need input.`

## Stakeholders

- {Who must weigh in. Mark required vs informed.}

## Options

### Option A — {name}

**Approach:** {2-4 sentences describing the shape, no code.}

**Tradeoffs:**
- Pro: {concrete}
- Pro: {concrete}
- Con: {concrete}
- Con: {concrete}

**Reversibility:** {one-way door | two-way door | mostly reversible}

**Effort estimate:** {S | M | L | XL — and what drives it}

### Option B — {name}

{Same structure}

### Option C — {name, if applicable}

{Same structure}

## Recommendation

**{Option X}**, because {one paragraph naming the deciding factor}.

**Switch trigger:** {what observation or change would flip the recommendation}.

<!-- OVERLAY INSERTION POINT — active overlays' template sections render here, in catalog order. Omit this comment in the final artifact if no overlays activated. -->

## Out of Scope

- {What this architecture does NOT decide}
- {What is deferred to task-level planning}

## Risks

- {Risk}: {mitigation or "accepted"}

## Open Questions

- {Question}: blocks {what} until answered.

## Handoff Notes

{One paragraph. What kind of follow-up consumer this artifact expects (by role, not by skill name). If consumer_role is `domain-expert`: what the expert should rule on. If `none`: what decision the user must make. If chaining to a future task plan: which sub-tasks would follow. If overlays are active, name what each overlay's sections demand from the consumer.}
```

## Common failure modes

- **Premature recommendation.** Recommending before alternatives explored = not architecture, just preference. Always lay out ≥ 2 options first.
- **Strawman options.** Listing "do nothing" or "rewrite everything" as filler Option C to make the real recommendation look good. Skip — three real options or two real options, not two real plus one strawman.
- **Tradeoffs as adjectives.** "More scalable", "cleaner", "more maintainable" = noise. Concrete or cut.
- **Recommendation without switch trigger.** A recommendation that can't be falsified is faith. Always name what would change it.
- **Output drift into task plan.** If the document starts listing ordered steps and effort estimates per step, it has drifted out of architecture. Split into two artifacts.
