# Agent Pattern — Orchestrating Skills

Recipe for building project-specific orchestrator agents that sequence skills via the handoff bus.

This is a recipe, not a dependency. Skills work without it. Projects that want a button-press "do the whole flow" experience write an agent. Projects that prefer manual skill invocation skip the agent entirely.

---

## The model

```
agent (project-specific, in .claude/agents/)
  ↓ invokes
skill (generic, in .claude/skills/)
  ↓ writes/reads
.claude/handoff/*.md (artifacts per handoff protocol)
  ↓ feeds next
skill (next in sequence)
```

**Skills are pure-ish functions.** Input: CLAUDE.md + own memory + handoff artifact (if any). Output: handoff artifact (if producer) or none (if pure consumer).

**Agents are impure orchestrators.** Hold workflow state. Sequence skills. Pass context. Project-specific.

---

## Example flow

```
user: "implement TASK-0042 — add idempotent refund"
  ↓
agent (coordinator.md)
  ├─ Step 1: invoke mimir skill
  │            → writes 20260520-143022-task-add-idempotent-refund.md (status: draft)
  │            → user approves manually (edits status: approved)
  ├─ Step 2: invoke task-manager skill
  │            → reads handoff, creates task entry
  ├─ Step 3: invoke implementation skill (e.g., sindri)
  │            → scans handoff dir, finds approved task plan
  │            → builds code + tests
  │            → marks handoff status: consumed
  │            → optionally writes a review-request artifact
  ├─ Step 4: invoke review skill (e.g., multi-perspective-review)
  │            → reviews diff
  │            → writes 20260520-160000-review-add-idempotent-refund-findings.md
  ├─ Step 5: invoke implementation skill again (iterate mode)
  │            → reads findings handoff
  │            → addresses each
  │            → marks findings status: consumed
  ├─ Step 6: invoke decision-log skill
  │            → records any **Decision (...)** marks from the session
  └─ Step 7: loop to next task or close session
```

Skills don't know about each other. The agent strings them together.

---

## Where the agent lives

```
.claude/agents/coordinator.md        ← project-specific agent
.claude/agents/build-session.md      ← per-workflow agent (optional)
.claude/agents/review-session.md     ← per-workflow agent (optional)
```

Agents are Claude Code's project-level agent feature. They have YAML frontmatter (`name`, `description`, `model`, etc.) and natural-language instructions for orchestrating skills.

---

## Session state (optional)

If a workflow has many steps and may be paused/resumed, agents can keep their own session state file. This is NOT part of the handoff protocol — it's the agent's internal bookkeeping.

Recommended convention (from the backtesting-algo-trading reference repo):

```
.claude/agent-sessions/{YYYY-MM-DD}-{session-id}.json
```

One file per session. Never deleted. Resume by globbing.

The agent's session state references handoff artifacts by filename. Handoff artifacts are immutable history; agent session state is mutable workflow state.

---

## Agent responsibilities

1. **Read user intent.** Classify request, pick the workflow.
2. **Sequence skills.** Invoke in order; pass context via handoff artifacts.
3. **Approve handoffs (optional).** Some agents may auto-approve trivial drafts. Most leave approval to the user. Document this in the agent's instructions.
4. **Hold session state.** Track progress across sub-skill invocations. Survive resume.
5. **Surface terminal states.** When a skill returns `Blocked — need input.`, agent surfaces to user and waits.
6. **Close out.** After all steps, summarize, optionally invoke `decision-log` skill, commit if requested.

---

## Skill responsibilities (orthogonal to agents)

1. **Read only own memory + CLAUDE.md + handoff artifact.** Never reach into another skill's directory.
2. **Declare role accurately** (producer/consumer/both) in handoff artifacts.
3. **Obey the no-op contract** if handoff dir empty.
4. **Don't sequence other skills.** Skills are leaves; agents are branches.

---

## Building an agent

Minimal template:

```markdown
---
name: my-coordinator
description: Use when user wants to <flow>. Orchestrates <skill A> → <skill B> → <skill C>.
model: sonnet
---

You are a workflow orchestrator. Run this sequence:

## Step 1 — Plan

Invoke the planner-role skill with the user's request as input. Wait for terminal
state. If `Plan ready.`: read the produced handoff artifact filename from the
directory listing (most recent file with `status: draft`, matching `consumer_role`).
Surface filename to user. Wait for user to approve (edit status to `approved`).

## Step 2 — Implement

Invoke the implementation-role skill. It will scan `.claude/handoff/` and find the
approved artifact via `scope_hint`. Wait for terminal state.

## Step 3 — Review

Invoke the review-role skill on the produced diff. It writes a findings artifact.

## Step 4 — Iterate

If findings non-empty: invoke implementation skill in iterate mode. It reads
findings artifact, addresses each. Repeat until clean.

## Step 5 — Close

Invoke decision-log skill to record decisions. Summarize session for user.
```

Customize per project. Add domain-expert step. Add task-manager step. Add quality gate. Whatever the workflow needs.

---

## Anti-patterns

- **Putting workflow logic in a skill.** Skills are leaves. Workflow = agent.
- **Hardcoding skill names in an agent.** Wrong for the agent layer, right for the skill layer. Agents are project-specific and CAN name specific installed skills — they encode the project's chosen skill stack. Skills must stay generic.
- **Agent reading skill memory directly.** Agents read handoff artifacts (per protocol) and project files (CLAUDE.md, tasks/, decisions/). Skill memory is the skill's private state.
- **Agent skipping handoff approval.** Drafts must be user-approved unless explicitly auto-approved with documented reason.
- **One agent for all workflows.** Better: small focused agents per workflow (build-session, review-session, evaluate-session). Easier to read, easier to maintain.

---

## Reference

For a working example of this pattern at scale, see:
`/Users/vikrantdhawan/repos/backtesting-algo-trading/`
- `.claude/agents/build-session.md` — orchestrator agent
- `workflows/agents/*.md` — sub-agent prompt templates
- `workflows/sessions/*.json` — per-session state files
- `workflows/handoffs/schema.md` — that project's handoff schema (predates this generic protocol)

That project's handoff schema is JSON-based and project-specific. The generic protocol in `_shared/handoff-protocol.md` is markdown-based and cross-project. Choose JSON for tightly-coupled agent flows; choose markdown for human-readable cross-skill exchange. They can coexist — agents may emit both formats for different purposes.
