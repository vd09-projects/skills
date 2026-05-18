# Rune

Project onboarding skill. Run once per project before using other skills.

Takes a PRD, project brief, or verbal description. Grills until confident. Writes all prerequisite skill-memory files that make other skills project-aware.

## When to run

- Starting a new project
- Onboarding an existing codebase for the first time
- After a major pivot or architecture change

Not for incremental updates — Sindri handles those as patterns emerge.

## Installation

Copy or symlink this directory into the project's `.claude/skills/` directory:

```bash
# From the skills monorepo
ln -s /path/to/skills/rune .claude/skills/rune
```

Or into personal skills (available across all projects):

```bash
ln -s /path/to/skills/rune ~/.claude/skills/rune
```

Claude Code auto-discovers skills from `.claude/skills/` — no config needed.

## Usage

Share your PRD or project details, then trigger:

> "Set up this project" / "Run rune" / "Help me create skill memory"

Rune will:
1. Scan for installed skills that have a `rune.md`
2. Ask batched questions until context is complete
3. Show drafts of all output files
4. Write only after your approval

## What it creates

Always:
```
CLAUDE.md                    ← project root, loaded every session
```

Per installed skill (if that skill has a `rune.md`):
```
.claude/skill-memory/
  sindri/
    domain.md      ← domain invariants, rules, gotchas
    config.md      ← language, scope, quality overrides
    patterns.md    ← seeded hot spots, grows through use
  multi-perspective-review/
    config.md      ← reviewer overrides, project context
  [future-skill]/
    [whatever that skill declares in its rune.md]
```

## Adding a new skill to Rune

No changes to Rune needed. In the new skill:

1. Add `rune.md` at skill root — declares `memory_path`, `question_blocks`, `files`
2. Add `templates/{skill-name}/*.template.md` inside the skill directory
3. Install the skill alongside Rune

Rune discovers the new skill via filesystem scan and reads its `rune.md` automatically.

## Structure

```
SKILL.md                      ← orchestrator
references/
  questions.md                ← question bank (8 blocks, named IDs)
  output-format.md            ← CLAUDE.md template
schema/
  rune-manifest.schema.md     ← rune.md format spec + validation errors
```

Templates live in each skill's own directory — Rune reads them via discovered paths.
