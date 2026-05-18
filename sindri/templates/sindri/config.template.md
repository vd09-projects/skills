# Sindri Config — [Project Name]

Copy to `.claude/skill-memory/sindri/config.md` in your project repo.

---

## Language

primary_language: <!-- go | python | typescript | rust | etc. -->
language_version:  <!-- e.g., go1.22, python3.12 -->

## Scope

<!-- What is and isn't in scope for Sindri in this project.
     Default: anything in the codebase. Override here if needed.

     Examples:
     - "Backend only — frontend is a separate team"
     - "Internal packages only — pkg/ is a public API, changes need architecture review first"
-->

## Quality Overrides

<!-- Stricter or looser quality gates for specific reasons. Document the reason.
     Default: all gates in quality-gates.md apply.

     Stricter:
     - "100% test coverage required in pkg/accounting — financial correctness"

     Looser:
     - "scripts/ exempt from function length gate — one-off automation scripts"
-->

## Interrogation Defaults

<!-- Answers to common interrogation questions so they don't need to be re-asked.
     Sindri uses these as defaults when the user doesn't specify.

     Examples:
     - default_stage: build    (skip "what stage?" unless user says otherwise)
     - test_framework: pytest
     - performance_target: p99 < 100ms for all HTTP endpoints
-->

## Persona Integration

<!-- If a domain persona skill is also installed, name it here.
     Sindri defers to it for domain judgment calls.

     Example:
     - domain_persona: algo-trading-lead-dev
-->
