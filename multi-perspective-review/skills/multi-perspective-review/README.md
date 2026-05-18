---
name: multi-perspective-review
description: >
  This skill should be used when reviewing a PR, MR, diff, or code change.
  It simulates a panel of expert reviewers — each with a distinct domain and voice —
  selected adaptively based on the change.
---

# multi-perspective-review

Language-agnostic code review skill. Triage selects only the relevant reviewers — a 5-line fix gets 2 reviewers, a 300-line feature gets 7. Each writes in their distinct voice with specific, actionable findings.

## Invocation

```
Review this PR using multi-perspective-review.

PR Description: [what the change does]
Urgency: normal

[paste diff]
```

## Structure

```
multi-perspective-review/
├── SKILL.md                         ← lean orchestrator (~120 lines)
├── references/
│   ├── output-format.md             ← review template + rules
│   ├── reviewer-template.md         ← blank template for new reviewers
│   ├── examples.md                  ← 3 worked triage examples
│   └── reviewers/                   ← one file per reviewer (loaded on-demand)
│       ├── tech-debt-sentinel.md
│       ├── security-trust-reviewer.md
│       └── ... (13 total)
└── README.md
```

**Progressive disclosure:** SKILL.md loads first (~120 lines). Reviewer files load only for selected reviewers. A 3-reviewer PR loads ~120 + 90 lines. Not 667.

## Adding a Reviewer

1. Copy `references/reviewer-template.md` → `references/reviewers/{slug}.md`
2. Add one row to the signal table in SKILL.md
3. Done

## Skill Memory

Store project overrides at `.claude/skill-memory/multi-perspective-review/`:

| File | Purpose |
|---|---|
| `config.md` | Reviewer overrides, custom triage rules |
| `patterns.md` | Learned patterns, false positive suppressions |
| `accepted-debt-ledger.md` | Debt tracking with follow-ups |

Memory files are never written without user confirmation.
