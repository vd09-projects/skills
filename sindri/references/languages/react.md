# React — Generic Patterns

React-specific patterns. Load alongside `typescript.md` when the project uses React. Domain-specific patterns (state management choices, component library conventions) belong in `domain.md`.

Assumes: React 18+, functional components only, TypeScript.

---

## Component structure

Functional components only. No class components.

```typescript
interface UserCardProps {
  user: User;
  onSelect: (id: string) => void;
}

export function UserCard({ user, onSelect }: UserCardProps) {
  return (
    <button onClick={() => onSelect(user.id)}>
      {user.name}
    </button>
  );
}
```

One component per file. Filename matches component name (`UserCard.tsx`).

Props interface above the component, named `{ComponentName}Props`. Never inline the type in the function signature for non-trivial props.

Default exports for page-level components (Next.js convention). Named exports for everything else — they're refactorable and importable with autocomplete.

---

## Hook rules

The React hook rules are enforced by `eslint-plugin-react-hooks`:
- Only call hooks at the top level — never inside conditions, loops, or nested functions
- Only call hooks from React function components or custom hooks

**Custom hooks** extract reusable stateful logic. Name them `use{Something}`. They can call other hooks. They return values, not JSX:

```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);
  return debounced;
}
```

`useEffect` cleanup prevents memory leaks and stale closures — always return cleanup when effect creates subscriptions, timers, or event listeners.

---

## State management

**useState** for local UI state — toggle, form field value, loading flag.

**useReducer** when state has multiple sub-values that update together, or when next state depends on current state in non-trivial ways:

```typescript
type State = { count: number; status: "idle" | "loading" | "error" };
type Action = { type: "increment" } | { type: "reset" };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case "increment": return { ...state, count: state.count + 1 };
    case "reset":     return { count: 0, status: "idle" };
  }
}
```

**Context** for state that needs to reach many components without prop drilling — theme, auth user, locale. Not for frequently-updating state (causes re-renders across all consumers). Pattern: separate context for state vs. dispatch/actions:

```typescript
const CountContext = createContext<number | null>(null);
const CountDispatchContext = createContext<Dispatch<Action> | null>(null);

export function useCount() {
  const ctx = useContext(CountContext);
  if (ctx === null) throw new Error("useCount must be used inside CountProvider");
  return ctx;
}
```

**External state library** (Zustand, Jotai, Redux) for: cross-component state that changes frequently, optimistic updates, or state that lives outside React's tree. Don't reach for a library until Context + useState/useReducer is genuinely insufficient.

---

## Props patterns

**Composition over configuration** — accept `children` instead of a long list of render props. Avoids prop explosion.

```typescript
// Instead of: <Modal title="..." footer={...} body={...} closeButton={...} />
// Prefer:
<Modal>
  <Modal.Header>Title</Modal.Header>
  <Modal.Body>Content</Modal.Body>
  <Modal.Footer>Actions</Modal.Footer>
</Modal>
```

**Never spread unknown props onto DOM elements** — causes React warnings and forwards invalid HTML attributes:

```typescript
// Wrong:
function Input({ ...props }) { return <input {...props} />; }

// Right — destructure known props, spread rest only if you know what they are:
function Input({ value, onChange, className, ...rest }: InputProps) {
  return <input value={value} onChange={onChange} className={className} />;
}
```

**Callback props named `on{Event}`** (`onSelect`, `onChange`, `onDelete`). Handler functions named `handle{Event}` in the parent (`handleSelect`, `handleDelete`).

---

## Performance

`useMemo` and `useCallback` are for correctness (stable references) not speed. Apply when:
- A value is used as a `useEffect` dependency and recreating it would cause infinite loops
- A callback is passed to a memoized child component (`React.memo`)
- Computing the value is genuinely expensive (measured, not assumed)

Don't add them by default — they add complexity and have their own overhead.

`React.memo` on a component when it re-renders often with the same props and the re-render is measurably expensive. Profile first.

**Keys in lists** must be stable, unique IDs from the data — not array index. Index keys cause bugs when the list reorders or items are deleted:

```typescript
// Wrong:
items.map((item, i) => <Item key={i} {...item} />)

// Right:
items.map((item) => <Item key={item.id} {...item} />)
```

---

## Error boundaries

React 18 does not have a built-in functional error boundary. Use `react-error-boundary`:

```typescript
import { ErrorBoundary } from "react-error-boundary";

<ErrorBoundary fallback={<ErrorFallback />}>
  <FeatureComponent />
</ErrorBoundary>
```

Async errors (from `useEffect`, event handlers, or async server actions) are NOT caught by error boundaries — handle them with try/catch and local error state.

---

## Data fetching

**In Next.js App Router:** prefer Server Components for data fetching — no loading state, no useEffect, no client bundle cost.

**In client components:** use a data-fetching library (`TanStack Query`, `SWR`) rather than raw `useEffect` + `fetch`. Raw useEffect data fetching has well-known bugs (race conditions, no deduplication, no caching).

```typescript
// Prefer:
const { data, error, isLoading } = useQuery({
  queryKey: ["user", id],
  queryFn: () => fetchUser(id),
});

// Avoid for data fetching:
useEffect(() => {
  fetch(`/api/users/${id}`).then(r => r.json()).then(setUser);
}, [id]);
```

---

## Testing

**`@testing-library/react`** — query by role, label, text. Never by class name or component name.

```typescript
import { render, screen, fireEvent } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

it("calls onSelect when button clicked", async () => {
  const onSelect = vi.fn();
  render(<UserCard user={mockUser} onSelect={onSelect} />);
  await userEvent.click(screen.getByRole("button", { name: mockUser.name }));
  expect(onSelect).toHaveBeenCalledWith(mockUser.id);
});
```

**`userEvent` over `fireEvent`** — simulates real user interactions including focus, keyboard, and pointer events. `fireEvent` is for edge cases where `userEvent` doesn't fit.

Custom hooks tested with `renderHook`:

```typescript
import { renderHook, act } from "@testing-library/react";

it("debounces value", () => {
  vi.useFakeTimers();
  const { result } = renderHook(() => useDebounce("initial", 300));
  act(() => { vi.advanceTimersByTime(300); });
  expect(result.current).toBe("initial");
});
```

---

## Quality gate extensions

These extend the generic gates in `quality-gates.md` for React specifically.

- **No class components** — functional only.
- **Hook rules obeyed** — no hooks inside conditions or loops. `eslint-plugin-react-hooks` catches these.
- **No array index as key** in lists with reordering, deletion, or insertion.
- **`useEffect` has cleanup** when it sets up subscriptions, timers, or event listeners.
- **No raw `useEffect` for data fetching** — use TanStack Query, SWR, or Server Components.
- **Error paths handled** — async errors not caught by error boundaries need local error state.
- **`onX` / `handleX` naming** — consistent callback and handler naming.
