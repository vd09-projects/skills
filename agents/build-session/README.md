# build-session

Generic end-to-end build-session orchestrator agent. Plug-and-play across projects.

## What it does

Picks a task, plans it, reviews the plan, builds it, reviews the build, iterates, harvests decisions, closes the task. Five skills work in harmony through skald's persistence layer:

```
task-manager (pick)
  → decision-journal (related-context lookup)
    → skald run mimir (plan)
      → skald run multi-perspective-review (plan review, ≤3 rounds)
        → user approval
          → skald run sindri (build)
            → skald run multi-perspective-review (build review, ≤3 rounds)
              → decision-journal (harvest inline marks)
                → task-manager (status + follow-ups)
```

Every producer skill runs as a sub-agent through skald — orchestrator context stays small.

## Required skills

Installed at `~/.claude/skills/`:

- `skald`
- `mimir`
- `sindri`
- `multi-perspective-review`
- `task-manager`
- `decision-journal`

Plus skald's `skill_registry` (`~/.claude/skill-memory/skald/config.md`) must list the three producer skills. Agent's pre-flight verifies this and offers to wire it up if missing.

## Install

One-time symlink:

```bash
ln -s ~/repos/skills/agents/build-session/build-session.md \
      ~/.claude/agents/build-session.md
```

Verify:

```bash
ls -la ~/.claude/agents/build-session.md
```

## Usage

Triggers — any of:

- "what's next" / "what should I work on"
- "implement TASK-NNN" / "build TASK-NNN"
- "resume the task we started"
- "ship this feature"

The agent invokes itself automatically when these phrases appear and the main thread routes to it. You can also explicitly: "use the build-session agent to ..."

## State model — no parallel JSON

The handoff layer IS the source of truth. There is no session-state JSON. Pipeline progress is derived from which canonical files exist in `.claude/handoff/{slug}/` + their `status:` frontmatter.

Two sentinel files the agent owns per scope (everything else is skald's):

| File | Purpose |
|---|---|
| `.linked-task` | One line: task ID this scope serves. Written in Step 3 after skald creates the scope dir. Used to filter open scopes on resume. |
| `_HARDSTOP.md` | Written when any hard-stop fires. Contains reason + needed input. User deletes (or instructs agent to clear) before resume. |

## Handoff artifacts (skald-owned)

```
.claude/handoff/{scope-slug}/
├── planner-task.md             (mimir output, wrapped)
├── implementation-build.md     (sindri output, wrapped)
├── review-findings.md          (multi-perspective-review output, wrapped)
├── _history/                   (prior versions on iteration)
├── _thread.md                  (chronological narrative)
├── INDEX.md                    (scope index)
├── LOG.md                      (append-only log)
├── .linked-task                (agent-owned — task ID)
└── _HARDSTOP.md                (agent-owned — present only when stopped)
```

Each iteration archives the prior canonical to `_history/`. The current canonical is always the live handover to the next step.

## Resume

Agent globs `.claude/handoff/*/.linked-task` at startup, filters scopes whose final canonical is not `consumed`, and:

- 0 matches → fresh session
- 1 match without `_HARDSTOP.md` → resume, derive current step from canonicals' status fields
- 1 match WITH `_HARDSTOP.md` → surface stop reason, wait for user to clear
- ≥2 matches → ask user which to resume

## Caps and hard stops

- Plan review cap: 3 rounds.
- Build review cap: 3 rounds.
- Hard-stop on: same `file:line` finding 2 rounds in a row, all tasks blocked, skill returns Blocked, skald classification failure.
- One human gate only: plan approval after plan review converges. Build review loop runs autonomously to convergence or cap.

## Tuning per project

The agent body has an `APPENDIX B — When to override` section listing the knobs (caps, domain-expert insertion, quality-gate runner, auto-commit). Override by copying the agent into project-local `.claude/agents/` and editing — global stays untouched.

## Anti-scope

This agent does NOT:

- Commit code (no git operations).
- Push or open PRs.
- Run CI.
- Make methodology decisions.
- Decide what code to write.
- Auto-approve plans or builds.

Those belong to other agents (`conventional-commits`, domain personas, etc.) — chain them as separate sessions if needed.
