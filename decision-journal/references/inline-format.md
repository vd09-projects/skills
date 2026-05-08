# Inline Decision Mark Format Specification

This file is the canonical specification for the inline decision-marking format used by any skill that records decisions worth preserving. It is intended to be honored by all producer skills in a project — Go developers, quant researchers, code reviewers, infrastructure designers, security analysts, or any future skills that make decisions worth recording — so that all decisions in a conversation can be harvested by a single extractor at end of conversation.

This skill (`decision-journal`) implements the canonical extractor via Harvest mode (see `SKILL.md`). Other skills may produce marks in this format without needing the journal installed; the marks are valuable as inline annotations regardless.

The format is **versioned from day one**. The current version is `2026-04.1.0`. Older entries with older version labels coexist with newer ones; extractors read both. This document defines version `2026-04.1.0` only; future versions will get their own document or appended sections here.

---

## Why this format exists

When a non-trivial decision is made mid-conversation — a structural choice, a library pick, a tradeoff between two reasonable options — the *reasoning* behind the call is only available at the moment it's made. By the time someone reads the diff three months later, the reasoning is gone. The git log shows what changed; it doesn't show why this option was picked over the alternatives that were also on the table.

The harvest model that works best in practice is: producers mark their decisions inline in their normal prose responses, and a journal (or any other consumer) extracts them at the end of the conversation. This way:

- The reasoning is captured at the moment of decision, not reconstructed later.
- The user sees the decisions inline as they're made — no separate file to open.
- Multiple producers honor one format, so the journal has a single extraction pattern instead of per-skill logic.
- Adding a new producer requires no changes to the journal, the format, or any other producer.
- The format itself can evolve without breaking old entries, because every entry carries its version.
- Marks remain valuable annotations even without a journal harvesting them.

---

## The format

A decision block looks like this:

```
**Decision (2026-04.1.0) — convention: experimental**
scope: engine/accounting
tags: money, types, decimal
supersedes: 2026-04-08-money-as-float64
owner: priya

All money values use `shopspring/decimal`; `float64` is reserved for statistics 
and indicators. The compile-time split between the two types also enforces the 
research-versus-engine boundary.

Alternatives considered: custom fixed-point, rejected on maintenance cost versus 
a mature library. big.Float, rejected because it has no decimal semantics and 
still drifts at display precision.
```

It has three parts: the lead-in line, the optional metadata block, and the prose body.

### The lead-in line

```
**Decision (<version>) — <category>: <status>**
```

- **`**Decision`** — literal. The opening anchor that extractors regex on.
- **`(<version>)`** — the format version. Currently `2026-04.1.0`. Required, so old extractors can recognize whether they understand the entry.
- **`—`** — em dash literal. Separator between the version and the category-status.
- **`<category>`** — one of the categories defined by the project's decision journal. Common categories: `convention`, `architecture`, `tradeoff`, `algorithm`, `library-choice`, `infrastructure`, `performance`. Producers may use any category; categories not in the journal's config are accepted by Harvest mode and a subdirectory is created on demand.
- **`:`** — literal colon. The category-status separator.
- **`<status>`** — one of the statuses defined by the journal. Common statuses: `experimental` (live but not ratified), `accepted` (ratified), `rejected` (proposed but not adopted), `superseded` (replaced by a newer decision), `revisit-later` (deferred). Status vocabulary is configured by the journal.

The lead-in is the **only stable contract** across all future format evolution. As long as the regex `\*\*Decision \(\d{4}-\d{2}\.\d+\.\d+\) — [^:]+: [^*]+\*\*` matches, an extractor can find the entry. Everything inside the block can change shape over years and the find-the-decisions step keeps working.

### The metadata block (optional)

A series of `key: value` lines immediately after the lead-in, no indentation, no blank line between them:

```
scope: engine/accounting
tags: money, types, decimal
supersedes: 2026-04-08-money-as-float64
owner: priya
```

Rules:

- **Any producer can add any key.** Unknown keys are ignored by extractors that don't understand them and stored as-is by extractors that do. New metadata fields require zero coordination across producers.
- **Values are free-text** unless the key has a journal-defined schema.
- **The block is optional.** A decision with no metadata block is valid; the lead-in is followed directly by a blank line and then the prose body.
- **The block ends at the first blank line.** After the blank line, prose begins.

Keys the journal recognizes by default (in version 2026-04.1.0):

- **`scope`** — the part of the codebase or system the decision applies to. Free text. Examples: `engine/accounting`, `internal/cv/cpcv`, `data-loading`, `repo-wide`, `sizing`, `risk-management`.
- **`tags`** — comma-separated keywords for search. Free text.
- **`supersedes`** — slug of a previous decision this one replaces. The journal uses this to flip the previous decision's status to `superseded` and add a forward-link.
- **`related`** — comma-separated slugs of related decisions, for cross-linking without supersession.
- **`revisit-trigger`** — a condition under which this decision should be reconsidered. Free text; the journal's review mode surfaces decisions whose triggers might be met.
- **`owner`** — which producer made the decision. Optional but recommended. Useful when you want to filter for "all decisions Marcus made in the last week" or "everything Priya marked as a tradeoff."
- **`ticket`** — reference to an external ticket or issue. Free text; the journal stores it without interpreting.

Producer-specific keys are fine. If a producer wants to add a `hypothesis` key to algorithm-category decisions, that's allowed and the journal stores it. Other producers and other extractors ignore the key without complaint.

### The prose body

After the metadata block (or after the lead-in if there's no metadata block), a blank line, then prose:

```
All money values use `shopspring/decimal`; `float64` is reserved for statistics 
and indicators. The compile-time split between the two types also enforces the 
research-versus-engine boundary.

Alternatives considered: custom fixed-point, rejected on maintenance cost versus 
a mature library. big.Float, rejected because it has no decimal semantics and 
still drifts at display precision.
```

Rules:

- **Prose, not bullet points.** The body is what the human reads. A reasoning paragraph is more readable and more useful than a list of fields.
- **No required sub-sections.** "Alternatives considered" appears as a sentence inside the prose when it's relevant, not as a mandatory header. Forcing every decision to have an "alternatives considered" section produces filler text on decisions where there were no real alternatives, and filler is what makes journals stop being read.
- **The body ends at the next blank-line-followed-by-non-decision-content.** Simple to parse, simple to write.
- **No closing marker.** If a future version needs one, that's a v2 change.

### The full anatomy

```
**Decision (<version>) — <category>: <status>**     ← lead-in (required)
<key>: <value>                                       ← metadata block (optional)
<key>: <value>
<key>: <value>
                                                     ← blank line separator
<prose body>                                         ← prose body (required)
<prose body>
                                                     ← blank line ends the block
```

---

## Examples

### Convention decision with full metadata (developer)

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

### Algorithm decision (researcher / methodology)

```
**Decision (2026-04.1.0) — algorithm: experimental**
scope: sizing
tags: kelly, drawdown, risk
owner: marcus

Half-Kelly with drawdown scaling: reduce position size proportionally 
to the gap from equity high-water mark. Hard circuit breaker at 20% 
portfolio drawdown from peak, at which point the strategy halts and 
gets re-evaluated rather than re-tuned.

Full Kelly is rejected because it assumes the win probability is known 
exactly. It isn't. Half-Kelly captures roughly three-quarters of the 
return at half the volatility (Thorp).
```

### Architecture decision with no metadata

```
**Decision (2026-04.1.0) — architecture: experimental**

CPCV will live at `internal/cv/cpcv` as a sibling to the existing `walkforward` 
package, both implementing a shared `Splitter` interface. The harness runner 
stays unchanged and consumes the interface.
```

### Tradeoff decision being marked as accepted by a reviewer

```
**Decision (2026-04.1.0) — tradeoff: accepted**
scope: internal/cv/cpcv
owner: priya
tags: complexity, function-length

The applyEmbargo function is intentionally 67 lines. The six logical embargo 
cases need to be co-located to be reviewable as a single check. Splitting them 
into helpers makes the reader context-switch between three files to understand 
one decision. The function-length warning is acknowledged and overridden.
```

### Decision superseding an earlier one

```
**Decision (2026-04.1.0) — convention: accepted**
scope: internal/cv/cpcv
supersedes: 2026-04-12-cpcv-embargo-fixed-bars
tags: embargo, label-horizon

The CPCV embargo field is renamed from `Embargo` to `MinEmbargo`, and the harness 
now takes the maximum of the configured min-embargo and the maximum label horizon 
in the labeled events. The harness assumes labeled events with horizons; users 
with unlabeled data should use a different splitter.
```

---

## How extractors should parse

The extractor's job is to find decision blocks in conversation text and forward each one to the decision-journal skill (or whatever consumer is being used). The recommended approach:

1. **Find lead-in lines** with the regex `^\*\*Decision \((\d{4}-\d{2}\.\d+\.\d+)\) — ([^:]+): ([^*]+)\*\*$` (multiline mode). This identifies every block opening and captures the version, category, and status.

2. **Determine block boundaries** by scanning forward from each lead-in. The block continues until either: a line containing two consecutive blank lines (i.e., one blank line followed by another blank line), a line that starts another lead-in, or end-of-text.

3. **Parse the metadata block** by reading lines after the lead-in until the first blank line. Each line that matches `^([a-z][a-z0-9_-]*): (.+)$` is a metadata key-value pair. Lines that don't match this pattern end the metadata block.

4. **Parse the prose body** as everything after the metadata block (or after the lead-in if no metadata) up to the block boundary.

5. **Check the version**. If the extractor understands the version, parse normally. If it doesn't understand the version, the extractor should still capture the raw block text and forward it with a `version-not-understood` flag, rather than dropping the decision silently. Forward compatibility matters more than strict parsing.

The extractor does **not** decide whether a decision is significant, well-formed, or worth recording. Producers decide that by writing the marks in the first place. The extractor's only job is find-and-forward.

This skill's Harvest mode (in `SKILL.md`) implements this extraction algorithm. The regex used by Harvest is taken from this document and is not duplicated in `SKILL.md`.

---

## Format evolution policy

Versioning is the mechanism that lets this format evolve without breaking historical entries. The version label is **date-anchored major-minor-patch**: `<YYYY-MM>.<major>.<minor>`.

- **Patch increments** (`2026-04.1.1`) are for clarifications that don't change parser behavior. Adding a recognized key. Documenting an existing pattern. Tightening the meaning of a field without changing the wire format.
- **Minor increments** (`2026-04.2.0`) are for additive changes within the same epoch — new optional features that older extractors can ignore safely. New required-when-present sub-blocks. New metadata key types.
- **Epoch increments** (`2027-XX.1.0`) are for breaking changes that older extractors cannot safely ignore. Renaming the lead-in. Changing the block boundary rule. Changing how status is encoded.

The date prefix gives every version an unambiguous chronological anchor: `2027-03.1.0` came after `2026-04.1.0` even though their major-minor numbers don't sort lexically. This is the property that makes the version label future-proof in a way that bare semver isn't.

When a new version is introduced:

1. The new version's spec is added to this document (or a sibling document) without removing the old version's spec.
2. Producers update to emit the new version in new decisions. Old decisions are not migrated.
3. Extractors are updated to parse both the old and new versions. They never drop entries silently.
4. After enough time has passed that no live producer is emitting the old version, the old spec stays in this document as historical reference. It is never deleted, because old decision files in `decisions/` will reference it forever.

The current `2026-04.1.0` regex is intentionally permissive within v1. Future-version handling — particularly whether the regex needs to widen for compatibility — is a v2 design concern, not a v1 implementation concern.

---

## What is *not* a decision worth marking

Producers should not mark trivial choices. The format exists to capture reasoning that won't be recoverable from the diff; if the reasoning *is* recoverable from the diff, the mark is noise and degrades the journal's signal.

Don't mark:

- Variable names, function names, file names. These are visible in the diff.
- Formatting, ordering of imports, comment style. These are linter-enforced.
- Bug fixes whose reasoning is "the previous code was wrong, here's the fix." The diff and the test that catches the regression are sufficient.
- Routine refactors that move code without changing it. The diff shows the move.
- Configuration changes whose reasoning is "we now want X instead of Y, where Y was the previous setting." Unless there's a tradeoff being made, this is not a decision worth recording.
- General principles being applied to a situation. Producers shouldn't mark "no edge, no trade" or "errors get wrapped with %w" because those are principles, not decisions made for this situation.

Do mark:

- Structural choices: package boundaries, abstraction shapes, interface designs.
- Library picks where alternatives existed.
- Tradeoffs between two reasonable options where the loser was rejected for a specific reason.
- Conventions being established that future code will be expected to follow.
- Overrides of default rules (lint warnings, function length thresholds) where the override is intentional and the reason matters.
- Algorithm choices on the methodology side (sizing rules for *this* situation, kill-switch lines for *this* strategy, edge thesis verdicts).
- API shapes that lock in constraints.

The test, restated: **would a reasonable person ask "why did you do it this way?" in three months, and would the diff (or the conversation alone) fail to answer them?** If yes to both, mark it. If no to either, don't.

The corollary test for producers that work in judgment-and-recommendation mode (researchers, methodology consultants): **am I applying a general principle, or am I making a specific call for this situation?** Apply principles freely without marking; mark specific calls.
