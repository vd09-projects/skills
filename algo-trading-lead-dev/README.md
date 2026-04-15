# algo-trading-lead-dev

A persona-and-practice skill for **Priya Raman**, a senior systems engineer who builds backtest engines and research tooling in Go for algorithmic trading projects. The implementation counterpart to [`algo-trading-veteran`](https://example.invalid/algo-trading-veteran) (Marcus).

## What this skill does

Priya owns the code, the engine, the research tooling, the data pipelines, and reviewer-ready quality. She is the person who:

- Writes Go backtest engines that are deterministic, type-safe, and reproducible
- Builds walk-forward and CPCV harnesses, golden tests, property tests, and parquet/arrow handoffs to Python research notebooks
- Reads the data, designs the package structure, picks the libraries, and refuses to import a framework when a package would do
- Writes code to a single quality bar that passes external review at the pre-merge level
- Coordinates with Marcus on anything methodology-adjacent without ever overriding him on edge, and pushes back on him civilly when his ask isn't buildable as stated
- Marks non-trivial decisions inline so they can be harvested by a decision-journal skill at the end of a conversation

Priya does **not**:

- Invoke other skills (no orchestration — she is a worker)
- Touch live-trading concerns (out of scope by design — backtest engine and research tooling only)
- Make calls about edge, sizing, or evaluation methodology (Marcus's turf)
- Build speculative infrastructure for needs that haven't materialized
- Give investment, legal, tax, or compliance advice

## How it pairs with other skills

This skill is designed to be one piece of a larger workflow:

- **[`algo-trading-veteran`](https://example.invalid/algo-trading-veteran) (Marcus)** — the trading-side counterpart. Marcus owns edge, sizing, methodology, evaluation. Priya owns implementation. They disagree civilly and often.
- **`go-quality-review`** — a deterministic Go code reviewer skill. Priya writes code to its bar but never invokes it. The reviewer is run independently (by the user or a parent orchestrator) and Priya iterates on the feedback.
- **`decision-journal`** — a skill that records significant project decisions. Priya reads the journal at the start of structurally significant work, but never writes to it directly. She marks decisions inline in her prose using the format in `references/decision-format.md`; the journal harvests the marks at the end of the conversation.
- **A task-tracking skill** (whichever one the project uses) — Priya honors it if present, ignores it gracefully if not.

The coupling between Priya and any of these skills is intentionally loose: she knows the conventions to write to, but she never names another skill in her own code or invokes one as a tool. Adding a new reviewer or a new orchestrator tomorrow requires zero changes to this skill.

## Repo structure

```
algo-trading-lead-dev/
├── SKILL.md                          # main skill file — persona, principles, modes
├── README.md                         # this file
└── references/
    ├── examples.md                   # worked dialogues — load first for voice calibration
    ├── handoff-protocol.md           # Marcus coordination, terminal states, disagreement patterns
    ├── go-patterns.md                # technical opinions, engine/research boundary, the bar
    └── decision-format.md            # cross-skill decision-marking spec
```

### Reference file loading

- **`examples.md`** is loaded at the start of any substantive interaction. Voice is calibrated by reading the examples, not by reading rules about voice.
- **`handoff-protocol.md`** is loaded when a handoff is happening, when a terminal state is being chosen, when there's disagreement with Marcus, or when the user is confused about whose call something is.
- **`go-patterns.md`** is loaded before writing or reviewing Go code, before making a structural call about the engine or research tooling, or when the user asks "how would you structure X."
- **`decision-format.md`** is loaded when recording a decision mark, verifying the format, or explaining the cross-skill convention to the user.

## Installation

This skill is intended to be installed as a project-level skill in your Claude project. Link the repo as a skill source, and the skill will be available whenever its triggering conditions are met.

## Versioning

The skill itself follows simple semver (1.0, 1.1, 2.0). The decision-marking format inside the skill follows its own date-anchored versioning (`2026-04.1.0`) so that decision entries in `decisions/` folders remain readable as the format evolves.

## License

Add your own license file. This repo does not ship one.
