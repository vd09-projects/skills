# Question Bank

Full set of questions Rune works through. Each block has a named ID used in `rune.md` manifests.
Do not reference blocks by ordinal number ("Block 1") — use the ID ("project-identity").

Questions marked **[CRITICAL]** cannot be left as TBD — block if unanswered.
Questions marked **[SKIP IF]** have a condition under which they're irrelevant.

Default tiers (skills can override per their `rune.md`):
- **REQUIRED** — asked in Phase 1, block on unanswered criticals
- **RECOMMENDED** — asked in Phase 1, TBD accepted
- **DEFERRABLE** — skipped in Phase 1, surfaced by Sindri as gaps emerge during use

---

## `project-identity` — Default tier: REQUIRED

1. **[CRITICAL]** What is this project in one sentence? What does it do and for whom?
2. What problem does it solve that nothing else currently does?
3. What does success look like in 6 months?
4. Is this greenfield, an existing codebase, or a major rewrite of something existing?

---

## `domain-rules` — Default tier: RECOMMENDED

5. **[CRITICAL]** What are the 2–3 things that must NEVER break or be wrong?
6. What are the core business rules that are always true — invariants the code must enforce?
7. What domain-specific terminology should I know?
8. What are the known edge cases or gotchas that have burned the team before?
9. **[SKIP IF: greenfield]** What existing behavior must be preserved exactly?

---

## `tech-stack` — Default tier: REQUIRED

10. **[CRITICAL]** Primary language(s) and version(s)?
11. Framework(s)?
12. Database / storage?
13. How is the app deployed?
14. Key external services or APIs the code integrates with?
15. Any significant libraries that define patterns in the codebase?

---

## `architecture` — Default tier: RECOMMENDED

16. What are the major modules or packages and what does each own?
17. What are the hard boundaries — what should NEVER cross into what?
18. What's the data flow?
19. **[SKIP IF: greenfield]** What architectural decisions are already final?
20. What patterns are explicitly forbidden in this codebase?

---

## `quality-bar` — Default tier: DEFERRABLE

21. What's the test strategy?
22. What does "done" mean for a feature?
23. What would make a PR unacceptable, even if it works?
24. Any performance targets?
25. How strict is backward compatibility?

---

## `conventions` — Default tier: DEFERRABLE

26. Error handling convention?
27. Logging approach?
28. How is config and secrets managed?
29. Naming conventions that differ from language defaults?
30. **[SKIP IF: greenfield]** Any code areas that are known trouble spots?

---

## `team-process` — Default tier: DEFERRABLE

31. Who else works on this?
32. Any reviewers that should always be included for certain change types?
33. Urgency default?
34. Any domain persona skill installed alongside Sindri?

---

## `out-of-scope` — Default tier: RECOMMENDED

35. What is explicitly NOT in scope for this project or codebase?
36. What should Sindri specifically NOT build here, even if asked?

---

## `notes-system` — Default tier: RECOMMENDED

For knowledge / note-capture skills (e.g. note-builder). Where notes live and how
they should be filed.

37. **[CRITICAL]** Where do your notes live, and where should new notes be filed?
    A Notion parent page or database (name or URL), or a markdown directory path.
38. Is a Notion MCP connector available in this environment, or should notes be
    emitted as paste-ready markdown for you to file yourself?
39. What top-level concept buckets should notes file under (e.g. Postgres,
    Trading, Languages)? List the ones that already exist so notes accrete, not orphan.
40. Default depth bias — keep the standard "default shallow" (stop at L1 unless
    asked to go deeper), or bias deeper / shallower for this context?
41. Date format and timezone for freshness stamps (`last touched`)? Default: ISO
    `YYYY-MM-DD`, local time.

---

## Synthesis checklist (internal — run before Phase 2)

Before drafting files, verify these are answered (not TBD):

- [ ] Project identity — one sentence captured
- [ ] At least 2 core invariants identified (from `domain-rules`)
- [ ] Primary language(s) confirmed (from `tech-stack`)
- [ ] At least one architectural boundary named (from `architecture`, if recommended)
- [ ] At least one "will not do" item captured (from `out-of-scope`)

If any REQUIRED block has unanswered criticals → block, do not draft.
If RECOMMENDED blocks are TBD → proceed, mark TBD with `confidence: MED` in output.
