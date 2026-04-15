# DISCUSSION.md Template

---

```markdown
---
ticket: {TICKET-SLUG}
title: {Short descriptive title}
created: {DATE}
last_updated: {DATE}
---

# Discussion Log — {Ticket Title}

> This file is the living conversation record for this ticket.
> It spans all three phases (Problem Framing, Architecture, Ticket Breakdown).
>
> Rules:
> - Every question asked must be logged BEFORE being asked
> - Every answer must be logged when received
> - When a priority shift changes direction, add a new version block — never edit old ones
> - Mark superseded questions [SUPERSEDED by v{N}] — never delete them

---

## Phase 1 — Problem Framing

### Round 1.1 — Initial Clarification ({DATE})

**Questions asked:**

1. {Question text}
2. {Question text}
3. {Question text}

**Answers received ({DATE}):**

1. {Answer to question 1}
2. {Answer to question 2}
3. {Answer to question 3}

**Assessment after this round:**
{Did you have enough to propose solutions? Or were follow-up questions needed?}

---

### Round 1.2 — Follow-up ({DATE})  [add only if needed]

**Why a follow-up was needed:**
{What was unclear or insufficiently answered from Round 1.1}

**Questions asked:**

1. {Question text}

**Answers received ({DATE}):**

1. {Answer}

**Assessment:** Ready to propose solutions.

---

### Solution Decision ({DATE})

**Options presented:** Option 1 ({name}), Option 2 ({name}), Option 3 ({name})

**User choice:** Option {N} — {name}

**Modifications requested:** {any changes the user made to the option, or "none"}

**Confirmed understanding:** {restate the chosen solution in one sentence}

---

## Phase 2 — Architecture Design

### Round 2.1 — Architecture Proposal ({DATE})

**Repos considered:**
- {repo-name}: {how it was assessed — relevant / not relevant / to be extended}

**Open questions surfaced:**

| ID   | Question                              | Category   |
|------|---------------------------------------|------------|
| Q-01 | {Question text}                       | OPEN       |
| Q-02 | {Question text}                       | TO_OWNER   |

**User feedback ({DATE}):**
{What they changed, confirmed, or pushed back on}

---

### Round 2.2 — Architecture Iteration ({DATE})  [add as needed]

**What changed from Round 2.1:**
{Specific changes to the architecture}

**Questions resolved in this round:**

| ID   | Question                   | Answer                    |
|------|----------------------------|---------------------------|
| Q-01 | {Question text}            | {Answer}                  |

**New questions opened:**

| ID   | Question                   | Category  |
|------|----------------------------|-----------|
| Q-03 | {Question text}            | OPEN      |

**User confirmed architecture stable:** {DATE}

---

## Phase 3 — Ticket Breakdown

### Round 3.1 — Ticket Review ({DATE})

**User feedback on TASK.md:**
{Any changes requested to milestones, subtask sizing, ordering, or scope}

**Changes made:**
{What was updated}

---

## Priority Shifts  [add a block here whenever direction changes significantly]

### Shift v{N} — {DATE}

**What changed:**
{What the user decided to change and why}

**Questions superseded by this shift:**
- Q-{ID}: [SUPERSEDED by Shift v{N}] — {brief note on why it's no longer relevant}

**New direction:**
{Restated direction after the shift}

**Impact on existing files:**
- SOLUTION.md: {what needs updating}
- ARCHITECTURE.md: {what needs updating}
- TASK.md: {what needs updating}

---
```
