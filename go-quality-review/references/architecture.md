# Architecture dimension

This dimension evaluates structural health — the patterns that determine whether a codebase gets easier or harder to work with over time.

---

## Depth: dep direction (checked at deep level)

### Dependency direction

Dependencies should flow inward — from handlers/transports toward domain logic, never the reverse.

A healthy Go project typically layers like this:
```
cmd/           → main, wiring, configuration
handlers/      → HTTP/gRPC handlers (depend on domain)
domain/        → business logic, interfaces (depends on nothing)
store/         → database implementations (implements domain interfaces)
```

**What to check:**
- Does the `domain` or `model` package import `handlers`, `store`, or infrastructure packages? If yes, the dependency direction is inverted — this is a blocker.
- Do handler packages import each other? This creates coupling between unrelated features.
- Does any package import `cmd/`? Nothing should depend on the entry point.

**How to check:**
```bash
go list -f '{{.ImportPath}}: {{join .Imports ", "}}' ./...
```

Review the import graph for cycles and inversions. The `go vet` tool catches import cycles at compile time, but directional inversions are valid Go that creates maintenance problems.

---

## Depth: full (checked at pre-merge level)

Everything above, plus:

### Package design

#### Meaningful package boundaries

Each package should represent a coherent concept with a clear responsibility. Flag:

- **God packages** — packages with more than 15-20 files or that contain unrelated types. A `models` package that contains User, Order, Payment, Notification, and Config is a junk drawer, not a package.
- **Thin wrapper packages** — packages that just re-export another package's types with no added logic. These add indirection without value.
- **The `utils` / `helpers` / `common` anti-pattern** — these are dumping grounds that grow forever. Every function in a utils package belongs in a more specific package.

#### Package naming signals design

Good package names describe what the package *does*, not what it *contains*:
- `auth` (what it does) vs `authmodels` (what it contains)
- `store` (capability) vs `database` (technology)
- `notify` (action) vs `notifications` (collection of things)

If a package name needs a qualifier to be understood (`userservice`, `orderhandler`), it might be doing too much or be at the wrong abstraction level.

### Coupling analysis

#### Interface segregation

Check whether packages depend on large interfaces when they only use 1-2 methods. This is a sign of tight coupling:

```go
// BAD — auth package depends on the entire UserStore interface (10 methods)
// but only calls GetUser and ValidatePassword
type UserStore interface {
    GetUser(ctx context.Context, id string) (*User, error)
    ListUsers(ctx context.Context) ([]*User, error)
    CreateUser(ctx context.Context, u *User) error
    DeleteUser(ctx context.Context, id string) error
    // ... 6 more methods
}

// GOOD — auth defines only what it needs
type UserAuthenticator interface {
    GetUser(ctx context.Context, id string) (*User, error)
    ValidatePassword(ctx context.Context, id, password string) (bool, error)
}
```

#### Concrete type coupling

Flag places where a package imports another package solely to reference a concrete type that should be behind an interface. This creates compile-time coupling between packages that should be independent.

#### Circular dependency signals

Go prevents import cycles at compile time, but logical circular dependencies still happen through interfaces or shared packages. If package A defines an interface that package B implements, and B needs types from A — that's fine (dependency flows A→B). But if A also needs to call B directly (not through an interface), there's a hidden circular dependency.

### God-package detection

Quantitative signals that a package is becoming a god package:
- More than 15 `.go` files (excluding tests)
- More than 20 exported types
- Types within the package that don't interact with each other
- The package is imported by more than 60% of other packages in the project

These aren't strict thresholds — a well-designed package can be large if its contents are cohesive. But they warrant investigation.

### Testability assessment

Architecture should make testing easy. Flag patterns that make testing hard:

- Functions that create their own dependencies internally instead of receiving them
- Direct calls to external services without an interface boundary
- Business logic mixed into HTTP handlers (can't test logic without spinning up a server)
- Database queries embedded in domain logic (can't test domain without a database)

A well-architected package should be testable with in-memory fakes or simple mocks — if testing requires complex setup or external services, the architecture is coupling concerns that should be separated.
