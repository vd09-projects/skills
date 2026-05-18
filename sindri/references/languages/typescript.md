# TypeScript — Generic Patterns

Generic TypeScript and JavaScript patterns for any well-engineered TS/JS codebase. Load when writing or reviewing TypeScript or JavaScript. Domain-specific conventions belong in `domain.md`.

Applies to: TypeScript (preferred), JavaScript. Node.js, Deno, and browser environments unless `config.md` specifies otherwise.

---

## Type annotations

Enable strict mode in `tsconfig.json`. Without it, type annotations are aspirational, not enforced.

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```

Public functions fully annotated — parameters and return type. Avoid `any`; use `unknown` when the type is genuinely unknown, then narrow explicitly.

```typescript
function parseConfig(raw: unknown): Config {
  if (!isConfig(raw)) throw new TypeError(`invalid config: ${JSON.stringify(raw)}`);
  return raw;
}
```

Prefer union types over enums for simple sets of values — unions are narrowed by TypeScript without runtime overhead:

```typescript
type Status = "pending" | "active" | "cancelled";
```

Use `interface` for object shapes that may be extended; use `type` for unions, intersections, and aliases. Mixing them works but be consistent per codebase.

Generic utility types over manual repetition: `Partial<T>`, `Required<T>`, `Pick<T, K>`, `Omit<T, K>`, `Readonly<T>`.

---

## Async and error handling

All async functions return `Promise<T>` — annotate it explicitly. Never `async` a function that doesn't `await`.

```typescript
async function fetchUser(id: number): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) throw new HttpError(response.status, `fetch user ${id}`);
  return response.json() as Promise<User>;
}
```

**Unhandled promise rejections crash Node.js processes** (since Node 15) and produce uncaught errors in browsers. Every `Promise` is either `await`ed, returned, or has `.catch()` attached.

Wrap errors with context before re-throwing:

```typescript
async function loadConfig(path: string): Promise<Config> {
  try {
    const text = await fs.readFile(path, "utf-8");
    return JSON.parse(text) as Config;
  } catch (cause) {
    throw new Error(`load config from ${path}`, { cause });
  }
}
```

`Error.cause` (ES2022, Node 16.9+) chains errors without losing the original. Use it instead of string concatenation on error messages.

Custom error classes for domain errors:

```typescript
class NotFoundError extends Error {
  constructor(readonly resource: string, readonly id: string | number) {
    super(`${resource} ${id} not found`);
    this.name = "NotFoundError";
  }
}

// Check it:
if (err instanceof NotFoundError) { ... }
```

Never `catch (e: any)` — use `catch (e: unknown)` and narrow:

```typescript
catch (e: unknown) {
  if (e instanceof Error) {
    logger.error("operation failed", { message: e.message, cause: e.cause });
  }
  throw e;
}
```

---

## Null safety

`strictNullChecks` (part of `strict`) makes `null` and `undefined` explicit. Never disable it.

Optional chaining `?.` and nullish coalescing `??` for safe access:

```typescript
const name = user?.profile?.displayName ?? "Anonymous";
```

Don't use `!` (non-null assertion) to silence TypeScript — fix the type instead. Exception: when you have just checked the value and the type system can't narrow it (rare).

---

## Structs and data shapes

Plain objects for data that's just data. Classes for objects with behavior.

`readonly` for properties that shouldn't change after construction:

```typescript
interface Config {
  readonly host: string;
  readonly port: number;
}
```

Use `as const` for literal objects and arrays that serve as lookup tables:

```typescript
const HTTP_METHODS = ["GET", "POST", "PUT", "DELETE"] as const;
type HttpMethod = typeof HTTP_METHODS[number]; // "GET" | "POST" | "PUT" | "DELETE"
```

Zod (or similar runtime validator) for external data (API responses, user input, env vars). TypeScript types are compile-time only — JSON that doesn't match the type is silently wrong at runtime:

```typescript
import { z } from "zod";

const UserSchema = z.object({
  id: z.number(),
  email: z.string().email(),
});
type User = z.infer<typeof UserSchema>;

const user = UserSchema.parse(apiResponse); // throws on invalid shape
```

---

## Imports and modules

Use ES module syntax (`import`/`export`), not CommonJS (`require`/`module.exports`), unless the project's `tsconfig` targets CommonJS explicitly.

Named exports preferred over default exports — named exports are refactorable and importable with autocomplete:

```typescript
// Preferred:
export function parseConfig(raw: unknown): Config { ... }
export type { Config };

// Avoid for non-entry-points:
export default function parseConfig(raw: unknown): Config { ... }
```

No barrel files (`index.ts` that re-exports everything from a package) unless intentional — they break tree-shaking and make circular dependency debugging painful.

Absolute imports over relative for cross-package imports. Configure `paths` in `tsconfig.json`:

```json
{ "paths": { "@app/*": ["src/*"] } }
```

---

## Testing

**Vitest** for new projects (fast, native ESM, compatible with Jest API). **Jest** for existing Jest projects — don't migrate without a reason.

Test file convention: `{module}.test.ts` co-located with the module, or `__tests__/` for larger groupings.

```typescript
import { describe, it, expect, vi, beforeEach } from "vitest";

describe("parseConfig", () => {
  it("returns parsed config for valid input", () => {
    expect(parseConfig({ host: "localhost", port: 3000 })).toEqual({
      host: "localhost",
      port: 3000,
    });
  });

  it("throws on missing required field", () => {
    expect(() => parseConfig({ host: "localhost" })).toThrow();
  });
});
```

**`vi.fn()` / `jest.fn()`** for mock functions. `vi.spyOn()` to spy on module exports. Don't mock what you own — write fakes for internal dependencies.

**Fake timers** for code that uses `setTimeout`, `setInterval`, `Date.now()`:

```typescript
beforeEach(() => { vi.useFakeTimers(); });
afterEach(() => { vi.useRealTimers(); });

it("retries after 1 second", async () => {
  const p = retryable();
  vi.advanceTimersByTime(1000);
  await expect(p).resolves.toBe("ok");
});
```

**`@testing-library`** for React/DOM tests — test behavior, not implementation. Query by role, label, or text, not by class names or test IDs unless necessary.

---

## Common runtime patterns

**Environment variables** — access through a typed config module, never `process.env.FOO` scattered through business logic:

```typescript
// config.ts — validated at startup
const config = {
  databaseUrl: requireEnv("DATABASE_URL"),
  port: parseInt(requireEnv("PORT"), 10),
} as const;

function requireEnv(key: string): string {
  const val = process.env[key];
  if (!val) throw new Error(`missing required env var: ${key}`);
  return val;
}
```

**Graceful shutdown** for Node.js servers:

```typescript
process.on("SIGTERM", async () => {
  await server.close();
  await db.disconnect();
  process.exit(0);
});
```

**Structured logging** — `pino` for Node.js (fast, JSON output). Never `console.log` in production code:

```typescript
import pino from "pino";
const logger = pino({ level: process.env.LOG_LEVEL ?? "info" });
logger.info({ userId: user.id }, "user logged in");
```

---

## Linting

**ESLint** with `typescript-eslint`. Recommended config:

```json
{
  "extends": ["eslint:recommended", "plugin:@typescript-eslint/strict-type-checked"]
}
```

Key rules that matter most:

- `@typescript-eslint/no-explicit-any` — ban `any`
- `@typescript-eslint/no-floating-promises` — unhandled promises caught at lint time
- `@typescript-eslint/no-misused-promises` — async function passed where void callback expected
- `@typescript-eslint/explicit-function-return-type` — or infer when obvious
- `no-console` — use structured logger instead

**Prettier** for formatting. Not negotiable — consistent formatting is not a style debate.

---

## Quality gate extensions

These extend the generic gates in `quality-gates.md` for TypeScript specifically. Both sets must pass before `Ready for review.`

- **No `any`** — use `unknown` and narrow, or fix the type. `// eslint-disable-next-line @typescript-eslint/no-explicit-any` requires a comment explaining why.
- **No floating promises** — every `Promise` is awaited, returned, or `.catch()`-ed. `@typescript-eslint/no-floating-promises` catches these at lint time.
- **No `console.log` in production paths** — use the project's structured logger.
- **Env vars accessed through typed config module** — not `process.env.FOO` in business logic.
- **External data validated at runtime** — API responses, user input, env vars validated with Zod or equivalent before use as typed values.
- **Async functions have error boundaries** — any `async` function that can reject has its errors either caught and handled or explicitly propagated to a caller that handles them.
- **`Error.cause` used for re-thrown errors** — wrapping adds context, doesn't replace it.
