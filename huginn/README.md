# huginn

Deep **tech research** on a problem statement, with adversarial verification.
Named after Odin's raven *Hugin* ("Thought") — flies the world, returns with what
is real, not the first plausible story.

Huginn turns a software/engineering **problem statement** into a **verified
recommendation**. It frames the unknowns, fans out parallel grounded searches,
forms an opinion — then **attacks that opinion against primary sources** before it
becomes a cited, evidence-graded, versioned report in your repo.

Built on one finding from surveying every research agent on the market: a cited
report looks authoritative whether or not it's true (citation validity >94%,
factual accuracy 39–77%, and accuracy *drops* the more the agent searches). **No
existing tool does real adversarial cross-source verification** — that gap is the
reason this skill exists.

## What it's for

- **DECIDE** — "X vs Y, which?" → version-aware tradeoff + a pick
- **APPROACH** — "best way to solve this?" → ranked approaches
- **PRIOR-ART** — "how's it solved already — reuse or build?" → survey + a call
- **FEASIBILITY** — "can we even? X exists, how does Y fit?" → verdict + unknowns
- **UI** — "given this UI problem, what directions?" → grounded brief + design loop

Not a learning tool ("teach me X") and not an implementation tool. It can produce
an **MVP/spike plan** to test a hypothesis — never a full build.

## Pipeline (3 human checkpoints)

```
FRAME → ⏸ → FAN-OUT → SYNTHESIZE+OPINION → ⏸ → VERIFY → [DESIGN] → REPORT → ⏸
```

Frame the unknowns → approve the plan → parallel grounded fan-out → form an
opinion → review it → adversarially verify every load-bearing claim → (optional UI
design loop) → versioned cited report → approve. Never runs end-to-end unattended.

## Layout

- `SKILL.md` — the pipeline and non-negotiables (entry point)
- `references/framing.md` — frame the problem, split knowns/unknowns, decompose
- `references/fan-out.md` — parallel grounded sub-agent orchestration
- `references/verification.md` — the adversarial verification protocol
- `references/design-loop.md` — UI intent: frontend-design / claude.ai Design + DesignSync
- `references/report-format.md` — opinion shape + versioned report
- `templates/report.template.md` — the report skeleton
- `templates/huginn/config.template.md` — per-project config

## Config

`.claude/skill-memory/huginn/config.md` (project) over
`~/.claude/skill-memory/huginn/config.md` (global): output dir, recency cutoff,
authority preferences + pinned versions, design path, depth. No config → sane
defaults; report lands at `research/<slug>/report.md`.
