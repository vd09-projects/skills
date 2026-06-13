# Task Level

For task-level breakdown: ordered steps, test strategy, risks, scope boundaries. Output targets `consumer_role: implementation` — any implementation-role skill can read it.

## When this level applies

- "Plan refactor of {module}"
- "Break down this ticket: {paste}"
- "What's the order of operations to do X"
- "Plan migration of Y to Z" (single-module migration, not multi-system)
- User has a single goal with a known shape but needs ordered work

Not this level: option compare between approaches (use `architecture`), single trivial change (skip planning, go straight to implementation), exploratory spike (a planning artifact is overkill — invoke an implementation skill in spike mode directly).

## Required slots (in addition to core)

Get these before producing artifact. If missing, ask.

1. **Greenfield or modification.** If modification, ask to see the relevant files before planning order.
2. **Existing code shape (if modification).** What's there now, what's broken/slow/wrong, what stays.
3. **Integration points.** What this touches that's owned by other code paths or teams.
4. **Test environment available.** Real DB, mocked DB, sandbox, none — affects test strategy.

## Discipline

- **Steps ordered, not bulleted.** Order encodes dependency. If two steps can swap freely, mark them "parallel-safe".
- **Each step names files or functions where possible.** Vague steps ("update the service") force the implementation consumer to re-plan. Specific steps ("update `PaymentService.charge` to call `Refundable.assert` before processing") feed straight into a build.
- **Test strategy per behavior, not per file.** "Table-driven unit test for the 5 error paths in `validate()`" is a strategy. "Add tests" is not.
- **Out of scope explicit.** Three to five bullets minimum. Prevents the implementation consumer's "while-I'm-here" creep.
- **Risks named with mitigations.** Especially anything touching load-bearing code, concurrency, data shape, or auth.
- **No code.** Reference functions by name. Describe what they'd return. Never write the implementation.

## Output template

Mimir emits this as its natural output. No frontmatter, no structured metadata — plain markdown.

**Title format (required first H1):**

```
# Task plan: {one-line scope title}
```

The `Task plan` prefix identifies the plan kind. The portion after the colon names the scope.

If active overlays exist for the plan, prepend an optional metadata line directly under the title:

```
**Overlays:** data-migration, perf-critical
```

```markdown
# Task plan: {one-line scope title}

**Overlays:** {comma-separated active overlay slugs, omit line if none}

## Problem

{One paragraph. What needs doing and why now.}

## Constraints

- {Deadline, blast radius, team, compat, perf — bullets, terse}

## Success Metric

REQUIRED — every plan declares a measurable outcome that means this task succeeded. Not "tests pass" (that's intrinsic), not "code merged" (that's a milestone, not an outcome). Observable, time-bounded.

- **Primary metric:** {quantified outcome — e.g., "users can complete checkout in under 3 steps, conversion +X% in A/B test", "background job processes 1M rows/hour at < 1% error rate", "removed library reduces bundle by N kB"}
- **Counter-metric (must not regress):** {what would make this win pyrrhic — error rate, adjacent feature perf, support volume}
- **Evaluation window:** {how long the metric is observed post-deploy before declaring success}
- **Evaluator:** {role or person who calls success/failure}

If this section is empty, the plan is not ready — either fill the section or terminate `Blocked — need input.`

## Mode

- Greenfield | Modification

## Existing Code Shape (modification only)

{What is there now. Reference files and functions by name. What stays, what changes.}

## Integration Points

- {File / module / service this touches that belongs to another path}
- {External dependency that must keep working}

## Steps

1. **{Step name}** — {what it does, files touched}
   - Acceptance: {how do we know this step is done}
   - Parallel-safe with: {step numbers, or "none"}
2. **{Step name}** — {...}
3. **{Step name}** — {...}

{Typically 3-8 steps. If more than 10, this should probably be split into multiple task plans or escalated to architecture.}

## Test Strategy

- **{Behavior or invariant}** — {test type: unit / integration / property / golden / smoke}. {What it specifically asserts.}
- {repeat per behavior — not per file}

<!-- OVERLAY INSERTION POINT — active overlays' template sections render here, in catalog order. Omit this comment in the final artifact if no overlays activated. -->

## Out of Scope

- {Explicit non-goal}
- {Refactor that is NOT happening as part of this work}
- {Edge case that is being deferred}
- {minimum 3 bullets}

## Risks

- **{Risk}** — {likelihood, impact}. Mitigation: {action} or "accepted".

## Open Questions

- {Question}: blocks {step or decision} until answered.

## Handoff Notes

This artifact targets `consumer_role: implementation`. The consumer should:
- Honor the step order.
- Treat "Out of Scope" as hard — no while-I'm-here additions.
- Treat the test strategy as the minimum, not the maximum.
- Honor any overlay sections inserted above — they are not advisory; they encode required acceptance criteria for the overlay's concern.
- Re-plan (its own plan mode, or a fresh plan-skill invocation) if discovery during build invalidates ≥ 2 steps.
```

## Common failure modes

- **Vague steps.** "Update the auth flow" = re-plan needed by the consumer. Always name the function or file.
- **Steps without acceptance.** "Refactor the validator" → when is it done? Acceptance is the contract.
- **Test strategy per file.** "Add tests to validator.ts" = nothing. "Property test: validate(x) is idempotent for all x" = something.
- **Empty Out of Scope.** Consumers will fill the gap with helpers and refactors. Force minimum 3.
- **Risks listed without mitigation.** A risk without action is decoration. Either mitigate or explicitly accept.
- **Steps that span depths.** "Decide how to model the data, then build it" = step 1 is architecture, not task. Pull out, run architecture plan first.
