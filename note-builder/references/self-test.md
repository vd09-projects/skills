# Self-test questions

Self-test is the note's **revision layer**, not a quiz. **Every page carries its
own self-test**, scoped to that page's level: the concept page tests L0+L1, the L2
page tests the mechanism, the L3 page tests the tradeoffs, the L4 page tests the
implementation gotchas. The bar per page: a reader who answers that page's set out
loud should be able to **reconstruct that page from memory**. Descend the whole
ladder, answer each page's set, and you've revised the entire concept — the
coverage is distributed across the tree, not piled on the entry page.

Built for *retrieval, not memorization*: the user answers from their own head,
then expands the toggle to check. A miss points at the section right above it.

## Who writes them, and when

- **Claude drafts.** The user curates — keeps the sharp ones, drops the rest.
- **Stage 1**: optional single seed question on the concept page, to anchor it.
- **Stage 2 (develop)**: as each level page is created, draft *its own* self-test
  alongside its content. A new L3 page ships with L3 questions in the same pass.
- **Checkpoint 2**: the user prunes. Over-deliver candidates, let them cut.

## Count — coverage-based, per page

Forget "1–3." On each page, write **as many as it takes to cover that page**, no more.

- The concept page: an anchor recall + the core *why* (usually 2–3).
- Each level page: enough to rebuild *that level's* load-bearing content — a
  mechanism page needs the steps; a tradeoffs page needs each gotcha/decision.
- Depth, not length, drives count. Stop when another question only restates one
  already there. **Padding to a number is the same error as inventing depth.**

Rule of thumb: strip a page's body, hand someone only its questions + their own
knowledge — could they regenerate that page? If yes, that page's set is done.

## What each page's questions target

Weight every page's set toward the **why/tradeoff** — the perishable part. The
*type* of question follows the page's level:

| Page | Primarily tests | Question style |
|---|---|---|
| **Concept (L0+L1)** | the claim + why it matters | one recall anchor + the core "why this, not the alternative" |
| **L2 · How it works** | can you reconstruct the mechanism | "what resets the timer?", "what happens on each call?" |
| **L3 · Details / tradeoffs** | edges, gotchas, decisions | "when does it fail?", "what do you give up if…?" (several) |
| **L4 · Implementation** | the doing gotchas | light — only what bites in practice; mostly defer to links |

Skip any page whose material doesn't support a real question — don't manufacture
one to fill the slot.

## How to write a diagnostic question

A good question **fails loudly when the model is wrong** and cannot be answered by
rephrasing the question itself.

Do:
- Ask "why" and "when-not," not "what." `Why is a B-tree bad for low-cardinality
  columns?` beats `What is a B-tree?`
- Force a decision or comparison: "X or Y, and why?" surfaces a fuzzy model fast.
- Make it answerable in 1–2 sentences. If it needs a paragraph, split it.
- Phrase so a wrong mental model gives a visibly wrong answer.

Don't:
- Yes/no or guess-the-keyword questions — they pass on luck.
- Questions whose answer is restated in the question wording.
- Trivia with no decision attached unless the number *is* the load-bearing fact.
- One mega-question covering the whole page — that defeats gap-location.

## Answer format

Each page ends with a `## Self-test` section. Question on the visible line; answer
nested in a `<details>` **toggle** beneath it (toggles are the one place a level's
content *doesn't* become a subpage). Indent the answer with a real tab or it falls
outside the toggle.

- **1–2 lines**, the core of the answer — enough to confirm a hit, not a re-teach.
- **End each answer with a `↪ read more` jump link to the exact block/section it
  tests** (Style B — the chosen default). The answer tests *this page's own* content,
  so the link points at the source block *on this same page* (the gist line, the
  specific bullet) — a miss jumps straight there. Don't link to *another* level for a
  same-level question (that's the MAP's job, and it implies the answer lives elsewhere).
- **Anchoring the link:** the link is `pageURL#<blockId>`. Source the blockId per
  `notion-filing.md` — REST token (clean, auto) ▸ "Copy link to block" (manual, clean)
  ▸ throwaway probe-comment (auto, delete after). Never a plain-text "reread X".
- **Linking reality (two-pronged):** the connector can't mint a heading anchor
  (no block ids), so a `<mention-page>` only ever lands at a page's *top*. To get
  links that actually hit the right content:
  1. **Split finer (default, automatable).** Make the thing worth linking its own
     page — a sub-section *is* a sub-page — then the mention lands exactly on it.
     If a level page holds several distinct ideas you'd point at separately, split
     them into child pages rather than headings-within-a-page.
  2. **Manual anchor (escape hatch).** For a precise jump to a heading you'd rather
     not split out, ask the user to use Notion's **"Copy link to block"** and paste
     it; wire that exact URL into the answer as a normal link. It's the only true
     in-page anchor.
  Never leave a plain-text "reread L1" that masquerades as a link.
- Don't paste the page's full content into the toggle — point, don't copy.

## "Read more" — two link styles (pick one project-wide)

A self-test answer is a gap-check. After a miss there are two "read more" intents,
and two ways to serve them. Pick one and apply it consistently.

**Style A — clean answer + MAP (no per-answer link).** The page is short by design
(gist + self-test), so rechecking the fact is a glance up; going *deeper* is the
MAP's job, once, at the bottom.

```
## L1 · Gist
Debounce = run after events stop for N ms. Throttle = run at most once per N ms.

## Self-test
▾ Q: One line each — what does debounce do vs throttle?
    Debounce: fire after silence. Throttle: fire at a fixed max rate.
▾ Q: Why debounce a search box rather than throttle it?
    You only want the final query, not every keystroke.

## MAP
- → L2 · How it works        ← the one "go deeper" path
```

*Pro:* zero clutter, nothing to maintain, no broken-looking links. *Con:* no
one-click jump to the exact source line (but it's a few lines up on a short page).

**Style B — per-answer block anchor (manual).** Each answer ends with a real link to
the section it came from, made via Notion's **"Copy link to block"** (the only source
of a true within-page anchor — the connector can't mint these).

```
## Self-test
▾ Q: One line each — what does debounce do vs throttle?
    Debounce: fire after silence. Throttle: fire at a fixed max rate.
    ↪ read more: [L1 · Gist](https://www.notion.so/…-<pageid>#<blockid>)
```

*Pro:* one click scrolls to the exact heading. *Con:* you must copy a block link by
hand for every pointer; it's not automatable, and the link breaks if the block is
deleted.

| | Style A | Style B |
|---|---|---|
| Per-answer link | none | block anchor |
| Effort | zero | manual copy each |
| Jumps to exact section | no (glance up) | yes |
| Automatable | yes | no |
| Best when | pages stay short | a page is long / heavily revisited |

**Chosen default: B** — every self-test answer ends with a `read more` anchor to its
source block. **A is the fallback** for when no anchor method is available (no REST
token and the user won't paste a block link): answers stand clean and "go deeper" is
the MAP.

## Maintenance

Self-test tracks the page it lives on. When Stage 2 adds a level page, it ships
with its own questions; when a page's content changes, fix its questions in the
same pass. Bump `last touched` on the concept page when you edit any of it.

## Worked example — `B-tree indexing` (distributed across the tree)

```
CONCEPT PAGE — "B-tree is Postgres's default index…"
  ## Self-test
    Q: One line — what is a B-tree index and what queries is it for?   ▸ (recall)
       ↳ Sorted balanced tree; =, <, >, BETWEEN, ORDER BY.
    Q: Why is it the right default over a hash index?                  ▸ (why)
       ↳ Supports ranges & ORDER BY, not just equality.

  └─ L2 · How it works
       ## Self-test
         Q: How does the planner decide to use the index vs a seq scan?  ▸ (mechanism)
            ↳ O(log n) descent when selective; flips to scan when the match set is large.

       └─ L3 · Details / tradeoffs
            ## Self-test
              Q: Why is it a poor fit for very low-cardinality columns?  ▸ (boundary)
                 ↳ Few distinct values → most rows match → scan beats the tree walk.
              Q: When does a B-tree NOT help at all?                     ▸ (boundary)
                 ↳ Non-prefix LIKE, full-text, array/containment — use GIN/BRIN.
              Q: What do you give up switching this column to a hash index?  ▸ (tradeoff)
                 ↳ Range & ORDER BY support — hash does equality only.
```

Each page self-contained for revision; the deeper you go, the more pointed the
questions. A shallow note is just the concept page's two questions and stops.
