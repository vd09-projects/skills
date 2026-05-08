<!-- MAINTENANCE: This is a compact subset of the canonical inline-decision-mark
     format spec. The canonical spec lives in decision-journal/references/inline-format.md.
     If you change the format here, also update the canonical spec.
     If you change the canonical spec, regenerate this file from the journal's spec.
     Don't let them drift. -->

# Decision Marking — Compact Reference for Marcus

The format Marcus uses to mark decisions inline in his responses. Designed to be cheap to load (~1,000 tokens) so per-decision cost stays small. The full spec — versioning policy, parsing algorithm, evolution rules, all metadata keys — lives in the `decision-journal` skill at `references/inline-format.md`.

## The format

```
**Decision (2026-04.1.0) — <category>: <status>**
<key>: <value>
<key>: <value>

<reasoning in prose>
```

Three parts: lead-in line, optional metadata block (key:value lines, ends at first blank line), prose body. The prose body is what the human reads — paragraphs, not bullets.

## Marcus's category

Marcus writes to **`algorithm`**. This is his domain — sizing rules, kill-switch lines, edge thesis verdicts, methodology choices, feature-addition decisions, anything that affects how the strategy makes money or how it's evaluated.

Marcus does NOT write to `convention`, `architecture`, or `tradeoff` — those are Priya's categories (implementation territory).

## Default status

`experimental` for Marcus's own calls. Live in the recommendation, not yet ratified. User feedback or a later live result can promote to `accepted`, or the user can mark it `rejected` if they choose to ignore the recommendation.

## Metadata keys Marcus commonly uses

- `scope` — what the decision applies to (`sizing`, `risk-management`, `feature-addition`, `kill-switch`, `<strategy-name>`).
- `tags` — comma-separated keywords for search.
- `owner: marcus` — useful for filtering by producer when other producers are also marking decisions.
- `revisit-trigger` — a condition under which to reconsider this decision (e.g., "if drawdown exceeds 15% and the line was 20%").

Other keys are allowed; the journal stores unknown keys without complaint.

## Example

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

## When to mark — applying principles vs making specific calls

This is the line Marcus has to walk. The five principles are not decisions — they're principles. He doesn't mark "no edge, no trade" as a decision because it's a principle, not a call he made for this user.

He DOES mark specific calls. *"For this user with $50k on BTC perps, half-Kelly with drawdown scaling at 5%/10%/15% thresholds and a hard halt at 20%."* That's a specific recommendation, not a principle. It's a call with reasoning that won't be recoverable from the diff (because there is no diff — Marcus's domain is methodology, not code).

The corollary test: **am I applying a general principle, or am I making a specific call for this situation?** Apply principles freely without marking; mark specific calls.

The harder test: **would a reasonable person ask "why did you size it this way?" or "why did you kill this strategy?" in three months, and would the conversation alone fail to answer them?** If yes to both, mark it.

**Don't mark:** general principles being applied, restatements of well-established methodology (use CPCV, account for funding, watch survivorship), trivial "this is clearly bad" calls where the reasoning is obvious from the situation.

**Do mark:** specific sizing rules for this user's strategy, kill-switch lines tied to this strategy's bootstrapped distribution, verdicts on whether to add a specific feature for this specific reason, recommendations that depart from defaults (e.g., "use full Kelly here because the edge is exceptionally well-measured" — that needs a paper trail).

## Without the journal installed

These marks are valuable inline annotations even if no journal is present to harvest them. They're readable conversation-level documentation; the user can see Marcus's reasoning at the moment of recommendation. The journal makes them durable across conversations and queryable. Without the journal, they remain useful but ephemeral.
