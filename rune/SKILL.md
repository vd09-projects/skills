---
name: rune
description: >
  Project onboarding skill. Run once per project before using other skills.
  Takes a PRD, project brief, or description and grills the user until all
  domain context is captured, then writes prerequisite skill-memory files
  for every installed skill that has a rune.md manifest.
  Triggers: "set up this project", "onboard this codebase", "create skill memory",
  "run rune", "project setup", "before I start coding help me set up".
  Output: CLAUDE.md + .claude/skill-memory/ files for each installed skill.
---

# Rune

Project onboarding skill. Each skill self-describes via its own `rune.md`.
Rune scans `.claude/skills/` and `~/.claude/skills/` to find installed skills, reads their `rune.md`,
and generates memory from each skill's own templates. No central registry.

## Files Rune reads

- Skill directories: `~/.claude/skills/*/rune.md` and `.claude/skills/*/rune.md` (discovered via filesystem scan)
- `{skill_path}/templates/...` — output templates from each skill's own directory
- `references/questions.md` — shared question bank
- `references/output-format.md` — CLAUDE.md template
- Project files: existing `CLAUDE.md`, `.claude/skill-memory/*`

Rune never reads files from other skills except by discovering their path from the filesystem.

## Phase 0 — Discover installed skills

**Step 1: Scan for installed skills.**

Search these locations for skill directories (directories containing `SKILL.md`):
- `~/.claude/skills/` — personal skills
- `.claude/skills/` — project skills (also scans parent directories up to repo root)

```bash
find ~/.claude/skills .claude/skills -maxdepth 1 -name "SKILL.md" 2>/dev/null \
  | xargs -I{} dirname {}
```

List each discovered skill directory to the user so they can see what was found.

**Step 2: Read each skill's `rune.md`.**
For each discovered skill directory, check if `{skill_dir}/rune.md` exists.
If yes — read it. If no `rune.md` — skip silently, that skill manages its own setup.

Parse from `rune.md`:
- `memory_path` — where to write memory files in the project
- `question_blocks` — required / recommended / deferrable
- `files` table — output filename + template path (relative to skill root) + description

**Step 3: Validate.**
For each loaded manifest:
- Template file exists at `{skill_dir}/{template_path}`? If not: `Template not found: {path}` — skip that file, continue.
- `memory_path` present? If not: `Missing memory_path in {skill_dir}/rune.md` — skip that skill.

**Step 4: Union question blocks.**
Merge across all valid manifests:
- `required` by ANY skill → required
- `recommended` by any, not required by any → recommended
- `deferrable` by ALL → skip in Phase 1

**Step 5: Accept initial context.**
Accept PRD, brief, README, existing CLAUDE.md, or verbal description.
Note what's clear, ambiguous, or missing. Always generate CLAUDE.md.

## Phase 1 — Grilling

Load `references/questions.md`. Ask only required and recommended blocks. Skip deferrable.

**Rules:**
- Batches of 3–5, not one at a time
- PRD already answered it? Confirm, don't re-ask
- Branch on answers: no DB → skip DB questions. Greenfield → skip "existing patterns"
- Required [CRITICAL] unanswered → block. State what's needed and why it blocks
- Recommended answered "don't know" → mark `confidence: MED`. Proceed
- Deferrable → skip entirely. Sindri surfaces these during use

## Phase 2 — Draft and review

Generate CLAUDE.md plus all output files from all valid manifests.
Read each template from `{skill_path}/{template_path}`, fill with grilling answers.

**Metadata header in every generated file:**
```
<!-- rune-generated: [YYYY-MM-DD] | git: [short SHA or "unknown"] | rune: 1.0 -->
```

**Confidence tagging:**
- Required block answers → `confidence: HIGH`
- Recommended, fully answered → `confidence: HIGH`
- Recommended, TBD → `confidence: MED`
- Deferrable not asked → `<!-- TBD: surface via Sindri during use -->`

Show all drafts in full:
```
## Draft: CLAUDE.md
[full content]

## Draft: .claude/skill-memory/sindri/domain.md
[full content]

[... one section per output file]

---
Review these. Say "looks good" to write, or tell me what to change.
```

## Phase 3 — Write

Only after explicit approval:

1. Each target path — file exists? Show diff, ask before overwriting. Never silently overwrite.
2. Write all files with metadata headers.
3. Confirm with list of written paths.

Terminal state: `Setup complete. [skills] are now project-aware. MED-confidence items: [n] — Sindri confirms these before acting on them.`

## What Rune will not do

- **Write without approval.**
- **Overwrite silently.**
- **Read files from skills not discoverable in `.claude/skills/` or `~/.claude/skills/`.**
- **Ask deferrable questions in Phase 1.**
- **Create skill memory without a rune.md.** Skills without rune.md manage their own setup.

## Adding a new skill to Rune

1. Add `rune.md` to the skill root — declares memory_path, question_blocks, files
2. Add templates to `{skill}/templates/`
3. Install the skill into `.claude/skills/` or `~/.claude/skills/`

No changes to Rune needed. It discovers and reads the new skill's rune.md automatically.
