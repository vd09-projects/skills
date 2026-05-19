---
overlay: auth-authz
applies_to: [architecture, task]
---

# Authentication & Authorization Overlay

Composable concern: change touches identity, sessions, tokens, roles, permissions, or any path that gates access. Forces explicit modeling of the identity surface and permission impact so a "small auth tweak" doesn't quietly open or close access.

## Triggers

Activate when one or more present:

- Keywords: `auth`, `authentication`, `authorization`, `login`, `logout`, `session`, `token`, `JWT`, `OAuth`, `SAML`, `SSO`, `OIDC`, `MFA`, `2FA`, `password`, `role`, `permission`, `RBAC`, `ABAC`, `ACL`, `scope`, `claim`, `principal`, `service account`, `API key`
- Path/file signals: middleware, guard, interceptor, policy, identity provider config, session store
- Phrases: "who can do X", "only admins should…", "lock down", "expose to", "elevate privileges", "impersonate"

Do not activate for: pure UI label changes to login screens with no flow change, refactors of auth code with no behavior change AND existing test coverage.

## Required Slots

1. **Identity surface affected.** Which actors — end users, admins, service-to-service callers, third-party integrators? Enumerate.
2. **Permission model in effect.** RBAC, ABAC, ACL, policy engine (OPA, Cedar), ad-hoc checks. Name the model and where the source-of-truth permission data lives.
3. **Pre/post permission diff.** For each affected resource × actor pair, what changes — gain access, lose access, no change. A table is non-negotiable.
4. **Session/token lifecycle impact.** Does the change invalidate existing sessions, force re-login, rotate tokens, change expiry, change refresh behavior?
5. **Attack surface delta.** What new surface is exposed (endpoint, parameter, scope), what is removed. Drives whether security review is needed.
6. **Audit logging plan.** What auth events are logged, where, with what fields. Auth changes without audit trail are unsupportable in incident response.

## Template Sections

Append to base body at overlay insertion point.

### Identity Surface

| Actor type | Examples | Currently authenticated via | This change's impact |
|---|---|---|---|
| {End user} | {humans, free / paid tier} | {OIDC / password / magic link} | {what shifts} |
| {Admin / privileged} | {staff} | {SSO + MFA} | {what shifts} |
| {Service-to-service} | {internal services} | {mTLS / service tokens} | {what shifts} |
| {Third-party / partner} | {API consumers} | {API key / OAuth} | {what shifts} |

### Permission Model & Source of Truth

- **Model:** {RBAC | ABAC | ACL | policy-engine: name | ad-hoc}
- **Source of truth:** {DB table / IdP claims / policy bundle / hardcoded}
- **Evaluation point:** {edge / gateway / per-service middleware / per-handler}

### Permission Diff

| Resource | Action | Actor / role | Before | After | Net change |
|---|---|---|---|---|---|
| {entity} | {read / write / delete / invoke} | {role or actor} | {allowed/denied}  | {allowed/denied} | {grant / revoke / no change} |

Repeat per affected pair. Any row with a **grant** is a privilege increase — treat with the bar that implies.

### Session & Token Lifecycle

- **Invalidation:** {existing sessions remain valid / forced re-login / partial invalidation by role}
- **Token rotation:** {if applicable — what tokens rotate, on what schedule}
- **Expiry change:** {old → new TTL}
- **Refresh behavior:** {unchanged / new refresh policy}
- **Backward-compat window:** {how long old tokens remain accepted, if at all}

### Attack Surface Delta

- **New surface:** {endpoint, scope, parameter — exposed to whom, with what auth requirement}
- **Removed surface:** {what is no longer reachable / required}
- **Surfaces that change scope/required role:** {endpoint X now requires role Y where it required role Z}

### Audit Logging Plan

- **Events logged:** {login success/fail, permission denied, role change, token issuance, etc. — by name}
- **Fields:** {actor id, target resource, action, timestamp, outcome, client IP, request id}
- **Sink:** {centralized log store, SIEM, audit table}
- **Retention:** {duration, per compliance requirement}

## Discipline

- **Default deny.** A new resource or action defaults to no-access; access is granted explicitly. If the plan reverses this default, name it.
- **Permission check at the resource, not just the route.** Route-level guards are fine for the obvious cases; resource-level checks catch indirect access (export endpoints, bulk operations, search filters).
- **Token = bearer until proven otherwise.** Anyone who possesses it can act as the subject. Plan transport, storage, and rotation accordingly.
- **MFA bypasses are bugs in disguise.** Any "for ops convenience" exception must have an audit log entry and an expiry.
- **Identity provider changes touch every consumer.** If switching providers or changing claims, the consumer inventory section IS the plan.
- **Privilege escalation paths get a dedicated review.** Any code path that lets an actor act as a higher-privileged actor (impersonation, account recovery, support tooling) is its own risk.

## Common Failure Modes

- **"It's only exposed to internal users."** Internal still means authenticated, authorized, audited. "Internal" is not an auth model.
- **Permission diff with no revokes recorded.** Granting access is visible; quietly removing access creates support tickets nobody connects to the change.
- **Audit logs that store the token / password / secret.** Auditability ≠ leakage. Hash, redact, or omit sensitive fields.
- **Session invalidation as an afterthought.** Shipping new auth without forcing re-login leaves users on stale sessions with stale claims for the lifetime of the token.
- **Role explosion.** Every new feature adds two new roles. Within a year, no one knows who has what. Name the role catalog and stick to it.
- **No path for the "I lost MFA" case.** Account recovery IS an auth flow, with all the rigor that implies.
