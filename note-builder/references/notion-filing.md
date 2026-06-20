# Filing into Notion (Stage 3)

Place the approved note under the right **concept**, at whatever depth it reached,
without ever creating a duplicate. Organize by concept, never by source — that is
what lets notes *accrete and get better* over time instead of multiplying.

Depth is **page nesting**: the concept page carries L0+L1, and L2/L3/L4 are child
pages chained beneath it (see `template.md`). You create a level page only when the
material fills it — never a pre-built empty skeleton.

## Before you write — read the spec, use tabs

- Read the MCP resource `notion://docs/enhanced-markdown-spec` (via the resource
  interface, **not** a fetch tool) before composing page content. Don't guess
  Notion-flavored Markdown.
- **Indent children of a toggle / callout with a real tab**, or they render outside
  the toggle. Self-test answers are the main place this bites.

## The placement decision (do this in order)

1. **Search Notion for the concept first** (`search` the concept name, e.g.
   "B-tree indexing" — not the source it came from).
2. **Concept exists → accrete onto it.** Merge new material into the matching level:
   deepen the L2 page, add an L3 gotcha, add an L4 source. Reword for one consistent
   voice, bump `last touched`. **One home per fact** — never a second page.
3. **Concept is new → create it**, then attach it to the tree:
   - Find or create its **parent / domain hub** (e.g. `Indexing` under `Postgres`).
   - **Bootstrap when there is no hub yet** (fresh workspace, or first note in a
     domain): offer to create the parent hub — a lean page with a one-line gist and
     an empty MAP — then file the concept page under it. Don't leave the note orphaned
     at the top level with a dead-text PARENT; either nest it under a hub or, if the
     user declines a hub, say the PARENT is unset and why.
   - Add the **PARENT** back-mention and any **RELATED** cross-mentions (with reasons).
4. **Depth grows as child pages, lazily.** The concept page holds L0+L1. Promote a
   level to its own child page the moment that level has real content — but never
   pre-create empty L2/L3/L4 pages. Each new level page opens with a local gist and a
   back-mention to its parent.
5. **Keep hubs and concept pages lean.** A hub is gist + a MAP (page mentions to
   children that actually exist) — not a dumping ground.

## Linking — use real page mentions, not plain text

PARENT, RELATED, MAP, and self-test reread pointers must be **clickable mentions**,
not `[[text]]` placeholders. Per the markdown spec:

```
<mention-page url="https://www.notion.so/...">Page title</mention-page>
```

To link a target: `search` for it → take the result `url` → mention it. If the
target page **doesn't exist yet**, leave the reference as plain text and add it to
the MAP / open-questions so it gets created and linked later — don't fabricate a URL.

**Page granularity is the limit** — and the workaround is two-pronged. A
`<mention-page>` lands at the *top* of the target page; the connector can't mint a
link to a specific heading/block (it exposes no block ids — every write tool targets
text, not blocks). To make links actually hit the right content:

1. **Split finer (default).** Make anything worth linking its own page, so the
   mention lands exactly on it; a sub-section *is* a sub-page. Keep level pages
   small (top-of-page ≈ the section). When a page holds several separately-linkable
   ideas, split them into child pages rather than headings-within.
2. **Manual anchor (escape hatch).** For a precise mid-page heading jump the user
   doesn't want to split out, have them use Notion's **"Copy link to block"** and
   paste the URL; wire it in as a normal link. That's the only real anchor source.

Never leave a plain-text "reread X" that masquerades as a link.

## How the template maps into Notion

- **Title** → the concept page title (the claim-style line).
- **What / Why** → first line of the page body, plain text.
- **L1 Gist** → plain text on the concept page (open, no toggle).
- **Self-test** → a `## Self-test` section on **every page**, scoped to that page's
  level (concept page tests L0+L1; each level page tests its own content). Question
  as text, answer nested in a `<details>` toggle (tab-indented); reread target is the
  section above it on the same page.
- **L2 / L3 / L4** → **child pages**, each nested under the level above: local gist +
  that level's content + its own self-test. No toggle headings. Create on demand only.
- **MAP / RELATED / PARENT** → `<mention-page>` links.
- **META** → a short property line at the bottom of the concept page (or page
  properties if it lives in a database). `last touched` is the freshness signal.

## Notion MCP operations you can use

The official Notion connector supports **search**, **fetch**, **create-pages**,
**update-page**, and **move-page**. Typical Stage-3 flow:

- `search` for the concept → decide accrete vs. create.
- `fetch` the parent hub or the existing concept note.
- `create-pages` (parent = the concept/level page) to add a deeper level page, or
  `update-page` to revise an existing level's content.
- `move-page` only when an inline child earns promotion to elsewhere in the tree.

Always confirm what you wrote back in one line ("Created concept page under Postgres
→ Indexing; added L2 + L3 child pages; PARENT/RELATED mentioned; last touched set").
Verify accuracy — these become notes the user acts on.

## MCP gotchas (verified the hard way)

- **Only `create-pages` and `update-page`'s `update_content` reliably parse
  multi-line Notion Markdown.** `insert_content` and `replace_content` mangle it —
  newlines collapse, `<details>`/`<summary>` get escaped to literal text, mentions
  flatten to plain text. To add a self-test or any block to an existing page, prefer
  recreating the page with `create-pages`, or use `update_content` with precise
  `old_str`/`new_str`. Don't append blocks with `insert_content`.
- **`replace_content` refuses to run if it would orphan child pages**, even when you
  include the `<page>` tag (the URL match is finicky). If a page has children,
  `move-pages` the child out, edit the parent, then move it back — rather than
  fighting the child-preservation check.
- **No hard delete in the connector.** To retire a page, blank/redirect its body and
  retitle it `[DEPRECATED → see <canonical>]`; the user trashes it in the Notion UI.
  Never leave a stale duplicate competing with the canonical note.
- **Always `fetch` after writing** to confirm toggles, mentions, and nesting
  actually rendered — escaped markdown looks fine in the request and only shows up on
  read-back.

## Shared / common sub-concepts

A sub-concept reused by several notes gets **one home** under a top-level `Common/`
(or `Shared/`) hub; every parent that needs it `<mention-page>`-links to it rather
than copying it. Duplicate only when a shared home is genuinely impossible, and
sparingly — a duplicated fact that goes stale in one place poisons trust everywhere.

## Maintenance on access (not on a schedule)

There is no review chore. Every time a note is opened for a real need, that's the
trigger to verify it's still true, patch the gap just found, and bump `last touched`.
The notes used most stay freshest automatically.

## Fallback: no Notion connector available

Don't fail and don't block. Produce a clean, paste-ready markdown block in the chat:

- Concept page first — Title as H1, What/Why as the first line, L1 gist as plain text.
- Self-test questions as bullets with the answer indented beneath.
- Each deeper level under a `### Lx · Name` heading, in order, with a note that each
  becomes its **own child page** in Notion (the user creates the subpages with
  `/page`). MAP / RELATED / PARENT / META as a short footer.

Tell the user exactly where to nest it (under which hub) and that L2–L4 become
subpages. The format is the durable asset — it survives any tool.
