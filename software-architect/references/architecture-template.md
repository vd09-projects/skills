# ARCHITECTURE.md Template

---

```markdown
---
ticket: {TICKET-SLUG}
title: {Short descriptive title}
version: v1
created: {DATE}
last_updated: {DATE}
---

# Architecture — {Ticket Title}

> This file records the system design for the chosen solution.
> It is the input to Phase 3 (Ticket Breakdown).
>
> When the architecture changes, add a changelog entry and update affected sections.
> Mark superseded sections [SUPERSEDED by v{N}] — never delete them.

---

## Changelog

| Version | Date   | Summary of change              |
|---------|--------|--------------------------------|
| v1      | {DATE} | Initial architecture design    |

---

## Solution Reference

**Chosen solution:** {Option name from SOLUTION.md}
**Summary:** {One sentence restating what is being built}

---

## Component Map

> All components in the system — existing and new.

| Component        | Status     | Repo / Location                  | Type          | Description                              |
|------------------|------------|----------------------------------|---------------|------------------------------------------|
| {component-name} | EXISTING   | {repo-name}                      | MCP_SERVER    | {What it does}                           |
| {component-name} | EXTENDING  | EXISTING_REPO:{repo-name}        | CODE          | {What's being added to it}               |
| {component-name} | NEW        | NEW_REPO:{suggested-name}        | SKILL         | {What it will do}                        |
| {component-name} | NEW        | NEW_MODULE:{repo/path}           | ORCHESTRATOR  | {What it will do}                        |

**Type reference:** SKILL / MCP_SERVER / CODE / ORCHESTRATOR / CONFIG / RESEARCH
**Status reference:** EXISTING (unchanged) / EXTENDING (adding to) / NEW (creating)

---

## Repo Placement Decisions

> For each NEW or EXTENDING component, document the placement decision.

### {component-name} → {PLACEMENT}

**Decision:** {NEW_REPO / EXISTING_REPO:{name} / NEW_MODULE:{path} / EXTRACT_LATER}

**Rationale:**
{Why this placement. Reference the decision framework criteria that were met.}

**Alternatives considered:**
- {Alternative placement} — rejected because {reason}

**Revisit trigger:**
{Condition under which this placement should be reconsidered}

---

<!-- Repeat for each component that has a non-obvious placement -->

---

## Data & Event Flow

> How data moves through the system. What each component receives and emits.

```
{component-A}
  ─── emits: {artifact/event name} ──►
                                      {component-B}
                                        ─── emits: {artifact/event name} ──►
                                                                            {component-C}
```

**Artifacts / contracts:**

| Artifact / Event      | Producer         | Consumer(s)       | Format     | Notes                          |
|-----------------------|------------------|-------------------|------------|-------------------------------|
| {artifact-name}       | {component-A}    | {component-B}     | JSON / MD  | {Schema or key fields}        |
| {event-name}          | {component-B}    | {component-C}     | Webhook    | {Trigger condition}           |

---

## Integration Points

> External systems, APIs, or repos this architecture depends on.

| System / Repo         | Integration type    | Contract / API                    | Owner         | Risk                          |
|-----------------------|---------------------|-----------------------------------|---------------|-------------------------------|
| {system-name}         | REST API call       | {endpoint or contract summary}    | {team/person} | {What could break}            |
| {repo-name}           | Shared library      | {interface or export used}        | {team/person} | {Version coupling risk, etc.} |

---

## Open Questions

> Architecture decisions that depend on unresolved questions.
> These are also logged in DISCUSSION.md.

| ID   | Question                                              | Category   | Blocks                  | Status  |
|------|-------------------------------------------------------|------------|-------------------------|---------|
| Q-01 | {Question the architecture depends on}                | TO_OWNER   | {component or decision} | PENDING |
| Q-02 | {Technical unknown that affects a placement decision} | OPEN       | {component or decision} | OPEN    |
| Q-03 | {Thing being assumed until confirmed}                 | ASSUMPTION | {milestone}             | ASSUMED |

---

## Out of Scope (Architecture)

> What this architecture explicitly does NOT address.
> Naming what's out of scope is as important as naming what's in scope.

- {Out of scope item — e.g., "Auth layer — handled by existing service, not modified here"}
- {Out of scope item — e.g., "Monitoring and alerting — separate ticket"}
- {Out of scope item — and which future ticket addresses it, if known}

---
```
