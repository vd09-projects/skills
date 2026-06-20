# Filing into Notion (Stage 3)

Place the approved note under the right **concept**, at whatever depth it
reached, without ever creating a duplicate. Organize by concept, never by
source — that is what lets notes *accrete and get better* over time instead of
multiplying.

## The placement decision (do this in order)

1. **Search Notion for the concept first.** Use the MCP search for the note's
   concept (e.g. "B-tree indexing"), not for the source it came from.
2. **If a note on the same concept exists → accrete onto it.** Merge the new
   material into the matching levels (deepen L2, add an L3 gotcha, add a source
   to L4), reword for one consistent voice, and bump `last touched`. Do **not**
   create a second page. One home per fact.
3. **If no such note exists → create it**, then attach it to the tree:
   - Find or identify its **parent hub** (e.g. `Indexing` under `Postgres`).
   - Add the **PARENT** backlink and any **RELATED** cross-links (with reasons).
4. **Inline-first, promote on pressure.** Keep the new material as a toggle
   inside the parent hub by default. Promote it to its own child page only when
   it earns it: it's long enough to clutter the parent's skim-ability, **or**
   it's referenced from more than one place, **or** it has grown its own
   children. Never promote pre-emptively.
5. **Keep hubs lean.** A hub page is gist + a map (index of links to children) —
   not a dumping ground. The map only lists children that actually exist.

## How the template maps into Notion

- **Title** → the page title (the claim-style line).
- **What / Why** → the first line of the page body, plain text.
- **Self-test** → question as text; answer nested inside a **toggle** beneath it.
- **L1–L4** → each is a **toggle heading**. L1 open by default; L2–L4 collapsed.
  The collapsed page *is* the depth ladder.
- **MAP / RELATED / PARENT** → `@`-mention links / page mentions.
- **META** → either a short property line at the bottom, or page properties if
  the note lives in a database. `last touched` is the freshness signal.

## Notion MCP operations you can use

The official Notion connector supports: **search**, **fetch** (read a page),
**create-page**, **update-page**, **append** (insert blocks), and **move-page**.
Typical Stage-3 flow:

- `search` for the concept → decide accrete vs. create.
- `fetch` the parent hub or the existing concept note.
- `append` the new toggles/blocks, or `update-page` to revise existing levels.
- `create-page` (child) + `move-page` only when promotion is earned.

Always confirm what you wrote back to the user in one line ("Filed under
Postgres → Indexing → B-tree at L1–L3, accreted onto the existing note,
last touched bumped"). Verify accuracy — these become notes they act on.

## Maintenance on access (not on a schedule)

There is no review chore. Every time a note is opened for a real need, that's
the trigger to verify it's still true, patch the gap just found, and bump
`last touched`. The notes used most stay freshest automatically. If the user
opens a note via this skill to add to it, treat that as an access: refresh the
date and fix anything stale you notice.

## Fallback: no Notion connector available

Don't fail and don't block. Produce a clean, paste-ready markdown block in the
chat, formatted for Notion:

- Title as an H1, What/Why as the first line.
- Each level as a heading prefixed `▸ Lx` (the user converts these to toggle
  headings in Notion with one keystroke), L1 first.
- Self-test questions as bullets with the answer indented beneath.
- MAP / RELATED / PARENT / META as a short footer.

Tell the user exactly where to paste it (under which hub) and that they can
turn the `▸` sections into toggles. The format is the durable asset — it
survives any tool, so a manual paste loses nothing but a few seconds.
