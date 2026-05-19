---
overlay: infra-blast
applies_to: [architecture, task]
---

# Infrastructure Blast-Radius Overlay

Composable concern: change touches production infrastructure, deploy pipeline, traffic routing, or shared platform state. Forces rollout, rollback, and kill-switch discipline so a bad deploy is contained.

## Triggers

Activate when one or more present:

- Keywords: `prod`, `production`, `deploy`, `rollout`, `canary`, `traffic shift`, `feature flag`, `kill switch`, `k8s`, `kubernetes`, `terraform`, `IaC`, `helm`, `ingress`, `load balancer`, `DNS`, `secret rotation`
- File signals: `terraform/`, `k8s/`, `helm/`, `.github/workflows/`, `Dockerfile`, `docker-compose*`, ingress YAML, network policy YAML
- Phrases: "ship to prod", "shared platform", "all environments", "global config", "platform-wide"

Do not activate for: changes scoped to a single non-production environment, code-only changes deployed via existing untouched pipelines.

## Required Slots

1. **Blast radius.** Worst-case scope if the change misbehaves — % of traffic, % of users, which services, which regions. "All checkout traffic in EU" is concrete; "could affect users" is not.
2. **Rollback time target.** From "we see the problem" to "production is back to prior state", how many minutes? Drives whether feature-flag toggle is required or `kubectl rollout undo` is enough.
3. **Kill switch availability.** Is there a runtime toggle that disables the new path without redeploy? If no, plan must add one OR justify why not.
4. **On-call awareness.** Has on-call been notified of the rollout window? Are runbook entries updated? "No" means the first failure becomes a paging incident with no context.
5. **Shared-infra dependencies.** What other teams' services depend on the infra being changed? Drives cross-team coordination need (consider also activating `cross-team` overlay).

## Template Sections

Append to base body, after `## Constraints`, before terminal sections.

### Rollout Strategy

- **Pattern:** {dark launch | canary | percentage rollout | blue-green | in-place}
- **Stages:** {ordered traffic shifts — e.g., 1% → 10% → 50% → 100%}
- **Dwell time per stage:** {how long before promoting — must cover at least one full traffic cycle and observation window}
- **Promotion criteria:** {metrics that must be green to promote to next stage}

### Canary Plan

- **Canary surface:** {single pod / single region / single tenant / synthetic traffic}
- **Diff metrics watched:** {error rate, latency, saturation — old vs canary, with thresholds}
- **Abort criteria:** {what triggers automatic rollback during canary}

### Kill Switch

- **Mechanism:** {feature flag name, config key, env var}
- **Default state at deploy:** {off | on}
- **Toggle latency:** {seconds/minutes from flip to effect}
- **Owner:** {who can flip without further approval at 3 AM}

### Rollback Procedure

- **Detection:** {what monitoring fires the rollback decision}
- **Action:** {exact command, runbook link, or automated trigger}
- **Recovery time objective:** {minutes}
- **Verification post-rollback:** {how we confirm we're actually back on the prior state — not just "no errors"}

### Stakeholder Notification

| Audience | Channel | Timing | Owner |
|---|---|---|---|
| On-call | {Slack channel, PagerDuty} | {pre-deploy + during} | {team} |
| Dependent teams | {channel} | {pre-deploy} | {team} |
| Status page | {if external-facing} | {at incident, not at deploy} | {team} |

## Discipline

- **No prod rollout without rollback.** Rollback procedure section is non-optional.
- **A kill switch you can't flip without approval is not a kill switch.** Toggle authority belongs with on-call, not with a manager in another timezone.
- **Canary observation must outlast typical user session length.** Promoting after 30 seconds misses anything that depends on session state or background jobs.
- **Stage promotion is a decision, not a timer.** Automated promotion that ignores metrics is just delayed rollout.
- **Secret rotation always has a window.** Old and new secrets must both work until all consumers cut over.

## Common Failure Modes

- **"Blast radius is small" without numbers.** % traffic or % users is non-negotiable.
- **Rollback procedure = `revert the PR`.** Reverting code doesn't unwind a Terraform apply, a DNS change, or a database migration. Each layer needs its own rollback.
- **Kill switch buried behind config push.** A toggle requiring full deploy is not a kill switch — it's just another deploy.
- **Canary on synthetic traffic only.** Real users find bugs synthetic traffic cannot.
- **No notification to dependent teams.** Surprise infra changes destroy trust faster than the change itself.
- **Treating IaC review as optional.** Terraform/Helm diffs hide enormous behavior changes in tiny text deltas.
