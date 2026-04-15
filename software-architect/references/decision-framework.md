# Decision Framework — Placement & Classification

Reference this file when classifying subtasks in Step 2 of the skill.

---

## Task Type Classification

### RESEARCH
A task that produces a **decision or document**, not code.

Use when:
- The shape of the work is not yet known
- A technical approach needs to be validated before committing
- An external system's behaviour needs to be understood first
- More than one reasonable solution exists and the choice has downstream impact

Output: A decision document, spike result, or updated TASK-REASONING.md entry.
Rule: Every RESEARCH task must produce a concrete artifact. "Investigated X" is not a done-condition. "Documented decision on X in TASK-REASONING.md ADR-0N" is.

---

### SKILL
An LLM-invokable, reusable capability.

Use when:
- An LLM needs to decide when to invoke it
- It is stateless and reusable across different pipelines or contexts
- It wraps a well-defined transformation or generation capability
- You would describe it to a human as "the AI can do X"

Lives in: A skill repo or `/skills` folder, as a named SKILL.md + optional resources.

Do NOT use for: orchestration logic, glue code, or things only one pipeline ever uses.

---

### MCP_SERVER
Wraps an external system or maintains state the LLM needs to access.

Use when:
- It talks to an external API, database, queue, or filesystem
- It needs to maintain state across LLM calls
- The LLM needs to treat an external tool as a named capability

Lives in: A dedicated MCP server repo or `/mcp` folder with its own lifecycle.

Do NOT use for: pure data transformations with no external calls.

---

### CODE
Deterministic transformation, scheduled job, utility, or infrastructure.

Use when:
- Invoked by code on a fixed schedule or trigger (not by LLM decision)
- It's a one-time or pipeline-specific transformation
- It's glue logic connecting other components
- It's a data pipeline step with no reuse value outside this pipeline

Lives in: The pipeline repo, as a module or script.

---

### ORCHESTRATOR
Sequences, routes, or coordinates other skills/steps.

Use when:
- The task is "run A then B then C based on output of A"
- It contains conditional logic about which path to take
- It doesn't do the work itself — it delegates to other components

Lives in: The pipeline repo or as an orchestrator skill.
Rule: Orchestrators should be thin. If orchestration logic grows large, something is misclassified.

---

### CONFIG
Environment setup, credentials, deployment, or infrastructure definition.

Use when:
- No logic, only configuration values or structure
- Enables other tasks but doesn't do any processing itself

Lives in: The relevant repo's config or infra folder.

---

## Repo Placement Decision

### NEW_REPO

Create a new repo when ALL of the following are true:
- It has an independent release lifecycle (can be versioned/deployed separately)
- It is currently consumed by 2+ real projects (not hypothetical)
- It runs in a different environment than the parent project

Test: "If I deleted the parent repo, would this piece still make sense standing alone?"

---

### EXISTING_REPO:{name}

Belongs in an existing repo when:
- It extends the current domain (same vocabulary, same business rules)
- It is meaningless without the surrounding context of that repo
- The same person/team owns it
- It does not need independent versioning

---

### NEW_MODULE:{repo/path}

A new folder or module inside an existing repo, when:
- It's a distinct enough concern to warrant isolation
- But it's not reusable outside this repo yet
- Creating a new repo would be premature

---

### EXTRACT_LATER

Keep inside the current repo but mark explicitly for future extraction when:
- You can see it will be reusable, but only one consumer exists today
- Extracting now would be premature abstraction

Mark with a comment: `# EXTRACT_LATER: candidate for shared library when {condition}`

---

## Boundary Health Checks

After classifying each subtask, verify:

**Language check**
Do the same terms mean different things here vs. in another part of the system?
If yes → separate bounded context → likely separate repo or module.

**Communication check**
Will this need to constantly call back to another component to work?
If yes → wrong boundary. Merge them or introduce a shared abstraction.

**Ownership check**
Does this have exactly one reason to change and one owner?
If no → split further.

**Decomposer/solver check**
Is this deciding HOW to break work, or DOING the work?
Never mix orchestration into execution components.

**Size check**
Can you describe this in one sentence without the word "and"?
If no → still too big.

**Event boundary check**
Does this communicate its output to the next stage via a defined artifact?
Should: emit a clean output that the next stage consumes.
Should not: directly call the next stage.

---

## Conway's Law reminder

Your system will mirror your team/ownership structure whether you plan it or not.
Design boundaries intentionally: one owner per repo/module, one reason to change per component.
If two people need to coordinate every time either touches a component, the boundary is wrong.
