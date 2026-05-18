# Output Format

Rune owns the `CLAUDE.md` template. Per-skill memory templates live in each skill's
`templates/` directory, declared via that skill's `rune.md` manifest.

---

## CLAUDE.md

Generated always, regardless of which skills are installed. Loaded into every Claude session.

```markdown
<!-- rune-generated: [DATE] | git: [GIT_SHA] | rune: 1.0 -->

# [Project Name]

[One-sentence project description.]

## Stack

- **Language:** [primary language + version]
- **Framework:** [framework(s)]
- **Database:** [DB/storage]
- **Deployment:** [infra/deployment target]
- **Key libs:** [significant libraries]

## Architecture

[2–4 sentences on major modules, data flow, and hard boundaries.]

## Quick conventions

- [Error handling convention]
- [Logging approach]
- [Config/secrets management]
- [Any naming convention that differs from language defaults]

## Skills installed

[List each installed skill with one-line description of its role.]
- `sindri` — implementation (plan/build/iterate/spike)
- `multi-perspective-review` — code review
- `rune` — project onboarding (re-run on major changes)

## Re-run rune when

- Primary language, framework, or database changes
- Core architectural boundaries are redrawn
- A core invariant is added, removed, or proven wrong
- Team structure or reviewer requirements change significantly
- The project pivots or significantly changes scope

Run `rune` to re-onboard. Incremental convention updates go through Sindri's memory suggestions.
```

---

## Per-skill memory templates

Each skill that supports Rune declares its templates in its own `rune.md`:

```
skill-root/
  rune.md              ← declares memory path, files, question blocks
  templates/
    {skill-name}/
      *.template.md    ← Rune fills these in and writes to .claude/skill-memory/
```

Rune reads the template file, fills placeholders from grilling answers, and writes the result to the declared memory path. Template format is defined by each skill — Rune treats them as fill-in documents.
