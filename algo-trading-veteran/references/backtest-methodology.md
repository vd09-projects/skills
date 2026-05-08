<!-- SCOPE: backtest-methodology.md
     Covers: how to test (data hygiene, methodology, execution realism, sanity checks),
     what metrics to compute and which ones matter, code review heuristics for user-submitted
     backtests (mostly Python — vectorbt, backtrader, pandas, custom), and the red flags
     Marcus calls out immediately on a backtest review.
     Does NOT cover: edge thesis evaluation (see edge-and-sizing.md), strategy lifecycle 
     and decay (see strategy-lifecycle.md), crypto-specific concerns (see crypto-perps.md), 
     Go engine-side code (that's Priya's domain — see algo-trading-lead-dev/references/go-patterns.md).
     LOAD WHEN: user submits a backtest for review, pastes code for audit, asks about 
     testing methodology, or asks about which performance metrics to trust. -->

# Backtest Methodology

Marcus's checklist for evaluating any backtest — his own work, the user's work, anything claiming to show edge. Anything failing here is grounds for not trusting the result.

---

## The four-section checklist

### Data hygiene

- Point-in-time data only. No restated fundamentals, no survivorship-cleaned universes, no forward-looking adjusted prices used as if they were live.
- Corporate actions handled explicitly for equities. Funding, fees, and basis explicit for perps and futures.
- Time zones and session boundaries pinned down.

### Methodology

- Train / validation / test split declared *before* looking at results. Or better: walk-forward with a fixed re-fit cadence. Or better still: **Combinatorial Purged Cross-Validation** (López de Prado). CPCV beats vanilla walk-forward because it generates many train/test paths instead of one, and it *purges* training observations whose labels overlap test observations — the most common source of subtle leakage in ML-based strategies. Worth using whenever the labels span more than one bar.
- Out-of-sample period meaningful relative to trade frequency — not 3 months on a strategy that trades once a week.
- Parameter sensitivity tested. If Sharpe falls off a cliff when you nudge a lookback from 20 to 22, it is fitted to noise. Marcus's heuristic: a real edge has a *plateau* of working parameter values, not a *peak*.
- Monte Carlo on trade order and bootstrap-resampled returns to get a confidence interval, not a point estimate.
- **Multiple-testing correction is non-negotiable.** If you tried 200 variants and picked the best, your reported Sharpe is inflated — that's selection bias. Use the **Deflated Sharpe Ratio** (Bailey & López de Prado), which adjusts for the number of trials, the length of the sample, and non-normal returns. If you don't compute DSR, at minimum apply a heavy mental discount: the more you searched, the less your in-sample number means. Von Neumann's line, which Marcus likes to quote: *"With four parameters I can fit an elephant, and with five I can make him wiggle his trunk."*
- Estimate the **Probability of Backtest Overfitting (PBO)** when the strategy is the result of an extensive search. PBO answers: "What's the probability that the configuration I selected will underperform the median configuration out-of-sample?" If it's high, you've fit noise.

### Execution realism

- Costs in: commissions, exchange fees, expected slippage as a function of size and ADV, borrow cost for shorts, funding for perps.
- Fills modeled honestly. No filling at the bar's low. For limit strategies, model queue position or assume worse than midpoint.
- Capacity test. At what AUM does the strategy break? If you don't know, you don't know the strategy.

### Sanity

- Look at the equity curve. Too smooth is a bug, not a feature. Real strategies have ugly months.
- Look at trade-level distribution. Is the edge concentrated in a handful of fat tails (one earnings season, one COVID month)? Then it's not an edge, it's a memory.
- Stress regimes: 2008, 2015, 2018 Q4, March 2020, 2022. If the strategy was not alive across at least two distinct regimes, you have not tested it.
- **Drawdown recovery time** — López de Prado calls this an under-appreciated tell. If the strategy takes much longer to recover from drawdowns out-of-sample than in-sample, it's a latent weakness. A Sharpe number alone hides this.

---

## Performance metrics — what Marcus actually looks at

He looks at all of these, in this rough order of importance, and refuses to summarize a strategy with a single number:

- **Sharpe**, annualized correctly, with realistic costs. Daily-bar Sharpe > 2.5 on a non-HFT strategy is suspicious until proven otherwise. (Renaissance's *individual-trade* hit rate is barely above 50% — the legendary numbers come from ensembling and leverage, not from any single signal having a 5.0 Sharpe.)
- **Deflated Sharpe / PSR** when many variants have been tried. Use this *whenever* the user has done a parameter search, which is almost always.
- **Sortino** and **Calmar / MAR** — Sharpe punishes upside vol, Sortino doesn't, Calmar tells you return-to-pain.
- **Max drawdown** in % *and in duration*. Most people can't sit through a 9-month drawdown even if the math says they should. Long durations are also a leading indicator of strategy decay.
- **Drawdown recovery time** in-sample vs out-of-sample. Divergence is a red flag.
- **Profit factor** and **win rate** together. A 35% win rate with PF 1.8 is fine; a 70% win rate with PF 1.1 is a bomb.
- **Tail ratio** (95th / 5th return). Tells you whether the strategy is short-vol in disguise.
- **Turnover** and **capacity** — paper Sharpe means nothing if the strategy can't hold $1M without moving the market.

---

## Code review — what Marcus looks at first

When the user pastes a backtest in Python (vectorbt, backtrader, pandas, custom), Marcus does not read line by line from the top. He scans for the things that go wrong most often, in this order:

1. **The data loading and any timestamp / index manipulation.** Lookahead bias lives here. Is `.shift(1)` applied to signals before they're used? Are returns computed from `close[t]` to `close[t+1]`, or from `open[t+1]` to `open[t+1]`? Is the strategy trading on the same bar it computes the signal from?
2. **The signal-to-position pipeline.** Is the position determined at time `t` from data only available at time `t` or earlier? Any feature using a future window (centered moving average, future-knowing normalization) is a bug.
3. **Costs.** Search the file for "commission", "fee", "slippage". If none of these appear, the backtest is missing the most important reality check.
4. **Train/test split.** Where in the code is the test data first touched? If there isn't a clear boundary, the strategy has been trained on its own evaluation set.
5. **Universe construction.** For multi-asset strategies, where does the list of assets come from? If it's the current S&P 500, that's survivorship bias.
6. **The sizing logic.** Is there one? Or does every trade go in at fixed notional regardless of vol or capital?

Only after these does Marcus look at the actual strategy logic. The strategy is usually fine; the framing around it is usually broken.

This code review pattern is for *user-submitted backtests* — typically Python, typically a notebook or a small script. Engine-side Go code (the production backtest engine, deterministic harnesses, the parquet/arrow handoff layer) is Priya's domain; see `algo-trading-lead-dev/references/go-patterns.md` for that.

---

## Red flags Marcus calls out immediately

When Marcus sees any of these in a user-submitted backtest, he names them plainly and explains why:

- Sharpe > 3 on daily bars without a microstructure or HFT story
- Equity curve that looks like a 45-degree line
- "I optimized the parameters and now it works"
- Backtest that includes 2020 but not 2018 or 2022
- No transaction costs, or "I'll add costs later"
- Win rate > 80% with profit factor near 1
- A strategy whose author can't tell you how many variants they tried
- "I don't know exactly what data this is, but it's from a paper"
- Strategy works on one ticker and the user wants to scale it to 50
- Drawdown recovery time out-of-sample is much longer than in-sample
- Anyone, anywhere, promising fixed monthly returns

Each of these maps to a specific failure mode the checklist above already covers. Marcus uses the red flag list as the *fast scan*; the checklist as the *full audit*.
