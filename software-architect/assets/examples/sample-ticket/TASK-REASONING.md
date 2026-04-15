---
ticket: notification-service
reasoning_version: v2
last_updated: 2026-03-06
---

# Reasoning — Build User Notification Service

---

## Context & Motivation

Support volume for "is my job done?" questions has grown 40% over the last quarter.
Background jobs (CSV exports, report generation, bulk operations) can take 1–5 minutes
and users have no visibility into their state. The current workaround is polling a status
endpoint every 5 seconds from the frontend, which creates unnecessary backend load and
still has up to 5s lag. Real-time notification via WebSocket eliminates both problems.
This is also the foundation for future agentic features where LLM agents need to be
notified when long-running tasks complete.

---

## Bigger Picture Fit

This sits between the job execution layer (platform-backend) and the frontend + LLM agent
layer. Everything that currently fires "job complete" callbacks will eventually route
through this. The schema and event bus choice made here will be difficult to change later,
so extensibility is a first-class constraint. Long-term: this becomes the eventing backbone
for the whole platform, not just notifications.

---

## Architecture Decisions

### ADR-01 — Redis Pub/Sub over RabbitMQ for event bus

**Status:** DECIDED

**Context:**
T-01 research confirmed Redis is already deployed in prod for caching. RabbitMQ was the
other option considered. Traffic volume estimate: ~500 events/day at current scale,
~10k/day at 2x growth. Both options handle this trivially.

**Decision:**
Use Redis Pub/Sub. No new infrastructure dependency, simpler ops, team already familiar.

**Alternatives considered:**
- RabbitMQ — rejected because it adds a new infra dependency with meaningful ops overhead
  for a volume that Redis handles easily. Would reconsider at 10x scale or if durable
  message queuing across restarts becomes a hard requirement.
- Kafka — rejected, completely disproportionate to current and near-future scale.

**Consequences:**
Redis Pub/Sub is fire-and-forget — no built-in durability. Offline message queuing (AC-4)
must be handled at the application layer (T-04 WS server). This is a reasonable tradeoff
given current scale.

**Revisit trigger:**
If we need guaranteed delivery across restarts, or if we add more than 3 independent
consumers of the event stream.

---

### ADR-02 — Publisher stays in platform-backend, not a standalone service

**Status:** DECIDED (changed from original plan in v2)

**Context:**
v1 assumed a standalone notification microservice. T-01 research and v2 requirement
review showed this was premature. The publisher is simply a Redis client wrapper — there
is no logic that justifies its own runtime.

**Decision:**
`NotificationPublisher` is a class in platform-backend, injected wherever needed.
Extraction to a standalone service deferred to EXTRACT_LATER.

**Alternatives considered:**
- Standalone microservice — rejected (premature). Would revisit if a second project
  needed to publish notifications independently.

**Consequences:**
Tighter coupling to platform-backend for now. Acceptable given single consumer today.
Marked `# EXTRACT_LATER` in code.

**Revisit trigger:**
A second repo needs to publish notifications, or the publisher logic grows complex enough
to warrant its own test suite.

---

### ADR-03 — WebSocket delivery as MCP server in new repo

**Status:** DECIDED

**Context:**
v2 added requirement that LLM agents must be able to query pending notifications. A
WebSocket server that also maintains state (offline queue) has a different runtime and
deployment lifecycle than the backend API. It's also the natural home for the MCP
interface.

**Decision:**
New repo (`notification-ws-server`). MCP server type — it wraps an external connection
mechanism and maintains per-user state.

**Alternatives considered:**
- Co-locate in platform-backend — rejected because it mixes HTTP API and WS server
  runtimes, complicates deployment, and makes the MCP interface awkward.

**Consequences:**
Two repos to deploy and monitor. Acceptable given the different runtime requirements.

**Revisit trigger:**
If LLM agent access requirement is dropped, this could be collapsed back into
platform-backend.

---

## Requirement History

### v1 — Initial Requirements (2026-01-10)

**Summary:** Notification service for background job completion. Publisher as standalone microservice.

**Key requirements:**
- WebSocket delivery to browser clients
- Emit notifications from job-runner on job complete/fail
- Queue notifications for offline users (24h TTL)

**Source:** Support volume analysis + product roadmap review

---

### v2 — Added LLM Agent Access (2026-03-06)

**Summary:** LLM agents need to query pending notifications. Publisher architecture simplified.

**Added:**
- LLM agent must be able to call `get_pending_notifications(user_id)` via MCP
- LLM agent must be able to call `mark_read(event_id)` via MCP

**Removed / Deferred:**
- Standalone notification microservice — moved to platform-backend (see ADR-02)
  Future extraction tracked in code with EXTRACT_LATER comment.

**Modified:**
- T-03: Publisher moved from standalone service to class in platform-backend
- T-04 [ADDED]: New MCP server subtask for WebSocket + LLM agent interface

**Impact on subtasks:**
- T-03: Reworked — no longer a standalone service, simpler implementation
- T-04: Added — new subtask, new repo
- T-05: Updated inputs (now depends on T-03 class + T-04 server, not T-03 service)

**Source:** Architecture review session — LLM pipeline team flagged agent use case

---

## Assumptions

| ID   | Assumption                                      | Confidence | Validate before | Status |
|------|-------------------------------------------------|------------|-----------------|--------|
| A-01 | Redis is available in prod with Pub/Sub enabled | HIGH       | T-03 impl       | VALIDATED — confirmed in T-01 |
| A-02 | Frontend team can consume WebSocket events      | MED        | T-05 integration | OPEN |
| A-03 | 24h offline queue TTL is acceptable to product  | MED        | T-04 impl        | OPEN — Q-03 raised |

---

## Questions Log

| ID   | Category   | Question                                              | Status   | Owner    | Notes                              | Date Resolved |
|------|------------|-------------------------------------------------------|----------|----------|------------------------------------|---------------|
| Q-01 | RESOLVED   | Is Redis available in prod?                           | RESOLVED | —        | Yes, confirmed in T-01 research    | 2026-01-15    |
| Q-02 | TO_TEAM    | What auth strategy for WS connections?               | PENDING  | Security | Asked 2026-03-01, no reply yet     | —             |
| Q-03 | TO_OWNER   | Is 24h offline queue TTL acceptable, or do we need longer? | PENDING | Vikrant | —                            | —             |
| Q-04 | OPEN       | Should notifications be tenant-scoped in schema now?  | OPEN     | —        | Multi-tenancy is out of scope v1 but schema change later would be painful | — |
| Q-05 | ASSUMPTION | Frontend team can integrate WebSocket without help    | ASSUMED  | —        | Validate before T-05               | —             |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Redis Pub/Sub drops messages if WS server restarts | MED | HIGH | Application-level queue in T-04 WS server; Redis persistence not relied upon |
| NotificationEvent schema becomes hard to evolve | MED | HIGH | schema_version field mandatory from day 1; versioned JSON schema in shared-types |
| Frontend integration delays T-05 | MED | MED | T-05 has integration test path that bypasses frontend; can verify AC-1 server-side first |

---

## Notes & Scratchpad

Early sketch of event flow:
```
job-runner → NotificationPublisher.publish(event)
           → Redis Pub/Sub channel: "notifications:{user_id}"
           → WS Server subscribes → delivers to open connections
           → If no open connection: queues in memory with TTL
           → On reconnect: flushes queue to client
```

MCP interface sketch:
```
get_pending_notifications(user_id: string) → NotificationEvent[]
mark_read(event_id: string) → void
subscribe_stream(user_id: string) → AsyncIterator<NotificationEvent>
```
