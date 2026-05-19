---
overlay: public-api-change
applies_to: [architecture, task]
---

# Public API Change Overlay

Composable concern: changes to a public API surface — HTTP endpoint, gRPC method, SDK function, exported library symbol, CLI flag, public config schema. Adds slots and sections for consumer impact, versioning, deprecation.

## Triggers

Activate when one or more present:

- Keywords: `endpoint`, `route`, `handler`, `public API`, `SDK`, `interface`, `contract`, `OpenAPI`, `proto`, `breaking change`, `deprecate`, `v1 → v2`
- Path/file signals: `api/`, `handlers/`, `routes/`, `proto/`, `openapi.yaml`, `*.proto`, exported package files
- Phrases: "change the response shape", "rename the endpoint", "remove the field", "new required parameter", "SDK function signature"

Do not activate for: purely internal refactors with no exported surface change, private helper renames, request body edits that remain backward compatible AND are tested.

## Required Slots

1. **Consumer inventory.** Who calls this surface — first-party services, third-party SDK users, internal scripts, partner integrations? List by name or class. "Unknown" means investigate before planning.
2. **Versioning policy in effect.** Semver, header-based versioning, URL-pathed (`/v1/`, `/v2/`), date-based, none. Drives whether breaking changes are allowed at all.
3. **Deprecation timeline tolerance.** How long must the old shape coexist with the new — one release, one quarter, "indefinite"? Drives expand-contract scope.
4. **Contract test coverage.** Are there contract or schema tests today? If not, the change ships with zero safety net — plan must add them.
5. **Communication channels.** Where consumers are notified — changelog, release notes, Slack, email, partner portal? "Nowhere" means consumers learn by breakage.

## Template Sections

Append to base body, after `## Constraints`, before terminal sections.

### Consumer Inventory

| Consumer | Surface used | Breaking? | Migration action | Owner |
|---|---|---|---|---|
| {service or partner} | {field/endpoint} | {yes/no} | {what they must change} | {team or external} |

### Versioning Policy

- **Current policy:** {semver | header version | path version | date version | none}
- **This change classification:** {patch | minor | major | breaking}
- **Justification:** {why this classification — what spec rule maps}

### Deprecation Timeline

- **Announcement date:** {when consumers learn}
- **Dual-support window:** {how long old + new coexist}
- **Removal date:** {when old shape disappears}
- **Sunset signal:** {deprecation header, log warning, response field — how consumers detect the timer}

### Contract Tests

- **Existing coverage:** {what is tested today — schema, examples, golden responses}
- **Coverage gap closed by this work:** {tests added as part of the change}
- **Test type:** {schema test | golden response | pact-style consumer contract | integration}

### Communication Plan

- **Pre-release:** {who is told, where, when}
- **At release:** {changelog entry, migration guide link}
- **Post-release:** {monitoring of old-version usage to confirm consumers migrated}

## Discipline

- **No silent breaking changes.** If the version classification slot is "breaking", the deprecation timeline section is non-optional.
- **Removed field ≠ optional field.** Treat field removal as breaking regardless of whether clients "should have handled it".
- **Default values changed = breaking.** Consumers wrote code assuming the old default.
- **New required parameters = breaking.** Adding optional parameters with defaults is non-breaking; making them required is.
- **Internal-but-shared is still public.** If another team's service depends on it, it has consumers, even without a `/v1/` prefix.

## Common Failure Modes

- **"It's only used internally" without grep.** Consumer inventory slot must be filled by checking, not assuming.
- **Deprecation announced with no removal date.** A deprecation without a sunset is a permanent maintenance tax. Force the date.
- **Old + new shape, no monitoring.** Without usage metrics on the old shape, no one knows when removal is safe.
- **Migration guide missing examples.** "Use the new endpoint instead" forces consumers to reverse-engineer the diff.
- **Skipping contract tests because "we tested it manually".** Manual tests do not survive the next refactor.
