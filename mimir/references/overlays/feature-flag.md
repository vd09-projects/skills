---
overlay: feature-flag
applies_to: [architecture, task]
---

# Feature Flag Overlay

Composable concern: change ships behind a runtime toggle — for gradual rollout, A/B testing, kill switch, or long-lived configuration. Forces explicit flag lifecycle planning so flags don't accumulate, decay, or outlive their purpose.

Lighter-weight than `infra-blast` — applies to any code-level flag (LaunchDarkly, Unleash, Statsig, GrowthBook, Flagsmith, OpenFeature, in-house config). Use with `infra-blast` together when the flag governs production rollout strategy.

## Triggers

Activate when one or more present:

- Keywords: `feature flag`, `feature toggle`, `flag`, `kill switch`, `A/B test`, `experiment`, `rollout`, `gradual`, `cohort`, `targeting rule`, `variant`, `LaunchDarkly`, `Unleash`, `Statsig`, `GrowthBook`, `OpenFeature`, `Flagsmith`
- Path/file signals: imports from flag SDKs, calls to `isEnabled` / `getBooleanFlag` / `variation` / `treatment`
- Phrases: "behind a flag", "guarded by", "ship dark", "opt-in beta", "kill switch if it breaks", "5% rollout"

Do not activate for: build-time constants, environment-based config that doesn't change at runtime, deprecated dead-code branches.

## Required Slots

1. **Flag purpose category.** One of: release toggle (short-lived, removed after full rollout), kill switch (always-on, never removed), experiment (A/B/n, removed after readout), permission flag (long-lived entitlement). Drives lifecycle expectation.
2. **Default state.** Off-on-deploy vs on-on-deploy. Drives blast radius if config service is unreachable.
3. **Targeting rules.** Who sees the new behavior — % rollout, user cohort, org/tenant, geography, account tier, allow-list. Be specific.
4. **Owner.** Single name or role responsible for the flag through its lifecycle. Not the whole team — one human.
5. **Removal plan.** Date or trigger condition for flag removal (or "permanent" for kill switches and entitlements). Without this, flag becomes legacy.
6. **Fallback behavior when flag service is unreachable.** Returns last-known value? Returns the default? Fails closed? Affects reliability.
7. **Observability tie-in.** Metrics that fire by flag variant — so the team can tell whether the new path is working differently from the old.

## Template Sections

Append to base body at overlay insertion point.

### Flag Inventory

| Flag key | Purpose category | Default | Type | Owner | Removal trigger |
|---|---|---|---|---|---|
| {flag.key.name} | {release / kill-switch / experiment / permission} | {off / on} | {boolean / string variant / JSON config} | {name or role} | {date / condition / "permanent"} |

### Per-Flag Detail (repeat for each flag)

**Flag:** `{flag.key.name}`

- **Purpose:** {one sentence — why this flag exists, what it controls}
- **Category:** {release toggle | kill switch | experiment | permission}
- **Default state:** {off / on / variant} when no targeting rule matches
- **Default state on flag-service outage:** {return default / return last-known / fail-closed to old path}
- **Type:** {boolean | multi-variant string | JSON payload}
- **Variants (if multi-variant):**
  - `control`: {behavior}
  - `treatment-A`: {behavior}
  - `treatment-B`: {behavior}

### Targeting Rules

```
Targeting plan for {flag.key.name}:
  - Stage 1 (week 1): internal users only (cohort: employees)
  - Stage 2 (week 2): 5% of free-tier traffic
  - Stage 3 (week 3): 25%
  - Stage 4 (week 4): 100% (default-on)
  - Stage 5 (week 6): flag removed, behavior becomes unconditional
```

For experiments:
- **Allocation:** {%/variant}
- **Stratification:** {by tenant / region / device / none}
- **Sample size target:** {N per variant for {power} at {effect size}}
- **Readout date:** {when results evaluated}

### Lifecycle & Removal

- **Created:** {date}
- **Expected removal:** {date or condition}
- **Removal owner:** {who deletes the flag and its dead branch}
- **Cleanup PR linked from flag config:** {yes/no — link the future PR ID or the cleanup ticket}
- **Stale-flag policy:** {what happens if flag isn't removed by expected date — e.g., automated reminder, owner gets pinged, blocked from creating new flags}

### Observability per Flag

- **Metrics segmented by variant:**
  - {request count, error rate, latency, conversion, revenue — segmented by `flag_variant` label}
- **Dashboard:** {link or stub}
- **Alert if variant divergence exceeds threshold:** {y/n, threshold}

### Code Patterns

- **Read site shape:** {single `isEnabled` call at entry / many scattered call sites — prefer the former}
- **Branch cleanup pattern when flag is removed:** {document the pattern so cleanup PRs are mechanical}
- **No flag reads in tight loops:** {confirmed — cache once at the boundary}

### Cross-Flag Interactions

- **Flags this depends on:** {flag X must be on / off for this flag to apply}
- **Flags this conflicts with:** {if both on, undefined / pick rule}
- **Combinatorial test matrix:** {N flags = 2^N combinations — pick the meaningful ones}

## Discipline

- **Every flag has an owner and a removal trigger.** A flag without either is a permanent maintenance debt.
- **Release toggles are short-lived.** If a release toggle is older than its initial removal target by 2x, it's a kill switch (re-categorize and document) or it's stale (remove).
- **Experiments must declare readout date AND removal date.** "We'll keep it on forever" is not an experiment, it's a permanent feature.
- **Default-on flags are riskier than default-off.** A default-off flag fails safe if the service is down; default-on assumes the service is always reachable.
- **Read the flag once at the boundary, not deep in business logic.** Otherwise every call to a deep function depends on flag state, hard to test.
- **Flag value should not change mid-request.** Cache the read at request start; don't re-read mid-flow or behavior splits.
- **Tests should run against both variants of every flag.** "We tested with the flag on" leaves the off-path untested in CI.
- **No flag check inside a hot loop.** Resolve once, branch outside.

## Common Failure Modes

- **Flag with no owner** — when it breaks, nobody knows what it does.
- **Stale flags** — code accumulates `if (flag.foo) { /* old */ } else { /* new */ }` branches across the codebase, nobody removes them.
- **Flag service goes down, app behaves randomly** — no documented fallback behavior.
- **Flag check in 30 places** — toggling becomes a refactor, not a config change.
- **Targeting rule based on user-controlled input** — e.g., user-agent string — easy to spoof for entitlement flags.
- **Default-on rollout with no canary** — flag is supposed to gate the feature, but it ships default-on. Just a deploy, not a toggle.
- **Experiment results read once, never re-evaluated** — variant kept forever based on a one-time positive readout that doesn't hold at scale.
- **A/B test with no segmentation** — overall metric moves +1%, but it's +5% for one cohort and -3% for another. Aggregate hides the truth.
- **Same flag controlling two unrelated behaviors** — when one becomes problematic, you can't disable just that one.
- **Flag tested only in the "on" state** — turning it off breaks because the old path bit-rotted.
