# The note template

Every note has the same shape. A fixed shape means near-zero per-note decisions,
and it survives any tool migration. Fill it lazily — empty rungs are fine.

**Depth is page nesting, not headings on one page.** The concept page carries L0+L1;
each section that needs elaboration becomes a **child page**. The tree **fans out
and recurses** — a page can have *many* children, and any child branches again.
The sidebar tree *is* the depth map — open the node you want.

```
CONCEPT PAGE  (the search hit = L0 + L1)
  TITLE:      [claim-style — the answer in one line]                 (L0)
  WHAT / WHY: [one sentence: what it is + why you'd care]            (L0)
  L1 Gist:    [30–60s working mental model — plain text, no toggle]  (L1)

  SELF-TEST:  Q: [...]   ▸ answer in a toggle      (this page = L0+L1: recall + core why)
              Q: [...]   ▸ answer in a toggle

  MAP:        → <mention: each direct child page>               (index of deeper nodes)
  RELATED:    → <mention: cross concept> (+ one phrase on why it connects)
  PARENT:     ← <mention: parent / domain hub>
  META:       type: concept | reference · confidence · last touched: YYYY-MM-DD

  ├─ Child A · How it works     (child page — local gist + mechanism, ← back to concept)
  │    SELF-TEST: own questions on the mechanism
  │    ├─ A child page          (a sub-mechanism heavy enough to stand alone)
  │    └─ Another child page    (a different sub-mechanism — siblings fan out)
  │         └─ A deeper page    (recurse — no level ceiling)
  └─ Child B · A different facet (a *sibling* of A, not nested under it)
       SELF-TEST: own questions on this facet
```

Each page exists **only once the material fills it** — never pre-build an empty
skeleton (that's the premature-structure anti-pattern). Write the content first,
then split out a child *only* where a section is too heavy for its page; link that
section down to the child. A simple note is one page; a rich one is a fanned-out
tree. The collapsed sidebar shows exactly how far each branch goes. Read
`depth-ladder.md` for when to split vs. keep inline.

## Field-by-field

- **TITLE** — make it a *claim*, the answer itself. "B-tree is Postgres's default
  index, best for range & equality lookups" — not "B-tree notes." A good title
  answers "is this the note I want?" from the search hit alone.
- **WHAT / WHY** — one sentence. The *why* is the perishable, expensive part;
  always include it.
- **L1 Gist** — plain text on the concept page, open and visible (no click). The
  30–60s mental model.
- **SELF-TEST** — **every page carries its own**, scoped to that page's level: the
  concept page tests L0+L1, each level page tests its own content. Questions on the
  visible line, answers nested in `<details>` toggles; the reread target is the
  section right above. Coverage is distributed down the tree, not piled on the
  entry page. See `self-test.md`.
- **CHILD PAGES** — each elaborated section is a **child page**, nested under the
  section that spawned it; a page can have *many* children, and any child branches
  again (no level ceiling). Every child opens with its own one-line local gist + a
  back-mention to its parent, holds that section's content, and ends with its own
  self-test (anti maze-trees — a deep landing is never disorienting). See
  `depth-ladder.md`.
- **MAP** — a page's index of its **direct** children (and any child concepts), as
  page mentions. This is how the tree stays navigable; only list nodes that exist.
  Each elaborated section should also link inline to its own child page.
- **RELATED** — real conceptual connections, each a page mention with a short reason.
  Connect, don't group: no generic tag-buckets.
- **PARENT** — every page mentions its parent (concept → domain hub; child → the
  page that spawned it). No orphans.
- **META** — on the concept page.
  - `type`: `concept` (something you're learning) or `reference` (a system,
    call, or codebase you operate).
  - `confidence`: how you know it — `confirmed` (verified), `told` (someone said
    so), `assumed`, `inferred`. Matters when the user later acts on it.
  - `last touched`: the freshness date; bump it on every real-use edit.

## Shared / common sub-concepts

When a sub-concept is reused by several notes (e.g. `Event loop` under both
`Debounce vs throttle` and `Promises`), give it **one home** under a top-level
`Common/` (or `Shared/`) hub and `<mention-page>`-link to it from each parent —
don't copy it into each tree. Duplicate only when a real shared home is impossible,
and sparingly; one stale edit in a duplicated fact poisons trust everywhere.

## Two modes, one shape

The `type` property flips the emphasis without changing the structure.

| | **Concept note** (learning) | **Reference note** (work / system) |
|---|---|---|
| Examples | Postgres, a trading strategy, a language | A service, a call outcome, a codebase area |
| Weight on | L1 gist + the **why** | tradeoff/gotcha pages + provenance & freshness |
| Deepest layer usually | Link to official docs | Link to code / PR / config |
| Staleness risk | Low | **High** → keep `last touched` current |

You maintain one system, not two.

## Worked example — `B-tree indexing` (type: concept)

```
CONCEPT PAGE — "B-tree is Postgres's default index, best for range & equality lookups"
  WHAT / WHY: Balanced tree keeping sorted keys; the right default for most ordered queries.
  L1 Gist:    sorted, balanced tree; O(log n) lookups; supports =, <, >, BETWEEN, ORDER BY.

  SELF-TEST:   (this page = L0+L1)
    Q: One line — what is a B-tree and what queries is it for?  ▸ (recall)
    Q: Why is it the right default over a hash index?           ▸ (why)

  MAP:     → <How it works>  → <When to choose it>     (its two direct children)
  RELATED: → <GIN index> (full-text / arrays)  → <Query planner>
  PARENT:  ← <Indexing>
  META:    type: concept · confidence: confirmed · last touched: 2026-06-07

  ├─ How it works         — pages, keys, leaf/internal nodes, how the planner chooses it
  │    SELF-TEST: Q: how does the planner pick index vs seq scan?  ▸
  │    ├─ On-disk structure   — page layout, fan-out, splits   (heavy enough to split out)
  │    └─ Planner cost model  — selectivity, when it flips to seq scan
  │         └─ Examples + → [Postgres docs: B-tree]   (recurse: implementation page)
  └─ When to choose it    — a *sibling* of "How it works", not nested under it
       SELF-TEST: Q: when does it NOT help?  Q: cost of low-cardinality columns?  ▸
       └─ When GIN/BRIN beat it — tradeoffs vs other index types
```

Two things to notice: the concept fans out to **two** children ("How it works"
*and* "When to choose it") rather than one linear chain, and "How it works" itself
branches further. Contrast: a language-learning topic might be a single concept
page with no children at all — same shape, no branches. Depth flexes to the subject
because it's emergent, not prescribed.
