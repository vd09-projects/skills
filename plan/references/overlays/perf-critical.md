---
overlay: perf-critical
applies_to: [architecture, task]
---

# Performance-Critical Overlay

Composable concern: change targets a hot path, claims a performance win, or has measurable latency/throughput SLOs. Forces baseline-target-measurement discipline so the plan does not hand-wave on "should be faster".

## Triggers

Activate when one or more present:

- Backend keywords: `latency`, `throughput`, `p50`, `p95`, `p99`, `QPS`, `RPS`, `hot path`, `bottleneck`, `slow`, `optimize`, `N+1`, `index`, `cache`, `batch`, `SLO`, `SLA`
- Frontend / Web Vitals keywords: `LCP`, `largest contentful paint`, `CLS`, `cumulative layout shift`, `INP`, `interaction to next paint`, `FID`, `first input delay`, `TBT`, `total blocking time`, `TTFB`, `time to first byte`, `FCP`, `first contentful paint`, `bundle size`, `code split`, `lazy load`, `hydration time`, `long task`, `main-thread`, `frame rate`, `jank`
- Quantified targets: any "Xms", "X req/s", "X kB", "X% reduction" in problem text
- Phrases: "speed up", "reduce latency", "high traffic", "request flooding", "feels slow", "ranking factor", "Core Web Vitals", "page weight", "render thrash"

Applies equally to backend (service latency, throughput, query time) and frontend (load metrics, runtime metrics, bundle weight) — the baseline / target / measurement discipline is the same; only the units differ.

Do not activate for: feature work where perf is incidental, refactors with no measurable target, "cleaner code" claims with no metric.

## Required Slots

1. **Current baseline metric.** A specific number, recently measured, with the measurement method named. "p95 latency = 420ms measured via Grafana panel X over last 7d". "Slow" is not a baseline.
2. **Target metric.** A specific number with rationale. "p95 < 200ms, because checkout page SLO is 500ms end-to-end and this service accounts for 40%."
3. **Load profile.** Traffic shape — steady state RPS, peak RPS, burst pattern, request size distribution. Drives whether the win survives realistic load, not just synthetic.
4. **Measurement environment.** Production observability, staging with load gen, local benchmark, none. Determines confidence in any reported win.
5. **Regression budget.** What other metric is allowed to worsen, and by how much? "Memory may grow by ≤ 20% if latency drops by ≥ 30%." No budget = optimization without tradeoff = suspect.

## Template Sections

Append to base body, after `## Constraints`, before terminal sections.

### Baseline Metrics

| Metric | Current value | Measurement source | When measured |
|---|---|---|---|
| {p95 latency / RPS / memory / etc.} | {number + unit} | {dashboard / benchmark / synthetic} | {date} |

### Target SLO

| Metric | Target | Acceptance threshold | Rationale |
|---|---|---|---|
| {metric} | {number} | {pass/fail boundary} | {why this target} |

### Load Profile

- **Steady-state:** {RPS, request mix, payload size}
- **Peak:** {when peaks occur, magnitude, duration}
- **Burst behavior:** {spike characteristics — cold cache, fan-out, batch arrivals}

### Measurement Plan

- **Pre-change measurement:** {how baseline confirmed before any work starts}
- **In-progress measurement:** {what is measured per step — micro-benchmark, integration benchmark, canary}
- **Post-change measurement:** {validation against target, in what environment, over what window}
- **Statistical rigor:** {n trials, warm-up, outlier handling — at least name the trap}

### Regression Budget

| Other metric | Pre-change | Tolerance | Hard ceiling |
|---|---|---|---|
| {memory / CPU / cost / read amplification} | {value} | {allowed delta} | {failure threshold} |

### Observability Hooks

- **Metrics added:** {counters, histograms — by name and labels}
- **Traces added:** {span names, attributes}
- **Dashboards updated:** {dashboard names — pre-flight that observability is in place to verify the win post-deploy}

## Discipline

- **No micro-benchmark as sole evidence.** A 10x improvement in an isolated benchmark is necessary but not sufficient. Integration/end-to-end measurement is the deciding metric.
- **Production p95, not local average.** Localhost numbers are dev convenience, not correctness.
- **Cache hit ratio is a config-dependent variable, not a constant.** Measurement plan names the cache state assumed.
- **N+1 fixes report query count, not just latency.** Latency improvements can mask remaining N+1 patterns under low load.
- **A regression budget that's never exceeded was probably too loose.** Tight budgets force real tradeoffs.

## Common Failure Modes

- **"Faster" with no number.** Target slot must hold a measurable value.
- **Baseline taken in dev environment.** Dev DBs, dev caches, dev CPU profiles all differ. Baseline must come from prod or prod-shaped staging.
- **Optimization shipped with no observability to confirm it.** Without dashboards reflecting the new shape, the win is anecdotal.
- **Improving one metric, ignoring others.** Latency drops, memory triples, infra cost doubles. Regression budget catches this.
- **Premature optimization.** If the baseline meets the SLO today, this overlay is wrong — drop it and re-scope.
