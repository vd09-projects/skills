# Go — Generic Patterns

Generic Go patterns for any well-engineered Go codebase. Load when writing or reviewing Go code, making structural calls about package boundaries, or when the user asks "how should I structure X in Go."

These are not domain-specific. Domain conventions (what types to use for domain values, what the event loop should look like, etc.) belong in `domain.md`. These are the baseline any Go codebase should meet.

---

## Error handling

Every error is wrapped with context using `%w`. The context string names the operation and any variable that identifies *which* call failed:

```go
if err := db.QueryRow(ctx, query, id).Scan(&user); err != nil {
    return nil, fmt.Errorf("fetch user %d: %w", id, err)
}
```

The context string is a phrase, not a sentence. No capital letters, no period, no "error:" prefix — those appear when the error chain is printed and would create double-prefixes.

Bare `return err` is never right. It loses the call site.

Wrapping that adds no information (`fmt.Errorf("error: %w", err)`) is also wrong — it adds noise without signal.

Sentinel errors for callers who need to distinguish:

```go
var ErrNotFound = errors.New("not found")

// Return it:
return nil, fmt.Errorf("user %d: %w", id, ErrNotFound)

// Check it:
if errors.Is(err, ErrNotFound) { ... }
```

---

## Context

`context.Context` is the first parameter of any function that does I/O, blocks, or depends on a deadline. Not embedded in a struct. Not threaded through a global.

```go
func (s *Store) Get(ctx context.Context, id int64) (*User, error)
```

The function propagates the context down. It does not call `context.Background()` internally when a ctx was passed in — that discards the caller's deadline and cancellation.

`context.WithTimeout` wraps external calls that don't respect the parent context:

```go
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()
resp, err := client.Get(ctx, url)
```

---

## Interfaces

Defined at the consumer, not the producer. The package that uses the interface declares it; the package that implements it doesn't know about it.

```go
// In package store — the consumer:
type UserReader interface {
    Get(ctx context.Context, id int64) (*User, error)
}

// In package postgres — the producer:
// Implements UserReader without importing it.
type Store struct { ... }
func (s *Store) Get(ctx context.Context, id int64) (*User, error) { ... }
```

Small interfaces preferred. One to three methods. A five-method interface is often two interfaces that got merged. If an interface is only ever satisfied by one type, it probably shouldn't be an interface.

Accept interfaces, return concrete types. Callers can decide what level of abstraction they want to wrap the concrete in; they can't unwrap an interface.

---

## Structs

Named fields, always. Positional struct literals are a maintenance trap:

```go
// Wrong — breaks if fields reorder:
u := User{"Alice", "alice@example.com", 30}

// Right:
u := User{Name: "Alice", Email: "alice@example.com", Age: 30}
```

Zero values should be meaningful where possible. A struct that panics on zero value is a footgun. If zero value is intentionally invalid, document it.

Constructor functions (`New*`) for structs that require validation or have non-obvious initialization:

```go
func NewStore(cfg Config) (*Store, error) {
    if cfg.DSN == "" {
        return nil, errors.New("DSN is required")
    }
    return &Store{dsn: cfg.DSN}, nil
}
```

---

## Concurrency

**Goroutines need shutdown paths.** Every goroutine launched has one of: context cancellation, channel close, or WaitGroup signal. A goroutine that runs forever with no way to stop is a leak.

```go
go func() {
    defer wg.Done()
    for {
        select {
        case <-ctx.Done():
            return
        case msg := <-ch:
            process(msg)
        }
    }
}()
```

**errgroup for parallel work that can fail:**

```go
g, gctx := errgroup.WithContext(ctx)
for _, item := range items {
    item := item // capture
    g.Go(func() error {
        return process(gctx, item)
    })
}
if err := g.Wait(); err != nil {
    return err
}
```

**Write to pre-allocated slice at fixed index** when results need to be in input order:

```go
results := make([]*Result, len(items))
for i, item := range items {
    i, item := i, item
    g.Go(func() error {
        r, err := process(gctx, item)
        results[i] = r   // safe — each goroutine owns one index
        return err
    })
}
```

**Mutexes protect state.** Channels communicate. If you're using a channel to protect shared state, use a mutex instead.

**`time.Now()` in testable code is banned.** Inject a clock:

```go
type Clock interface{ Now() time.Time }
type RealClock struct{}
func (RealClock) Now() time.Time { return time.Now() }
```

---

## Package structure

Packages by responsibility, not by type. `handlers/`, `services/`, `repositories/` organizes by layer — every feature touches all three. `user/`, `payment/`, `catalog/` organizes by domain — a feature stays in one package.

`internal/` for code that shouldn't be imported by other modules. Use it freely within a module to enforce package boundaries without creating an external API.

No circular imports. If A imports B and B needs something from A, the shared thing belongs in a third package C.

Package names: lowercase, no underscores, no stutter (`user.User` not `user.UserType`).

---

## Testing

**Table-driven tests** for anything with multiple cases:

```go
func TestValidate(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        wantErr bool
    }{
        {"empty string", "", true},
        {"valid", "alice@example.com", false},
        {"no at-sign", "aliceexample.com", true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := validate(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("validate(%q) err = %v, wantErr %v", tt.input, err, tt.wantErr)
            }
        })
    }
}
```

**`cmp.Diff` for assertions** — clear failure messages that show what changed, not just "not equal":

```go
if diff := cmp.Diff(want, got); diff != "" {
    t.Errorf("mismatch (-want +got):\n%s", diff)
}
```

**Fakes over mocks.** Write a small in-memory implementation of the interface. It's a working implementation that's fast and doesn't break on refactor.

**`t.Helper()`** in helper functions so error lines point to the caller, not the helper.

**`t.Parallel()`** where tests are independent and don't share global state. Parallel tests catch data races.

No testify, no gomock, no ginkgo. stdlib `testing` + `go-cmp` covers everything.

---

## Common libraries

| Purpose | Library | Notes |
|---|---|---|
| Structured logging | `log/slog` | stdlib since Go 1.21 |
| Parallel work | `golang.org/x/sync/errgroup` | standard |
| Deep equality in tests | `github.com/google/go-cmp/cmp` | better than reflect.DeepEqual |
| YAML config | `gopkg.in/yaml.v3` | — |
| CLI (complex) | `github.com/spf13/cobra` | only with multiple subcommands |
| HTTP client | `net/http` | stdlib; always set explicit timeouts |

Default: stdlib first. Reach for a library when stdlib genuinely doesn't cover it, not when a library is slightly more convenient.

No global mutable state. No `init()` except for driver registration (`database/sql`, `image/png`).

---

## Linting

- `errcheck` — errors must be handled
- `wrapcheck` — external errors must be wrapped
- `cyclop` or `gocognit` — complexity ceiling ~15
- `funlen` — functions over 80 lines warn
- `godot` — exported comments end with period
- `exhaustive` — switch on enum must handle all cases
- `nolint` comments require a justification comment on the same line

Fix the code, don't suppress the linter. If suppression is necessary, document why.

---

## Quality gate extensions

These extend the generic gates in `quality-gates.md` for Go specifically. Both sets must pass before `Ready for review.`

- **Errors wrapped with `%w`** — use `fmt.Errorf("operation %s: %w", name, err)`. No bare `return err`. Wrapping is what makes `errors.Is` / `errors.As` work up the call chain.
- **No `time.Now()` in testable code** — inject a `Clock` interface; tests pass a `FakeClock`. Functions that call `time.Now()` directly can't be tested deterministically.
- **Every goroutine has a shutdown path** — context cancellation, channel close, or WaitGroup. Goroutines that never stop are leaks.
- **`context.Context` first parameter** on any function doing I/O. Never embedded in a struct, never created internally when a ctx was passed.
- **Magic values as named constants or `time.Duration` expressions** — `86400` is not a timeout; `24 * time.Hour` is.
- **No `fmt.Println` / `log.Print` debug output** left in production code — use `slog` with appropriate level.
- **Named struct fields in literals** — positional struct literals break silently on field reorder.
- **Map iteration is sorted if output order matters** — Go's `range` over a map is intentionally randomized; sort keys before iterating for any deterministic output.
