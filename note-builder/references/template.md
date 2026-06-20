# The note template

Every note has the same shape. A fixed shape means near-zero per-note decisions,
and it survives any tool migration. Fill it lazily — empty rungs are fine.

```
TITLE:      [claim-style — the answer in one line]                 (L0)
WHAT / WHY: [one sentence: what it is + why you'd care]            (L0)

SELF-TEST:  Q: [...]  → answer in a toggle
            Q: [...]  → answer in a toggle
            (coverage-based: enough Qs to revise the whole concept from the
             doc, weighted to why/tradeoff. On-demand recall, not a quiz.
             See self-test.md.)

▸ L1  Gist            (open by default)
▸ L2  How it works    (toggle)
▸ L3  Details / tradeoffs / gotchas   (toggle)
▸ L4  Implementation + → source links (toggle)

MAP:        → [[child page]]  → [[child page]]   (index of deeper nodes)
RELATED:    → [[cross-linked concept]] (+ one phrase on why it connects)
PARENT:     ← [[parent page]]

META:       type: concept | reference
            confidence: confirmed | told | assumed | inferred
            last touched: YYYY-MM-DD
```

In Notion each `Lx` is a **toggle heading**, so the collapsed page *is* the
depth ladder — the user expands only the rung they want.

## Field-by-field

- **TITLE** — make it a *claim*, the answer itself. "B-tree is Postgres's default
  index, best for range & equality lookups" — not "B-tree notes." A good title
  answers "is this the note I want?" from the search hit alone.
- **WHAT / WHY** — one sentence. The *why* is the perishable, expensive part;
  always include it.
- **SELF-TEST** — questions on the visible line, answers nested in toggles. A
  miss points the user straight to the section to reread. Write enough to revise
  the whole concept from the doc (not a fixed count), weighted to why/tradeoff;
  keep the sharp ones, drop the rest. They're for finding gaps, not rote
  memorization. Full rules in `self-test.md`.
- **L1–L4** — see `depth-ladder.md`. Fill only as far as the material supports.
- **MAP** — links to deeper children. Only appears once a note has children.
- **RELATED** — real conceptual connections, each with a short reason. Connect,
  don't group: no generic tag-buckets.
- **PARENT** — every note links back to its parent. No orphans.
- **META** —
  - `type`: `concept` (something you're learning) or `reference` (a system,
    call, or codebase you operate).
  - `confidence`: how you know it — `confirmed` (verified), `told` (someone said
    so), `assumed`, `inferred`. Matters when the user later acts on it.
  - `last touched`: the freshness date; bump it on every real-use edit.

## Two modes, one shape

The `type` property flips the emphasis without changing the structure.

| | **Concept note** (learning) | **Reference note** (work / system) |
|---|---|---|
| Examples | Postgres, a trading strategy, a language | A service, a call outcome, a codebase area |
| Weight on | L1 gist + the **why** | L3 gotchas + provenance & freshness |
| L4 usually | Link to official docs | Link to code / PR / config |
| Staleness risk | Low | **High** → keep `last touched` current |

You maintain one system, not two.

## Worked example — `B-tree indexing` (type: concept)

```
TITLE:      B-tree is Postgres's default index, best for range & equality lookups
WHAT / WHY: Balanced tree keeping sorted keys; the right default for most ordered queries.

SELF-TEST:
  Q: When does a B-tree index NOT help?               ▸ (answer)
  Q: Why is it bad for very low-cardinality columns?  ▸ (answer)

▸ L1  Gist — sorted, balanced tree; O(log n) lookups; supports =, <, >, BETWEEN, ORDER BY
▸ L2  How it works — pages, keys, leaf/internal nodes, how the planner chooses it
▸ L3  Details — bloat, fillfactor, partial & covering indexes, when GIN/BRIN beat it
▸ L4  Examples + → [Postgres docs: B-tree], → [our schema's index definitions]

RELATED:    → [[GIN index]] (full-text / arrays)  → [[Query planner]]
PARENT:     ← [[Indexing]]
META:       type: concept · confidence: confirmed · last touched: 2026-06-07
```

Contrast: a language-learning topic might be just three shallow pages with no
deep branches — same template, far less tree. Depth flexes to the subject
because it's emergent, not prescribed.
