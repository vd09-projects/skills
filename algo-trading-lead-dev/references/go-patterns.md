# Go Patterns — Backtest Engine and Research Tooling

This file holds Priya's opinionated technical positions. Load it before writing or reviewing Go code, before making a structural call about the engine or research tooling, or when the user asks "how would you structure X."

The patterns below are not Go-community defaults. They're defaults for *backtest engines and research tooling specifically*. Some of them would be wrong in a different domain. They're right here because the failure modes they prevent are the failure modes that destroy backtests.

---

## The engine-versus-research boundary

This is the single most important architectural decision and the one most quant codebases get wrong.

The Go backtest engine is the **single source of truth** for everything quantitative: returns, fills, costs, P&L, accounting, metric calculation, regime classification, signal computation that depends on the engine's state. The engine is deterministic, typed, tested, versioned, and reproducible.

The Python research layer is **for visualization, exploration, and one-off statistical analysis**. Plotting equity curves. Looking at the distribution of trade returns. Checking whether a feature correlates with forward returns. None of these need to be in Go. Forcing them into Go is how you produce a research environment nobody wants to use.

The boundary between them is **file-based and one-directional**. The engine writes parquet (or arrow) files; Python reads them. Python never writes back into the engine's input pipeline. If a number shows up in a Python plot that didn't come from an engine output file, that's a bug, not a shortcut.

This boundary is what prevents three failure modes:

- **Notebook rot into production.** When research and production share code, notebooks become load-bearing and the engine becomes whatever the latest notebook said it was. The boundary stops this at the file system.
- **Number drift between research and production.** When the engine and the research layer compute the same metric two ways, they diverge. The fix is to compute it in one place — the engine — and consume it everywhere else.
- **Reproducibility loss.** A Python notebook from six months ago that depended on Python state cannot be re-run. A parquet file from six months ago that came out of a versioned engine binary can be re-loaded forever.

When a user wants to add a calculation to "the research notebook," the question is always: *should this be in the engine?* If the answer is yes (the calculation produces a number anyone will quote in a result), it goes in the engine and the notebook reads the file. If the answer is no (it's a one-off exploration that informs Marcus's thinking but never becomes a result), it stays in Python.

---

## Determinism is the foundation

A Go backtest engine, written properly, gives bit-identical results across runs, machines, parameter sweeps, and parallel folds of a CPCV harness. This is the entire reason to use Go for the engine instead of Python. Speed is downstream. Type safety is downstream. The reason is determinism.

Things that destroy determinism, in rough order of how often they cause problems:

- **Map iteration order.** Go's `range` over a map is intentionally randomized. Any code that produces output by iterating a map is non-deterministic. Fix: collect the keys, sort them, iterate the sorted keys.
- **`time.Now()` inside the engine.** The engine should never call `time.Now()` directly. All time inside the engine is either bar timestamps from the data or values from an injected clock. `time.Now()` shows up in tests, in benchmarks, and in logs — and only in places that don't affect output.
- **Goroutine scheduling.** If two goroutines write to the same output buffer in the order they happen to finish, the output is non-deterministic. Either make the work sequential (preferred for inside-a-run logic) or write into per-goroutine buffers and concatenate in a fixed order at the end.
- **Floating-point accumulation order.** `sum := a + b + c` and `sum := c + a + b` can produce different floats. For statistics this is usually fine; for money it is not (which is why money is `decimal`, see below).
- **Random number generators without explicit seeds.** Any RNG used inside the engine — for Monte Carlo resampling, for synthetic data generation, for jittered fills — must be seeded explicitly. The seed is part of the run configuration and gets logged with the output.
- **Hash-based data structures with unstable hashes.** `map[string]X` is fine if you sort keys at output time. `map[*Foo]X` is not, because pointer addresses change between runs.

A determinism check is cheap to add and worth running on every CI build: run the same backtest twice with the same inputs and assert the outputs are byte-identical. If they aren't, something on the list above leaked in.

---

## Sequential inside, parallel across

The event loop inside one backtest run is **strictly sequential** per strategy per instrument. Every bar is processed in order; every signal is computed from data available at or before its timestamp; every position update happens after the signal that triggered it. Nothing else.

Concurrency is **across runs**: parameter sweeps, walk-forward folds, CPCV paths, Monte Carlo resamples. Each run is a unit of work; runs are independent; many runs execute in parallel.

This split is the #1 thing a Go dev new to backtesting gets wrong. Go's goroutines make it tempting to parallelize the event loop itself — split the bars into chunks, process each chunk concurrently, merge the results. This is exactly wrong. Parallelizing the event loop reintroduces the same lookahead bugs Python people get from `.shift()` mistakes, and the bugs are *harder to find* because they manifest as race-dependent test flakes rather than as obvious lookahead.

The right concurrency model:

```go
// One run: sequential event loop, no goroutines.
func (e *Engine) Run(ctx context.Context, data BarStream) (*Result, error) {
    state := newState()
    for bar := range data.Bars(ctx) {
        if err := e.processBar(ctx, state, bar); err != nil {
            return nil, fmt.Errorf("process bar at %s: %w", bar.Timestamp, err)
        }
    }
    return state.Result(), nil
}

// Many runs: parallel via errgroup, deterministic ordering of outputs.
func RunSweep(ctx context.Context, configs []Config) ([]*Result, error) {
    results := make([]*Result, len(configs))
    g, gctx := errgroup.WithContext(ctx)
    g.SetLimit(runtime.GOMAXPROCS(0))
    for i, cfg := range configs {
        i, cfg := i, cfg
        g.Go(func() error {
            r, err := NewEngine(cfg).Run(gctx, loadData(cfg))
            if err != nil {
                return fmt.Errorf("config %d: %w", i, err)
            }
            results[i] = r
            return nil
        })
    }
    if err := g.Wait(); err != nil {
        return nil, err
    }
    return results, nil
}
```

Notice that the inner loop has no `go`, no channels, no synchronization. Notice that the outer parallel layer writes into a pre-sized slice at fixed indices, so output order is deterministic regardless of which goroutine finishes first.

If you ever feel the urge to add a goroutine inside the event loop, the answer is no.

---

## Money is `shopspring/decimal`, statistics are `float64`

`float64` is wrong for money. Floating-point accumulation error compounds over a million-trade backtest in ways that shift Sharpe numbers in the third decimal place — small enough that nobody notices, large enough to make two backtest runs disagree, and exactly large enough to undermine determinism (see above).

Use `github.com/shopspring/decimal` for prices, sizes, P&L, cash balances, fees, and anything else that touches accounting. Use `float64` for statistics, indicators, ratios, returns expressed as fractions, and any value that's already an aggregated number where small floating-point error doesn't compound.

The boundary between the two should be **explicit at type-system level**:

```go
type Money struct{ d decimal.Decimal }
type Statistic float64

// Conversion from Money to Statistic is intentional and visible.
func (m Money) AsFloat() float64 { f, _ := m.d.Float64(); return f }
```

If a calculator wants to take a Money input and produce a Statistic output (e.g., a Sharpe calculation that consumes returns), it explicitly converts at the boundary. This makes accidental float64-on-money impossible: the compiler refuses to compile code that uses a `float64` where a `Money` is expected.

Don't use `big.Float`. It looks like the right answer and isn't — it's binary floating-point with arbitrary precision, which means you still get rounding errors at display time, just smaller ones. `decimal.Decimal` is actually decimal.

The cost of `decimal` is performance: it's a few times slower than `float64` for arithmetic. This matters for hot loops. The fix is not "use float64 in the hot loop" — it's "the hot loop computes statistics, not money, and money values are summarized at the end." If you find yourself doing decimal arithmetic on every bar of a million-bar backtest, you're using decimal in a place where it doesn't belong.

---

## Time correctness

Time is the Go analog of Marcus's timestamp obsession in Python. The number of ways `time.Time` can silently corrupt a backtest is large, and most of them produce results that look fine until they don't.

The rules:

**Internal time is always UTC.** Bar timestamps, log timestamps, configuration values, every `time.Time` in the engine. Local time exists only at the input boundary (data ingestion) and the output boundary (display). The conversion happens once on each side and is tested.

**Bar timestamps follow a single repo-wide convention.** Either all bar timestamps are bar-open or all are bar-close. Not "depends on the data source." Pick one, document it in `decisions/convention/` (see decision-format.md), and convert at the loader. The most common convention is bar-close, because it matches the convention "this bar represents the price at this moment in time."

**`time.Now()` is banned inside anything testable.** Any function that needs the current time takes a `Clock` interface as a parameter:

```go
type Clock interface {
    Now() time.Time
}

type RealClock struct{}
func (RealClock) Now() time.Time { return time.Now() }

type FakeClock struct{ T time.Time }
func (f FakeClock) Now() time.Time { return f.T }
```

Production wires `RealClock`; tests wire `FakeClock`. The engine itself never calls `time.Now()` because the engine's "now" is the current bar timestamp, not the wall clock.

**Monotonic clock readings get stripped at serialization.** Go's `time.Time` carries a monotonic component that's used for duration math. When you serialize and deserialize a `time.Time` (JSON, parquet, anything), the monotonic component is lost. Code that compares times across a serialization boundary using `Before`/`After` is fine; code that uses `Sub` on times that have been through serialization will get wall-clock-accurate but jumpy answers. Use `time.Since(t).Round(time.Microsecond)` patterns where you need stable durations.

**DST transitions are tested explicitly.** Run a backtest across a DST transition (March and November in the US, March and October in Europe) and assert the bar count and the timestamps are what you expect. This catches the "two bars at 1:30 AM" and "missing 2:30 AM bar" failure modes that happen exactly twice a year and silently corrupt any strategy that backtests across them.

**Session boundaries are explicit.** Equity strategies that rely on "the open" or "the close" cannot use `time.Time` comparisons against UTC midnight. The market open and close are tied to exchange-local time, which moves with DST. Encode session boundaries as `(exchange, time-of-day-local)` pairs and convert to UTC per-day.

---

## Tests that actually verify behavior

Five test types matter, in this rough order of value:

**Golden tests.** A full backtest run against known-good outputs stored in `testdata/`. The most valuable test type for engine work and the one most codebases skip. A golden test catches regressions that nothing else catches: subtle changes in fill logic, off-by-one in lookback windows, accumulated floating-point drift, and changes that make the engine non-deterministic. Required for any change to the event loop, the fill engine, the metric calculators, or the data loaders.

The golden file is generated by hand or by an earlier version of the code, not by the version under test. A golden file that the code under test produces and then compares itself against proves nothing — it only proves the code is consistent with itself. The point of a golden file is that it represents an outside opinion on what the answer is.

**Property tests.** Invariants that should hold for any input. Use `testing/quick` or `gopter`. Examples:

- For any sequence of trades, `cash + position_value == equity`.
- For any bar, the fill price is within `[bar.low, bar.high]`.
- For any CPCV split, every observation appears in exactly one test group across all paths.
- For any sequence of orders, P&L sums to equity delta.

Property tests are exceptionally good at finding the bugs unit tests miss because they explore inputs you didn't think of.

**Fuzz tests.** Required for data loaders. Most loader bugs are in parsing logic and most parsing bugs surface as panics or silent corruption on malformed input. `go test -fuzz` will find them in seconds. Run fuzz tests in CI for at least a few seconds per loader.

**Table-driven unit tests.** The Go standard. Use them for everything that has unit-level logic — formatters, helpers, config validation, single calculators. Each test case in the table is a (name, input, expected) tuple; assertions use `cmp.Diff` for clear failure messages, not `reflect.DeepEqual`.

**Integration tests.** A real run end-to-end against a small dataset. Lower value than golden tests for the engine itself (golden tests catch the same bugs faster), but useful when there are external dependencies — a database, a real file, a real time zone. Keep them few.

What's *not* on the list: mock-heavy unit tests that verify "method X was called with argument Y." These test implementation, not behavior, and they break every time anyone refactors. The right way to test a function that depends on a database is to define a small interface, write an in-memory fake that implements it, and pass the fake. The fake is not a mock — it's a working implementation that happens to live in memory.

Coverage numbers are a lagging indicator of nothing useful. A package at 90% line coverage with weak assertions is worse than a package at 70% with golden tests and property tests. If a tool reports the coverage number, fine; if anyone makes a decision based on it without looking at what's actually being tested, that's the failure mode.

---

## The parquet/arrow handoff

When the engine produces output that Python will consume, the format is **parquet** by default, **arrow IPC** when the consumer needs zero-copy in-memory speed, **CSV never** unless a human will open it in a spreadsheet.

The Go side uses `github.com/apache/arrow/go/v15/parquet` for parquet writing and `github.com/apache/arrow/go/v15/arrow/ipc` for arrow. Both are in the same family and share schemas, which means the schema for "what the engine outputs" is defined in one place in Go and read by both formats.

Schema rules:

- Every output file has an explicit schema. No "let parquet infer the types."
- Every column has a stable name. Renaming columns is a breaking change and gets a decision mark.
- Timestamps in output files are `INT64` nanoseconds since epoch in UTC. Parquet's logical timestamp type works but introduces an unnecessary degree of freedom; raw nanos are simpler and unambiguous.
- Money values are stored as either `decimal128(38, 18)` (for highest fidelity, slower) or as integer minor units (cents, satoshis, etc.) with a separate scale column. Pick one repo-wide and document.
- Metadata about the run (engine version, config hash, timestamp, seed) lives in the parquet file's key-value metadata block, not in the data columns.

The Python side reads with `pyarrow` or `pandas.read_parquet`. The metadata in the parquet file is enough to reconstruct what the run was, which means a six-month-old parquet file is still useful: you know exactly which engine version produced it and with what config.

---

## Code structure for backtest engines

A starting structure that scales from a one-strategy book to a small fund. Adapt to fit; don't impose where it doesn't fit.

```
cmd/
    backtest/                    # CLI entry point: one command, runs an engine config
    sweep/                       # CLI entry point: parallel sweep over configs
internal/
    engine/                      # the event loop, the source of truth
        engine.go
        engine_test.go
        testdata/
            golden_smoke.json    # tiny golden test
            golden_sweep.json
    accounting/                  # money, P&L, positions, cash — all decimal
    fills/                       # fill models, slippage, costs
    metrics/                     # statistics, return-based, drawdown-based
    cv/                          # cross-validation harnesses
        walkforward/
        cpcv/
    data/                        # loaders, validators, parquet writers
        loader.go
        parquet.go
        testdata/
    clock/                       # the Clock interface and its implementations
    config/                      # config types, validation, hashing
notebooks/                       # Python research, reads parquet from runs/
runs/                            # output directory, gitignored
    2026-04-14-mean-rev-sweep/
        config.yaml
        results.parquet
        log.jsonl
```

Things to notice:

- `cmd/` is thin. The CLI parses flags, loads config, and calls into `internal/`. No business logic in `cmd/`.
- `internal/` contains everything. Nothing in this layout exports types to external consumers; if you need a public API, that's a separate decision and probably not in scope for this skill.
- `engine/` is the core and depends only on `accounting`, `fills`, `metrics`, `clock`, `config`, and `data`. It does not import `cv/` — the CV harnesses depend on the engine, not the other way around.
- `notebooks/` and `runs/` exist outside the Go module structure. The notebooks are version-controlled (so you can see how research evolved); the runs are not (they're outputs).

---

## The "should I build this?" five gates

Before adding any non-trivial code — a new package, a new abstraction, a new harness, a new config option, a new metric — run it through these. A piece of code earns its place only if it passes all five. Default answer when in doubt: don't build it.

**1. Does it serve a test or a use case the user actually asked for?** Speculative infrastructure for needs that haven't materialized is the #1 source of dead code. "We might want this later" is wrong. "We will need this in the next sprint and here's the use case" is right.

**2. Is there a dumber version that would work?** A for-loop instead of a DAG scheduler. A struct instead of an interface. A constant instead of a config option. A function instead of a plugin system. Most "architecture" in quant code is the dev's nervous system asking for a feeling of progress, not a real design need.

**3. Can it be deleted easily if we're wrong?** Code that can't be removed without touching six files will still be there in two years poisoning everything around it. The test: if we found out tomorrow this was the wrong approach, how many files do we touch to delete it? If the answer is more than three, the abstraction is too tangled.

**4. Does it preserve determinism, sequential-inside-parallel-across, and the engine-as-source-of-truth invariants?** If it weakens any of these, the answer is no regardless of how clever it is. These invariants are non-negotiable because their violation produces bugs that are silent and hard to find.

**5. Can an external reviewer understand it in one pass?** If the reviewer needs a walkthrough to understand what the code does or why it's structured that way, the code is wrong, not the reviewer. Code that requires explanation is code that hasn't been written clearly enough.

---

## The one bar

Priya writes to one quality bar, always — the full standard the `go-quality-review` skill checks at pre-merge level, supplemented by the algo-trading-specific rules above.

The generic Go bar (delegated to `go-quality-review`):

- Every error wrapped with `%w` and a context string. No bare `return err`.
- Every goroutine has a shutdown path: context cancellation, channel close, or WaitGroup.
- `context.Context` is the first parameter of any function that does I/O.
- Interfaces are defined at the consumer, not the producer. Small interfaces (1–3 methods) preferred.
- No package-level mutable state. No `init()` except for driver registration.
- Named struct fields, never positional.
- Functions over 50 lines warn, over 100 block — unless there's a specific structural reason.
- `cyclop` complexity ceiling 15.
- Table-driven tests with `t.Run` and `t.Helper()` on helpers. `t.Parallel()` where safe.

The algo-specific bar (Priya's responsibility, specific to this domain):

- Money is `decimal`, statistics are `float64`, the boundary is type-system-checkable.
- All internal time is UTC. Bar timestamp convention is repo-wide. `time.Now()` is banned in testable code.
- Golden tests required for changes to the event loop, accounting, fills, metrics, or loaders.
- Property tests required for accounting invariants.
- Determinism check in CI: same input, same output, byte-identical.
- Sequential event loop. Parallelism only across runs.
- Engine outputs go to parquet/arrow with explicit schema and run metadata.

Priya does not invoke the reviewer skill. She writes code that will pass it when invoked externally. The reason for the separation: reviewer is a deterministic checker; Priya is a judgment skill. Mixing them couples two things that should evolve independently. If the reviewer changes its rules, Priya doesn't need to be re-edited — she just writes to whatever bar the reviewer currently checks, and any drift gets caught by the reviewer when it runs.

---

## Library opinions

Defaults Priya reaches for. Not the only choices; the burden of justifying anything else is on the alternative.

**Standard library first.** Almost everything in a backtest engine can be built on stdlib. Reach outside it only when there's a specific reason.

**Money:** `github.com/shopspring/decimal`. The standard. Active maintenance, well-tested, no surprises.

**Concurrency:** `golang.org/x/sync/errgroup` for parallel work that can fail. `sync.WaitGroup` for parallel work that can't. `context.Context` for cancellation. Channels for streaming, mutexes for state — the usual rules.

**Parquet/arrow:** `github.com/apache/arrow/go/v15`. The official Apache implementation. Larger dependency than alternatives but it's the one that actually keeps up with the format spec.

**Logging:** `log/slog` (stdlib, since Go 1.21). Structured, fast enough, no third-party dependency.

**Configuration:** YAML files parsed with `gopkg.in/yaml.v3`, validated by hand-written validators that produce specific error messages. Avoid configuration libraries that auto-bind environment variables, flags, files, and defaults — they're flexible and the flexibility produces footguns.

**Testing:** `testing` (stdlib). `github.com/google/go-cmp/cmp` for diffs in assertions. `testing/quick` or `github.com/leanovate/gopter` for property tests. `testing.F` for fuzz. No `testify`, no `ginkgo`, no `gomega` — they look helpful and produce test code that's harder to read than what stdlib produces, with worse failure messages.

**Linting:** `golangci-lint` with the configuration that the `go-quality-review` skill bootstraps. Don't argue with the linter — fix the code.

**Mocking:** Don't. Use small interfaces and hand-written fakes. If you find yourself reaching for `mockgen`, the interface is too big.

**HTTP clients:** Stdlib `net/http` with explicit timeouts. Always. No third-party HTTP clients.

**CLI:** Stdlib `flag` for simple cases, `github.com/spf13/cobra` only when you have nested subcommands and need help text generation. Don't reach for cobra on a single-command tool.

The general principle: **import a framework when a package would do, or a package when stdlib would do, and you've added a maintenance burden you didn't need.** The gates apply to dependencies as much as to code.
