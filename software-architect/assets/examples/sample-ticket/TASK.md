---
ticket: notification-service
title: Build User Notification Service
version: v2
status: IN_PROGRESS
created: 2026-01-10
last_updated: 2026-03-06
owner: Vikrant
---

# Build User Notification Service

## Big Picture

The platform currently has no way to notify users when background jobs complete or fail.
Users refresh manually and have no visibility into long-running operations. This causes
support tickets and poor UX. This ticket builds a lightweight notification service that
emits events from existing services and delivers them to users via WebSocket. It is the
foundation for all future real-time features, so the event schema and delivery contract
need to be extensible from the start.

---

## Acceptance Criteria

- [ ] AC-1: A user receives a notification within 2 seconds of a background job completing
- [ ] AC-2: Notifications are delivered over WebSocket; HTTP polling fallback not required in v1
- [ ] AC-3: Any existing service can emit a notification by publishing to the event bus
- [ ] AC-4: Missed notifications (user offline) are queued and delivered on reconnect (up to 24h)
- [ ] AC-5: Notification schema is versioned and documented

---

## Subtasks

### T-01 — Research: Event Bus Options

| Field        | Value |
|--------------|-------|
| **Type**     | RESEARCH |
| **Placement**| EXISTING_REPO:platform-backend |
| **Depends on**| — |
| **Blocks**   | T-02, T-03 |
| **Input**    | Current infra inventory (Redis available, RabbitMQ available) |
| **Output**   | ADR-01 in TASK-REASONING.md: chosen event bus with rationale |
| **Done when**| ADR-01 written, Redis Pub/Sub vs RabbitMQ decision documented with tradeoffs |

**Notes:**
Check whether Redis is already used in prod (likely yes). RabbitMQ adds ops overhead.
Decision affects T-02 and T-03 significantly.

---

### T-02 — Define Notification Event Schema

| Field        | Value |
|--------------|-------|
| **Type**     | CODE |
| **Placement**| EXISTING_REPO:platform-backend / shared-types module |
| **Depends on**| T-01 |
| **Blocks**   | T-03, T-04, T-05 |
| **Input**    | ADR-01 decision, existing event patterns in codebase |
| **Output**   | `NotificationEvent` TypeScript type + JSON schema + version field |
| **Done when**| Schema merged, documented in README, consumed by T-03 without modification |

**Notes:**
Must include: event_id, type, payload, timestamp, schema_version, target_user_id.
Schema versioning is non-negotiable — this is consumed by multiple future components.

---

### T-03 — Implement Event Bus Publisher [CHANGED v2]

| Field        | Value |
|--------------|-------|
| **Type**     | CODE |
| **Placement**| EXISTING_REPO:platform-backend |
| **Depends on**| T-01, T-02 |
| **Blocks**   | T-05 |
| **Input**    | NotificationEvent schema, chosen event bus |
| **Output**   | `NotificationPublisher` class — any service calls `.publish(event)` |
| **Done when**| Unit tested, existing job-runner service uses it to emit one real event |

**Notes:**
[CHANGED v2]: Originally scoped as a standalone microservice. Moved to existing repo
after T-01 research confirmed Redis is already available and traffic volume doesn't
justify a separate service. See TASK-REASONING.md v2 for context.

---

### T-04 — Build WebSocket Delivery MCP Server [ADDED v2]

| Field        | Value |
|--------------|-------|
| **Type**     | MCP_SERVER |
| **Placement**| NEW_REPO:notification-ws-server |
| **Depends on**| T-02 |
| **Blocks**   | T-05 |
| **Input**    | NotificationEvent schema |
| **Output**   | WebSocket server that LLM agents can query for pending notifications |
| **Done when**| LLM agent can call `get_pending_notifications(user_id)` and `mark_read(event_id)` |

**Notes:**
[ADDED v2]: Requirement to support LLM agent access was added in v2.
Separate repo justified: different runtime (Node WS server), independent deploy lifecycle.
Also manages offline queue — maintains state, so MCP not CODE.

---

### T-05 — Integration: Wire Publisher to WebSocket Server

| Field        | Value |
|--------------|-------|
| **Type**     | CODE |
| **Placement**| EXISTING_REPO:platform-backend |
| **Depends on**| T-03, T-04 |
| **Blocks**   | — |
| **Input**    | Running publisher (T-03), running WS server (T-04) |
| **Output**   | End-to-end: job completes → event published → user receives WS notification |
| **Done when**| AC-1 and AC-4 pass in staging environment |

---

## Dependency Map

```
T-01 (Research) ──► T-02 (Schema) ──► T-03 (Publisher) ──► T-05 (Integration)
                          └──────────► T-04 (WS Server) ──► T-05
```

T-01 has no dependencies — start here.
T-03 and T-04 can run in parallel after T-02.

---

## Parallel Opportunities

- T-03 and T-04 can run in parallel after T-02 is done
- Frontend notification UI (not in this ticket) can begin after T-02 schema is published

---

## Out of Scope

- Email or push notification delivery (future ticket: `notification-channels`)
- Notification preferences / muting (future ticket: `notification-prefs`)
- Frontend notification UI component (tracked in `frontend` repo separately)
- Multi-tenant notification routing

---

## Definition of Done (Ticket Level)

- [ ] All subtasks marked complete
- [ ] All acceptance criteria verified in staging
- [ ] TASK-REASONING.md updated with all implementation decisions
- [ ] NotificationEvent schema published to shared-types docs
- [ ] All OPEN questions resolved
- [ ] Q-02 (auth strategy for WS) confirmed with security team

---

## Changelog

| Version | Date       | Author  | Summary |
|---------|------------|---------|---------|
| v1      | 2026-01-10 | Vikrant | Initial ticket — publisher as standalone microservice |
| v2      | 2026-03-06 | Vikrant | Moved publisher to existing repo; added MCP server for LLM access |
