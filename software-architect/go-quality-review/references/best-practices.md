# Best practices dimension

This dimension checks adherence to idiomatic Go patterns. These aren't arbitrary style rules — each one prevents a specific category of bug or maintenance problem.

---

## Error handling (checked at standard level and above)

Error handling is the most common source of Go bugs in AI-generated code. Check these carefully.

### Every error must be handled

No error return value should be silently discarded. For every function call that returns an error:

```go
// BAD — silent discard
json.Unmarshal(data, &result)

// BAD — assigned but never checked
err := json.Unmarshal(data, &result)

// GOOD
if err := json.Unmarshal(data, &result); err != nil {
    return fmt.Errorf("unmarshal config: %w", err)
}
```

The only acceptable exception is when a function's error is truly irrelevant (e.g., `fmt.Fprintf` to stdout in a CLI). Even then, use `_ =` with a comment:

```go
_ = fmt.Fprintf(os.Stdout, "done\n") // stdout write failure is non-recoverable
```

### Errors must be wrapped with context

Bare `return err` loses context. Every error return should add information about what was happening when the error occurred:

```go
// BAD — bare return
if err != nil {
    return err
}

// GOOD — wrapped with context
if err != nil {
    return fmt.Errorf("load user %s: %w", userID, err)
}
```

Use `%w` (not `%v`) to preserve the error chain for `errors.Is` and `errors.As`.

### Never use panic for expected errors

`panic` is for unrecoverable programmer errors (out-of-bounds, nil dereference in impossible code paths). Business logic errors should always be returned:

```go
// BAD
if user == nil {
    panic("user not found")
}

// GOOD
if user == nil {
    return nil, ErrUserNotFound
}
```

### Use sentinel errors and error types appropriately

- Sentinel errors (`var ErrNotFound = errors.New("not found")`) for conditions callers need to check with `errors.Is`
- Custom error types (`type ValidationError struct{...}`) when callers need to extract structured information with `errors.As`
- Plain `fmt.Errorf` for errors that just need to be logged/propagated

---

## Full checklist (checked at deep level and above)

Everything above, plus:

### Context usage

`context.Context` should be the first parameter of any function that does I/O, makes network calls, or could need cancellation:

```go
// BAD
func GetUser(id string) (*User, error)

// GOOD
func GetUser(ctx context.Context, id string) (*User, error)
```

Context must be threaded through the entire call chain — not created fresh inside a function:

```go
// BAD — discards caller's context
func processOrder(ctx context.Context, order Order) error {
    newCtx := context.Background() // loses cancellation, deadlines, values
    return db.Save(newCtx, order)
}

// GOOD — passes through
func processOrder(ctx context.Context, order Order) error {
    return db.Save(ctx, order)
}
```

### Interface design

#### Accept interfaces, return concrete types

Functions should accept the narrowest interface that describes what they need, and return concrete types:

```go
// BAD — accepts concrete type, returns interface
func ProcessData(f *os.File) io.Reader

// GOOD — accepts interface, returns concrete
func ProcessData(r io.Reader) (*Result, error)
```

#### Define interfaces at the consumer, not the implementer

Interfaces should be declared in the package that uses them, not the package that implements them:

```go
// BAD — "producer-side" interface in the database package
package database
type UserStore interface { ... }
type PostgresStore struct { ... }

// GOOD — consumer-side interface
package auth
type UserStore interface {  // only the methods auth needs
    GetUser(ctx context.Context, id string) (*User, error)
}
```

#### Keep interfaces small

Interfaces with more than 3-5 methods are a smell. They're hard to mock and hard to implement. If an interface is large, it probably should be split.

### No package-level mutable state

Global variables that get mutated are a concurrency hazard and make testing difficult:

```go
// BAD
var db *sql.DB
var logger *log.Logger

func init() {
    db = connectDB()
    logger = setupLogger()
}

// GOOD — inject dependencies
type Server struct {
    db     *sql.DB
    logger *log.Logger
}

func NewServer(db *sql.DB, logger *log.Logger) *Server {
    return &Server{db: db, logger: logger}
}
```

Package-level constants and read-only variables (set once at init, never mutated) are fine.

### Avoid init() functions

`init()` runs implicitly, can't receive dependencies, can't return errors, and runs in unpredictable order when multiple packages have them. Almost everything in `init()` is better done explicitly in `main()` or a constructor.

Acceptable uses of `init()`: registering codecs/drivers (`sql.Register`, `image.RegisterFormat`) where the registration pattern requires it.

### Struct initialization

Use named fields, not positional:

```go
// BAD — positional (breaks when fields are added/reordered)
user := User{"alice", "alice@example.com", true}

// GOOD — named fields
user := User{
    Name:   "alice",
    Email:  "alice@example.com",
    Active: true,
}
```

When a zero-value struct is meaningful, document what the zero value means. When it's not, provide a constructor.

### Naming

- Package names: short, lowercase, single word. No `utils`, `helpers`, `common`, `base`.
- Variables: short names for short scopes (`i`, `r`, `ctx`), descriptive for wider scopes (`userCount`, `retryInterval`).
- Receiver names: short (1-2 chars), consistent across all methods of a type. Not `this` or `self`.
- Exported names: don't stutter with the package name (`http.Server`, not `http.HTTPServer`).

### Function design

- Functions over 50 lines are a warning. Over 100 is a blocker.
- More than 3-4 parameters is a sign the function needs a config struct.
- Boolean parameters are confusing at call sites — use option pattern or named config fields instead.
