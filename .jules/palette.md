## PALETTE'S JOURNAL - CRITICAL LEARNINGS ONLY

## 2026-02-13 - [Brand Color Contrast Failure]
**Learning:** The brand color `#667eea` fails WCAG AA contrast (3.4:1) against white backgrounds, affecting accessibility for text headers and primary buttons.
**Action:** Replace `#667eea` with `#4f46e5` (Indigo 600) which passes WCAG AA (5.5:1) while maintaining brand identity. Update all instances including `manifest.json`.

## 2026-02-13 - [Status Indicator Accessibility]
**Learning:** Status badges relying solely on color (`green` vs `red` backgrounds) fail WCAG 1.4.1 Use of Color. Screen readers may not convey the semantic meaning of the background color alone.
**Action:** Combine status colors with semantic SVG icons (check-circle/alert-triangle) and ensure sufficient contrast ratios (e.g., Green-700 instead of Green-500) for text legibility.
