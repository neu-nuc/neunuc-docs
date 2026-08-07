# Accessibility

NeuNuc is built to work for everyone. The operator dashboard, outreach surfaces, and documentation conform to WCAG 2.1 Level AA. The runtime API is screen-reader friendly by default — all responses include structured text that can be consumed programmatically.

---

## Standards

| Standard | Version | Conformance |
|----------|---------|-------------|
| WCAG | 2.1 | Level AA |
| Section 508 | Refresh | Applies to all federal deployments |
| EN 301 549 | v3.2.1 | European accessibility standard |

---

## Operator surfaces

### Keyboard navigation

Every interactive element in the operator dashboard and outreach surfaces is reachable via keyboard:

- `Tab` — Move forward through focusable elements
- `Shift + Tab` — Move backward
- `Enter` / `Space` — Activate buttons and links
- `Escape` — Close modals and dropdowns

Focus indicators are visible with a 2px offset outline in the accent color.

### Screen reader support

All outreach surfaces use semantic HTML5 landmarks:

```html
<header role="banner">...</header>
<nav role="navigation" aria-label="Main">...</nav>
<main role="main">...</main>
<footer role="contentinfo">...</footer>
```

Form inputs include `aria-label` or associated `<label>` elements. Error messages are linked via `aria-describedby`.

### Color and contrast

| Element | Foreground | Background | Ratio |
|---------|-----------|------------|-------|
| Body text | `#1a1a1a` | `#f7f8f9` | 15.3:1 |
| Muted text | `#666666` | `#f7f8f9` | 5.4:1 |
| Accent link | `#4a7a9e` | `#f7f8f9` | 4.6:1 |
| Dark mode body | `#d0d0d0` | `#111111` | 12.1:1 |

All ratios exceed WCAG AA thresholds (4.5:1 for normal text, 3:1 for large text).

### Motion and animation

No auto-playing animations. No flashing content. Reduced motion is respected via `prefers-reduced-motion`:

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Runtime API accessibility

The REST and WebSocket APIs return structured data that can be consumed by assistive technologies:

```json
{
  "ok": true,
  "text": "The capital of France is Paris.",
  "elapsed_ms": 450,
  "trace_id": "a1b2c3d4"
}
```

All error responses include a human-readable `error` field:

```json
{
  "ok": false,
  "error": "Rate limit exceeded. Try again in 30 seconds.",
  "retry_after": 30
}
```

---

## Accessibility statement

NeuNuc is committed to ensuring digital accessibility for people with disabilities. We are continually improving the user experience for everyone and applying the relevant accessibility standards.

**Conformance status:** Partially conformant. Some third-party dependencies may not fully meet WCAG 2.1 AA. We monitor upstream releases and update accordingly.

**Feedback:** Contact `accessibility@neunuc.com` with accessibility issues. Response within 48 hours.

**Assessment method:** Self-evaluation using axe-core and manual keyboard testing.

---

## Remediation backlog

| Issue | Impact | Priority | Target |
|-------|--------|----------|--------|
| Custom icon set lacks alt text in some contexts | Low | Medium | Q1 2026 |
| Mermaid diagrams are not screen-reader accessible | Medium | Low | Q2 2026 |
| Voice pipeline transcription accuracy varies with accent | Medium | Medium | Ongoing |
