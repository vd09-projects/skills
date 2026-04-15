# TASK-REASONING.md Template

---

```markdown
---
ticket: {TICKET-SLUG}
reasoning_version: v1
last_updated: {DATE}
---

# Reasoning — {Ticket Title}

> This file is the memory of the ticket. It captures WHY decisions were made,
> how requirements evolved, what was assumed, and what questions remain.
>
> NEVER delete history. When things change, ADD to this file.
> Old reasoning that gets superseded should be marked [SUPERSEDED by v{N}] — not removed.

---

## Context & Motivation

> The "why now". What triggered this work?
> What would happen if this wasn't built?
> Who is affected and how?

{Write context here — 3–8 sentences. Be specific. Future-you will thank present-you.}

---

## Bigger Picture Fit

> Where does this sit in the overall system/roadmap?
> What other components depend on this, or will this depend on?
> What is the long-term direction this is moving toward?

{System context, upstream/downstream dependencies, strategic direction}

---

## Architecture Decisions

> Each significant decision gets a block. Small obvious choices don't need one.
> A decision is significant if a reasonable engineer could have chosen differently.

### ADR-01 — {Decision Title}

**Status:** DECIDED | SUPERSEDED | DEFERRED

**Context:**
{What situation forced this decision? What constraints existed?}

**Decision:**
{What was chosen and why}

**Alternatives considered:**
- {Alternative A} — rejected because {reason}
- {Alternative B} — rejected because {reason}

**Consequences:**
{What becomes easier? What becomes harder? What is now locked in?}

**Revisit trigger:**
{What would cause this decision to be reconsidered?}

---

### ADR-02 — {Decision Title}

**Status:** DECIDED | SUPERSEDED | DEFERRED

**Context:** {Context}

**Decision:** {What and why}

**Alternatives considered:**
- {Alternative A} — rejected because {reason}

**Consequences:** {Tradeoffs}

**Revisit trigger:** {Condition}

---

<!-- Add ADR-0N blocks as decisions are made during implementation -->

---

## Requirement History

> Versioned log of how the requirements evolved.
> Each version adds a new block — existing blocks are never edited.

### v1 — Initial Requirements ({DATE})

**Summary:** {Brief description of original scope}

**Key requirements:**
- {Req 1}
- {Req 2}
- {Req 3}

**Source:** {Where did this come from? Conversation, spec doc, user request?}

---

### v2 — {Change Title} ({DATE})

**Summary:** {What changed and why}

**Added:**
- {New requirement or scope addition}

**Removed / Deferred:**
- {What was dropped and why, or which future ticket picks it up}

**Modified:**
- {What was adjusted}

**Impact on subtasks:**
- T-02: {Affected — needs to be reworked to account for X}
- T-04: [ADDED v2] — new subtask required by this change

**Source:** {Conversation, stakeholder request, technical constraint discovered during implementation}

---

<!-- Add v{N} blocks as requirements evolve. Never edit previous versions. -->

---

## Assumptions

> Things treated as true that have not been confirmed.
> Every assumption should be validated before the ticket ships.

| ID   | Assumption                                       | Confidence | Must validate before | Status      |
|------|--------------------------------------------------|------------|----------------------|-------------|
| A-01 | {Assumption description}                         | HIGH/MED/LOW | {Milestone/subtask} | OPEN / VALIDATED / INVALIDATED |
| A-02 | {Assumption description}                         | HIGH/MED/LOW | {Milestone/subtask} | OPEN / VALIDATED / INVALIDATED |

---

## Questions Log

> Every open question is tracked here. Questions never disappear — they move to RESOLVED.

| ID  | Category   | Question                                     | Status   | Owner     | Answer / Notes               | Date Resolved |
|-----|------------|----------------------------------------------|----------|-----------|------------------------------|---------------|
| Q-01 | OPEN      | {Question that has no owner yet}             | OPEN     | —         | —                            | —             |
| Q-02 | TO_OWNER  | {Decision needed from ticket owner}          | PENDING  | {Name}    | Asked on {date}              | —             |
| Q-03 | TO_TEAM   | {Question for another team or domain expert} | PENDING  | {Team}    | —                            | —             |
| Q-04 | ASSUMPTION | {Thing we're assuming — needs confirmation} | ASSUMED  | {Name}    | Treating X as true until Y   | —             |
| Q-05 | RESOLVED  | {Question that was answered}                 | RESOLVED | —         | {The answer}                 | {DATE}        |

**Category definitions:**
- `OPEN` — unanswered, no owner assigned yet
- `TO_OWNER` — needs a decision from the ticket owner or product stakeholder
- `TO_TEAM` — requires input from another team or domain expert
- `ASSUMPTION` — actively treating as true; must be confirmed before shipping
- `RESOLVED` — answered and closed; kept for traceability

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| {Risk description} | HIGH/MED/LOW | HIGH/MED/LOW | {How it's being handled} |
| {Risk description} | HIGH/MED/LOW | HIGH/MED/LOW | {How it's being handled} |

---

## Notes & Scratchpad

> Free-form space for things that don't fit neatly elsewhere.
> Design sketches, early explorations, rejected ideas worth remembering.

{Free text, diagrams, links, etc.}
```
