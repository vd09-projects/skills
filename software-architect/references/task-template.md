# TASK.md Template

---

```markdown
---
ticket: {TICKET-SLUG}
title: {Short descriptive title}
version: v1
status: DRAFT | READY | IN_PROGRESS | DONE
created: {DATE}
last_updated: {DATE}
owner: {NAME}
---

# {Ticket Title}

## Big Picture

> Why does this work exist? What breaks or degrades if it doesn't get done?
> How does this fit into the larger system or roadmap?
> Keep this to 3–5 sentences. The person reading this at 11pm should understand
> the full context without asking anyone.

{Write the big picture here}

---

## Acceptance Criteria

> What does TRUE DONE look like for the whole ticket?
> These are not subtask completions — these are user/system observable outcomes.

- [ ] {AC-1: Observable outcome 1}
- [ ] {AC-2: Observable outcome 2}
- [ ] {AC-3: Observable outcome 3}

---

## Milestones & Subtasks

> Work is grouped into milestones. Each milestone delivers something demonstrable.
> Subtasks within each milestone are ordered by dependency.
> Each task must have a single, verifiable done-condition.

---

### Milestone 1 — {Milestone Title}

> {What this milestone delivers. What can be tested or demoed when it's done?}

#### {T-01} — {Subtask Title}

| Field        | Value |
|--------------|-------|
| **Type**     | RESEARCH / SKILL / MCP_SERVER / CODE / ORCHESTRATOR / CONFIG |
| **Placement**| NEW_REPO / EXISTING_REPO:{repo-name} / NEW_MODULE:{repo/path} / EXTRACT_LATER |
| **Depends on**| — (none) |
| **Blocks**   | T-02, T-03 |
| **Input**    | {What this task receives/needs to start} |
| **Output**   | {What this task produces — the artifact or event} |
| **Done when**| {One sentence: verifiable completion condition} |

**Notes:**
{Any additional context, edge cases, or constraints specific to this subtask}

---

#### {T-02} — {Subtask Title}

| Field        | Value |
|--------------|-------|
| **Type**     | RESEARCH / SKILL / MCP_SERVER / CODE / ORCHESTRATOR / CONFIG |
| **Placement**| NEW_REPO / EXISTING_REPO:{repo-name} / NEW_MODULE:{repo/path} / EXTRACT_LATER |
| **Depends on**| T-01 |
| **Blocks**   | T-03 |
| **Input**    | {Output of T-01} |
| **Output**   | {What this task produces} |
| **Done when**| {One sentence verifiable condition} |

**Notes:**
{Context, constraints, open decisions}

---

<!-- Repeat T-0N block for each subtask within the milestone -->

---

### Milestone 2 — {Milestone Title}

> {What this milestone delivers. Depends on Milestone 1 being complete.}

#### {T-03} — {Subtask Title}

| Field        | Value |
|--------------|-------|
| **Type**     | RESEARCH / SKILL / MCP_SERVER / CODE / ORCHESTRATOR / CONFIG |
| **Placement**| NEW_REPO / EXISTING_REPO:{repo-name} / NEW_MODULE:{repo/path} / EXTRACT_LATER |
| **Depends on**| T-02 |
| **Blocks**   | T-04 |
| **Input**    | {Output of T-02} |
| **Output**   | {What this task produces} |
| **Done when**| {One sentence verifiable condition} |

**Notes:**
{Context, constraints, open decisions}

---

<!-- Add Milestone N sections as needed. Each milestone = one demonstrable deliverable. -->

---

## Dependency Map

```
[M1] T-01 ──► T-02 ──► [M2] T-03 ──► T-04
                   └──────────────► T-05
[M1] T-06 (independent within M1) ──► [M2] T-05
```

> Milestone prefixes show which milestone each task belongs to.
> Tasks at the left have no dependencies and can start immediately.
> Tasks that share a column can run in parallel once their shared dependency is met.

---

## Parallel Opportunities

> List subtasks that can be worked in parallel once their dependencies are met.

- T-01 and T-03 can run in parallel (no shared dependencies)
- T-04 and T-05 can run in parallel after T-02

---

## Out of Scope

> Explicitly list what this ticket does NOT cover.
> This is as important as what it does cover.

- {Out of scope item 1}
- {Out of scope item 2}
- {Out of scope item 3 — and which future ticket will cover it, if known}

---

## Definition of Done (Ticket Level)

- [ ] All subtasks marked complete
- [ ] All acceptance criteria verified
- [ ] TASK-REASONING.md updated with any decisions made during implementation
- [ ] All OPEN questions resolved or consciously deferred with a note
- [ ] No ASSUMPTION left unvalidated

---

## Changelog

| Version | Date | Author | Summary of change |
|---------|------|--------|-------------------|
| v1      | {DATE} | {AUTHOR} | Initial ticket |
```
