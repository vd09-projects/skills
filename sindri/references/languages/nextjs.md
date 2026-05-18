# Next.js — Generic Patterns

Next.js-specific patterns. Load alongside `typescript.md` and `react.md` when the project uses Next.js. Assumes: Next.js 13+ with App Router (current default). Page Router patterns noted where they differ significantly.

---

## App Router vs Pages Router

**App Router** (`app/` directory) — current default. Uses React Server Components by default. File-based routing via `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `route.ts`.

**Pages Router** (`pages/` directory) — legacy. All components are Client Components by default. `getServerSideProps`, `getStaticProps`, API routes at `pages/api/`.

If the project uses both: check which directory the feature lives in. Don't mix patterns.

---

## Server Components vs Client Components

**Server Components** (default in App Router) — run on the server, no client JS bundle, can `async/await` directly, can access server-only resources (DB, filesystem, env vars):

```typescript
// app/users/page.tsx — Server Component by default
export default async function UsersPage() {
  const users = await db.user.findMany(); // direct DB access, no API call needed
  return <UserList users={users} />;
}
```

**Client Components** — add `"use client"` directive at the top. Required for: event handlers, useState/useEffect/hooks, browser APIs, third-party client libraries.

```typescript
"use client";

export function SearchBar({ onSearch }: { onSearch: (q: string) => void }) {
  const [query, setQuery] = useState("");
  return <input value={query} onChange={e => { setQuery(e.target.value); onSearch(e.target.value); }} />;
}
```

**The pattern:** push `"use client"` as deep in the tree as possible. Keep parents as Server Components — they fetch data; pass it down as props to Client Components that handle interactivity.

Server Components **cannot** use hooks, event handlers, or browser APIs. Client Components **cannot** be async or directly import server-only code (use `server-only` package to enforce).

---

## Data fetching (App Router)

Fetch in Server Components with native `fetch` — Next.js extends it with caching:

```typescript
// Cached (default) — reused across requests, invalidated on revalidation:
const data = await fetch("https://api.example.com/data").then(r => r.json());

// No cache — fresh on every request (like getServerSideProps):
const data = await fetch("https://api.example.com/data", { cache: "no-store" }).then(r => r.json());

// Revalidate every N seconds:
const data = await fetch("https://api.example.com/data", { next: { revalidate: 60 } }).then(r => r.json());
```

Direct DB/ORM calls in Server Components don't use `fetch` — use `unstable_cache` from `next/cache` for caching:

```typescript
import { unstable_cache } from "next/cache";

const getCachedUser = unstable_cache(
  async (id: string) => db.user.findUnique({ where: { id } }),
  ["user"],
  { revalidate: 300, tags: ["user"] },
);
```

**Client-side data fetching:** TanStack Query or SWR — same as React patterns.

---

## Server Actions

Async functions that run on the server, called from Client Components. Replace API routes for form submissions and mutations.

```typescript
// app/actions/user.ts
"use server";

export async function createUser(formData: FormData) {
  const name = formData.get("name") as string;
  await db.user.create({ data: { name } });
  revalidatePath("/users");
}

// app/users/page.tsx (Server Component)
import { createUser } from "../actions/user";

export default function NewUserForm() {
  return <form action={createUser}><input name="name" /><button type="submit">Create</button></form>;
}
```

**Validate all Server Action inputs** — they're callable from any client. Never trust the shape of `FormData` without validation (use Zod):

```typescript
"use server";

const CreateUserSchema = z.object({ name: z.string().min(1).max(100) });

export async function createUser(formData: FormData) {
  const parsed = CreateUserSchema.safeParse({ name: formData.get("name") });
  if (!parsed.success) return { error: parsed.error.flatten() };
  await db.user.create({ data: parsed.data });
  revalidatePath("/users");
}
```

---

## API Routes (Route Handlers)

`app/api/{path}/route.ts` — named exports for each HTTP method:

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  const users = await db.user.findMany();
  return NextResponse.json(users);
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const parsed = CreateUserSchema.safeParse(body);
  if (!parsed.success) return NextResponse.json({ error: parsed.error }, { status: 400 });
  const user = await db.user.create({ data: parsed.data });
  return NextResponse.json(user, { status: 201 });
}
```

Use API Routes for: external webhooks, public API endpoints, third-party integrations. Prefer Server Actions for internal mutations from UI.

---

## Routing and navigation

File-based routing in `app/`:
- `page.tsx` — renders the route
- `layout.tsx` — wraps page and nested layouts (persists across navigation)
- `loading.tsx` — Suspense fallback shown while page loads
- `error.tsx` — error boundary for the route (`"use client"` required)
- `not-found.tsx` — rendered by `notFound()` call
- `[param]/` — dynamic segment, accessed via `params.param`
- `(group)/` — route group, doesn't affect URL

Navigation:
```typescript
import { useRouter } from "next/navigation"; // App Router (not next/router)
import Link from "next/link";

// Programmatic:
const router = useRouter();
router.push("/dashboard");
router.replace("/login"); // no history entry

// Declarative:
<Link href="/users/123">View user</Link>
```

`next/navigation` (App Router) ≠ `next/router` (Pages Router). Don't mix them.

---

## Environment variables

`NEXT_PUBLIC_` prefix exposes vars to the browser bundle. Without it, vars are server-only:

```
# .env.local
DATABASE_URL=...          # server-only — never exposed to client
NEXT_PUBLIC_API_URL=...   # exposed in browser JS
```

Access server-only vars in Server Components, Route Handlers, Server Actions. Never in Client Components — they'd be included in the client bundle.

Validate all env vars at startup (same pattern as TypeScript env var validation):

```typescript
// lib/env.ts
export const env = {
  databaseUrl: requireEnv("DATABASE_URL"),
  apiUrl: requireEnv("NEXT_PUBLIC_API_URL"),
};
```

---

## Images and assets

Use `next/image` for all images — automatic optimization, lazy loading, prevents CLS:

```typescript
import Image from "next/image";
<Image src="/avatar.png" alt="User avatar" width={64} height={64} />
```

For remote images, configure `remotePatterns` in `next.config.js`. Never disable image optimization.

---

## Middleware

`middleware.ts` at project root — runs on every request (or matched routes). Use for: auth redirects, locale detection, A/B testing headers. Keep it fast — no DB calls, no heavy computation:

```typescript
// middleware.ts
export function middleware(request: NextRequest) {
  if (!request.cookies.has("session") && !request.nextUrl.pathname.startsWith("/login")) {
    return NextResponse.redirect(new URL("/login", request.url));
  }
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"],
};
```

---

## Cache invalidation

```typescript
import { revalidatePath, revalidateTag } from "next/cache";

revalidatePath("/users");          // invalidate all cache for this path
revalidatePath("/users/[id]", "page"); // specific dynamic route
revalidateTag("user");             // invalidate all fetches tagged "user"
```

Call these in Server Actions or Route Handlers after mutations.

---

## Quality gate extensions

These extend the generic gates in `quality-gates.md` for Next.js specifically.

- **`"use client"` pushed as deep as possible** — Server Components preferred for data fetching.
- **Server Action inputs validated** — Zod or equivalent before any DB write.
- **No sensitive env vars in Client Components** — `NEXT_PUBLIC_` only for values that can be public.
- **Images use `next/image`** — not raw `<img>` tags.
- **`next/navigation` in App Router** — not `next/router` (Pages Router import).
- **`revalidatePath`/`revalidateTag` called after mutations** — stale cache after write is a bug.
- **`error.tsx` and `loading.tsx` present** for routes with async data or mutation risk.
- **Middleware stays lightweight** — no DB calls, no slow I/O.
