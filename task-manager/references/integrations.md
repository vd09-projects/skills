# Integrations with other skills

These integrations are optional. Only activate them if the referenced skill is actually
linked to the project.

## session-continuity

- **Begin mode:** After session-continuity loads the previous session, surface the top "Up
  Next" item alongside the handoff. One seamless prompt, not two separate ones.
- **End mode:** After session-continuity captures the session summary, run Mode 2 Harvest
  (`references/mode-harvest.md`). Then prompt for in-progress task updates. The sequence
  is: session summary → harvest → status check.

## decision-journal

- When a decision is recorded, check if it implies new tasks (e.g., "decided to use
  approach X" may mean "implement approach X"). Suggest task creation with source
  `decision`.
- Tasks can reference decision IDs in their Notes field.

## project-context

- When in-progress tasks shift significantly (many reprioritizations, new critical items),
  suggest updating PROJECT-CONTEXT.md's "Current State" section.
