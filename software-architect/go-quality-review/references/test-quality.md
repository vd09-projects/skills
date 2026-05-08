# Test quality dimension

This dimension evaluates whether tests actually verify behavior, not just execute code.

---

## Depth: coverage

Run at standard level and above.

### Execution

```bash
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out
```

### Evaluation

1. **Package-level coverage**: flag any package below 70% line coverage. This threshold is a floor — critical packages (auth, payments, data access) should be higher.

2. **New code coverage**: if you can identify which files/functions are new or changed (via git diff or user context), check that new code has corresponding test additions. New production code without new tests is a warning.

3. **Coverage distribution**: a package at 80% overall but with a 200-line function at 0% is worse than a package at 70% with even distribution. Flag uncovered functions, not just package-level numbers.

### What coverage doesn't tell you

Coverage measures execution, not verification. A test that calls a function but never checks the return value shows 100% coverage but tests nothing. This is why mutation testing matters at higher review levels.

---

## Depth: full (coverage + mutation + pattern analysis)

Run at deep and pre-merge levels.

### Mutation testing

Mutation testing answers: "if I break this code, will a test catch it?"

It works by making small changes (mutations) to the source code — flipping operators, changing return values, removing statements — and checking if the test suite fails. If a mutation survives (tests still pass), the test is weak at that point.

#### Execution

Use `gremlins` or `go-mutesting`:

```bash
# Using gremlins (preferred — actively maintained)
go install github.com/go-gremlins/gremlins@latest
gremlins unleash ./pkg/auth/...

# Using go-mutesting (alternative)
go install github.com/zimmski/go-mutesting/cmd/go-mutesting@latest
go-mutesting ./pkg/auth/...
```

If neither tool is installed, flag this and suggest installation. Do not skip mutation testing silently.

#### Interpreting results

- **Mutation score above 70%**: acceptable for most code
- **Mutation score 50-70%**: tests exist but have gaps — likely testing happy paths only
- **Mutation score below 50%**: tests are mostly decorative — they execute code but don't verify behavior

Focus on surviving mutations in critical paths. A surviving mutation in error handling code is more dangerous than one in a log message formatter.

### Test pattern analysis

Review test files for these patterns:

#### Table-driven tests (the Go standard)

Tests should use the table-driven pattern — a slice of test cases iterated with `t.Run`. This is the idiomatic Go approach and naturally encourages covering multiple cases.

**What good looks like:**
```go
tests := []struct {
    name    string
    input   Input
    want    Output
    wantErr error
}{
    {name: "valid input", input: validInput, want: expectedOutput},
    {name: "empty input", input: Input{}, wantErr: ErrEmptyInput},
    {name: "boundary value", input: boundaryInput, want: boundaryOutput},
}
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        got, err := Function(tt.input)
        // assertions
    })
}
```

**Red flags:**
- Individual test functions for each case instead of a table (`TestValidInput`, `TestEmptyInput`, `TestBoundaryValue` as separate functions)
- Table tests with only 1-2 entries — the table structure is there but cases are missing
- No error case entries in the table — only testing the happy path

#### What each test should cover

For every function under test, check that the test table includes:
- Happy path (valid input → expected output)
- Empty/zero-value input
- Boundary values (max int, empty string, nil slice)
- Error conditions (invalid input, downstream failure)
- Edge cases specific to the domain

#### Tests verify behavior, not implementation

**Warning signs of implementation-coupled tests:**
- Asserting on unexported struct fields
- Mocking internal helper functions (rather than interfaces)
- Tests that break when you refactor internals without changing behavior
- Checking the number of times a method was called (usually indicates testing implementation)

**What good behavioral tests look like:**
- Assert on public return values and side effects
- Mock at interface boundaries (database, HTTP clients, external services)
- Tests still pass when internal implementation changes

#### Subtests and parallel execution

- Subtests (`t.Run`) should be used for each case in a table
- Tests that are independent should use `t.Parallel()` for faster execution
- Tests sharing state should NOT use `t.Parallel()` — flag if they do

#### Test helpers

- Common setup should be in helper functions marked with `t.Helper()`
- Custom assertion helpers should call `t.Helper()` so failure messages point to the right line
- `testdata/` directory should be used for fixture files, not inline strings for large inputs
