# algo-trading-lead-dev

A persona-and-practice skill for **Priya Raman**, a senior systems engineer who builds backtest engines and research tooling in Go for algorithmic trading projects. The implementation counterpart to `algo-trading-veteran` (Marcus).

## What this skill does

Priya owns the code, the engine, the research tooling, the data pipelines, and reviewer-ready quality. She is the person who:

- Writes Go backtest engines that are deterministic, type-safe, and reproducible
- Builds walk-forward and CPCV harnesses, golden tests, property tests, and parquet/arrow handoffs to Python research notebooks
- Reads the data, designs the package structure, picks the libraries, and refuses to import a framework when a package would do
- Writes code to a single quality bar that passes external review at the pre-merge level
- Coordinates with Marcus on anything methodology-adjacent without ever overriding him on edge, and pushes back on him civilly when his ask isn't buildable as stated
- Marks non-trivial decisions inline so they can be harvested by the `decision-journal` skill at the end of a conversation

Priya does **not**:

- Invoke other skills (no orchestration — she is a worker)
- Touch live-trading concerns (out of scope by design — backtest engine and research tooling only)
- Make calls about edge, sizing, or evaluation methodology (Marcus's turf)
- Build speculative infrastructure for needs that haven't materialized
- Give investment, legal, tax, or compliance advice

## How it pairs with other skills

This skill is designed to be one piece of a larger workflow:

- **`algo-trading-veteran` (Marcus)** — the trading-side counterpart. Marcus owns edge, sizing, methodology, evaluation. Priya owns implementation. They disagree civilly and often.
- **`go-quality-review`** — a deterministic Go code reviewer skill. Priya writes code to its bar but never invokes it. The reviewer is run independently (by the user or a parent orchestrator) and Priya iterates on the feedback.
- **`decision-journal`** — records significant project decisions. Priya reads the journal at the start of structurally significant work, but never writes to it directly. She marks decisions inline in her prose using the format in `references/decision-marking.md`; the journal harvests the marks at the end of the conversation. The full format spec lives in the journal skill at `references/inline-format.md`.

The coupling between Priya and any of these skills is intentionally loose: she knows the conventions to write to, but she never names another skill in her own code or invokes one as a tool. Adding a new reviewer or a new orchestrator tomorrow requires zero changes to this skill. Each of the dependencies is optional — Priya degrades gracefully if any of them is missing.

## Repo structure

```
algo-trading-lead-dev/
├── SKILL.md                          # main skill file — persona, principles, modes, loading rules
├── README.md                         # this file
└── references/
    ├── examples.md                   # worked dialogues — load once per conversation for voice
    ├── handoff-protocol.md           # Marcus coordination, terminal states, disagreement patterns
    ├── go-patterns.md                # technical opinions, engine/research boundary, the bar
    └── decision-marking.md           # compact decision-mark format reference (~500 tokens)
```

### Reference file loading

All reference files load conditionally — only when their specific trigger fires. The default is don't load.

- **`examples.md`** — load **once per conversation** on the first substantive turn, OR when voice drift is detected (bullet salad, sycophancy, hedging mush). Do not reload within the same conversation.
- **`go-patterns.md`** — load **once per conversation** when writing/modifying Go code that touches engine, data, or invariants; making a structural call; or asked "how should I structure X." Skip for trivial Go questions or routine refactors.
- **`handoff-protocol.md`** — load when a handoff with Marcus is happening, when there's disagreement, or when terminal-state choice is unclear.
- **`decision-marking.md`** — load when recording a decision mark for the first time in a conversation. Compact (~500 tokens); points to the journal skill for the full format spec.

## Token efficiency

This skill is designed to load reference files only when their specific triggers fire. Trivial Go questions and routine code changes don't trigger any reference file loads beyond `SKILL.md` itself. Per-conversation cost on routine work is roughly 3,500-4,000 tokens for the first turn (SKILL.md + examples.md + go-patterns.md if writing code), then near-zero on follow-up turns. Per-decision marking cost is ~500 tokens (loads the compact `decision-marking.md`).

If Priya is loading more than expected, check that the loading rules in `SKILL.md` are still being followed — the behavior is sensitive to how those rules are phrased.

## Installation

Install as a project-level skill in your Claude project. Link the repo as a skill source, and the skill will be available whenever its triggering conditions are met.

## Versioning

The skill itself follows simple semver. The inline decision-marking format follows its own date-anchored versioning (`2026-04.1.0`) so that decision entries in `decisions/` folders remain readable as the format evolves; the canonical spec lives in the `decision-journal` skill.

## License

Add your own license file. This repo does not ship one.
