# The depth ladder + how deep to go

A consistent set of levels so you always know where to enter and how far to go.
**Levels are optional and lazily filled.** Some notes stop at L1; others reach
L4. Filling a level the source doesn't actually support is an error, not
thoroughness.

| Level | Name | Contents | Reader intent |
|---|---|---|---|
| **L0** | Identity | Claim-style title + one-line "what & why" | The search hit; "is this the note I want?" |
| **L1** | Gist | 30–60s working mental model | Quick refresh / fast relearn |
| **L2** | How it works | The key concepts, the core mechanism | "I want to understand it" |
| **L3** | Details | Nuance, tradeoffs, gotchas, edge cases, comparisons | "I'm reasoning seriously / about to use it" |
| **L4** | Implementation + source | Commands, code, worked examples, **links to canonical sources** | "I'm doing it now" |

- **L1 = maximum discoverability** (compressed). **L4 = maximum understanding**
  (full context).
- **L4 is mostly pointers** — link the docs / code / PR; don't transcribe what
  you can link to. Transcribed facts rot; interpretation ages slowly.

## The complexity → depth heuristic (use this in Stage 2)

Default shallow. Read the pasted material and ask "how much is genuinely here,
and how complex is the topic?" Then pick a ceiling and fill up to it:

1. **Single definition or fact** → **L1 only.** Say so explicitly: "This is
   simple — it's complete at L1." Don't manufacture an L2/L3 to look thorough.
2. **Has a mechanism** (it *works* a certain way) → add **L2.**
3. **Has tradeoffs, gotchas, edge cases, or comparisons** → add **L3.**
4. **Has commands, code, config, or worked examples** → add **L4**, kept mostly
   as links to the canonical source.

Two independent gates, both must pass to deepen:
- **Does the material support it?** (Is the mechanism / tradeoff / code actually
  in what they pasted, or would you be inventing it?)
- **Does the user want it now?** Lazy depth — only as deep as today's interest.
  If unsure, go one level shallower and offer to deepen on request.

## Why this matters

The whole system is designed backwards from the moment of *retrieval*. A note
that's shallow-but-true and findable beats a note that's deep-but-padded. The
governing tension on every note is **discoverability** (small, skimmable) vs.
**understanding** (full context). Each level is a point on that dial; you're
choosing where on the dial this particular note should sit today. It can always
accrete more depth later when the user returns to it with a real need.
