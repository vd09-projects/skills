---
overlay: observability
applies_to: [architecture, task]
---

# Observability Overlay

Composable concern: change ships new behavior, a new code path, or a new failure mode that someone will need to debug at 3 AM. Forces logs/metrics/traces/alerts to be designed up-front, not retrofitted after the first incident.

Applies to both backend (services, jobs, pipelines) and frontend (error tracking, user-facing telemetry, Web Vitals reporting).

## Triggers

Activate when one or more present:

- Keywords: `log`, `logging`, `metric`, `counter`, `gauge`, `histogram`, `trace`, `span`, `tracing`, `alert`, `alarm`, `SLO`, `SLI`, `runbook`, `dashboard`, `observability`, `telemetry`, `monitoring`
- Path/file signals: log config, OpenTelemetry imports, metric registration, alert YAML, dashboard JSON
- Phrases: "how will we know if X breaks", "what fires when Y", "dashboards", "on-call visibility", "debug in prod"
- Implicit (still activate): any new failure mode, any new background job, any new external dependency, any new user-facing flow with non-trivial error states

Do not activate for: pure refactors with no new code paths AND existing observability covers behavior, internal-only tooling with no production deployment.

## Required Slots

1. **What new failure modes exist after this change.** A bulleted list. If you can't enumerate failures, you can't design observability for them.
2. **Who consumes the telemetry.** On-call humans, dashboards, alert routing, downstream pipelines (analytics, billing, security). Drives format, retention, cost.
3. **SLO / SLI definitions.** What measurable behavior must hold for "the change is working in prod". Even one SLI is better than none.
4. **Alert thresholds and routing.** What numbers trigger paging vs warning vs ticket-only. Who gets paged.
5. **Cost / cardinality envelope.** Estimated log volume, metric label cardinality, trace sampling rate. Observability without a cost ceiling is how budgets get blown.
6. **Runbook plan.** Where new runbook entries are added and what they cover. "We'll write it later" = it doesn't get written.

## Template Sections

Append to base body at overlay insertion point.

### Failure Mode Inventory

| Failure mode | Detection signal | Sev | First responder |
|---|---|---|---|
| {what can go wrong} | {log line / metric breach / trace anomaly / user report} | {SEV1-3} | {team / role} |

Five rows minimum for non-trivial changes — if fewer, ask whether failure modes were actually thought through.

### Metric Inventory

| Metric name | Type | Labels | What it measures | Cardinality estimate |
|---|---|---|---|---|
| {namespaced name} | {counter / gauge / histogram / summary} | {labels, kept small} | {behavior} | {cardinality bound} |

Label discipline: each label multiplies cardinality. `user_id` as a label is almost always wrong. `endpoint`, `status_class` (2xx/4xx/5xx), `region` — fine.

### Log Schema

- **Format:** {JSON / logfmt / plain text} — pick one, document it
- **Required fields per log line:** {timestamp, level, service, trace_id, span_id, request_id, message, structured_fields}
- **Sensitive fields handling:** {redaction rules — PII, tokens, secrets must NOT land in logs}
- **Levels in use:** {which severity levels are produced by this code, with examples}

### Trace Plan

- **New spans:** {span name, parent, attributes — by name}
- **Sampling:** {head/tail, sample rate, force-sample conditions for errors}
- **Cross-service propagation:** {confirm trace context flows over the relevant transports}

### SLO / SLI

| SLI | Definition | Target (SLO) | Window | Error budget consumption rule |
|---|---|---|---|---|
| {availability / latency / freshness / correctness} | {exact formula} | {%, ms, etc.} | {rolling 7d / 30d} | {what counts as "burned"} |

### Alerts

| Alert name | Condition | Severity | Routes to | Runbook link |
|---|---|---|---|---|
| {name} | {metric > threshold for duration} | {page / warn / ticket} | {team / channel} | {path or "TBD-by-owner-X-by-date"} |

### Dashboards

- **New dashboards:** {name, owner, link or stub}
- **Updated dashboards:** {existing dashboard that gains panels}
- **Required panels per dashboard:** {RED — rate/error/duration, or USE — utilization/saturation/errors, or custom}

### Runbook Updates

- **New runbook entries:** {filename / wiki page, scope}
- **Required sections per entry:** symptoms, immediate mitigation, deeper diagnosis steps, escalation, rollback procedure
- **Owner:** {who writes it, by when, blocks deploy yes/no}

### Cardinality & Cost Envelope

- **Log volume estimate:** {GB/day}
- **Metric time-series estimate:** {count of series produced}
- **Trace volume:** {spans/sec at expected load}
- **Retention:** {logs: N days; metrics: M months; traces: K days}

## Discipline

- **Alert on symptoms, not causes.** Pages should fire on user-visible badness (errors, latency, missed SLO), not on every internal anomaly. Cause investigation comes from dashboards.
- **Every page has a runbook link.** A page with no runbook is a 3 AM problem multiplied by the panic of a sleepy human.
- **Logs are for narrative, metrics are for aggregation.** Don't aggregate over logs; don't narrate via metrics. Trace for causality.
- **High-cardinality fields go to traces or sampled logs, not metrics.** `user_id` as a metric label kills the metrics store; same field on a sampled trace is fine.
- **Test the alert.** A new alert that has never fired is unverified. Use a synthetic injection or a chaos drill to confirm the page routes correctly.
- **Sampling decisions are documented.** "We sample at 1%" is fine. Silent sampling at unknown rate is unauditable.

## Common Failure Modes

- **Logging the bug, alerting on nothing.** The error lands in logs, no one looks, the incident is reported by users.
- **`log.info` for what should be `log.debug`** — log volume blows up, important signals drown.
- **Dashboards added, never reviewed.** Without an owner and a review cadence, dashboards rot.
- **Metric names without a namespace.** `request_count` clashes with every other `request_count`. Prefix.
- **Tracing context dropped at a queue boundary.** Async hops require explicit propagation; otherwise the trace ends at the producer.
- **Sensitive data in error messages.** Stack traces routinely leak tokens, query parameters, and PII. Redact before logging.
- **No "what changed" link from alert to deploy.** When an alert fires, the responder needs to know which deploy correlates. Build that link.
