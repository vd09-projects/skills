# Self-test questions

Self-test is the note's **revision layer**, not a quiz. The bar: a reader who
answers the whole set out loud should be able to **reconstruct the concept from
the doc** — gist, mechanism, and the load-bearing tradeoffs — without reading the
note body first. A miss is a signal, pointing straight at the rung to reread.

Built for *retrieval, not memorization*: the user answers from their own head,
then expands the toggle to check. The questions find the gaps; the note fills
them.

## Who writes them, and when

- **Claude drafts.** The user curates — keeps the sharp ones, drops the rest.
- **Stage 1**: optional single seed question, just to anchor the note.
- **Stage 2 (develop)**: draft the *full* set, sized to the depth the note
  reached (see Count below). This is where the revision layer is really built.
- **Checkpoint 2**: the user prunes. Curation is theirs — over-deliver candidates,
  let them cut. Better to draft 6 and keep 4 than draft 2 and miss coverage.

## Count — coverage-based, no fixed cap

Forget "1–3." Write **as many as it takes to cover the concept**, and no more.

Concretely, the set is complete when answering all of them rebuilds the note's
load-bearing content:

- Every rung that carries real meaning gets at least one question that probes it.
  A note that reached L3 will usually need ~4–6; an L1 stub needs 1–2.
- Depth, not length, drives count. A short but subtle note can need more
  questions than a long but obvious one.
- Stop when an extra question would only restate one already there. **Padding to
  hit a number is the same error as inventing depth** — don't.

Rule of thumb, not a quota: if you removed the note body and handed someone only
the questions + their own knowledge, could they regenerate the gist and the key
tradeoffs? If yes, the set is done. If a whole rung would vanish, you're missing
a question.

## What each question targets

Spread the set across these, **weighted heavily toward the why/tradeoff** — that
is the perishable, expensive part of understanding and the first thing to decay.

| Target | Tests | Maps to | Weight |
|---|---|---|---|
| **Why / tradeoff** | mental model — why this over the alternative, what you'd give up | L1–L3 | **majority** |
| **Boundary / when-NOT** | edges — when it fails, gotchas, where it stops applying | L3 | several |
| **Mechanism (how)** | can you reconstruct how it works | L2 | some |
| **Recall the claim** | the core definition as an anchor | L1 | one, lightest |

Most notes want: one anchor recall, one or two mechanism, several why/tradeoff,
one or two boundary. Skip any row the material doesn't support — a pure
definition note may be a single recall question and nothing else.

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
- Trivia with no decision attached (exact numbers, names) unless the number *is*
  the load-bearing fact.
- One mega-question covering the whole note — that defeats gap-location.

## Answer format

Question on the visible line; answer nested in a **toggle** beneath it.

- **1–2 lines**, the core of the answer — enough to confirm a hit, not a re-teach.
- End with a **reread pointer** to the rung that holds the full version:
  `→ reread L2`. A miss routes the user straight there.
- Don't paste the rung's full content into the toggle — that duplicates the note
  and rots independently. Point, don't copy.

## Maintenance

Self-test tracks the note. When Stage 2 adds or removes a rung, add or cut the
questions that cover it in the same pass — an L3 added with no boundary question
leaves that depth untested. Bump `last touched` when you edit the set.

## Worked example — `B-tree indexing` (extends template.md)

```
SELF-TEST:
  Q: One line — what is a B-tree index and what queries is it for?     ▸ (recall, L1)
     ↳ Sorted balanced tree; =, <, >, BETWEEN, ORDER BY.  → reread L1
  Q: Why does the planner pick it over a seq scan, and when does it stop?  ▸ (why, L2)
     ↳ O(log n) on selective lookups; flips to seq scan when the match set is large.  → reread L2
  Q: Why is it a poor fit for very low-cardinality columns?            ▸ (why, L3)
     ↳ Few distinct values → most rows match → tree walk costs more than a scan.  → reread L3
  Q: When does a B-tree NOT help at all?                              ▸ (boundary, L3)
     ↳ Non-prefix LIKE, full-text, array/containment — use GIN/BRIN.  → reread L3
  Q: What would you give up by switching this column to a hash index?  ▸ (tradeoff, L3)
     ↳ Range & ORDER BY support — hash does equality only.  → reread L3
```

Five questions, weighted to *why/tradeoff*, one per load-bearing rung. Answer all
five and you've rebuilt the concept from the doc — which is the whole point. A
shallow note would have one or two of these and stop.
