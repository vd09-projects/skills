# huginn-workers

The two tool-sandboxed sub-agents huginn fans out to. They are **workers, not a
driver** — huginn itself stays in the main thread (so its three human checkpoints stay
direct and its Stage 2/5 synthesis + write stay in a safe top-level context), and
delegates only the heavy, autonomous-between-checkpoints work to these.

```
huginn  (main thread — frame · synthesize · write · 3 checkpoints)
  ├─ Stage 1 fan-out   → research-scout   (one per sub-question, parallel)
  └─ Stage 3 verify    → claim-verifier   (one per load-bearing claim, blind)
```

## Why these, not a host agent

Huginn is already an orchestrator with a human in the loop. Burying the whole pipeline
in one driver agent would (a) turn every checkpoint into a relay that risks paraphrase,
and (b) push fan-out/verify into deeper nesting that huginn warns against for the write.
The high-leverage, reusable piece is the **worker** huginn calls many times — and
sandboxing it fixes a real defect: by default huginn's workers are `general-purpose`
(full tools), so a "verifier" can edit the very draft it checks and a gatherer can
fabricate-then-write. These two close that off **structurally**.

| Agent | Stage | Locked to | Cannot |
|---|---|---|---|
| `research-scout` | 1 — grounded gather | Read, Grep, Glob, Bash, WebSearch, WebFetch | write files · synthesize across questions · spawn sub-agents |
| `claim-verifier` | 3 — blind adversarial verify | Read, Grep, Glob, Bash, WebSearch, WebFetch | see/edit the draft · write into the repo · spawn sub-agents |

Both: **no Write/Edit, no Agent tool.** `claim-verifier`'s Bash is for a throwaway
verification probe in a temp sandbox only (Step 2.5), never the repo.

## Install

Symlink both agents into `~/.claude/agents/`, and (since these are workers, not a
driver) make sure huginn itself is installed so it runs in the main thread:

```bash
ln -s ~/repos/skills/agents/huginn-workers/research-scout.md  ~/.claude/agents/research-scout.md
ln -s ~/repos/skills/agents/huginn-workers/claim-verifier.md  ~/.claude/agents/claim-verifier.md
ln -s ~/repos/skills/huginn                                   ~/.claude/skills/huginn
```

Verify:

```bash
ls -la ~/.claude/agents/research-scout.md ~/.claude/agents/claim-verifier.md ~/.claude/skills/huginn
```

## Wiring

huginn's references point at these by name:

- `huginn/references/fan-out.md` — "if a `research-scout` agent type is installed, fan
  out to it" (else a generic sub-agent with the same brief).
- `huginn/references/verification.md` — "if a `claim-verifier` agent type is installed,
  use it" (else a generic blind sub-agent).

So when huginn reaches Stage 1 / Stage 3 it selects these automatically. They also work
standalone for any supervisor that needs one grounded sub-question researched or one
claim attacked.

## Usage

You don't invoke these directly in normal use — huginn does, during a research run:

```
research: redis vs postgres LISTEN/NOTIFY for our job queue
```

huginn frames → (checkpoint) → fans out `research-scout`s → synthesizes opinion →
(checkpoint) → attacks each load-bearing claim with `claim-verifier`s → writes the
graded, cited, versioned report → (checkpoint).

Standalone is fine too: "use research-scout to gather grounded findings on X" or
"use claim-verifier to blind-check: <atomic claim>".

## Anti-scope

Neither agent: writes a report · forms the overall recommendation · approves a stage ·
files an issue · commits. Those stay with huginn and the human.
