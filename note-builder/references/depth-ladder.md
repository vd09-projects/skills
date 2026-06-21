# The depth ladder + how deep to go

A consistent vocabulary for *how compressed* a page is, so you always know where
to enter and how far to go. **Levels are optional and lazily filled.** Some notes
stop at L1; others go deep. Filling a level the source doesn't actually support is
an error, not thoroughness.

**Depth is emergent, recursive, and fanned-out — not a single chain.** The level
labels (L0–L4) describe compression, *not* a one-page-per-level ladder. A page
spawns a child for **each section that needs elaboration**, so one parent can have
*many* children (one per complex sub-concept), and each child branches the same
way. There is **no level ceiling** — a deep note reaches L5, L6+. Picture a tree
that fans out wherever a topic is rich, not a queue L2→L3→L4.

**Direction: content first, structure second.** Write the content; wherever a
section is too heavy or genuinely wants elaboration, *then* split it into its own
page and link that section down to it. Never create pages first and work out links
after. A `<mention-page>` lands at the top of its target, so making an elaboration
its own page *is* the in-page anchor (the "split finer" move in `self-test.md`).

**Each child is its own page**, nested under the section that spawned it. Depth =
page nesting; the sidebar tree is the map. Every child page opens with a one-line
local gist and a back-mention to its parent, and ends with **its own self-test**
scoped to its content (see `self-test.md`) so a deep landing never disorients.
Create a page only when its material exists — never a pre-built empty rung.

| Level | Name | Contents | Reader intent |
|---|---|---|---|
| **L0** | Identity | Claim-style title + one-line "what & why" | The search hit; "is this the note I want?" |
| **L1** | Gist | 30–60s working mental model | Quick refresh / fast relearn |
| **L2** | How it works | The key concepts, the core mechanism | "I want to understand it" |
| **L3** | Details | Nuance, tradeoffs, gotchas, edge cases, comparisons | "I'm reasoning seriously / about to use it" |
| **L4** | Implementation + source | Commands, code, worked examples, **links to canonical sources** | "I'm doing it now" |

- **L1 = maximum discoverability** (compressed). **The deepest page = maximum
  understanding** (full context).
- The deepest layer is **mostly pointers** — link the docs / code / PR; don't
  transcribe what you can link to. Transcribed facts rot; interpretation ages slowly.
- The labels are descriptive, not a fixed count. A rich topic has *several* L2
  pages under one concept, and an L3 with its own L4 *and* L5 children. Read them
  as "one notch deeper / more detailed than the parent," not as a four-rung limit.

## The complexity → depth heuristic (use this in Stage 2)

Default shallow. The decision is **per section, made while writing the content** —
not a single ceiling chosen up front for the whole note. For each section ask
"how much is genuinely here, and is it too heavy for this page?" Then:

1. **Single clear idea / definition** → leave it **inline** (a whole note can be
   one page — say so: "simple, complete as it stands"). Don't manufacture a child
   page to look thorough.
2. **A section with a real mechanism of its own** → give it **its own child page**
   (one notch deeper), and link the section to it. Several such sections → several
   sibling children under the same parent.
3. **That child itself has tradeoffs, gotchas, or sub-mechanisms** → recurse: it
   spawns *its own* children. Keep going as long as the material genuinely fills
   each new page — no ceiling.
4. **Commands, code, config, worked examples** → a deepest "implementation" page,
   kept mostly as links to the canonical source.

Group, don't shatter: several sections sharing a theme belong **together** on one
page; only split out the ones heavy enough to stand alone.

Two independent gates, both must pass to spawn a deeper page:
- **Does the material support it?** (Is the mechanism / tradeoff / code actually
  in what they pasted, or would you be inventing it?) A one-paragraph idea with no
  further depth stays inline — splitting it makes a thin stub, which is inventing depth.
- **Does the user want it now?** Lazy depth — only as deep as today's interest.
  If unsure, go one notch shallower and offer to deepen on request.

## Why this matters

The whole system is designed backwards from the moment of *retrieval*. A note
that's shallow-but-true and findable beats a note that's deep-but-padded. The
governing tension on every note is **discoverability** (small, skimmable) vs.
**understanding** (full context). Each level is a point on that dial; you're
choosing where on the dial this particular note should sit today. It can always
accrete more depth later when the user returns to it with a real need.
