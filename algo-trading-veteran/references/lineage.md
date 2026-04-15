# Lineage — the people Marcus stole from

This file is loaded on demand when the user wants attribution, depth, the "why" behind a principle, the math, or historical context. It is not loaded by default. When you cite from here, name the source — Marcus is generous with credit.

## Table of contents

1. Jim Simons & Renaissance Technologies — the strategy factory
2. Ed Thorp — edge, Kelly, and survival
3. Marcos López de Prado — the modern statistician of backtesting
4. Cliff Asness & AQR — factors, decay, and discipline
5. The war stories (1987, 1998, 2007, 2015, 2020)
6. Math cheatsheet — Kelly, Sharpe, Deflated Sharpe, PBO

---

## 1. Jim Simons & Renaissance Technologies — the strategy factory

The only fund whose track record makes Marcus shut up and listen. Medallion averaged about **66% gross / 39% net annual returns from 1988 to 2018**, on a 5-and-44 fee structure. Internal post-2010 numbers (Brown / Mercer era) reportedly continued in the 70s gross, 40s net.

**The core insight** — and the one Marcus repeats most often — is that Renaissance did not get rich on a great trade idea. They got rich on a *strategy factory* that produced many small, weakly-correlated edges and ran them simultaneously at high turnover with significant leverage. Medallion's individual-trade hit rate is reportedly only **about 50.75%**. The legendary returns come from:

- Running thousands of bets per day across instruments
- Ensembling many small signals so no one signal can sink the book
- Average leverage in the 12.5x range (with confident, diversified positioning)
- Brutal cost control in execution
- Discipline: once a model is live, no human override

**Talent over finance background.** Simons hired physicists, mathematicians, statisticians, and computer scientists — not MBAs. The firm's stated bet was that "financial knowledge can be learned, but raw scientific talent cannot." The most consequential hires came from IBM's Thomas J. Watson Research Center speech-recognition group (Bob Mercer, Peter Brown), who brought hidden-Markov-model thinking to markets.

**Data-first epistemology.** Simons's most-quoted line: *"We don't start with models. We start with data. We don't have any preconceived notions. We look for things that can be replicated thousands of times."* The Renaissance standing rule: *"If the signal works and is not obviously spurious, trade it."* Researchers often did not know *why* a signal worked. They knew *that* it worked, and they had statistical tests rigorous enough to be confident the pattern wasn't noise.

This is in tension with the academic factor school (Asness etc.) which insists on theory first. Marcus's reconciliation: Simons could afford this because he had the ensemble. One unexplained signal in an ensemble of hundreds is fine — it can't sink the book. One unexplained signal that *is* your book is a different animal entirely. A solo trader needs the napkin-rationale because they don't have ensemble protection.

**Signal categories Renaissance was known to mine.** From public sources (Zuckerman's *The Man Who Solved the Market*, employee interviews):

- **Trending behavior** at varying horizons
- **Mean reversion** after large moves
- **Seasonality** — including the famous "Monday's open often resembles Friday's close" pattern
- **Pre/post economic-release drift** (e.g., labor data)
- **Trader-habit patterns** — commodity traders flattening on Friday afternoons to avoid weekend risk, then rebuilding Monday
- **Weather correlations** — bright morning weather in a city's financial district mildly predicting that exchange's open. The signal was real but too small to overcome costs, which is why Renaissance let this one become public.

**The hands-off rule and the 2007 quant quake.** In August 2007, the great quant unwind hit Medallion hard — the fund lost roughly $1B (about 20% of its value) in three days as factor crowding caused simultaneous deleveraging across statistical arbitrage funds. Renaissance's policy was the same as always: let the models run. They did not intervene. By year end, **Medallion was up about 86% gross**. 2008, the global financial crisis, **about 75% net**. The lesson Marcus extracts: discretionary intervention in a drawdown is almost always wrong, *if* the underlying edge is intact. The hard part is knowing when it isn't.

**Capacity awareness.** Simons understood that returns and AUM are inversely related once you exceed your strategy's capacity. Medallion **stopped accepting outside money in 1993** and now only manages capital for current and former employees. The fund distributes profits twice a year and resets to roughly the same AUM. This is the single most important thing most retail traders ignore: a strategy that works at $100k may simply not exist at $10M.

**Leverage with confidence and diversification.** Medallion runs at average leverage of about 12.5x (10–20x range). Marcus's takeaway: *high leverage is acceptable when (a) the edge is statistically rock-solid and (b) the bets are diversified enough that no single move can hurt you proportionally.* It is not acceptable on a single concentrated thesis. EURCHF 2015 was a single concentrated thesis. (More on that below.)

---

## 2. Ed Thorp — edge, Kelly, and survival

Thorp is Marcus's patron saint of risk discipline. Math professor, blackjack card-counter, founder of Princeton/Newport Partners (the first modern quantitative hedge fund), author of *Beat the Dealer* and *A Man for All Markets*. Princeton/Newport ran for ~19 years with no losing year before being shut down in 1988 (for reasons unrelated to performance).

**The central idea: edge first.** Thorp is uncompromising about this. *"Trading without an edge is gambling — and the house always wins."* Before any sizing math, before any execution detail, the question is whether you actually have a positive expectation. Most retail traders skip this question because it is uncomfortable.

**The Kelly criterion.** Thorp brought John Kelly's 1956 information-theory result into the gambling and investing worlds. The Kelly formula for a binary bet:

```
f* = (b·p − q) / b
```

where `f*` is the optimal fraction of bankroll to bet, `p` is the probability of winning, `q = 1 − p` is the probability of losing, and `b` is the net odds received on the win (e.g., 1 for even-money). Kelly maximizes the long-run geometric (compounded) growth rate of wealth.

**Why fractional Kelly is the only sane choice in trading.** Thorp argues — and this is the line Marcus uses verbatim — that **proportional overbetting is dramatically worse than underbetting**. Specifically:

- **Half-Kelly** gives you about **75% of the return at 50% of the volatility.**
- **Full Kelly** has 50% drawdowns baked into its long-run distribution. Most humans, including Thorp, can't sit through them.
- **Double Kelly** eliminates 100% of your edge — your expected compounded return is zero.
- **More than double Kelly** makes your expected compounded return *negative*, regardless of how big your edge is.

So even an honest Kelly fraction is dangerous if you don't know your true win probability — and you never do. Quarter-Kelly to half-Kelly is the practical range. Bill Gross, who read *Beat the Dealer* and went to Vegas as a teenager, ran PIMCO's $1T bond book on Kelly principles for decades. *"Professional blackjack is being played in this trading room from the standpoint of risk management."*

**The drawdown rule.** Thorp's discipline: when you're losing, scale down. Position sizes should fall with cumulative losses. The goal is *preserving the ability to play the next hand*, not winning back what you lost. Every blowup story Marcus has seen — including his own EURCHF year — has the same shape: a trader doubling down to recover losses, in defiance of this rule.

**Black swans force you below naive Kelly.** Thorp explicitly warns that fat-tailed return distributions (which all financial returns have) make the naive Kelly calculation an overestimate. Real-world returns have black swans that the binary-bet math doesn't see. Discount accordingly.

**Princeton/Newport's strategy.** Convertible bond arbitrage, warrant arbitrage, and other market-neutral strategies — series of small, uncorrelated bets sized via Kelly. Same philosophical DNA as Renaissance, twenty years earlier.

---

## 3. Marcos López de Prado — the modern statistician of backtesting

If Marcus had to recommend one author for someone serious about systematic trading today, it's López de Prado. His books *Advances in Financial Machine Learning* (2018) and *Machine Learning for Asset Managers* (2020) are the practitioner standard. He's run quant teams at Guggenheim, AQR, and elsewhere.

**The central message:** most published backtests are wrong because they ignore selection bias and multiple testing. The math industry knows how to fix this; the trading industry mostly doesn't.

**The Deflated Sharpe Ratio (Bailey & López de Prado, 2014).** A standard Sharpe ratio assumes you tested one strategy. In practice you tested hundreds or thousands of variants and reported the best. Selection bias inflates the reported number. The Deflated Sharpe Ratio (DSR) corrects for:

1. The **number of independent trials** the researcher ran
2. The **length of the sample**
3. **Non-normality** of returns (skew and excess kurtosis)

It returns the probability that the *true* Sharpe is above zero given everything you actually tried. Most "great" published backtests fail this test.

**The Probabilistic Sharpe Ratio (PSR).** A simpler cousin of DSR for the single-test case. It estimates the probability that the true Sharpe exceeds a benchmark threshold given the sample length and return distribution. Use it when you didn't do an extensive search.

**The Probability of Backtest Overfitting (PBO).** Estimated via **Combinatorially Symmetric Cross-Validation (CSCV)**. PBO answers: *"Given everything I tried, what is the probability that my chosen strategy will underperform the median of my trials out of sample?"* If PBO is high, the optimization process itself has been overfitting — not just any single model.

**Combinatorial Purged Cross-Validation (CPCV).** López de Prado's main critique of vanilla walk-forward is that it produces only one train/test path and is leaky for any model whose labels span more than one bar. CPCV fixes both:

- **Combinatorial** — splits the data into N groups and forms many train/test combinations, generating many out-of-sample paths instead of one. You see distribution, not point estimate.
- **Purged** — removes from training any observations whose labels overlap with test labels. This kills the most common subtle leakage in ML strategies.
- **Embargoed** — adds a small gap after the test set before resuming training, to handle serial correlation.

Recent work (Sciencedirect 2024 study cited above) shows CPCV materially outperforms vanilla walk-forward on PBO and DSR metrics.

**Drawdown recovery time as a strategy tell.** López de Prado identifies recovery time as a key indicator of strategy decay. If a strategy's drawdowns take longer to recover from out-of-sample than in-sample, the underlying edge is weakening. A flat Sharpe number hides this.

**The seven failure modes of ML quant funds.** From his 2017 talk *"The 7 Reasons Most Machine Learning Funds Fail"*:

1. Working solo on the whole pipeline (instead of as specialists in an assembly line)
2. Backtest overfitting (use DSR / PBO)
3. Treating the chronology of financial data as if it were i.i.d. (use CPCV / purging)
4. Ignoring that observations are not independent (autocorrelation, regime shifts)
5. Misusing cross-validation methods designed for non-time-series data
6. Wrongly assuming return predictability is constant
7. Not focusing on **drawdown recovery time** as an early warning of strategy weakness

The first one matters even for solo traders: López de Prado's argument is that a single brain can't simultaneously be a good researcher, executor, and risk manager because the cognitive modes interfere. A solo shop should at least *role-switch* deliberately.

---

## 4. Cliff Asness & AQR — factors, decay, and discipline

Asness co-founded AQR in 1998 after leaving Goldman's quant group. Built the largest systematic factor-investing firm in the world. Has written more accessible plain-English papers than anyone else in the business; his "Cliff's Perspective" essays are required reading.

**The factor zoo and what survives.** Equity factor research has identified hundreds of "anomalies" — value, momentum, quality, size, low-vol, profitability, investment, betting-against-beta. Asness's work (with Frazzini, Israel, Moskowitz, and others) argues that a small number of these are real and persistent because they correspond to either:

1. **Risk premia** — compensation for bearing genuine risk that other investors don't want (value's tendency to underperform in the late stages of bubbles, momentum's tendency to crash on reversal). These can shrink with crowding but cannot be arbitraged away because they pay for real pain.
2. **Behavioral biases** — investor mistakes that don't go away because humans don't change (overreaction, underreaction, anchoring).

**Decay is real and measurable.** McLean and Pontiff (2016) replicated 97 published equity anomalies and found that on average, **post-publication returns were about 50% lower than in-sample returns**. Falck, Rej, and Thesmar (2021) extended this and found:

- **Year of publication alone explains about 30% of the variance in Sharpe decay across factors.**
- Overfitting variables (signal complexity, sensitivity to outliers) explain another **15%**.
- Arbitrage / crowding variables explain very little additional variance.

**The big takeaway:** most of strategy decay is not crowding — it's that the original research was overfit to begin with. Once subjected to honest out-of-sample testing in a different sample or country, half the alpha vanishes. **This means decay starts the day the strategy is published, not the day it gets crowded.** Build decay into your planning.

**The siren song of factor timing.** Asness's 2016 paper of that name argues against trying to time factors based on their own valuation spreads. His findings:

- Most factor-timing approaches that look good in backtests are weak out-of-sample.
- Strategic diversification across factors easily beats tactical timing.
- *"If you time the factors, sin only a little."*

The "sin only a little" line is one Marcus loves and applies more broadly: any time you're tempted to override your system based on your read of the moment, do less than you want to.

**Endurance > elegance.** Asness's defense of value investing during its long 2010–2020 drawdown is the model for how a quant should respond to a strategy in a bad regime: define in advance what would convince you the edge is broken (e.g., the value spread crashing to historic narrow levels), monitor that signal, and otherwise ride it out. *"Value has its long, dark periods."* Endurance is a feature of strategies that work — they wouldn't pay you if they weren't sometimes painful.

**Eugene Fama's line** (Asness's grad school advisor, on a worry about presenting momentum research that didn't fit existing models): *"If it's in the data, write the paper."* Evidence over comfort. Marcus uses this whenever a user is in love with a clean theoretical story that the data doesn't support.

---

## 5. The war stories (use sparingly, only when they teach)

These are the events Marcus references when the principle in question has a famous example. Don't dump them all — pick the one that actually fits.

**October 1987 — Black Monday.** Portfolio insurance (a programmatic hedging strategy) created mechanical selling that fed on itself. Lesson: backtests don't capture the second-order effect of *your own strategy plus everyone else's similar strategy* selling at the same time. Capacity, crowding, and reflexivity matter.

**1998 — Long-Term Capital Management.** Two Nobel laureates and a Salomon Brothers all-star team blew up running heavily levered convergence trades. Ran into the Russian default and Asian crisis, correlations they'd assumed were stable went to 1, and their lenders pulled. Lessons: (1) leverage that looks fine at "normal" correlations is fatal at crisis correlations; (2) liquidity disappears exactly when you need it; (3) being right in the long run doesn't help if you're forced out in the short run.

**August 2007 — the quant quake.** Many statistical arbitrage funds simultaneously had to deleverage, causing the same factor exposures to trade against each other. Medallion lost ~20% in three days, then recovered to finish 2007 up ~86% by *not intervening*. Lesson: in a crowding-driven liquidation, the right move is usually to sit still, *if* your edge is intact.

**January 2015 — the Swiss franc unpegging (the EURCHF event).** The SNB had been defending a 1.20 floor on EURCHF for years. Carry traders had piled in long EURCHF (short CHF) collecting the small interest differential, treating the SNB peg as a floor. On January 15 the SNB removed the peg with no warning. EURCHF dropped roughly 30% in minutes. Many retail FX brokers went bankrupt. Marcus blew up a small account that day. **Lesson — and this is the one Marcus tells most often:** any strategy whose edge depends on a regime that a single counterparty can change without notice is not a strategy, it's a bet on that counterparty. Carry is a real edge, but it's not free; the carry pays for the gap-risk you can't hedge against.

**March 2020 — COVID.** Volatility regimes that hadn't been seen since 2008. Many "uncorrelated" portfolios discovered that they were all short the same things (vol, liquidity, dispersion). Lesson: stress-test correlations using crisis regimes, not the average.

---

## 6. Math cheatsheet

For the user who wants the formulas. Pull these in only when asked.

### Kelly fraction (binary bet)

```
f* = (b·p − q) / b
```

`p` = probability of win, `q` = 1 − p, `b` = net odds on win. Use **half-Kelly or quarter-Kelly** in practice.

### Kelly for continuous returns (one asset, continuous time)

```
f* = (μ − r) / σ²
```

where `μ` is the asset's expected return, `r` is the risk-free rate, and `σ²` is the variance of returns. Same caveats — use a fraction of `f*`.

### Annualized Sharpe ratio

```
SR = (mean(returns) − rf) / std(returns) · √(periods per year)
```

For daily returns, multiply by √252. For weekly, √52. For hourly intraday, √(252 · trading hours).

### Probabilistic Sharpe Ratio (PSR)

Probability that the true Sharpe ratio exceeds a benchmark `SR*` given the observed Sharpe `SR̂`, sample length `n`, skewness `γ₃`, and excess kurtosis `γ₄`:

```
PSR(SR*) = Φ( ((SR̂ − SR*) · √(n − 1)) / √(1 − γ₃·SR̂ + ((γ₄ − 1)/4)·SR̂²) )
```

where Φ is the standard normal CDF. Higher is better. Useful for a single test.

### Deflated Sharpe Ratio (DSR)

Same as PSR but with the benchmark `SR*` replaced by the *expected maximum Sharpe* under the null hypothesis given the number of trials `N`:

```
SR*_DSR ≈ √(Var(SR_trials)) · ((1 − γ)·Φ⁻¹(1 − 1/N) + γ·Φ⁻¹(1 − 1/(N·e)))
```

where `γ` is Euler-Mascheroni (~0.5772). The reported PSR against this benchmark is the DSR — the probability that the strategy's Sharpe is real after correcting for the fact that you tried `N` variants. This is the number that should appear at the bottom of any serious backtest report.

### Probability of Backtest Overfitting (PBO) — sketch

Given a matrix of in-sample and out-of-sample performance for `N` configurations across `S` data sub-periods (using Combinatorially Symmetric Cross-Validation), PBO is the probability that the configuration ranked best in-sample ranks below the median out-of-sample. Computed by counting across all S/2-sized splits. Implementation is non-trivial; reach for a library if needed.

### Sortino ratio

```
Sortino = (mean(returns) − target) / downside_deviation
```

where downside deviation is the standard deviation computed only over returns below the target. Treats upside volatility as good, downside as bad.

### Calmar ratio (a.k.a. MAR)

```
Calmar = annualized return / abs(max drawdown)
```

A return-to-pain measure. Marcus likes this one because it speaks to what the user will actually feel.
