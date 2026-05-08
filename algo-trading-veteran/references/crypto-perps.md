<!-- SCOPE: crypto-perps.md
     Covers: crypto-specific concerns when running strategies on perpetual futures —
     funding rates, basis trades, exchange counterparty risk, liquidation cascades,
     token survivorship, weekend liquidity.
     Does NOT cover: general backtest methodology (see backtest-methodology.md),
     edge thesis evaluation (see edge-and-sizing.md), strategy lifecycle (see
     strategy-lifecycle.md). The general principles all transfer to crypto; only
     the specifics in this file are crypto-particular.
     LOAD WHEN: conversation involves crypto perpetual futures, funding rates,
     basis trades, exchange counterparty risk, or any backtest specifically
     on a crypto venue (Binance, Bybit, OKX, dYdX, Hyperliquid, etc.). -->

# Crypto and Perpetual Futures

Marcus runs a meaningful chunk of his book on crypto perps, and a lot of users showing up with strategies are working in the same space. The general principles all transfer; a few specifics need their own handling.

- **Funding rates are part of your P&L, always.** Long perps pay (or receive) funding every 8 hours on most exchanges. A strategy that's structurally long perps in a contango market is bleeding funding even when the price doesn't move. A strategy that ignores funding in its backtest is wrong, full stop. Marcus's first question on any crypto perp backtest: *did you net out funding?*

- **The basis is a tradable instrument.** Perp-spot basis trades (long spot, short perp, collect funding) are a real, persistent edge — risk-premium harvesting in the carry-trade bucket. They are also crowded and the funding compresses when too many people pile in. Treat the trade like any other carry trade: it pays you to bleed, the bleed is gap risk and exchange risk.

- **Exchange counterparty risk is not theoretical.** FTX (2022) was not a one-off. Any strategy with capital sitting on a single exchange has a single point of failure that no backtest captures. Marcus's rule: spread inventory across exchanges, keep working capital small, sweep profits to cold storage on a schedule.

- **Liquidation cascades break backtests.** Crypto's leverage structure means that during sharp moves, forced-liquidation flow becomes the dominant order flow for minutes at a time. Backtests that assume normal fills during these windows are fiction. A strategy that "works" during the May 2021 or November 2022 cascades on paper almost certainly didn't get the fills it thinks it did.

- **Survivorship in tokens.** The pool of "all crypto tokens that existed in 2018" is not the pool of "all crypto tokens that exist today." Backtesting an altcoin strategy on the current top-100 list is the most extreme survivorship bias Marcus has ever seen, and it's the default mistake.

- **Microstructure is wilder, weekend liquidity is thinner.** Strategies designed for equity-like sessions don't translate. Test on weekend bars explicitly.
