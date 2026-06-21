# Content disciplines + anti-patterns

What actually goes in a note, and what to refuse. Apply these mainly in Stage 2.

## What goes in (disciplines)

1. **Capture the "why," not just the "what."** For systems and code, the code
   already says *what*; the perishable, expensive knowledge is the rationale.
   Borrow from Architecture Decision Records: record the **decision, the
   context, the alternatives considered, and the consequences.** The
   "alternatives you rejected" note is gold — it stops future-you from
   re-litigating settled choices.
2. **Link to the source of truth; own only your interpretation.** Don't
   transcribe what lives canonically elsewhere. Capture the mental model, the
   gotcha, the map — and link out for full depth. Transcribed facts rot;
   interpretation ages slowly. This also shrinks how much must be kept fresh.
3. **Separate reference from explanation.** Lookup-facts (consulted while
   working) and rationale (read to understand *why*) serve different needs —
   keep them in distinct levels so neither buries the other.
4. **Mark provenance / confidence.** Note *how* you know something: observed in
   code / told on a call / assumed / inferred. "Confirmed" vs. "I think" matters
   when the user acts on it later.
5. **Write for a future self with zero context.** Spell out what's obvious
   today; it's gone in months.
6. **Track open questions / known gaps.** A running "unknowns" area turns holes
   into a visible checklist instead of something to rediscover.
7. **Keep it atomic — one thing, but the whole of that thing.** Too broad and
   links get muddied; too fragmented and one idea scatters across pages. Mental
   model: separation of concerns — one page, one responsibility, reusable.

## Two-phase mindset

- **Capture is zero-friction** — the user dumps raw material; no decisions.
- **Processing is where the thinking happens** — this skill drafts, but the
  user rewords the gist into their own words and verifies. A note in their own
  words is encoded; a copied note is not.

## Anti-patterns to refuse (don't produce these)

- **Raw AI dumps left unprocessed** — degrade findability (more low-signal text
  to wade through) and skip the encoding that makes the note theirs. This is why
  the pipeline always reshapes into the template and always checkpoints.
- **Duplication / many homes for one fact** — one stale edit silently poisons
  trust in everything. Search Notion first; accrete onto the existing concept.
- **Premature structure** — never pre-build a deep empty skeleton, and never
  create pages first and then work out how to link them. Content first: write, see
  what's too heavy, *then* spawn a child for it and link the section down. Let the
  tree grow (and fan out) from where the user digs. Premature structure is a top
  cause of abandonment.
- **Grouping instead of connecting** — generic tag-buckets add clutter, not
  meaning. Links should be real conceptual connections with a stated reason.
- **Maze trees** — deep branches without a lean, skimmable gist at each hub.
  Every page must reorient the reader locally.
- **Collector's fallacy** — capturing feels like learning; it isn't. Processing
  is where learning happens. More captured material is not more progress.
- **Inventing depth** — padding a simple note deeper to look thorough, *or*
  splitting a one-paragraph idea into its own thin stub page. A child page must
  earn its existence with material the source actually supports. Partial notes are
  complete notes; a section with nothing more to say stays inline.
