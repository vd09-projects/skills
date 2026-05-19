---
overlay: accessibility
applies_to: [architecture, task]
---

# Accessibility (a11y) Overlay

Composable concern: change touches user-facing UI — components, flows, forms, modals, navigation, dynamic content, media. Forces explicit accessibility targets so a11y isn't an afterthought patched up after a complaint or audit.

Language- and framework-agnostic. Applies to React, Vue, Svelte, Angular, plain HTML, native mobile a11y layers (the principles transfer).

## Triggers

Activate when one or more present:

- Keywords: `a11y`, `accessibility`, `ARIA`, `aria-label`, `role=`, `keyboard`, `screen reader`, `WCAG`, `Section 508`, `EAA`, `focus`, `tab order`, `contrast`, `color blind`, `caption`, `transcript`, `alt text`, `landmark`
- Path/file signals: form components, modal/dialog components, navigation/menu components, custom interactive widgets (anything that's not a plain button/link/input)
- Phrases: "keyboard nav", "screen reader users", "color is the only signal", "click target", "ARIA live", "announce", "skip link"
- Implicit (activate): new interactive widget, new form, new modal/overlay, new data visualization, new media element

Do not activate for: backend-only changes, internal-only admin tools with documented a11y exemption (rare — challenge the exemption), copy-only edits with no semantic change.

## Required Slots

1. **WCAG conformance target.** Which version and level — `WCAG 2.1 AA` is the modern default. Without a target, "accessible" is undefined.
2. **Assistive tech matrix.** Which screen readers, magnifiers, switch devices are in-scope — NVDA, JAWS, VoiceOver (macOS/iOS), TalkBack, Narrator. Drives test plan.
3. **Keyboard interaction model.** For new interactive components, what keys do what — Tab order, Enter/Space activation, Escape close, arrow keys for composite widgets.
4. **Focus management plan.** What gains focus on mount, what receives focus after modal close, where focus goes after async actions (form submit, navigation).
5. **Announcement strategy for dynamic changes.** Live regions, polite vs assertive, status messages — for any UI that updates without page navigation.
6. **Color and contrast.** Color contrast ratios for new visual treatments; non-color signals for state (focus rings, icons, text).
7. **Media accessibility.** Captions, transcripts, audio descriptions, autoplay behavior — if media is in scope.

## Template Sections

Append to base body at overlay insertion point.

### Conformance Target

- **Standard:** {WCAG 2.1 AA | WCAG 2.2 AA | Section 508 | EAA | custom subset}
- **Justification for any deviation:** {if not 2.1 AA, why}
- **Scope:** {which components/flows are in scope; explicit exemptions if any}

### Assistive Technology Matrix

| Tech | Platform | In-scope for this change | Test responsibility |
|---|---|---|---|
| NVDA | Windows | {yes/no} | {who tests} |
| JAWS | Windows | {yes/no} | {who tests} |
| VoiceOver | macOS | {yes/no} | {who tests} |
| VoiceOver | iOS | {yes/no} | {who tests} |
| TalkBack | Android | {yes/no} | {who tests} |
| Keyboard only | All | yes (always) | {who tests} |

### Keyboard Interaction Map

For each new interactive component:

| Component | Tab behavior | Activation | Dismiss | Composite navigation |
|---|---|---|---|---|
| {component} | {included in tab order / programmatic focus only} | {Enter / Space / both} | {Escape / explicit close} | {arrow keys, Home/End for composite widgets} |

Cross-reference WAI-ARIA Authoring Practices pattern by name where applicable (e.g., "follows ARIA Combobox pattern").

### Focus Management

| Moment | Focus moves to | Why |
|---|---|---|
| {modal open} | {first focusable inside modal / heading} | {reader context} |
| {modal close} | {trigger button / sensible next element} | {avoid focus loss} |
| {async submit success} | {confirmation message / next field} | {announce + continue} |
| {async submit failure} | {first error / error summary} | {jump to actionable info} |
| {route change} | {main heading / `<main>` landmark} | {SPA: replace browser default} |

### Live Region & Announcement Plan

- **Polite vs assertive:** {when each is used — polite for status, assertive for critical errors only}
- **Region locations:** {DOM nodes that hold live messages, by selector or component name}
- **Messages by event:** {event → message text, severity}

### Semantics & Landmarks

- **Landmarks in scope:** {header, nav, main, aside, footer — confirm each new page/view has exactly one main}
- **Heading hierarchy:** {h1-h6 plan — no skipped levels}
- **ARIA roles used:** {custom roles deployed only when native HTML cannot express the semantic}

### Color & Contrast

| Element | Foreground / background | Ratio | Required | Pass? |
|---|---|---|---|---|
| {body text} | {hex / hex} | {ratio} | {4.5:1 AA / 7:1 AAA} | {yes/no} |
| {UI controls} | {hex / hex} | {ratio} | {3:1 AA non-text} | {yes/no} |

- **Non-color state signals:** {focus ring style, error icon, underline on links — confirm not color-only}

### Media Accessibility (if applicable)

- **Captions:** {open / closed, language, source}
- **Transcripts:** {provided / not — where linked}
- **Audio descriptions:** {needed yes/no}
- **Autoplay:** {disabled by default, with user override}

### A11y Test Strategy

- **Automated:** {axe-core, Lighthouse, Pa11y — which, in CI yes/no}
- **Manual keyboard pass:** {who, on what flow, before merge}
- **Manual screen reader pass:** {assistive tech, flow, criteria}
- **User testing with disabled users:** {scope, recruiter, timing — for major changes}

## Discipline

- **Native HTML before ARIA.** A `<button>` beats `role="button"` every time. ARIA is for what HTML cannot express.
- **Visible focus is required.** Removing default focus styles without replacing them is a regression.
- **Keyboard reaches everything mouse does.** No mouse-only operations. No keyboard traps.
- **Don't rely on color alone.** State (error, success, selected) must be conveyed by at least one non-color signal.
- **Live regions exist before the announcement.** Adding the region to the DOM at the moment of the message means the message is missed.
- **Alt text is not optional.** Decorative images get `alt=""`. Functional images get a description. Photos with information get the information.
- **Captions for prerecorded video, transcripts for audio.** No exceptions for "internal training videos" — internal users have disabilities too.

## Common Failure Modes

- **`<div onClick>` instead of `<button>`** — not focusable, not announced, not Enter-activated, not Space-activated. Use the right element.
- **Modal that doesn't trap focus** — tabbing escapes into the background page, screen reader loses context.
- **Form errors with no announcement** — sighted users see red borders; screen reader users hear nothing.
- **`aria-hidden="true"` on an interactive element** — invisible to AT but reachable by keyboard. A focus trap nobody can escape.
- **Color contrast measured in dev mode against a different palette than ships** — measure on production assets and themes (including dark mode).
- **Skip-link absent on long pages** — keyboard users tab through nav on every page load.
- **Heading hierarchy used for visual sizing** — `<h3>` chosen because it "looks right" wrecks document outline.
- **`aria-label` overriding visible text** — when label and visible text diverge, voice control breaks.
