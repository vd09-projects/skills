# Fan-out — parallel grounded research

Stage 1 turns the approved sub-questions into evidence. The design follows the
one pattern every capable research system converged on: **a supervisor that fans
out into isolated-context sub-agents, each of which grounds in fetched sources and
compresses before returning.** Huginn is the supervisor. It does not write the
report here — it gathers graded findings for Stage 2.

## Orchestration contract

- **One sub-agent per sub-question**, launched **in parallel** (single message,
  multiple agent calls). Each gets its own context window so breadth doesn't
  exhaust one context.
- Sub-agents **return findings, not prose for the report.** Synthesis is huginn's
  job in Stage 2 — parallel writers produce disjoint, contradictory reports. The
  sub-agent's job ends at "here are graded, sourced findings for my sub-question."
- **Keep the report-write out of deep nesting.** Sub-agents research; huginn
  synthesizes and writes. If huginn is itself running inside a sub-agent chain,
  still keep Stage 2/5 in huginn's own context.
- Budget the parallelism. 3–5 sub-agents is typical; more adds coordination cost
  and duplication. If two sub-questions overlap, merge them before launching.

## The sub-agent brief (give each one this)

Each research sub-agent must be told, explicitly:

1. **The one sub-question** it owns, with its shape-of-answer and version/recency
   scope.
2. **Ground every claim in a fetched source.** Use web search to find candidates,
   then **fetch and read** the authoritative ones — do not answer from snippets or
   from parametric memory. Return the source URL for every claim.
3. **Authority hierarchy** (prefer top, distrust bottom):
   1. Official docs / API reference **for the pinned version**, changelogs /
      release notes, RFCs, the actual source code.
   2. Maintainer-authored migration/upgrade guides.
   3. Recent, **dated** blog posts / engineering writeups.
   4. Forum / Stack Overflow answers — **check the date**; treat answers that
      predate the relevant release as suspect.
4. **Version-pin.** For any API/syntax/behavior/default claim, state the version
   it holds for. An unversioned claim is incomplete. Knowledge cutoffs make
   parametric memory stale across breaking releases — prefer live fetched docs.
5. **Empty retrieval is a valid result.** If no authoritative source supports an
   answer, say "no authoritative source found" — **never invent a plausible
   source or number.** This is the #1 catastrophic failure to avoid.
6. **Distrust vendor numbers.** A benchmark/metric from the thing's own vendor is
   a claim, not a fact — note it as vendor-supplied, capture the settings (N-shot,
   version, hardware), and prefer independent replication where it exists.
7. **Compress, but keep sources.** Return a tight findings list — but do not
   summarize a fact away from its citation, and do not drop any source URL.

## What a sub-agent returns

A structured findings list for its sub-question, each finding as:

```
- CLAIM: <one self-contained factual statement, version-pinned where relevant>
  SOURCE: <url> — <which authority tier> — <date of source if known>
  SUPPORT: <the specific sentence/data from the source that backs the claim>
  CONFIDENCE: <high | medium | low> — <why: single source? vendor-supplied? contested?>
```

Plus a short note on **what it could NOT find** (open gaps) and **any
contradictions** it hit between sources. Gaps and contradictions are first-class
results — they shape Stage 2 and Stage 3.

## After collection

Huginn gathers all sub-agents' findings and moves to Stage 2 (synthesis). Do not
verify yet — Stage 1 gathers, Stage 3 attacks. But carry forward, per finding:
its sources, its support spans, its confidence, and whether it was vendor-supplied
or contested. Stage 3 will need all of it to grade the claim.

Huginn is **fully self-contained**: it gathers through its own grounded
sub-agents, never by delegating to another skill. Nothing else can honor the
authority-hierarchy + version-pinning contract above, so there is no escape hatch —
if a sub-question is hard, sharpen the sub-agent brief, don't outsource it.
