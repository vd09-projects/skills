# Rune Sizing Rubric

**Load when:** Mode 8 Rune fires (classify, reclassify), Mode 7 Decompose-merge candidate check,
Mode 6 Review backfill prompt, or repo setup writes `tasks/RUNE.md`.

**Don't load** for plain Create/Status/Next/Prioritize — Mode 8 only consults this file when the
rune is in doubt or the proposed scope contradicts the requested rune.

---

## The four runes

| Rune | Solves | Output | Sizing | Forbidden |
|---|---|---|---|---|
| **dev** | Big chunk of the problem; an end-to-end feature slice. | Shipped code + tests + integration. May include new interfaces, scaffolding, multi-file refactor. | 3-4 days of focused work. | Splitting itself into vibe siblings just to dodge review weight. |
| **vibe** | One subchunk of an already-understood problem. | Concrete code edit, atomic and reviewable. | Hours, not days. One commit, one focused diff. | Creating interfaces, designing abstractions, speculative scaffolding, "set up the structure for". If the task is interface-creation, it is not vibe. |
| **research** | Unknown — "we don't know how X works / what library to use / what the API returns". | Written findings (a note, a decision-journal entry, links, code spikes that are then thrown away). | Bounded — set a timebox up front. | Shipping production code. If research produces code worth keeping, spawn a follow-up `dev` or `vibe` task. |
| **analysis** | Best approach unclear — "we know the problem, we don't know which solution". | Tradeoff comparison + a recommendation (often a decision-journal entry). | Bounded — set a timebox up front. | Shipping production code. Spawn a follow-up implementation task. |

---

## Classification rules

1. Default to repo's `default_mode` from `tasks/RUNE.md` if it's `dev` or `vibe`. If `mixed`, ask.
2. **Override triggers — switch away from vibe:**
   - Title or context contains "design", "interface", "scaffold", "set up", "architecture",
     "approach" → likely `research` or `analysis`.
   - User cannot state the acceptance criteria concretely → `research` (figure out what done
     looks like) or `analysis` (figure out which done to aim at).
   - Task would touch 4+ files or introduce a new module → `dev`.
3. **Override triggers — switch away from dev:**
   - Acceptance criteria fit in one bullet and code change fits in one file → `vibe`.
   - Task is "verify X already works" with no production code expected → `vibe` or fold into the
     task that shipped X.
4. **Refusal cases.** If user requests `vibe` but the proposed work is interface design, scaffolding,
   or open-ended exploration, refuse with one line: "That's not vibe — it's `research`/`analysis`/`dev`.
   Reclassify or rescope." Do not silently downgrade.

---

## Cluster sizing (for Mode 7 Decompose-merge)

A cluster of 2+ tasks is a **merge candidate** when ALL of these hold:

- Each task individually fits the `vibe` rubric (one subchunk, one focused diff).
- Tasks share a parent, touch the same module, or were seeded from the same architectural noun.
- The union of their acceptance criteria fits the `dev` rubric (3-4 day chunk).
- No task in the cluster has shipped, been reviewed, or been committed yet.

If all four hold → propose merge to `dev`. If any fail → leave the cluster alone, optionally
note in each task's Notes that they're related siblings.

---

## Cross-references

- Repo default: `tasks/RUNE.md` `default_mode:` field.
- Per-task field: `**Rune:**` line in BACKLOG.md task block.
- Header stat: rune distribution in BACKLOG.md header line.
