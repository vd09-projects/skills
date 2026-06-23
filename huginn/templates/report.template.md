<!--
Huginn report template. The H1 IS the recommendation, not a topic label.
Fill the intent-shaped body (see references/report-format.md). Every load-bearing
claim carries an evidence grade: [verified] [single-source] [contested]
[model-only]. Re-runs prepend a Changelog entry and archive the prior version to
_history/report-vN.md — never overwrite.
-->

# {Recommendation as a claim — the answer in the title}

**Version:** v{N} · {YYYY-MM-DD} · Verification: {e.g. 9 verified / 2 contested / 1 model-only}
**Intent:** {DECIDE | APPROACH | PRIOR-ART | FEASIBILITY | UI}

## Changelog
<!-- Newest first. What changed and WHY. Omit on v1 (just "- v1 ({date}): Initial."). -->
- v{N} ({date}): {what changed + why — new evidence, regraded/killed claim, flipped rec, widened scope}

## Recommendation
{2–4 sentences. Lead with the answer. State what would change it.}
<!-- If the pick differs from a soft preference stated in framing, say so:
     "you leaned X; we recommend Y because …" — never a silent swap. -->

## Frame
| | |
|---|---|
| **Knowns (X)** | {given/fixed — tag each [hard constraint] or [soft preference]} |
| **Unknowns (Y)** | {what had to be resolved} |
| **Assumptions** | {taken as true, would flip the answer if wrong} |
<!-- FEASIBILITY: add an interaction map — how Y connects to X and A, what breaks at the seams. -->

## Reasoning
<!-- Intent-shaped (report-format.md):
     DECIDE → version-aware tradeoff table + the deciding factor(s)
     APPROACH → ranked approaches (cost/risk/fit/when-it-wins) + the pick
     PRIOR-ART → survey of existing solutions + explicit reuse-vs-build call
     FEASIBILITY → verdict (yes/no/yes-if) + interaction map + gating unknowns
     UI → design directions + grounded brief + analysis of the returned design -->

{body}

## Evidence & claims
<!-- Every load-bearing claim, graded, cited, quote-pinned. -->
- [verified] {claim} — {url} — "{quoted span}" ({version / date})
- [single-source] {claim} — {url} — "{quoted span}"
- [contested] {claim} — {url-a} vs {url-b} — axis: {what they disagree on}
- [model-only] (unverified) {claim} — no source.

## Contradictions left standing
{Where authoritative sources disagree — both sides attributed, axis named. Not averaged.}

## Open unknowns
{What's still unresolved or model-only, and what would settle it.}

## MVP / spike plan
<!-- Only if the user asked. The smallest experiment to test the core hypothesis —
     a scoped spike, NOT a full build. -->
- **Build:** {the minimal thing}
- **Signal:** {what it produces}
- **Confirms if:** {result} · **Refutes if:** {result}

## Sources
1. {url}
2. {url}
