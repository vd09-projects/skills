# Behavior dimension

This dimension analyzes runtime behavior patterns that static analysis and linters cannot catch. These are the bugs that show up in production under load, under cancellation, or after extended uptime.

---

## Concurrency

### Every goroutine must have a shutdown path

For every `go func()` or `go methodCall()`, verify:
1. What signal tells this goroutine to stop? (context cancellation, channel close, WaitGroup)
2. What happens if the signal never comes? (timeout, leak)
3. Who waits for it to finish? (WaitGroup, errgroup, done channel)

```go
// BAD — goroutine leak: nothing stops it, nothing waits for it
go func() {
    for msg := range ch {
        process(msg)
    }
}()

// GOOD — context-controlled with WaitGroup
g.Go(func() error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        case msg, ok := <-ch:
            if !ok {
                return nil
            }
            if err := process(ctx, msg); err != nil {
                return err
            }
        }
    }
})
```

### Channel ownership

Channels should have a clear owner — one goroutine that creates, writes to, and closes it. Receivers should never close a channel:

```go
// BAD — receiver closes
go func() {
    data := <-ch
    close(ch) // race with sender
}()

// GOOD — sender closes
go func() {
    defer close(ch)
    for _, item := range items {
        ch <- item
    }
}()
```

Check for:
- Sends on closed channels (panic)
- Unbuffered channels with no reader (goroutine blocks forever)
- Buffered channels used as semaphores without clear capacity reasoning

### Mutex usage

- `sync.Mutex` protects data, not code. The mutex should be near the data it guards, ideally in the same struct.
- Never hold a mutex while doing I/O, network calls, or channel operations — this invites deadlocks.
- `sync.RWMutex` is appropriate only when reads vastly outnumber writes. Otherwise, plain `Mutex` is simpler and often faster.
- Check for inconsistent locking — if a field is sometimes accessed with a lock and sometimes without, that's a data race.

### sync.WaitGroup and errgroup

- `wg.Add()` must be called before `go func()`, never inside the goroutine.
- Prefer `golang.org/x/sync/errgroup` over raw WaitGroup when goroutines can fail — it propagates the first error and cancels remaining work.

---

## Context threading

### Context must flow through the entire call chain

Trace the context from the entry point (HTTP handler, gRPC method, main function) through to every I/O operation. Flag any point where:
- A new `context.Background()` or `context.TODO()` is created mid-chain (breaks cancellation)
- Context is stored in a struct field (stale context survives request boundaries)
- A function does I/O but doesn't accept a context parameter

### Context values

Context values should be used only for request-scoped metadata (trace IDs, auth tokens), not for passing dependencies:

```go
// BAD — using context as dependency injection
ctx = context.WithValue(ctx, "db", database)
db := ctx.Value("db").(*sql.DB)

// GOOD — pass dependencies explicitly
func HandleRequest(ctx context.Context, db *sql.DB, req Request) error
```

### Timeouts and deadlines

Every outgoing network call should have a deadline, either from the incoming context or explicitly set:

```go
// BAD — no timeout, hangs forever if server is slow
resp, err := http.Get(url)

// GOOD — timeout from context
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()
req, _ := http.NewRequestWithContext(ctx, "GET", url, nil)
resp, err := client.Do(req)
```

---

## Error types and handling patterns

### Error types should match how callers need to react

Review error returns through the caller's lens:
- If the caller needs to branch on the error kind → use sentinel errors or typed errors
- If the caller just logs and returns → plain wrapped errors are fine
- If the caller needs structured data from the error → use a custom error type

### Errors in goroutines

Errors from goroutines must be collected, not silently lost:

```go
// BAD — error disappears
go func() {
    if err := process(item); err != nil {
        log.Println(err) // logged but caller never knows
    }
}()

// GOOD — error propagated via errgroup
g.Go(func() error {
    return process(item)
})
if err := g.Wait(); err != nil {
    return fmt.Errorf("processing failed: %w", err)
}
```

---

## Resource lifecycle

### Close what you open

Every resource that implements `io.Closer` must be closed. Check for:
- HTTP response bodies (`resp.Body.Close()`)
- Database connections, rows, statements
- File handles
- gRPC streams and connections

Use `defer` for closing, immediately after the open/create succeeds:

```go
f, err := os.Open(path)
if err != nil {
    return err
}
defer f.Close()
```

### Connection pools

Database and HTTP client connection pools should be:
- Created once and reused (not per-request)
- Configured with sensible limits (MaxOpenConns, MaxIdleConns, IdleTimeout)
- Closed gracefully on shutdown

Flag any pattern where `sql.Open`, `http.Client{}`, or similar pool-creating calls appear inside request handlers or loop bodies.
