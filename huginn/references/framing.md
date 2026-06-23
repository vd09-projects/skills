# Framing — turn a problem statement into a research plan

The frame is the spine of the whole run. A vague problem statement produces vague
research; the loopholes in market research agents (scope drift, "misinformation by
omission", answering a question nobody asked) start here. Spend disproportionate
care on Stage 0 — it is the cheapest place to be right.

## 1. Restate

One sentence, in your own words, that says what is actually being asked. If you
cannot restate it crisply, the problem statement is underspecified — ask 1–3
sharp clarifying questions before going further. Underspecified inputs are where
research agents waste the most compute.

## 2. Classify intent

The class sets the report shape (`report-format.md`) and whether Stage 4 runs.

| Class | The user is really asking | Report centers on |
|---|---|---|
| **DECIDE** | "X vs Y — which?" | A pick, with a version-aware tradeoff table + decisive factors |
| **APPROACH** | "What's the best way to solve this?" | A ranked set of approaches, each with cost/risk/fit |
| **PRIOR-ART** | "How is this solved already — reuse or build?" | A survey of existing solutions + an explicit reuse-vs-build call |
| **FEASIBILITY** | "Can we even do this? X exists; how does Y fit X and A?" | A verdict + the critical unknowns + an interaction map (Y↔X↔A) |
| **UI** | "Given this UI problem, what directions?" | Design directions + a grounded brief; triggers Stage 4 |

A statement can carry two classes (e.g. FEASIBILITY that resolves into a DECIDE).
Name the primary one; note the secondary. When unsure, ask — don't guess the
shape of the deliverable.

## 3. Split the ground: KNOWNS / UNKNOWNS / ASSUMPTIONS

This is the move that makes feasibility and approach questions tractable. Build a
small table:

| | Content |
|---|---|
| **KNOWNS (X)** | What is given, fixed, or already true. Splits into two kinds — **hard constraints** vs **soft preferences** (below); the split is load-bearing. |
| **UNKNOWNS (Y)** | What must be resolved for the answer to exist. The actual research targets. Each becomes one or more sub-questions. |
| **ASSUMPTIONS** | Things you're taking as true that *aren't given* and that **change the answer if wrong**. Name every one — an unstated assumption is how a confident report ends up wrong. |

### Hard constraint vs soft preference — do not conflate

The KNOWNS row hides a trap: a stated **preference** looks like a fixed constraint,
gets locked, and is never challenged — the report then rubber-stamps the user's
leaning instead of researching past it. Split every KNOWN into one of two:

| Kind | What it is | How research treats it |
|---|---|---|
| **Hard constraint** | Fixed, non-negotiable. The existing system, the stack, a budget cap, must-run-on-prem, a pinned version. | **Build on it. Never re-litigate.** It bounds the option space. |
| **Soft preference** | The user's current leaning, stated as taste not law — "I like X", "I'm leaning X, but open to the best way". | **A candidate, not the verdict.** Surface alternatives, weigh them against the leaning, and **override if a better option survives verification.** |

Tell them apart by signal words:

- "must / can't / required / non-negotiable / already built on" → **hard constraint**
- "I like / I'd prefer / I'm leaning / my instinct is / but open to best" → **soft preference**

When a KNOWN is ambiguous which kind it is, **ask** — guessing it hard silently
kills the research; guessing it soft re-opens something the user settled.

A soft preference flows downstream as a *labeled candidate*, never a foregone
conclusion: in a DECIDE tradeoff it is one row among the options (and the pick may
differ); in the report's Recommendation, an override is stated explicitly with its
reason — "you leaned X; we recommend Y because …" — never a silent swap.

For FEASIBILITY specifically, also sketch the **interaction**: Y must connect to X
(the existing world) and possibly to some A (a third component). "Can Y exist" is
usually less interesting than "how does Y talk to X and A, and what breaks at the
seams" — make the seams explicit unknowns.

## 4. Decompose into sub-questions

Turn the UNKNOWNS into **3–7 independently researchable sub-questions**. Each one:

- **Stands alone** — a sub-agent can research it without the others' results
  (dependencies between sub-questions mean you've cut them wrong; re-split).
- **Has a shape of answer** — name what a good answer looks like (a number, a
  yes/no + mechanism, a comparison, a list of existing tools).
- **Names its likely settling sources** — official docs, a benchmark, source
  code, an RFC, a maintainer's guide. If nothing authoritative could settle it,
  flag it as inherently soft (opinion/taste) so it isn't dressed up as fact later.
- **Is version/recency-scoped** where relevant — "in React 19", "as of 2026", "in
  the current LTS" — so the fan-out pins versions from the start.

Prefer fewer, sharper sub-questions over many shallow ones. Each extra sub-agent
adds coordination cost and dilutes focus; over-decomposition is a known failure
mode. 3–5 is the sweet spot for most problems; 6–7 only for genuinely broad ones.

## 5. Output the frame

Markdown, in this order:

1. **Restatement** — one sentence.
2. **Intent** — primary class (+ secondary if any), one line on why.
3. **Frame table** — KNOWNS / UNKNOWNS / ASSUMPTIONS, with each KNOWN tagged
   **[hard constraint]** or **[soft preference]** (+ interaction map for FEASIBILITY).
4. **Research plan** — the numbered sub-questions, each with shape-of-answer and
   likely sources.

Then stop for **Checkpoint 1**. Invite the user to edit sub-questions, fix an
assumption, re-scope, re-classify, **or flip a KNOWN between hard constraint and
soft preference** — the wrong tag there silently steers the whole run. The plan is
theirs to approve — surface it as editable, the way the best HITL research tools
gate on the plan before spending.
