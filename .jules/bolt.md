# Bolt's Journal ⚡

This journal is for CRITICAL, non-routine performance learnings ONLY.

- Codebase-specific bottlenecks
- Failed optimizations (and why)
- Surprising performance patterns
- Rejected changes with valuable lessons

## 2024-07-25 - MQL5 Native Functions vs. Scripted Loops
**Learning:** My assumption that a manual MQL5 loop over a pre-cached array would be faster than built-in functions like `iHighest()` and `iLowest()` was incorrect. The code review pointed out that MQL5's native, built-in functions are implemented in highly optimized C++ and are significantly faster than loops executed in the MQL5 scripting layer. The original comment stating this was correct.
**Action:** Always prefer using MQL5's built-in, native functions for calculations like finding highs/lows over manual loops, even if the data is already in a local array. The performance gain from the native implementation outweighs the overhead of the function call.

## 2024-07-26 - Native ArrayMaximum/ArrayMinimum Efficiency
**Learning:** Confirmed that native `ArrayMaximum()` and `ArrayMinimum()` are the preferred way to find extreme values in price arrays. Also, when using these functions, it's important to check if they return `-1` to avoid invalid array access, especially if the `count` or `start` parameters might be dynamic.
**Action:** When replacing manual loops with native array functions, always include a check for the `-1` return value to ensure robustness while gaining performance.

## 2026-01-19 - Native Object Cleanup in MQL5
**Learning:** While iterating through chart objects manually is flexible, it becomes a major bottleneck if the chart has thousands of objects. For simple prefix-based cleanup (often used in indicators), the native `ObjectsDeleteAll(0, prefix)` is significantly more efficient than a scripted loop calling `ObjectName()` and `StringFind()` for every object on the chart.
**Action:** Use `ObjectsDeleteAll()` for bulk object removal by prefix whenever the "keep N latest" logic is not strictly required or can be safely bypassed for performance.

## 2026-01-20 - Robust New Bar Check in MQL5 OnCalculate
**Learning:** An early exit in `OnCalculate` based on bar time MUST check `prev_calculated > 0`. If `prev_calculated == 0`, the terminal is requesting a full recalculation (e.g., after a history sync or data gap fill), and exiting early would result in stale data. Also, using `iTime()` is more robust than indexing into the `time[]` array if the array's series state is unknown.
**Action:** Always wrap "new bar" early exits in indicators with `if(prev_calculated > 0 && ...)` and prefer `iTime()` for the current bar's timestamp.

## 2026-01-20 - MQL5 OnTick Execution Flow Optimization
**Learning:** Significant performance gains in MQL5 EAs can be achieved by carefully ordering the logic in `OnTick`. Moving the `PositionSelect` check before `CopyRates` and `CopyBuffer` avoids expensive data operations when a trade is already active. Additionally, reducing the requested bar count in data fetching functions to the absolute minimum (e.g., 2 instead of 3) and using `SymbolInfoTick` for atomic, lazy price retrieval further reduces overhead.
**Action:** Always place 'gatekeeper' checks (new bar, position existence, terminal trading allowed) at the top of `OnTick` and minimize the data payload for indicator and price fetching to only what is strictly necessary for the current bar's logic.

## 2026-02-08 - Optimized Lot Calculation Flow
**Learning:** Redundant calculations in MQL5 can be avoided by consolidating the execution path of lot size normalization. In `CalculateLots`, applying margin-based clamping BEFORE the final normalization and volume limit checks (`MathFloor`, `MathMax`, `MathMin`) ensures these relatively expensive operations run only once, even if the initial risk-based lot size exceeds available margin. Additionally, caching the inverse of `SYMBOL_MARGIN_INITIAL` in `OnInit` (with a safety check for > 0) replaces a division with a faster multiplication in the trade execution path.
**Action:** Always structure lot calculation functions to identify all constraints (risk, margin, max lots) first, then apply rounding and final clamping in a single, unified step at the end of the function.
