# Note Builder — a retrieval-first note pipeline for Notion

Turn material you've **already read and understood** — an AI-chat summary, a blog
excerpt, call notes, a codebase area — into clean, structured notes and file them
into Notion. Built for **retrieval, not memorization**: every note gives the gist
in seconds and a map to go deeper, and depth scales with how much you actually
care.

This is **one skill with internal hierarchy**, not several skills. The pipeline,
the routing, and the two human checkpoints live in `SKILL.md`; the bulky,
stable knowledge (template, depth rules, content disciplines, Notion filing) lives
in `references/` and is loaded only when a stage needs it. That keeps a single
home for each piece of knowledge — the same "one home per fact" principle the note
system itself is built on.

## What's in the box

```
note-builder/
├── SKILL.md                      # the staged pipeline + routing + checkpoints
├── README.md                     # this file
└── references/
    ├── template.md               # the exact L0–L4 / self-test / META template + a worked example
    ├── self-test.md              # the revision-layer rules: count, targeting, answer format
    ├── depth-ladder.md           # the 5 levels + the "how deep should this go?" heuristic
    ├── disciplines.md            # what goes in a note + the anti-patterns to refuse
    └── notion-filing.md          # place-by-concept, MCP operations, toggle mapping, markdown fallback
```

## How the pipeline works

It runs in three stages with a review stop after the first two. You drive it —
nothing gets written to Notion without your yes.

1. **Draft basic note** — a shallow first pass: a claim-style title, a one-line
   what/why, a 30–60s gist, an optional seed self-test question, and the source
   link. *You review.*
2. **Develop ("migrate")** — grows the note down the depth ladder **only as far
   as the material supports and you want** — a simple idea stays at L1; a meaty
   one reaches L3 or L4. Adds the full self-test set (enough to revise the
   concept from the doc), cross-links, and metadata.
   *You review.*
3. **File to Notion** — places it under the right concept (accreting onto an
   existing note if one exists, never duplicating), at the depth it reached, via
   the Notion connector. No connector? It hands you a paste-ready markdown block
   instead.

## Install (Claude Desktop)

1. Open Claude Desktop → **Customize → Skills** (or **Settings → Capabilities →
   Skills**).
2. Click **"+"**, then **"+ Create skill."**
3. Upload **`note-builder.zip`** (the file this README came in).
4. Toggle it **on**. It's now active in chat, projects, and Cowork.

Requirements: a Pro / Max / Team / Enterprise plan and **Code Execution** enabled.
Skills work in the desktop app and on claude.ai, not in plain browser tabs without
skills enabled. To use the Notion filing step, also connect the **Notion**
connector; without it the skill falls back to giving you paste-ready markdown.

## Commands you can give

You don't need special syntax — plain language triggers each stage. Paste your
material, then say something like:

**Stage 1 — draft**
- "Make basic notes from this: …"
- "Turn this into a note."
- "Draft a quick note from this blog section."

**Stage 2 — develop / migrate**
- "Looks good — develop it."
- "Migrate it" / "deepen it" / "add more depth."
- "Take it to L3, it's a meaty topic."
- "This isn't complex, keep it at L1."
- "Add a couple of self-test questions."

**Stage 3 — file to Notion**
- "File it to Notion."
- "Save this under Postgres → Indexing."
- "Accrete this onto my existing B-tree note." (merges instead of duplicating)
- "File it at L1, it's simple."
- "No Notion right now — just give me the markdown to paste."

**Whole flow at once (still pauses for your review)**
- "Make notes from this and file them when they're ready."

**Tweaks during review**
- "Retitle it as a claim, not 'notes on X'."
- "Mark this as a reference note, not a concept."
- "Set confidence to 'told' — I haven't verified it."
- "What did you infer vs. what was in the source?"

## Design notes

- **Depth is adaptive.** The skill defaults shallow and only deepens when the
  material genuinely contains the mechanism / tradeoffs / code — it won't pad a
  simple note to look thorough. Partial notes are complete notes.
- **You verify, it drafts.** The encoding (rewording into your own words) and
  the fact-checking stay with you on purpose — that's where the learning happens
  and where you catch mistakes.
- **The format is the durable asset.** Claim title → one-liner → self-test →
  layered toggles → source link → metadata is plain hierarchy-plus-toggles. It
  pastes into Notion cleanly and survives any future tool change.

## Editing it later

Unzip, edit the markdown files, re-zip the `note-builder` folder, and re-upload
(delete or disable the old version). The `SKILL.md` description controls when the
skill triggers; the `references/` files control how it behaves at each stage.
