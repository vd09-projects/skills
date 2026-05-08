---
name: conventional-commits
description: >
  Generate or review Git commit messages following the Conventional Commits specification.
  Use this skill whenever the user asks for a commit message, says "write a commit", "what should I commit", 
  "help me commit this", "review my commit message", "is this commit message good", or when a coding session 
  is wrapping up and changes have been made. Also trigger when the user pastes a commit message and asks if 
  it looks right. Proactively offer this skill at the end of coding tasks.
---

# Conventional Commits Skill

## What this skill does
Generates clean, copy-paste-ready commit messages by:
1. Running `git diff` (and `git status`) to inspect actual changes
2. Drawing on conversation history to understand *why* the change was made
3. Applying the Conventional Commits spec to produce a precise message

## Step-by-step workflow

### 1. Gather context

Run these commands to understand what changed:
```bash
git status
git diff --staged        # prefer staged changes
git diff HEAD            # fallback if nothing staged
git log --oneline -5     # understand recent commit style on this repo
```

Also look at the **current conversation** for:
- The problem that was being solved
- The approach/solution that was decided on
- Any constraints or tradeoffs mentioned

### 2. Determine the commit type

| Type | When to use |
|------|-------------|
| `feat` | New feature or capability added |
| `fix` | Bug fix |
| `refactor` | Code restructured, no behavior change |
| `docs` | Documentation only |
| `test` | Tests added or updated |
| `chore` | Build, deps, config, tooling |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes |
| `style` | Formatting, whitespace (no logic change) |

**Breaking change?** Add `!` after the type, e.g. `feat!:` or add a `BREAKING CHANGE:` footer.

### 3. Write the message

Follow this format:
```
<type>[optional scope]: <description>

[optional body — only if the why isn't obvious from the description]

[optional footer — BREAKING CHANGE, issue refs, co-authors]
```

**Rules for a great description line:**
- Lowercase, no period at end
- Imperative mood: "add", "fix", "remove" — not "added" or "fixes"
- Under 72 characters
- Describes *what* changed, not *how*

**When to add a body:**
- Non-obvious reasoning or tradeoffs
- Multiple logical changes in one commit
- Important context for future readers

**When to add footers:**
- `BREAKING CHANGE: <description>` for breaking API changes
- `Refs: #123` for issue/ticket references
- `Co-authored-by: Name <email>` for pair work

### 4. Output format

Output **only** the commit message, inside a code block, ready to copy-paste:

```
feat(auth): add JWT refresh token rotation

Tokens are now rotated on each refresh to limit exposure window.
Previous tokens are invalidated immediately after rotation.

Refs: #88
```

No preamble. No explanation. Just the message.

---

## Reviewing an existing commit message

If the user provides an existing message to review:
1. Check type is valid and appropriate
2. Check description is imperative, lowercase, concise
3. Check for missing breaking change markers
4. Check body/footer are present when needed

Then output a **corrected version** in a code block (if changes are needed), or confirm it looks good (one sentence).

---

## Examples

### Minimal fix
```
fix(parser): handle null value in array input
```

### Feature with scope
```
feat(api): add pagination to /users endpoint
```

### Breaking change
```
feat(config)!: remove support for legacy JSON format

BREAKING CHANGE: config files must now use YAML. Run `migrate-config` to convert.
```

### Chore
```
chore(deps): bump axios from 1.4.0 to 1.6.0
```