## PALETTE'S JOURNAL - CRITICAL LEARNINGS ONLY

## 2026-02-18 - Color Contrast in Dashboard Badges
**Learning:** Standard Tailwind colors like `text-green-500` or `bg-amber-500` often fail WCAG AA contrast ratios (4.5:1) when used with white text or backgrounds. Specifically, `bg-amber-500` (#f59e0b) on white text is ~2.2:1, which is inaccessible.
**Action:** Use darker shades (700 scale, e.g., `emerald-700`, `amber-700`, `indigo-700`) for badges and important text on white backgrounds to ensure accessibility compliance.
