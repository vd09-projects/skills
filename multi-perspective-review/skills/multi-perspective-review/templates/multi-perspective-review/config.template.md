# Multi-Perspective Review Config — [Project Name]

<!-- rune-generated: [DATE] | git: [GIT_SHA] | rune: 1.0 -->

## Reviewer Overrides

always_include:
  <!-- - Security & Trust Reviewer (compliance requirement) -->

always_exclude:
  <!-- - Accessibility Reviewer (no UI in this project) -->
  <!-- - Concurrency & State Safety Reviewer (single-threaded service) -->

## Project Context

domain: <!-- e.g., "Algorithmic trading platform" -->
primary_languages: <!-- e.g., Go, Python -->
architecture: <!-- e.g., Microservices on Kubernetes -->
urgency_default: normal <!-- normal | hotfix | exploratory -->
debt_tolerance: normal <!-- low | normal | high -->

## Custom Triage Rules

<!-- - Any change touching pkg/payments/ → always include Security & Trust Reviewer -->
<!-- - Migration files → treat as scope: large regardless of line count -->

## Reviewer Voice Tuning

<!-- - Tech Debt Sentinel: stricter — over debt budget this quarter -->
<!-- - Naming Guardian: enforce Go conventions (PascalCase exports) -->
