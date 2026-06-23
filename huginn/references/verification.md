# Adversarial verification — the protocol

This is why huginn exists. No research agent on the market does real adversarial
cross-source verification; their "verify" is scrape-more-sites, self-reflection,
or relevance scoring. The result is reports that *look* authoritative while being
39–77% accurate — and accuracy that **drops** the more the agent searches, because
more retrieval means more chances to staple a real-looking citation to a wrong
claim ("hallucination laundering").

Stage 3 attacks the opinion formed in Stage 2 and only lets through what survives.

## The one design constraint

**The verification signal must come from outside the model's own forward pass.**
A model asked to "review and fix your answer" using only its own knowledge
reliably makes the answer *worse* (every gain in early self-correction papers came
from smuggled ground truth). So every check below routes through an **external**
signal — a fetched document, a different fresh context, or a code execution —
never the drafting model re-reading itself.

## Step 1 — Extract atomic, self-contained claims

From the Stage 2 opinion, pull out the **load-bearing** factual claims (the ones
the recommendation rests on — not every sentence). For each:

- **Make it atomic** — one fact per claim.
- **Make it self-contained** — resolve pronouns and vague references to explicit
  entities, so the claim survives outside the report's context.
- **Tag its type** — `factual` · `quantitative` (a number/benchmark) ·
  `version-sensitive` (API/syntax/behavior) · `code` (a code claim that can run).

Skip taste/opinion statements (flagged soft in framing) — they can't be verified,
only attributed. Don't dress them up as verified facts.

## Step 1.5 — Triage: spend the blind-verifier budget where laundering lives

Don't blind-re-verify everything — Stage 1 already fetched and **quote-pinned**
primary sources, and a second pass over a stable official-doc fact pays nothing.
Citation-laundering and staleness concentrate in a few places; aim the adversarial
budget there.

- **Promote directly to `verified`** (no second pass): claims already quote-pinned
  in fan-out to a **primary/official source** that is **static** — a documented
  API behavior, a spec'd limit, a syntax rule. The fetched span already settled it.
- **Always blind-verify** (this is where one-pass agents ship wrong): **volatile**
  claims — project status / maturity / "production-ready" / latest-version /
  anything time-sensitive (these rot between releases) — and **vendor-supplied
  numbers** (benchmarks, "Nx faster") regardless of how authoritative the source
  looked. A claim graded `single-source` or `contested` in fan-out also gets a pass.

Re-verifying a static official-doc fact while skipping a volatile maturity claim is
the budget spent exactly backwards. When unsure whether a claim is volatile, treat
it as volatile.

## Step 2 — Verify each claim in a fresh, blind context

For each load-bearing claim, spawn a **verifier sub-agent that does NOT see the
draft, the opinion, or huginn's reasoning** — only the bare claim. If a
`claim-verifier` agent type is installed, use it — it is tool-sandboxed (read + web +
temp-only Bash, no Write/Edit, no nested agents) so it *structurally* cannot see or
edit the draft, and it bakes the existence-vs-support / quote-pin / refutation-first
protocol below into its prompt. Otherwise spawn a generic blind sub-agent.
Independence is
load-bearing: a verifier shown the original claim anchors on it and rubber-stamps.
Give the verifier:

1. **Refutation-first queries.** Search to *break* the claim, not confirm it:
   "<claim> is wrong", "<X> deprecated", "<X> benchmark disputed", "<X> vs <Y>
   criticism". Confirmatory search retrieves confirming sources and entrenches
   errors; refutation surfaces the contradicting evidence that confirmation hides.
2. **Two separate checks — existence AND support:**
   - **Existence** — does the cited source actually resolve / does the DOI/arXiv
     id exist? 3–13% of citations are fabricated even in retrieval-augmented runs;
     a non-resolving URL is always fabricated.
   - **Support** — fetch the source and check it **entails** the claim
     (NLI-style: does the passage actually back the statement?). A real URL
     attached to a claim it doesn't support is the most common failure.
3. **Quote-pin.** The verifier must return the **specific sentence/data span**
   from the source that supports the claim. **No quotable span → unsupported.**
4. **Version-check** (version-sensitive claims) — confirm the claim holds for the
   *pinned* version, not a different one. "True in v18, false in v19" is a fail if
   the report implies the current version.
5. **Execute** (code claims) — run it where feasible. A passing test beats any
   cited doc. The strongest external signal available. See Step 2.5 — for an
   empirically testable claim, don't wait for runnable code to exist: **write a
   probe and run it.**

For **derived/quantitative conclusions** (math, multi-step inference), also run a
**self-consistency** check: sample the derivation a few times in independent
contexts and require agreement — disagreement means the conclusion is unstable.

## Step 2.5 — Verification spike (write a probe to settle a claim)

For a load-bearing claim that is **empirically testable** — "does X actually
support Y", "does this compile/run under the pinned version", "can Y talk to X" —
the strongest signal isn't another doc, it's **running code huginn writes itself**.
Don't wait for a runnable artifact to exist; manufacture the evidence. This is a
verification path, not implementation — the **research skill writes code only to
verify, never to build a feature.**

- **Trigger** — the claim is testable AND a probe settles it cheaper or harder
  than docs. Concentrated in FEASIBILITY ("does the seam between Y and X hold")
  and version-sensitive behavior claims.
- **Scope** — minimal, throwaway, single claim. One file, one behavior, no
  scaffolding. If the probe grows past roughly a screenful, it's the wrong tool —
  stop and settle the claim by docs instead. A probe is never a step toward the
  MVP/spike plan (that's a *plan* the report may carry; this is *code huginn runs
  now*).
- **Isolated** — build and run it in a temp dir / sandbox, **outside the repo's
  real source**. Park the artifact under `<output_dir>/<slug>/_history/probes/`
  for the audit trail, or discard it — never leave it as live code in the project.
- **Result is evidence:**
  - **Passes** → grade the claim `verified` (execution-backed — the strongest
    grade; record what ran and the observed output as the support span).
  - **Fails** → the claim is **killed**; the failure is itself a finding that
    reshapes the recommendation (loop back per Step 5).
  - **Inconclusive / can't isolate** → say so and fall back to doc verification;
    don't dress a flaky probe up as proof.
- **State the bound loud** — label it "probe to settle claim N, not an
  implementation", so the no-full-build line never blurs.

## Step 3 — Handle numbers and benchmarks with extra suspicion

- **Vendor numbers are claims.** Self-reported scores skew favorable; prefer
  independent replication, which usually lands lower.
- **A benchmark number is meaningless without its settings** — N-shot, CoT on/off,
  version/subset, hardware. Missing settings → caveat or reject the number.
- **Trace every number to its primary source.** Numbers drift through citation
  chains (blog cites blog cites paper). Pull the original table.
- **Be most skeptical near saturation** — a near-perfect score should raise
  suspicion (contamination), not confidence.

## Step 4 — Grade or kill each claim

Assign every load-bearing claim a grade, tied to **what backs it**, not to a
self-reported confidence number:

| Grade | Meaning | Action |
|---|---|---|
| `verified` | A primary/authoritative source entails it, quote-pinned, version-correct — **or a verification probe (Step 2.5) ran and passed** | Keep; cite with the pinned source + quoted span, or the probe + its observed output |
| `single-source` | Only one source supports it; not independently corroborated | Keep, but flag the thin support |
| `contested` | Authoritative sources disagree | Keep BOTH, attribute each, name the axis of disagreement — never average |
| `unsupported` | No source entails it / no quotable span / citation doesn't support | **Cut or downgrade** the claim; the recommendation must not rest on it |
| `model-only` | Asserted from parametric memory, no external grounding | Flag loudly as unverified; do not present as fact |

## Step 5 — Feed back into the opinion

Verification is allowed to **break the recommendation** — that's the point, not a
failure. If load-bearing claims fall:

- Cut/downgrade them and re-examine whether the recommendation still stands.
- If the core breaks, **say so explicitly** and loop back to Stage 2 (or even
  Stage 0 if an assumption was wrong) rather than salvaging a dead conclusion.
- Surface what's now `contested` or `model-only` as **open unknowns** in the
  report — an honest "here's what we still don't know" beats false closure.

The report that emerges carries each claim's grade inline, so the citation-quality
trap is visible instead of hidden: a reader sees not just "there's a citation" but
"this claim is `verified` / `contested` / `model-only`."
