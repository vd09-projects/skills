<!-- MAINTENANCE: This is a compact subset of the canonical inline-decision-mark
     format spec. The canonical spec lives in decision-journal/references/inline-format.md.
     If you change the format here, also update the canonical spec.
     If you change the canonical spec, regenerate this file from the journal's spec.
     Don't let them drift. -->

# Decision Marking — Compact Reference for Priya

The format Priya uses to mark decisions inline in her responses. Designed to be cheap to load (~500 tokens) so per-decision cost stays small. The full spec — versioning policy, parsing algorithm, evolution rules, all metadata keys — lives in the `decision-journal` skill at `references/inline-format.md`.

## The format

```
**Decision (2026-04.1.0) — <category>: <status>**
<key>: <value>
<key>: <value>

<reasoning in prose>
```

Three parts: lead-in line, optional metadata block (key:value lines, ends at first blank line), prose body. The prose body is what the human reads — paragraphs, not bullets.

## Priya's categories

- `convention` — code-style or repo-wide rule being established (decimal money, UTC time, named struct fields, etc.).
- `architecture` — package boundaries, abstraction shapes, interface designs, where things live.
- `tradeoff` — explicit choice between two reasonable options where the loser was rejected for a specific reason.

She does NOT write to `algorithm` — that's Marcus's category. She reads `algorithm` decisions to understand constraints.

## Default status

`experimental` for Priya's own calls. Live in the code, not yet ratified. Reviewer or Marcus or user feedback can promote to `accepted` later.

## Metadata keys Priya commonly uses

- `scope` — the part of the codebase the decision applies to (`engine/accounting`, `internal/cv/cpcv`, `repo-wide`).
- `tags` — comma-separated keywords for search.
- `supersedes` — slug of a previous decision this one replaces.
- `owner: priya` — useful for filtering by producer when other producers are also marking decisions.

Other keys are allowed; the journal stores unknown keys without complaint.

## Example

```
**Decision (2026-04.1.0) — convention: experimental**
scope: engine/accounting
tags: money, types, decimal
owner: priya

All money values use `shopspring/decimal`; `float64` is reserved for statistics 
and indicators. The compile-time split between the two types also enforces the 
research-versus-engine boundary.

Alternatives considered: custom fixed-point, rejected on maintenance cost versus 
a mature library. big.Float, rejected because it has no decimal semantics and 
still drifts at display precision.
```

## When to mark

The test: would a reasonable person ask "why did you do it this way?" in three months, **and** would the diff alone fail to answer them? If yes to both, mark it. If no to either, don't.

**Don't mark:** trivial choices (variable names, formatting), bug fixes (the diff explains them), or pure refactors (the diff is the explanation).

**Do mark:** structural choices, library picks where alternatives existed, tradeoffs with specific reasons, conventions being established, overrides of default rules where the override is intentional.

## Without the journal installed

These marks are valuable inline annotations even if no journal is present to harvest them. They're readable conversation-level documentation; the human can see Priya's reasoning at the moment of decision. The journal makes them durable across conversations and queryable. Without the journal, they remain useful but ephemeral.
