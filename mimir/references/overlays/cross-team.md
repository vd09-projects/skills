---
overlay: cross-team
applies_to: [architecture, task]
---

# Cross-Team Overlay

Composable concern: work spans multiple owning teams, repos, or services, OR requires sign-off from outside the originating team. Forces RACI clarity, sign-off enumeration, and a communication plan so coordination doesn't happen by accident.

## Triggers

Activate when one or more present:

- Keywords: explicit team names, `coordinate with`, `sign-off`, `approval from`, `partner team`, `platform team`, `infra team`, `security review`, `legal review`, `compliance`, `data steward`
- Scope signals: multiple repos mentioned, services owned by different orgs, shared library or framework edits, monorepo packages with different CODEOWNERS
- Phrases: "we need X team to", "blocked on Y team", "after Z team approves"

Do not activate for: single-team work, code reviews within one team's CODEOWNERS, library upgrades with no behavior change.

## Required Slots

1. **Owning teams.** For each touched area, who owns it? Use real team names. "Some other team" is not a slot value.
2. **Sign-off requirements.** Which stakeholders must approve before the change can merge or deploy — names or roles (not just teams). Include the form: written approval, design review session, async LGTM.
3. **Communication cadence.** Where coordination happens — shared Slack channel, weekly sync, ad-hoc DM, JIRA tickets. How often during the work.
4. **Deadline alignment.** Each team's availability and conflicting commitments — release freezes, on-call rotations, holiday windows. Drives whether the deadline is feasible.
5. **Escalation path.** If a dependency stalls, who unblocks it? Name the manager or process. "Hope they respond" is not a path.

## Template Sections

Append to base body, after `## Constraints`, before terminal sections.

### RACI Matrix

| Workstream | Responsible | Accountable | Consulted | Informed |
|---|---|---|---|---|
| {part of the change} | {who does the work} | {who owns the outcome} | {whose input shapes it} | {who needs to know} |

One row per major workstream. Keep small — large RACIs collapse into noise.

### Sign-Off List

| Stakeholder | Role | Sign-off form | Required by stage | Status |
|---|---|---|---|---|
| {person or role} | {security / legal / SRE / domain} | {written / meeting / async LGTM} | {design / pre-merge / pre-deploy} | {pending / approved / declined} |

### Communication Plan

- **Primary channel:** {Slack channel, mailing list — where updates land}
- **Cadence:** {standup, weekly sync, daily during cutover — when}
- **Status broadcasts:** {when major milestones are announced, to whom}
- **Decision log location:** {where decisions get recorded so absent teams catch up}

### Cross-Team Dependencies

| Dependency | Provided by | Needed by (date) | Risk if late | Backup plan |
|---|---|---|---|---|
| {API ready / schema agreed / library released} | {team} | {date} | {what blocks} | {workaround or escalation} |

### Escalation Path

- **Tier 1:** {first contact — usually a team lead or DRI}
- **Tier 2:** {if Tier 1 unresponsive — manager or shared platform forum}
- **Tier 3:** {executive sponsor, only for cross-org deadlocks}
- **Trigger:** {how long to wait at each tier before escalating}

## Discipline

- **Sign-offs collected before merge, not after.** "We'll get security to look at it in code review" is the path to a blocked launch.
- **Each dependency has a name and a date.** "Waiting on Team X" with no date is a permanent blocker.
- **Async-first communication.** Synchronous meetings encode information that someone will miss. Decision log is the source of truth.
- **The RACI is for the plan, not the personality.** When teams disagree on R/A, the disagreement IS the problem — surface it.
- **Holidays and freezes named in constraints.** Cross-team deadlines that ignore the other team's release calendar will slip.

## Common Failure Modes

- **"Team X is fine with it" with no written record.** Verbal agreements evaporate. Sign-off list demands a trace.
- **Single point of contact who goes on PTO.** Each owner has a named backup, or the path stalls.
- **Communication plan is "I'll DM them".** DMs don't scale and don't archive. Channel + decision log.
- **RACI with five "Accountable" entries.** Exactly one Accountable per row. Multiple Accountables = no one is accountable.
- **Escalation path = "ask my manager".** That's a step, not a path. Three tiers, with criteria for moving up.
- **Forgetting downstream-informed stakeholders.** Support, docs, sales engineering, partner success — the people who get the inbound questions when something ships.
