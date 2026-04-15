# algo-trading-veteran

A Claude skill that channels **Marcus**, a battle-scarred systematic trader with 15+ years of running his own book across equities, futures, FX, and crypto perps. Marcus helps you interrogate edge theses, design honest backtests, decide whether to add a feature to your model, size positions like an adult, and give a plain go/iterate/kill verdict on strategy ideas — in character, without hype, and without ever promising returns.

The persona is built on the durable ideas of Jim Simons / Renaissance (ensembling, capacity discipline, hands-off execution), Ed Thorp (edge-first, fractional Kelly, drawdown discipline), Marcos López de Prado (Deflated Sharpe, PBO, Combinatorial Purged Cross-Validation), and Cliff Asness / AQR (factor decay, "sin only a little," endurance over elegance).

## What it's good for

- Critiquing a backtest you already have ("is this any good?")
- Designing a backtest the right way before you waste a month on it
- Deciding whether a new feature / signal / filter actually adds value or just overfits
- Position sizing and risk framework for a strategy you've built
- Honest advice when you're staring at a live drawdown and tempted to retune
- Working through edge theses on idea-stage strategies
- Spotting the red flags in your own setup before the market does

## What it won't do

- Hand you a "profitable strategy" to copy-paste
- Recommend specific tickers, trades, or entries
- Promise returns or validate 50% / year claims
- Give regulated investment, legal, or tax advice
- Help build anything designed to manipulate markets

If you ask for a strategy directly, Marcus will redirect you to building one yourself — not as a principle, but because a strategy you didn't build, you can't debug, can't size, and won't trust through a drawdown.

## Structure

```
algo-trading-veteran/
├── README.md               ← this file
├── LICENSE                 ← MIT
├── SKILL.md                ← the skill itself (always in context when the skill triggers)
└── references/
    ├── examples.md         ← four worked dialogues showing Marcus's voice
    └── lineage.md          ← deep material on Simons, Thorp, López de Prado, Asness,
                              war stories, and the math (Kelly, DSR, PBO formulas)
```

Progressive disclosure: `SKILL.md` stays operational and under 300 lines. The two reference files are loaded on demand — `examples.md` at the start of any substantive trading conversation to calibrate voice, `lineage.md` when the user wants attribution, depth, the "why" behind a principle, or the math behind a formula.

## Installation

### Claude.ai (desktop / web)

1. Download or build the `.skill` package (a zip of the `algo-trading-veteran/` folder).
2. In Claude.ai, go to **Settings → Capabilities → Skills** and upload the `.skill` file.
3. The skill will trigger automatically when you bring up anything trading-strategy-related.

### Claude Code / API

Place the `algo-trading-veteran/` folder wherever your project loads skills from. The `name` and `description` in the SKILL.md frontmatter handle triggering.

### Building the .skill package yourself

A `.skill` file is just a zip of the skill folder. From the parent of `algo-trading-veteran/`:

```bash
zip -r algo-trading-veteran.skill algo-trading-veteran/
```

Or use Anthropic's skill-creator packaging script if you have it available.

## The persona in one paragraph

Marcus started on a futures desk in 2008, went independent in 2014, and has been running his own book ever since. He's had 50–80% years and years where he gave most of it back. He blew up exactly one account (2015, EURCHF unpeg, levered FX carry — he still brings it up). He now runs a small fund of his own capital, mostly futures and crypto perps, with a couple of equity stat-arb books on the side. He's direct, dry, allergic to hype, generous with knowledge, and would rather kill a bad idea in five minutes than let you waste a month on it.

## Design notes

A few decisions worth flagging for anyone reading the source:

- **Voice is treated as first-class.** There's a whole "voice failure modes" section in SKILL.md enumerating the LLM defaults that destroy the persona (bullet salad, sycophancy, hedging mush, "it's not just X it's Y," sign-offs). Without it, the persona drifts within a few turns.
- **Examples are the highest-leverage piece.** `references/examples.md` contains four full worked dialogues written in Marcus's actual voice. SKILL.md tells the model to load them at the start of any substantive conversation. A model can read fifty rules about voice and still drift; one good example to imitate keeps it on rails for a whole conversation.
- **The "give me a strategy" handler is explicit.** Users will absolutely ask. The skill doesn't just say "no" — it specifies the three-part redirect (name why, offer what Marcus will do instead, ask the wedge question: *"is there a behavior you've noticed in that market that you can't quite explain?"*).
- **Decay is treated as the base case**, not a footnote. Roughly half of a published anomaly's Sharpe vanishes after publication. Strategies are products with shelf lives, not monuments.
- **The 50–80% return claim in the persona is handled honestly.** Marcus acknowledges it's possible at small capital in friendly regimes, refuses to promise it, and warns against anyone selling it. Otherwise the skill becomes a hype machine and gives bad advice.
- **Crypto perps get specific treatment** (funding as P&L, basis trades, exchange counterparty risk, liquidation cascades, token survivorship) because the persona supposedly trades them and it would feel fake otherwise.

## Not included, deliberately

- Specific code snippets or library tutorials — dates fast, contradicts the "build it yourself" principle.
- Options pricing, Greeks, vol surfaces — Marcus is a directional / stat-arb trader, not an options market-maker. Pretending otherwise would weaken the voice by making him a generalist.
- A list of "strategies to try" — handing out recipes contradicts the edge-first principle the whole skill is built on.

## Testing it

The fastest way to know whether the skill is working:

1. Ask Marcus to give you a profitable strategy. He should redirect without lecturing.
2. Hand him a backtest with a suspiciously clean Sharpe. He should ask about parameter search count, costs, regime coverage, and data provenance before commenting on the number.
3. Tell him you're in a 3-month drawdown and want to retune. He should tell you not to, and walk you through the bootstrap-test → halt → re-research sequence.
4. Ask whether a new feature is worth adding. He should run it through the five gates (rationale, orthogonality, OOS lift, stability, cost of complexity) and default to "no" when in doubt.

If any of these feel off in the actual responses, the skill is drifting and the first thing to check is whether `references/examples.md` is being loaded.

## License

MIT. See `LICENSE`.
