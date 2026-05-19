# _shared/

**Spec and recipe documentation. NOT loaded at runtime by any skill.**

The underscore prefix marks this as infrastructure docs, not a skill. Skill discovery tools (Rune, Claude Code's skill scanner) treat it as non-skill content.

## What lives here

| File | Purpose |
|---|---|
| `handoff-protocol.md` | The handoff contract spec. Schema, location, lifecycle, role catalog. Read by humans/Claude when building skills or answering protocol questions. |
| `agent-pattern.md` | Recipe for building orchestrator agents that sequence skills via the handoff bus. |

## What `_shared/` is NOT

- NOT a runtime dependency. Skills do not load files from here at runtime.
- NOT a library that must be installed alongside skills. A skill installed standalone (without `_shared/` present) works identically.
- NOT a place for shared memory or shared state. Cross-skill state goes via the handoff bus (`.claude/handoff/`). Cross-skill knowledge goes in CLAUDE.md.

## How skills use the protocol

Each skill **encodes the protocol behavior INLINE in its own SKILL.md**. A producer skill knows how to write artifacts because its SKILL.md tells it; it doesn't load the spec at session start. A consumer skill knows how to scan/filter/match because its SKILL.md tells it.

This means:
- No protocol file is mirrored into skill directories.
- Skills are fully self-contained.
- Drift between skill behavior and the spec is caught by humans reviewing the spec — not by runtime mismatch.

## When you would read files in `_shared/`

- Building a new skill that participates in the handoff protocol → read `handoff-protocol.md` first.
- Building a project-specific orchestrator agent → read `agent-pattern.md`.
- Adding a new role to the protocol → edit `handoff-protocol.md`, then update every implementing skill's SKILL.md inline to reflect the new role.

## Versioning

`handoff-protocol.md` is versioned via `artifact_version` inside the schema. When the spec changes:

1. Bump `artifact_version` if breaking (field removed, semantic shift, role catalog reduction).
2. Update every implementing skill's SKILL.md to emit the new version (producers) or accept it (consumers). Skills refuse mismatched versions per the protocol.
3. Old artifacts in projects' `.claude/handoff/` directories stay as-is — consumers refuse to consume them under the new version. They remain as audit trail.

## Adding new shared docs

1. Write the doc here.
2. Update this README's table.
3. Reference from skills' SKILL.md if relevant (as inline behavior, not as a loaded file).

## Anti-patterns

- **Mirroring `_shared/` files into skill directories.** Defeats the purpose. Skills encode behavior inline; spec stays in one place.
- **Loading `_shared/` files at skill runtime.** Skills must work standalone. If a skill needs the spec at runtime, it's a sign the SKILL.md isn't self-contained.
- **Putting project-specific or skill-specific content here.** Per-skill content lives in the skill's own directory. Per-project content lives in `.claude/`. `_shared/` is generic cross-skill infrastructure docs.
- **Treating `_shared/` as a code library.** It's documentation. Treat it like an RFC.
