---
name: note-builder
description: >-
  Turn pasted raw material (AI-chat summaries, blog excerpts, call notes —
  anything the user has read and understood) into structured, retrieval-first
  notes and file them into Notion. Use this whenever the user pastes content and
  wants notes made from it, or says things like "make basic notes from this",
  "draft a note", "turn this into a note", "deepen / develop / migrate this
  note", "add depth", "file this to Notion", "save this to my notes", or "add a
  self-test question". Runs a staged, human-in-the-loop pipeline: draft a
  shallow gist, the user reviews, develop depth in proportion to how complex the
  material is, the user reviews again, then file it under the right concept in
  Notion. Always pause for the user's review between stages and never auto-file.
  Trigger even when the user never says the words "skill" or "note system" —
  pasting material and wanting it captured is enough.
---

# Note Builder

A pipeline for turning material the user has **already read and understood**
into notes built for *retrieval, not memorization*. Every note gives the gist
in seconds and a map to go deeper; depth is opt-in and scales with how much the
user actually cares. The system lives in Notion, organized by **concept** (not
by source), with one home per fact.

The user does the encoding and the verifying — that is where their understanding
forms and where they catch your errors. Your job is to remove the friction
(drafting, structuring, filing), **not** to think for them. So this runs as a
staged pipeline with human checkpoints, never as one autonomous dump.

## The pipeline (3 stages, 2 checkpoints)

```
PASTE → Stage 1: draft basic note  →  ⏸ CHECKPOINT 1 (user reviews)
      → Stage 2: develop / "migrate" → ⏸ CHECKPOINT 2 (user reviews)
      → Stage 3: file to Notion (depth-appropriate, by concept)
```

Run only the stage the user asked for. "Make basic notes" = Stage 1, stop.
"Looks good, develop it" / "migrate it" / "deepen it" = Stage 2, stop.
"File it to Notion" = Stage 3. If the user says "just do the whole thing,"
still surface each stage's output and get a yes before filing — the checkpoints
are load-bearing, not optional.

---

## Stage 1 — Draft the basic note (shallow by default)

Produce only the shallow layer, in the user's own concise words (do not
transcribe the source — capture the mental model):

- **L0 — Title**: a claim-style line that *is the answer* (not "Notes on X").
- **L0 — What / Why**: one sentence — what it is + why you'd care.
- **L1 — Gist**: a 30–60 second working mental model.
- **One self-test seed question** (optional): a diagnostic, not a quiz. The full
  coverage set comes in Stage 2 — see `references/self-test.md`.
- **Source link**: link out; do not copy the source in.
- **type**: guess `concept` (learning) or `reference` (a system/call/codebase).

Read `references/template.md` for the exact shape and a worked example.
Output it as markdown in the chat. Do **not** go deeper yet and do **not** touch
Notion. Then stop and hand it back: *"Here's the basic note — want me to develop
it, or file it as-is?"*

---

## ⏸ Checkpoint 1

Wait for the user. They may correct the gist, retitle it, change the type, or
say it's good. Apply edits, then proceed only on their say-so.

---

## Stage 2 — Develop (the "migrate"/"deepen" step)

Take the reviewed basic note and grow it into the full template — **but only as
deep as the material genuinely supports and the topic warrants.** This is the
heart of the system: depth is *emergent and lazily filled*, partial notes are
complete notes, and inventing depth the source doesn't contain is a content
error, not thoroughness.

Decide the target depth first, then fill up to it:

- Simple definition / single idea → stop at **L1** (it's already done — say so).
- Has a real mechanism → add **L2 (how it works)**.
- Has nuance, tradeoffs, gotchas, comparisons → add **L3**.
- Has commands / code / worked examples → add **L4 (mostly pointers + links)**.

Read `references/depth-ladder.md` for the level definitions and the
complexity→depth heuristic. Draft the self-test set in this stage too — enough
questions to **revise the whole concept from the doc**, sized to the depth the
note reached and weighted toward the *why/tradeoff*; see `references/self-test.md`.
Also propose RELATED cross-links and the PARENT link, and set metadata
(`type`, `confidence`, `last touched`). Follow `references/disciplines.md` for
the content rules (capture the *why*, link don't copy, mark provenance,
keep it atomic) and the anti-patterns to refuse.

Output the developed note as markdown. Stop. *"Here's the developed note at
L1–Lx — file it to Notion, or adjust depth?"*

---

## ⏸ Checkpoint 2

Wait for review. The user may ask for more or less depth, fix a tradeoff, or
approve. This is the verification pass — flag anything you inferred vs. were told
so they can confirm before it becomes a note they act on.

---

## Stage 3 — File to Notion

First read config if present: `.claude/skill-memory/note-builder/config.md`
(project) layered over `~/.claude/skill-memory/note-builder/config.md` (global) —
it sets the destination, `mode` (mcp vs markdown), concept buckets, depth bias, and
freshness format. Rune writes it; no config → ask the destination once, proceed.

Place the approved note under the **right concept**, at the depth it reached.
Before creating anything, search Notion for an existing note on the same concept:
if one exists, **accrete onto it** rather than making a duplicate (one home per
fact). Promote to its own child page only when it earns it; otherwise keep it
inline under the parent hub. Add the parent link and any cross-links.

Read `references/notion-filing.md` for the placement logic, the Notion MCP
operations to use, how L1–L4 map to toggle headings, and the maintenance-on-
access step (bump `last touched`).

**If no Notion MCP / connector is available:** don't fail. Output a clean,
paste-ready markdown block formatted for Notion (toggle headings as `▸`-marked
sections) and tell the user where to paste it. The format survives any tool.

---

## When to read which reference

| You're about to... | Read |
|---|---|
| Shape any note (Stage 1 or 2) | `references/template.md` |
| Write the self-test set (Stage 2) | `references/self-test.md` |
| Decide how deep to go (Stage 2) | `references/depth-ladder.md` |
| Judge what content belongs / what to refuse | `references/disciplines.md` |
| Put it into Notion (Stage 3) | `references/notion-filing.md` |

## Non-negotiables

- **Never auto-file.** Two human checkpoints, every time.
- **Never transcribe the source.** Capture interpretation; link to the source.
- **Never invent depth** the material doesn't support. Partial is complete.
- **Never duplicate a fact.** Search first; accrete onto the existing concept.
- **Default shallow.** Effort scales with the user's interest, not with your urge
  to be thorough.
