# Huginn Config — [Project Name]

Lives at `.claude/skill-memory/huginn/config.md` (project) layered over
`~/.claude/skill-memory/huginn/config.md` (global) — a project-level field
overrides the global one. No config → huginn uses the defaults below and asks the
output dir once if ambiguous.

---

## Output

<!-- Where Stage 5 writes the versioned report. REQUIRED for non-default.
     - output_dir: <repo-relative dir>   (reports land at <output_dir>/<slug>/report.md;
                                           prior versions in <output_dir>/<slug>/_history/)
     Default: research
     Common alternatives: docs/research, .claude/research -->

output_dir: research

## Recency

<!-- The freshness floor for tech claims. Sources/answers older than this for
     fast-moving topics get flagged as possibly stale and re-checked against
     current docs in Stage 3.
     - recency_cutoff: <e.g. "prefer <12 months for framework/library claims">
     - date_format: YYYY-MM-DD (ISO, default) -->

recency_cutoff: prefer sources within 12 months for framework/library/API claims
date_format: YYYY-MM-DD

## Authority

<!-- Tune the source-authority hierarchy (fan-out.md). Defaults are sane; add
     project specifics here.
     - prefer_domains: official docs / RFC / source repos to trust first
                       (e.g. react.dev, developer.mozilla.org, the project's own repo)
     - distrust_domains: stale mirrors / content farms to down-rank or block
     - pin_versions: the versions this project targets, so claims pin to them
                     (e.g. "React 19, Node 22 LTS, Postgres 16") -->

prefer_domains:
distrust_domains:
pin_versions:

## Design loop

<!-- Stage 4 path default (design-loop.md).
     - design_path: auto | inline | designsync
        auto       → huginn detects per problem (default)
        inline     → always generate UI via the local frontend-design skill
        designsync → always emit a brief + pull results via DesignSync (claude.ai Design)
     - design_project: <claude.ai design-system project name/uuid>  (designsync path only) -->

design_path: auto
design_project:

## Depth

<!-- Default research breadth.
     - max_subquestions: 5   (Stage 0 decomposition ceiling; 3–7)
     - default_subagents: 4  (Stage 1 parallel fan-out; budget the parallelism)
     - verify_scope: load-bearing | all
        load-bearing → verify only the claims the recommendation rests on (default)
        all          → verify every factual claim (slower, for high-stakes calls) -->

max_subquestions: 5
default_subagents: 4
verify_scope: load-bearing
