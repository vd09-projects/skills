# repos.yaml — Schema & Examples

This file documents the format for the repos registry used in Phase 2 (Architecture Design).

---

## Location & precedence

The skill looks for `repos.yaml` in this order:

1. `./{ticket-slug}/repos.yaml` — project-local, overrides global
2. `~/.claude/repos.yaml` — global registry, shared across all projects

If both exist, the local file wins entirely (no merging — local replaces global for this ticket).

---

## Schema

```yaml
repos:
  - name: {repo-identifier}          # short slug used to reference this repo (e.g. "reddit-factory")
    path: {/absolute/path/to/repo}   # absolute path on disk
    description: {one sentence}      # what this repo does — be specific
    tags:                            # optional — helps classify during architecture
      - {tag}                        # e.g. skill, mcp, pipeline, frontend, infra, shared-lib
    owner: {name or team}            # optional — who owns this repo
    notes: |                         # optional — multi-line extra context
      {anything else useful to know when deciding whether to reuse or extend this repo}
```

---

## Full example

```yaml
repos:
  - name: reddit-factory
    path: /Users/vikrantdhawan/repos/reddit-shorts-factory
    description: Generates short-form video content from Reddit posts — fetches posts, renders video, uploads to YouTube
    tags:
      - pipeline
      - orchestrator
    owner: vikrant
    notes: |
      Uses ffmpeg for video rendering. Has a job queue for async processing.
      Do not add new external API integrations here — use MCP servers instead.

  - name: software-architect
    path: /Users/vikrantdhawan/repos/skills/software-architect
    description: Skill that breaks down large tasks into structured tickets with reasoning captured
    tags:
      - skill
    owner: vikrant

  - name: claude-skills
    path: /Users/vikrantdhawan/repos/skills
    description: Collection of Claude skills — each skill is a SKILL.md in its own subfolder
    tags:
      - skill
      - shared-lib
    notes: |
      New skills go in their own subfolder here.
      Do not put MCP servers here — they have their own lifecycle.

  - name: infra
    path: /Users/vikrantdhawan/repos/infra
    description: Terraform configs for AWS infrastructure — VPCs, ECS clusters, RDS, S3
    tags:
      - infra
      - config
    owner: vikrant
```

---

## Tips for writing good entries

**`description`** — be specific about what the repo does, not what it is. "Handles video" is bad. "Renders Reddit posts as MP4 short-form videos using ffmpeg" is good.

**`tags`** — use these consistently so the architecture phase can quickly filter relevant repos:
- `skill` — a Claude skill (SKILL.md)
- `mcp` — an MCP server
- `pipeline` — end-to-end data or content pipeline
- `orchestrator` — sequences other components
- `frontend` — UI
- `api` — HTTP API or backend service
- `shared-lib` — reused by 2+ projects
- `infra` — infrastructure / config only
- `research` — spike or investigation repo

**`notes`** — write the things you'd want to know before extending this repo: gotchas, things not to do, architectural decisions already made.

---

## Creating your global registry

Run this to create or edit your global registry:

```
~/.claude/repos.yaml
```

Add entries for every repo you work with regularly. The skill will read this file in every project automatically.

To override for a specific ticket, create a `repos.yaml` inside the ticket folder:

```
{ticket-slug}/repos.yaml
```

This local file completely replaces the global one for that ticket.
