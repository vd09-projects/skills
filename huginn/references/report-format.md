# Report format — opinion shape (Stage 2) and the written report (Stage 5)

Two things use this file: Stage 2 (how to shape the opinion before verification)
and Stage 5 (how to write the versioned report). The report's job is to make the
**answer** and its **evidence grade** both visible — so a reader trusts it for the
right reasons, not because it merely has citations.

## The answer is the title

The report's H1 **is the recommendation**, not "Research on X". The reader should
get the answer in the title and the first paragraph, then descend for the why and
the evidence. (`Decision: use opaque tokens, not JWT, for session auth`, not
`JWT vs opaque tokens research`.)

## Per-intent shape

The intent class from Stage 0 sets the body shape:

| Intent | Body centers on |
|---|---|
| **DECIDE** | A **version-aware tradeoff table** (options × decisive factors), the pick, and the 1–2 factors that actually decided it. |
| **APPROACH** | A **ranked list of approaches**, each with cost / risk / fit / when-it-wins, then the recommended one and why. |
| **PRIOR-ART** | A **survey of existing solutions** (what each does, maturity, fit), then an explicit **reuse-vs-build** call with the deciding criteria. |
| **FEASIBILITY** | A **verdict** (yes / no / yes-if), an **interaction map** (how Y connects to X and A and what breaks at the seams), and the **critical unknowns** that gate it. |
| **UI** | **Design directions** + the grounded brief, plus the **analysis of the returned design** (Stage 4) and what it revealed. |

## Standard sections (all intents)

1. **Recommendation** — the answer, 2–4 sentences. Lead with it.
2. **Frame** — the KNOWNS / UNKNOWNS / ASSUMPTIONS table from Stage 0 (so the
   reader sees what the answer rests on, and which assumptions would flip it).
3. **The reasoning** — intent-shaped body (table above). This is where the
   evidence-graded claims live.
4. **Evidence & claims** — every **load-bearing claim** with its grade, citation,
   and the quote-pinned span. Render the grade inline so it's unmissable:

   ```
   - [verified] Opaque-token revocation is immediate; JWTs require a denylist
     until expiry. — <source url> — "<quoted span>" (v… / dated …)
   - [contested] Throughput claims differ: vendor reports 40k rps; independent
     replication reports ~26k. — <both urls> — axis: hardware + batch size.
   - [model-only] (unverified) Most teams migrate within one sprint. — no source.
   ```

5. **Contradictions left standing** — where authoritative sources disagree, both
   sides attributed, the axis named. Never averaged away.
6. **Open unknowns** — what's still unresolved or `model-only`, and what would
   settle it. Honest non-closure beats false confidence.
7. **MVP / spike plan** *(only if asked)* — the smallest experiment that would
   test the core hypothesis. A scoped spike, **not** a full implementation —
   what to build, what signal it produces, what result would confirm/refute.
8. **Sources** — sequential numbered list, every unique URL used, deduped.

## Evidence grades (from verification.md)

`verified` · `single-source` · `contested` · `unsupported` (cut/downgraded —
shouldn't appear as support) · `model-only` (flagged, never presented as fact).
Tie the grade to what backs the claim, not to a self-reported confidence number.

## Versioning (Stage 5)

The report is a living document; re-runs version it, never overwrite.

- **Path** — `<output_dir>/<slug>/report.md` (default `research/<slug>/report.md`;
  config overrides the dir). Prior versions archive to
  `<output_dir>/<slug>/_history/report-vN.md`.
- **On a re-run:** move the existing `report.md` to `_history/report-v{N}.md`,
  write the new one as v{N+1}, and **prepend a changelog entry** at the top:

  ```
  ## Changelog
  - v3 (2026-06-23): Flipped recommendation JWT → opaque tokens. New independent
    benchmark (─url─) refuted the vendor throughput claim that v2 rested on;
    that claim regraded contested → unsupported and cut.
  - v2 (2026-06-20): Added revocation-latency evidence; recommendation unchanged.
  - v1 (2026-06-18): Initial.
  ```

  The changelog records **what changed and why** — new evidence, a regraded or
  killed claim, a flipped recommendation, a widened scope. It's the audit trail of
  how the answer evolved.
- **Stamp** each version with the date (use the session date) and the verification
  state (e.g. "12 load-bearing claims: 9 verified, 2 contested, 1 model-only").
- **Never silently overwrite.** Archive first, changelog always.

## If no repo / output dir is resolvable

Don't fail — render the full report in chat as a clean markdown block and tell the
user where it would nest. The format survives any destination.
