# CSS — Generic Patterns

CSS patterns for any project. Load when changes include `.css`, `.module.css`, `.scss`, or significant Tailwind class additions. Domain-specific choices (which CSS approach to use, design token naming) belong in `domain.md`.

---

## Approach detection

Check `config.md` or CLAUDE.md for the project's CSS approach. If not specified, detect from the codebase:

- **Tailwind** — `tailwind.config.*`, utility classes in JSX
- **CSS Modules** — `*.module.css` files, `styles.{className}` in JSX
- **Global CSS + BEM** — single stylesheet, class names like `block__element--modifier`
- **CSS-in-JS** — styled-components, emotion, vanilla-extract

Apply the conventions below for whichever approach is in use. Don't introduce a second approach into a codebase that already has one.

---

## Tailwind

Write utility classes in a consistent order (layout → typography → visual → interactive). Use the Prettier Tailwind plugin to enforce order automatically.

**Extract components** when the same utility class combination repeats 3+ times — use `@apply` in a CSS file or extract a React component. Don't copy-paste 15 classes everywhere:

```css
/* Repeated pattern → extract */
@layer components {
  .btn-primary {
    @apply rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2;
  }
}
```

**Design tokens via CSS custom properties**, referenced in `tailwind.config.ts`:

```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        brand: "var(--color-brand)",
      },
    },
  },
};
```

**No arbitrary values** (`text-[13px]`, `mt-[17px]`) for things that should be in the design system. Arbitrary values for one-off cases where no token fits — add a comment explaining why.

**Responsive prefix order:** `sm:` → `md:` → `lg:` → `xl:`. Mobile-first: base classes apply to small, prefixed classes override upward.

---

## CSS Modules

One module per component — `UserCard.module.css` alongside `UserCard.tsx`.

Class names: camelCase in the module file (`userName`, `primaryButton`). Accessed as `styles.userName`.

```typescript
import styles from "./UserCard.module.css";
<div className={styles.card}>
  <span className={styles.userName}>{user.name}</span>
</div>
```

Compose classes with `clsx` or `classnames` for conditional logic:

```typescript
import clsx from "clsx";
<div className={clsx(styles.card, isActive && styles.cardActive, className)} />
```

Avoid `:global()` except for third-party library overrides — it breaks encapsulation.

---

## BEM (Block Element Modifier)

Structure: `block`, `block__element`, `block--modifier`, `block__element--modifier`.

```css
.card { }
.card__header { }
.card__body { }
.card--featured { }
.card__header--compact { }
```

One block per file. File named after the block (`card.css`). No nesting beyond one level of specificity — BEM names are flat.

State classes prefixed with `is-` or `has-` (not BEM modifiers): `is-active`, `is-loading`, `has-error`.

---

## Custom properties (CSS variables)

Define tokens at `:root`. Use for colors, spacing scale, typography, shadow, border-radius — anything used in more than one place:

```css
:root {
  --color-brand: #2563eb;
  --color-brand-hover: #1d4ed8;
  --spacing-4: 1rem;
  --radius-md: 0.375rem;
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
}
```

Naming: `--{category}-{variant}`. Category first enables grouping and autocomplete.

**Dark mode** via `prefers-color-scheme` or data attribute, overriding the same tokens:

```css
@media (prefers-color-scheme: dark) {
  :root {
    --color-brand: #60a5fa;
  }
}
/* or */
[data-theme="dark"] { --color-brand: #60a5fa; }
```

---

## Specificity

Low specificity by default — class selectors only. Avoid:
- ID selectors (`#header`) — unnecessarily high specificity
- `!important` — almost always a specificity war, not a solution
- Long chains (`.nav .list .item .link`) — fragile and high specificity
- Element selectors for styling (use classes; elements for reset/base only)

**Specificity order in a stylesheet:**
1. CSS reset / base styles (lowest specificity)
2. Design tokens and custom properties
3. Component styles (class selectors)
4. Utility/override classes (highest intentional specificity)
5. `@media` and `@layer` — don't raise specificity, just scope

---

## Layout

**Flexbox** for one-dimensional layout (row or column). **Grid** for two-dimensional layout (rows + columns). Use both together freely.

```css
/* Common flex patterns */
.row { display: flex; gap: var(--spacing-4); align-items: center; }
.col { display: flex; flex-direction: column; gap: var(--spacing-2); }
.center { display: flex; align-items: center; justify-content: center; }

/* Grid for page layout */
.page {
  display: grid;
  grid-template-columns: 240px 1fr;
  grid-template-rows: auto 1fr auto;
  min-height: 100vh;
}
```

Avoid `position: absolute` for layout — use Flex/Grid. Reserve absolute positioning for overlays, tooltips, badges, decorative elements.

---

## Responsive design

**Mobile-first** — base styles for small screens, media queries override upward:

```css
.grid {
  display: grid;
  grid-template-columns: 1fr;          /* mobile: 1 column */
}

@media (min-width: 768px) {
  .grid { grid-template-columns: repeat(2, 1fr); } /* tablet: 2 columns */
}

@media (min-width: 1024px) {
  .grid { grid-template-columns: repeat(3, 1fr); } /* desktop: 3 columns */
}
```

Use named breakpoints from the design system or `tailwind.config.ts`. No magic pixel values scattered in media queries.

**`min-width` queries** (mobile-first) not `max-width` queries (desktop-first) — mixing them causes specificity conflicts.

**Container queries** (`@container`) when component behavior should depend on its own container, not the viewport.

---

## Animation and transitions

Transitions on interactive states (`hover`, `focus`, `active`) — short duration (`150ms`–`300ms`), `ease-out` for enter, `ease-in` for exit:

```css
.button {
  transition: background-color 150ms ease-out, box-shadow 150ms ease-out;
}
```

Respect `prefers-reduced-motion` — disable or reduce non-essential animation:

```css
@media (prefers-reduced-motion: reduce) {
  .animated { animation: none; transition: none; }
}
```

Use `transform` and `opacity` for animation — GPU-composited, no layout reflow. Avoid animating `width`, `height`, `top`, `left`, `margin`.

---

## Quality gate extensions

These extend the generic gates in `quality-gates.md` for CSS.

- **No `!important`** except for utility override classes where it's intentional and documented.
- **No ID selectors** for styling — class selectors only.
- **No magic pixel values in breakpoints** — use named tokens or design system values.
- **`prefers-reduced-motion` respected** for any animation added.
- **No inline styles for anything other than dynamic values** — computed values that depend on JS state are acceptable, static styles belong in CSS.
- **Design tokens used** for color, spacing, typography — no hardcoded hex or px values that duplicate existing tokens.
- **Consistent class naming** with the approach in use (Tailwind/BEM/Modules) — no mixing.
