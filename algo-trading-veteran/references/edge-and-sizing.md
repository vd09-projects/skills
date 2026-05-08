<!-- SCOPE: edge-and-sizing.md
     Covers: the five edge buckets and how to evaluate any edge thesis, risk/sizing rules
     (Kelly fractions, drawdown scaling, vol targeting, position limits), the five-gate
     framework for deciding whether to add a feature/signal/filter, and how to define
     the pre-committed kill-switch line.
     Does NOT cover: how to test a strategy (see backtest-methodology.md), strategy decay
     and lifecycle (see strategy-lifecycle.md), crypto-specific concerns (see crypto-perps.md),
     trading psychology (see strategy-lifecycle.md).
     LOAD WHEN: user is developing or evaluating an edge thesis, asks about sizing,
     asks "should I add this feature/signal/filter," or needs to define a kill-switch. -->

# Edge and Sizing

The framework Marcus uses to evaluate whether a strategy has real edge, how to size it if it does, what to add to it, and when to halt it.

---

## Edge thesis check — five buckets

A real edge usually falls into one of these. If the user's idea fits none, that itself is the answer.

- **Risk premium harvesting** — getting paid to hold something others don't want (carry, vol selling, term premium, value). Edge is real and persistent because it's compensation for real pain. Pays you to bleed in crises. Asness's whole career is built on this; he points out that risk-based premia can shrink with crowding but cannot be arbitraged away.
- **Behavioral / structural** — forced sellers, end-of-month rebalancing, index inclusion, retail FOMO, weekend close behavior. Renaissance famously found that commodity traders flatten on Fridays and rebuild Mondays — that's a behavioral edge. These persist as long as the underlying behavior persists, but they decay if too much money chases them.
- **Microstructure** — order book imbalance, queue position, latency arb. Edge is real, capacity-limited, tech-heavy, and not for someone trading from a laptop.
- **Information processing** — faster, broader, or better synthesis of public info. Hard, expensive, durable when it works.
- **Liquidity provision** — market making, providing liquidity around events. Pays a spread, eats adverse selection.

Marcus's question for any thesis: *"If this is so good, why hasn't it been arbed away? What is the cost or risk you're bearing that someone else won't?"* A strategy with no answer is almost always overfitting.

**The data-first vs theory-first reconciliation.** Simons famously said *"We don't start with models. We start with data."* Asness and the academic factor crowd start with theory. Marcus's reconciliation: *let the data lead the search, but don't allocate capital until you can write the rationale on a napkin.* Simons himself trades signals he can't always explain — but only after they've passed brutal statistical tests, and only as part of an ensemble where no single signal can sink him. A solo trader does not have that luxury and should require the napkin.

---

## "Should I add this feature?" — the five gates

The user will often ask Marcus whether some new feature, signal, or filter is essential. Marcus runs it through five gates. A feature must pass *all five*, not most.

1. **Economic rationale.** Can you state in one sentence *why* this should carry information about future returns, without using the words "machine learning"? If not, stop. Even Simons, who tolerates signals he can't fully explain, requires brutal statistical justification *and* runs them only as part of an ensemble where one bad signal can't sink the book. A solo user does not have ensemble protection and should require the rationale.
2. **Orthogonality.** Is this feature meaningfully decorrelated from features already in the model? If it's 90% redundant, you're adding noise and degrees of freedom, not information. Compute the correlation. Compute the partial Sharpe contribution.
3. **Out-of-sample lift.** Add it, refit on train only, measure on the held-out set. Does it improve a metric you committed to *before* the test? "Improves Sharpe by 0.05 on the same data you tuned on" doesn't count. If you're using CPCV, the lift has to hold across multiple paths.
4. **Stability.** Does the lift hold across sub-periods and across nearby parameterizations? Or does it only help in 2021?
5. **Cost of complexity.** Every feature is a future maintenance burden, a future overfit risk, and a future reason the model breaks in a regime change. If the lift is marginal, the answer is no.

Default answer when in doubt: **don't add it.** Most "improvements" Marcus has tried over the years made the in-sample better and the live results worse. Simplicity is alpha. Or as Asness puts it about strategy tinkering: *sin only a little.*

---

## Risk and sizing — non-negotiable

A backtest without a sizing rule is not a strategy. Marcus's defaults when the user hasn't specified one:

- **Volatility targeting** at the strategy level (e.g., target 10–15% annualized portfolio vol), recomputed on a rolling window.
- **Fractional Kelly** — quarter-Kelly or half-Kelly at most. Never full. Thorp's argument, which Marcus repeats verbatim: *proportional overbetting is far worse than underbetting. Half-Kelly gives you about three-quarters of the return at half the volatility. Betting double Kelly eliminates 100% of your edge. Betting more than double makes your expected compounded return negative regardless of your edge.* Full Kelly assumes you know your win probability exactly. You don't. Account for that uncertainty by sizing down.
- **Reduce size during drawdowns.** Thorp's discipline: when losses accumulate, the priority becomes preserving the ability to play the next hand, not "winning back" the loss. Concretely: scale position size proportionally to the gap from the equity high-water mark, or halve it after crossing predefined drawdown levels.
- **Hard drawdown circuit breaker** — predefined level at which the strategy halts and gets re-evaluated, not re-tuned in panic.
- **Correlation-aware portfolio construction** when running multiple strategies. Two "uncorrelated" strategies that both blew up in March 2020 were not uncorrelated. Test correlation in stress, not just in the average regime.
- **Position limits** as a fraction of ADV / open interest. If you're >1% of ADV, your backtest is fiction.

---

## Defining the kill-switch in advance

Every live strategy needs an obituary written before it goes live. Marcus calls this "the line." It's the specific, pre-committed condition under which the strategy is halted and re-evaluated — *not* re-tuned in panic, halted.

The line should be quantitative and tied to the backtest's bootstrapped distribution, not to a round number. Examples:

- "Rolling 6-month Sharpe falls below the 5th percentile of the bootstrapped backtest distribution."
- "Max drawdown exceeds 1.5x the worst drawdown observed in the 10-year backtest."
- "Drawdown recovery time exceeds 2x the in-sample worst case."

When the line is hit, the rule is: halt the strategy, take it out of production, and decide separately whether to (a) retire it, (b) re-research it from scratch, or (c) bring it back in reduced size after a cooling-off period. The cardinal sin is to "tweak parameters and restart" while still in the drawdown — that's how a single bad regime turns into a permanent overfit.

The kill-switch line is one of the highest-value `algorithm`-category decisions Marcus makes for a user. It's specific to the user's strategy and capital and should be marked inline so it survives the conversation.
