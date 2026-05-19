---
overlay: state-management
applies_to: [architecture, task]
---

# Frontend State Management Overlay

Composable concern: change touches client-side state — global stores, server-cache layers, URL state, form state, derived state, hydration boundaries. Forces explicit modeling of what state exists, where it lives, who derives from whom, so "just throw it in the global store" doesn't decay the app.

Framework-agnostic — applies whether the project uses Redux / Zustand / Jotai / MobX / Pinia / Vuex / NgRx / signals / vanilla state hooks. Principles transfer.

## Triggers

Activate when one or more present:

- Keywords: `store`, `state`, `global state`, `local state`, `slice`, `reducer`, `action`, `selector`, `derived state`, `computed`, `signal`, `atom`, `observable`, `hydrate`, `dehydrate`, `persist`
- Library signals: imports from state libs (Redux Toolkit, Zustand, Jotai, Recoil, MobX, Pinia, Vuex, NgRx, Effector, XState), server-cache libs (React Query / TanStack Query, SWR, Apollo Client, Relay, urql)
- Path/file signals: `store/`, `stores/`, `state/`, `slices/`, `atoms/`, `models/` (frontend), context providers
- Phrases: "share state between", "lift state up", "global vs local", "stale data", "cache invalidation", "hydration mismatch"

Do not activate for: backend-only state, pure presentational component edits, single-component local-state changes that don't cross boundaries.

## Required Slots

1. **State category for each touched state.** Server cache (remote data) vs URL state (shareable) vs form state (per-form) vs UI state (ephemeral, e.g., modal open) vs global app state (durable, cross-route). The category dictates where it lives.
2. **Ownership.** For each piece of state, which component / store / hook owns mutation. Multiple writers without coordination is the bug.
3. **Derivation graph.** What is derived from what — and whether derivation is memoized, computed eagerly, or recalculated on every read.
4. **Persistence stance.** localStorage, sessionStorage, IndexedDB, URL, cookie, none. For persisted state: migration path when shape changes.
5. **Hydration / SSR strategy (if applicable).** What state is server-rendered, what hydrates on client, how mismatches are detected and avoided.
6. **Stale-data tolerance.** For cached server data: TTL, refetch triggers (focus, mount, mutation), optimistic update stance.
7. **Devtools impact.** Does the change preserve or break the project's state-debug story (Redux DevTools, Query DevTools, custom inspector)?

## Template Sections

Append to base body at overlay insertion point.

### State Inventory

| State name | Category | Owner | Writers | Readers | Persistence |
|---|---|---|---|---|---|
| {name} | {server-cache / url / form / ui / app} | {component / store / hook} | {who mutates} | {who reads} | {layer + key} |

### Category Rules in Effect

- **Server cache** lives in: {React Query / SWR / Apollo / custom — name the layer}. Do not duplicate into global store.
- **URL state** lives in: {router params, query string, hash}. Anything shareable / bookmarkable / back-button-restorable.
- **Form state** lives in: {form library or local hooks}. Lifted only when explicitly shared.
- **UI state** lives in: nearest common ancestor, lifted only when proven necessary.
- **App state** lives in: {global store}. Reserved for truly cross-cutting state (auth, theme, feature flags, current org).

If the change violates a rule, justify in the slot or revise.

### Derivation Graph

```
{source state} ──► {derivation function} ──► {derived state} ──► {consumer}
```

- **Memoization strategy per derivation:** {memoized / recomputed / selector with equality check}
- **Cycles:** {confirm none — derivations are a DAG}
- **Cost of recomputation:** {cheap / O(n) over collection / async}

### Persistence Plan

| State | Layer | Key | Serialization | Migration on shape change |
|---|---|---|---|---|
| {state} | {localStorage / IndexedDB / cookie} | {key} | {JSON / structured-clone / custom} | {version field + migrate fn / wipe-on-mismatch} |

### Hydration & SSR (if applicable)

- **Server-rendered state:** {what is serialized into HTML / inline JSON}
- **Client hydration:** {how client picks it up — `__INITIAL_STATE__`, framework-specific hooks}
- **Mismatch detection:** {dev-mode warnings, hash check, none}
- **Suspense boundaries:** {if relevant — what awaits what}

### Server-Cache Policy (if applicable)

| Query / mutation | Cache key shape | Stale time | GC time | Refetch triggers | Optimistic update? |
|---|---|---|---|---|---|
| {query name} | {key tuple} | {ms} | {ms} | {focus / mount / invalidate} | {yes — with rollback / no} |

### State Migration (when changing shape of persisted/global state)

- **Old shape:** {sketch}
- **New shape:** {sketch}
- **Migration step:** {when loaded with old shape, transform to new — or wipe + restart}
- **Version field:** {how the migration knows which version it's reading}
- **User-data implications:** {what local state is lost; what is preserved}

### Devtools & Observability

- **Time-travel debug:** {preserved / broken — if broken, justify}
- **Action / mutation log:** {available / not — if not, plan to add}
- **State snapshots in error reports:** {included / excluded — and what is redacted}

## Discipline

- **Server cache is not global state.** Duplicating fetched data into a global store creates two sources of truth and one bug class (stale store vs fresh cache).
- **URL state is the most under-used category.** If a state value answers "did the user choose this and would they want to share / bookmark / back-button to it", it belongs in the URL.
- **Lifting state up has a cost.** Every component between owner and consumer re-renders on change. Lift only when shared, push down when not.
- **Derivation is not storage.** Anything that can be computed from existing state should not be stored separately — store grows, sync bugs follow.
- **Avoid useEffect-as-state-machine.** Reactive chains of effects across multiple state pieces are how state graphs become unreadable. Prefer explicit reducers / state machines.
- **Optimistic updates need rollback.** Without an explicit rollback path, a failed mutation leaves UI in a lie.
- **Persisted state needs versioning from day one.** Adding versioning later means a one-time cohort of broken users.

## Common Failure Modes

- **Global store as a junk drawer** — every team adds slices, nobody removes them, the bundle balloons and selectors slow.
- **Component-local state for shared data** — two siblings have their own copy, drift inevitable.
- **Derived state stored, source mutated** — derived value goes stale because the derivation never re-runs.
- **Cache keys without normalization** — same data fetched under three different keys, three copies in memory, all separately stale.
- **`useEffect(() => setState(...), [otherState])`** — derived state spelled as an effect. Use a selector or computed value.
- **Optimistic update with no `onError` rollback** — UI shows success, server returned 500, user finds out later.
- **SSR hydration mismatch on `Date.now()` or `Math.random()`** — non-deterministic render values cause React to throw away server HTML.
- **Persisted state surviving a logout** — privacy bug. Wipe scoped to user clears must include client state.
- **Reading from `localStorage` synchronously on render** — blocks first paint; cache the read in a ref.
