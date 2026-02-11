## PALETTE'S JOURNAL - CRITICAL LEARNINGS ONLY

## 2026-02-11 - [Toast vs. Alert]
**Learning:** `confirm()` dialogs for updates are intrusive and block the UI, creating a jarring experience. Non-blocking Toast notifications provide a smoother, more modern "delight" factor while keeping the user informed.
**Action:** Replace native `alert`/`confirm` dialogs with custom, accessible Toast components for non-critical notifications.

## 2026-02-11 - [Color Contrast]
**Learning:** Standard Tailwind colors like `green-500` and `amber-500` often fail WCAG AA contrast ratios against white text.
**Action:** Default to `700` or `800` shade equivalents (e.g., `#047857` instead of `#10b981`) for text-on-background components like badges.
