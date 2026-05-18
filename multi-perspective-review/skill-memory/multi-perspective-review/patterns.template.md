# Learned Patterns

## Recurring Issues
<!-- - 2025-01-15: OrderService has silent error swallowing — Error Handling Inspector should flag new catch blocks here -->

## Project Conventions
<!-- - Error wrapping: fmt.Errorf("context: %w", err) -->
<!-- - Logging: structured via slog -->
<!-- - Tests: table-driven, named subtests -->

## False Positive Suppressions
<!-- - pkg/generated/ → skip Naming Guardian (auto-generated) -->
<!-- - vendor/ → skip Dependency Reviewer -->

## Known Hot Spots
<!-- - OrderService — changed 12 times in 3 months -->
