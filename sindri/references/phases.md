# Phases — Plan / Build / Iterate / Spike

Detail and discipline for each mode. The SKILL.md orchestrator summarizes these; this file is the authority.

---

## Plan mode

Goal: agree on approach before spending time building. Output is a plan the user can approve, redirect, or block. No code.

**Structure of a plan:**

1. **Restate the problem** in one sentence — confirms understanding before proposing anything.
2. **Proposed approach** — the structure: what components, what interfaces, where things live. Prose and optional diagrams. No pseudocode that looks like real code.
3. **What's explicitly out of scope** — name it. Prevents scope creep during build. If there's a simpler version that handles 80% of the ask, name it as an option.
4. **Success Metric** — quantified outcome that means this work succeeded post-deploy. Primary measure + observation window at minimum. Not "make it better". Not "tests pass" (that's intrinsic). "Auth error rate < 0.1% over 24h" or "checkout p95 < 500ms over 7d sustained" is. If a scope brief was supplied by the caller and contains a Success Metric, inherit it and do not re-state. Otherwise interrogate.
5. **Risks and open questions** — what could go wrong, what needs a decision before building can start.
6. **Test strategy** — specific: what test type covers what behavior. "Golden test against a fixed input/output pair" or "table-driven unit tests covering the five error paths" or "property test on the invariant that X + Y always equals Z." Not "I'll write some tests."
7. **Decision marks** — if the plan establishes a non-obvious convention or makes a structural call the user should know about, mark it inline.

**Plan mode rules:**

- No code. If the urge to write a snippet arises, convert it to a description of what the snippet would do.
- Every plan names the regression risk for changes near load-bearing code.
- Plans that surface ambiguity block immediately rather than paper over it.
- The plan is the thing being reviewed, not the implementation. If the user approves a plan and the build diverges from it, say so explicitly and explain why.
- **Success Metric is required.** Empty metric = the work has no defined success. If the user cannot supply a quantified outcome AND no scope brief covers it, terminate `Blocked — need input.` Do not paper over with "tests pass" or "feature works".
- **When scope is too big for sindri plan mode to deliver a sensible metric** (multi-task initiative, cross-team, architectural choice between options, specialized concern requiring overlay discipline) — surface the mismatch. Sindri plan mode is for single-task in-session work; broader scope requires a dedicated planner.

**Terminal states:**
- `Plan ready.` — approach described, test strategy named, Success Metric stated (or inherited from scope brief), open questions surfaced. Waiting for approval.
- `Blocked — need input.` — a question must be answered before a sensible plan is possible (including: Success Metric unanswerable). State exactly what's needed and why it blocks.

---

## Build mode

Goal: produce working, tested, review-ready code. Completeness over speed.

**Build discipline:**

- Tests ship in the same response as the code they cover. Not a follow-up. Not "I'll add these later." Same response.
- The diff is shown in full. Summarizing what was changed is not enough — the user must be able to read and copy the actual code.
- Decision marks go inline next to the code they describe, not collected at the end.
- If a build-time discovery invalidates the plan, stop and surface it. Don't silently implement a different plan.
- If domain context is missing that would change the implementation (a convention in `domain.md` doesn't cover this case), block and ask rather than guessing.
- Code that wasn't in scope doesn't appear in the output. No "while I'm here" additions without explicit ask.
- **Multi-file ripple check**: if the change touches 3+ files or crosses package/module boundaries, note the ripple risk explicitly in the response and recommend multi-perspective-review before merge.

**Quality gate must pass before `Ready for review.`** See `quality-gates.md`.

**Terminal states:**
- `Ready for review.` — code written, tests written, quality gate passed, decision marks placed.
- `Ready for review — recommend multi-perspective-review.` — same as above, plus the change is medium/large scope, cross-cutting, or involves security/concurrency/data migration concerns. Use this to route to the review skill.
- `Blocked — need input.` — hit something that can't be resolved without input. State specifically what's needed and what the options are. "Blocked — need more context" is wrong. "Blocked — need to know whether X or Y, because the error handling path changes depending on which" is right.

---

## Iterate mode

Goal: close out reviewer or user feedback cleanly. Every finding gets a response.

**Iterate discipline:**

- Address each piece of feedback in order. If three findings were raised, three get responses — not "fixed the issues" as a summary.
- For each finding, exactly one outcome:
  - **Fix** — describe what changed and show the updated code.
  - **Push back** — explain why the current approach is correct. Push back requires a specific reason, not a general disagreement. "This function is over 50 lines because splitting it would require callers to coordinate three steps that are logically atomic" is a reason. "I disagree with line-count limits" is not.
  - **Already handled** — point to where in the existing code this is addressed.
- If changing approach during iterate, say so explicitly. Don't quietly rewrite without acknowledgment.
- If a finding reveals something significant that wasn't in the original plan, surface it before fixing. Don't silently expand scope.

**Terminal states:**
- `Ready for review.` — all feedback addressed; code updated where appropriate.
- `No changes needed.` — feedback reviewed; current implementation already handles the raised concerns. Valid exit, not a cop-out. Explain briefly why no changes were needed.
- `Blocked — need input.` — a finding raises a question that can't be resolved without external input or a domain decision. State what's needed.

---

## Spike mode

Goal: answer a specific question or prove a concept is viable. Output is exploratory code, not production-ready. Every response in spike mode is labeled `[SPIKE]` at the top.

**Spike discipline:**

- State the question being answered at the top. If the spike doesn't have a specific question, block and ask — unfocused spikes produce unactionable results.
- **The spike question IS the Success Metric.** No separate Success Metric required — the answer to "can X be done in Y time?" or "does this library handle Z?" is the success criterion. Standard plan-mode Success Metric discipline does NOT apply to spike mode.
- Write enough code to answer the question. No more. A spike is not a first draft of the feature.
- Basic verification required: the spike runs, the happy path works, core error paths are exercised manually or with minimal tests. Full test suite not required.
- Explicitly list what spike code is NOT doing: no error handling for edge cases, no performance tuning, no production config, no security review. The list is the spike's "debt" if the approach is adopted.
- If the spike reveals the approach is unviable, say so clearly. A spike that finds "don't do this" is a success.
- If the spike confirms viability, state what would need to change to make it production-ready. This becomes the input to a build-mode task.

**What spikes skip:**

- Full test suite (unit, integration, property)
- Complete error handling
- Decision marks for every choice
- Linting / static analysis compliance

**What spikes do not skip:**

- The stated question must be answered
- Basic verification (it runs, core path works)
- Explicit "not production" labeling
- The viability/debt summary at the end

**Terminal states:**
- `Spike ready — not production.` — question answered, verification done, debt list written.
- `Blocked — need input.` — the spike question is unanswerable without more context. State what's needed.
