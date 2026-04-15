# SOLUTION.md Template

---

```markdown
---
ticket: {TICKET-SLUG}
title: {Short descriptive title}
version: v1
created: {DATE}
last_updated: {DATE}
---

# Solution — {Ticket Title}

> This file records the chosen solution and the alternatives that were considered.
> When requirements shift, add a changelog entry and update affected sections.
> Never delete previous reasoning — mark it [SUPERSEDED by v{N}].

---

## Changelog

| Version | Date   | Summary of change           |
|---------|--------|-----------------------------|
| v1      | {DATE} | Initial solution decision   |

---

## Problem Statement

> What is the actual problem being solved?
> What breaks, degrades, or is missing without this?
> Who is affected and how?

{2–4 sentences. Specific. The person reading this at 11pm should understand
the full context without asking anyone.}

---

## Constraints & Non-Negotiables

> What must be true regardless of which solution is chosen?

- {Constraint 1 — e.g., must work within existing infra, no new databases}
- {Constraint 2 — e.g., must be reversible, must not break existing API contract}
- {Constraint 3 — e.g., must be operable by current team with no new tooling}

---

## Options Considered

### Option 1: {Name}

**How it works:**
{1–3 sentences describing the approach}

**Fits well when:**
{The conditions under which this would be the right choice}

**Tradeoffs:**
- Pro: {reason}
- Pro: {reason}
- Con: {reason}
- Con: {reason}

**Key risks:**
{What could go wrong, or what this approach makes harder}

**Architectural implication:**
{Few sentences — e.g., "Requires new service; touches auth-service and user-db"}

**Status:** NOT CHOSEN — {reason in one sentence}

---

### Option 2: {Name}

**How it works:**
{1–3 sentences}

**Fits well when:**
{Conditions}

**Tradeoffs:**
- Pro: {reason}
- Con: {reason}

**Key risks:**
{Risks}

**Architectural implication:**
{Few sentences}

**Status:** NOT CHOSEN — {reason}

---

### Option 3: {Name}  [the chosen one]

**How it works:**
{1–3 sentences}

**Fits well when:**
{Conditions}

**Tradeoffs:**
- Pro: {reason}
- Pro: {reason}
- Con: {reason}

**Key risks:**
{Risks}

**Architectural implication:**
{Few sentences}

**Status:** CHOSEN

**Why this over the others:**
{Direct comparison — what made this better than Options 1 and 2 given the constraints}

---

## Chosen Solution

### Summary

{One paragraph describing what will be built and why. Clear enough that
a new engineer could read this and understand the direction before looking at any code.}

### User modifications to the option

{Any changes the user requested on top of the base option. If none, write "None — adopted as proposed."}

### What this does NOT solve

{Explicitly list what is out of scope for this solution.
Name which future ticket or decision will address each item, if known.}

---

## Open Questions from Phase 1

> Questions still unresolved when this file was written.
> These carry into Phase 2 (Architecture) for resolution.

| ID   | Question                              | Category   | Status  |
|------|---------------------------------------|------------|---------|
| Q-01 | {Question that wasn't answered yet}   | OPEN       | OPEN    |
| Q-02 | {Decision still pending}              | TO_OWNER   | PENDING |

---
```
