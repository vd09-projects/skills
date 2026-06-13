# Agent Pattern — Orchestrating Skills

Recipe for building project-specific orchestrator agents that sequence skills via the handoff bus.

This is a recipe, not a dependency. Skills work without it. Projects that want a button-press "do the whole flow" experience write an agent. Projects that prefer manual skill invocation skip the agent entirely.

---

## Three invocation modes

The project chooses. Skills don't.

### Mode 1 — Standalone (no registry required)
Call the skill directly. Output stays in the conversation. Nothing persisted.

Skills work standalone by default. No registry entry needed. No skald needed.
Use when no audit trail or handoff artifact is required.

### Mode 2 — Skald-wrapped (single invocation)
```
skald run <skill-name> "<request>"
skald run <skill-name> --scope <slug> "<request>"
```
Skald invokes the skill as a subagent, captures its markdown output, classifies via the title line, resolves the scope slug, persists the artifact. Requires: skill registered in `.claude/skill-memory/skald/config.md`.

Use when one skill's output should be captured as a handoff artifact.

### Mode 3 — Agent-mediated pipeline
An agent (`.claude/agents/<name>.md`) sequences multiple `skald run <skill>` calls. The agent holds workflow state. Each step goes through skald for persistence and classification.

Use when a multi-step workflow (plan → build → review → iterate) needs a persistent audit trail.

**The agent is where project-specific skill wiring lives.** The agent knows which skill fills each role in this project. The skills do not know the agent. The agent can be replaced, and the skills stay unchanged.

---

## The model (v2)

```
agent (project-specific, in .claude/agents/)
  ↓ invokes
skald (generic orchestrator skill)
  ↓ invokes
producer skill (e.g., <planner-skill>, <implementation-skill>, <review-skill>)
  ↓ emits NATURAL MARKDOWN with title contract:
      # {ArtifactKind}: {scope title}
skald classifies via title, wraps with frontmatter, writes
  ↓
.claude/handoff/{slug}/{producer_role}-{plan_type}.md
+ INDEX.md + LOG.md + _thread.md
  ↓ feeds next via skald (skald reads upstream, passes brief to consumer)
consumer skill (next in sequence — also via skald)
```

**Producer skills are pure functions.** Input: CLAUDE.md + own memory + optional scope brief from skald. Output: natural markdown with title-line contract. Producers do NOT know about the handoff protocol — no YAML frontmatter, no roles, no filenames, no versions.

**Consumer skills receive scope briefs from skald.** They do not scan `.claude/handoff/`, do not parse frontmatter, do not write status fields. They build/review/etc. against the brief; skald handles the status updates.

**Skald is the persistence + classification layer.** It reads producer output, parses the title to classify the artifact, looks up the producer's role via its skill registry, generates frontmatter, resolves the slug, writes the canonical file, archives prior versions, updates indices.

**Agents are impure orchestrators.** Hold workflow state. Sequence skill invocations through skald. Project-specific.

---

## Example flow (v2 — skald-mediated)

The following uses role placeholders. Replace with the skill names your project has installed for each role (declared in skald's skill registry).

```
user: "add idempotent refund flow"
  ↓
agent (coordinator.md)
  ├─ Step 1: invoke skald run <planner-skill> "add idempotent refund flow"
  │            → <planner-skill> emits planner-task content
  │            → skald resolves slug (proposes 'payment-refund', user confirms,
  │              reasoning recorded in skopes.md)
  │            → skald writes .claude/handoff/payment-refund/planner-task.md (v1)
  │            → appends to _thread.md, updates INDEX.md, appends to LOG.md
  │            → user approves manually (edits status: approved)
  ├─ Step 2: invoke skald run <implementation-skill> --scope payment-refund (build mode)
  │            → <implementation-skill> reads .claude/handoff/payment-refund/planner-task.md
  │            → builds code + tests
  │            → emits implementation-build content
  │            → skald writes .claude/handoff/payment-refund/implementation-build.md (v1)
  │            → marks planner-task.md status: consumed
  ├─ Step 3: invoke skald run <review-skill> --scope payment-refund
  │            → <review-skill> reviews diff
  │            → emits review-findings content
  │            → skald writes .claude/handoff/payment-refund/review-findings.md (v1)
  ├─ Step 4: if findings: invoke skald run <implementation-skill> --scope payment-refund (iterate)
  │            → <implementation-skill> reads review-findings.md
  │            → fixes each finding
  │            → emits updated implementation-build content
  │            → skald archives v1 → _history/implementation-build-v1.md
  │            → writes v2 with status: draft (user re-approves)
  │            → marks review-findings.md status: consumed
  ├─ Step 5: loop step 3-4 until review clean
  └─ Step 6: close session — summarize, commit if requested
```

Skills don't know about each other. They don't write files. Skald handles persistence. The agent strings them together via skald.

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

1. **Read only own memory + CLAUDE.md + scope brief from skald** (if invoked through skald). Never reach into another skill's memory directory. Never scan `.claude/handoff/` directly.
2. **Producer skills emit natural markdown with the title contract.** No YAML frontmatter. No protocol fields.
3. **Consumer skills receive a brief from skald.** They do not parse handoff artifacts themselves.
4. **Obey the no-op contract.** When invoked standalone (no skald, no brief), proceed against the user's request — no auto-discovery of prior plans.
5. **Don't write files to `.claude/handoff/`.** Skald writes everything in the handoff layer. Producers and consumers never touch the directory.
6. **Don't sequence other skills.** Skills are leaves; agents are branches; skald is the persistence trunk.

---

## Building an agent

Minimal template (v2 — skald-mediated):

```markdown
# Customize this template:
# - Replace <planner-skill> with the skill you use for planning (e.g., mimir)
# - Replace <implementation-skill> with the skill you use for building (e.g., sindri)
# - Replace <review-skill> with the skill you use for review (e.g., multi-perspective-review)
# - Confirm those skills are registered in .claude/skill-memory/skald/config.md

---
name: my-coordinator
description: Use when user wants to <flow>. Orchestrates skald-mediated <planner> → <implementation> → <review>.
model: sonnet
---

You are a workflow orchestrator. All persistence flows through skald.

## Step 1 — Plan

Invoke `skald run <planner-skill>` with the user's request as input. Wait for skald's
terminal state. Skald will: resolve the scope slug (asking user if new), invoke the
planner, persist the canonical file at `.claude/handoff/{slug}/planner-{plan_type}.md`,
report the path + version. Surface the path to user. Wait for user to approve (edit
status to `approved` in the canonical file).

## Step 2 — Implement

Invoke `skald run <implementation-skill> --scope {slug}`. Skald passes the scope dir
to the implementation skill, which reads the approved planner-task.md, builds code +
tests, emits a build-summary artifact body. Skald persists as
`implementation-build.md`. Wait for terminal state.

## Step 3 — Review

Invoke `skald run <review-skill> --scope {slug}`. Skald passes scope dir; review skill
reads the build summary and current diff, emits findings. Skald persists as
`review-findings.md`.

## Step 4 — Iterate

If findings non-empty: invoke `skald run <implementation-skill> --scope {slug}` in
iterate mode. Reads findings, addresses each, emits updated build artifact. Skald
archives prior version to `_history/`, writes v{N+1} with `status: draft`. Repeat
until clean.

## Step 5 — Close

Summarize session for user. Optionally invoke `skald run <decision-log-skill>` to
record decisions (deferred under v2 MVP — decisions journal is a separate future
feature).
```

Customize per project. Add domain-expert step. Add task-manager step. Add quality gate. Whatever the workflow needs.

**Never write to `.claude/handoff/` from the agent directly.** Always go through skald. The agent decides which skill runs when; skald handles all file I/O for handoff artifacts.

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

That project's handoff schema is JSON-based and project-specific. The generic protocol in `skald/references/handoff-protocol.md` is markdown-based and cross-project. Choose JSON for tightly-coupled agent flows; choose markdown for human-readable cross-skill exchange. They can coexist — agents may emit both formats for different purposes.
