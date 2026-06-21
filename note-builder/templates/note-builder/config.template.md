# Note Builder Config — [Project Name]

Written by Rune to `.claude/skill-memory/note-builder/config.md`.
Can also live globally at `~/.claude/skill-memory/note-builder/config.md` as a
cross-project default; a project-level file overrides the global one field-by-field.

---

## Destination

<!-- Where Stage 3 files notes. From `notes-system` Q37. REQUIRED.

     Notion:
     - notion_parent: <page or database name>   (the concept-hub root)
     - notion_url: <https://www.notion.so/...>   (optional, disambiguates)

     Markdown:
     - notes_dir: <absolute path>                (one file per concept)
-->

notion_parent:
notion_url:
notes_dir:

## Mode

<!-- From Q38. Decides Stage 3's filing path.
     - mcp        → Notion MCP connector available; file directly.
     - markdown   → no connector; emit paste-ready markdown (deeper levels as
                    ### Lx sections the user turns into subpages).
     If unsure, leave as markdown — it survives any tool. -->

mode: <!-- mcp | markdown -->

## Concept buckets

<!-- From Q39. Top-level parents new notes file under, so they accrete instead of
     orphaning. List the ones that already exist; add as the tree grows.

     Examples:
     - Postgres
     - Trading strategies
     - Languages / Spanish
-->

## Depth bias

<!-- From Q40. Tunes Stage 2's default target depth.
     - default    → standard "default shallow": stop at L1 unless asked to develop.
     - deeper     → bias toward L2–L3 by default (reference-heavy work contexts).
     - shallower  → gist-only; almost never auto-develop.
     Override per-note always wins; this is only the starting point. -->

depth_bias: default

## Freshness

<!-- From Q41. Format for the `last touched` stamp and the `type` default.
     - date_format: YYYY-MM-DD   (ISO, default)
     - timezone: local
     - default_type: concept | reference
       (concept = learning; reference = a system/codebase you operate)
-->

date_format: YYYY-MM-DD
timezone: local
default_type: concept

## Self-test links

<!-- How self-test answers link to their source (see references/self-test.md +
     notion-filing.md).
     selftest_style: B = each answer ends with a "↪ read more" anchor to its source
       block. A = clean, no link (fallback when no anchor method is available).
     anchor_method:
       - rest-token       → block ids from the Notion REST API (clean, automatic).
                            Requires a LOCAL token in a secrets file, never committed:
                            token_file: ~/.claude/skill-memory/note-builder/secrets.env
                            (NOTION_TOKEN=…), notion_api_version: 2022-06-28, and the
                            integration shared with the notes parent.
       - copy-link        → user pastes "Copy link to block" URLs (manual, clean).
       - probe-comment    → comment to read the block id, delete after (auto, throwaway).
     Anchor format: pageURL#<blockId-no-dashes>. -->

selftest_style: B
anchor_method: copy-link
