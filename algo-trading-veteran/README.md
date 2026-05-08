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
- Crypto perp specifics: funding, basis trades, exchange counterparty risk, liquidation cascades

## What it won't do

- Hand you a "profitable strategy" to copy-paste
- Recommend specific tickers, trades, or entries
- Promise returns or validate 50% / year claims
- Give regulated investment, legal, or tax advice
- Help build anything designed to manipulate markets

If you ask for a strategy directly, Marcus will redirect you to building one yourself — not as a principle, but because a strategy you didn't build, you can't debug, can't size, and won't trust through a drawdown.

## How it pairs with other skills

This skill is one piece of a larger workflow:

- **`algo-trading-lead-dev` (Priya)** — the implementation counterpart. Marcus owns edge, sizing, methodology, evaluation. Priya owns the engine, the code, the research tooling, the data pipelines. They disagree civilly and often.
- **`decision-journal`** — records significant project decisions. Marcus reads recent `algorithm`-category decisions before making related calls so he doesn't contradict prior recommendations. He marks his own decisions inline using the format in `references/decision-marking.md`; the journal harvests them at the end of the conversation. The full format spec lives in the journal skill.
- **`go-quality-review`** — Priya's code reviewer. Not Marcus's concern, but he'll see decisions that touch architecture get marked when they have methodology consequences.

The coupling is loose: Marcus knows the conventions and the format, but he never invokes another skill. Each dependency is optional — Marcus degrades gracefully if any of them is missing.

## Repo structure

```
algo-trading-veteran/
├── SKILL.md                          # main skill file — persona, principles, modes, loading rules
├── README.md                         # this file
├── LICENSE                           # MIT
├── .gitignore
└── references/
    ├── examples.md                   # four worked dialogues — load once per conversation for voice
    ├── lineage.md                    # depth on Simons, Thorp, López de Prado, Asness; war stories; math
    ├── backtest-methodology.md       # how to test, performance metrics, code review, red flags
    ├── edge-and-sizing.md            # the five edge buckets, sizing rules, feature gates, kill-switch
    ├── strategy-lifecycle.md         # psychology, decay, workflow, "give me a strategy" full handler
    ├── crypto-perps.md               # funding, basis, counterparty risk, liquidation cascades
    └── decision-marking.md           # compact inline-decision-mark format reference (~1,000 tokens)
```

### Reference file loading

All reference files load conditionally — only when their specific trigger fires. The default is don't load.

- **`examples.md`** — load **once per conversation** on the first substantive turn for voice calibration. Do not reload unless voice drifts.
- **`lineage.md`** — load when the user wants attribution, depth on a specific figure, or the math behind a formula.
- **`backtest-methodology.md`** — load when reviewing a backtest, auditing code, or asked about methodology or metrics.
- **`edge-and-sizing.md`** — load when evaluating an edge thesis, discussing sizing, running the feature-addition gates, or defining a kill-switch.
- **`strategy-lifecycle.md`** — load when user is in a drawdown, asks for a strategy directly, asks about decay/workflow, or shows behavioral warning signs.
- **`crypto-perps.md`** — load when the conversation specifically involves crypto perps.
- **`decision-marking.md`** — load when recording a decision mark for the first time in a conversation.

## Token efficiency

This skill is designed to load reference files only when their specific triggers fire. Per-conversation cost on routine work is roughly 5,000-9,000 tokens for the first turn (SKILL.md + examples.md + 1-2 reference files depending on the request), then near-zero on follow-up turns. Per-decision marking cost is ~1,000 tokens (loads the compact `decision-marking.md`).

The previous version (v1.0) had a 9,300-token SKILL.md that loaded everything inline plus an imperative loading rule that re-read `examples.md` on every substantive turn. The current version trims SKILL.md to ~3,500 tokens, moves depth to reference files, and uses conditional loading rules.

If Marcus is loading more than expected, check that the loading rules in `SKILL.md` are still being followed — the behavior is sensitive to how those rules are phrased.

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

## Testing it

The fastest way to know whether the skill is working:

1. Ask Marcus to give you a profitable strategy. He should redirect using the three-part move (name why, offer instead, ask the wedge question) without lecturing.
2. Hand him a backtest with a suspiciously clean Sharpe. He should ask about parameter search count, costs, regime coverage, and data provenance before commenting on the number.
3. Tell him you're in a 3-month drawdown and want to retune. He should tell you not to, and walk you through the bootstrap-test → halt → re-research sequence.
4. Ask whether a new feature is worth adding. He should run it through the five gates (rationale, orthogonality, OOS lift, stability, cost of complexity) and default to "no" when in doubt.
5. Paste a crypto perp backtest. He should ask whether you netted out funding before commenting on returns.
6. Make him give you a specific sizing recommendation. He should mark it as an `algorithm`-category decision.

If any of these feel off, the skill is drifting and the first thing to check is whether `references/examples.md` is being loaded on the first substantive turn.

## License

MIT. See `LICENSE`.
