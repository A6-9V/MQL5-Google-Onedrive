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

## 2026-02-05 - Lazy Loading MTF Confirmation in Indicators
**Learning:** Cross-timeframe data access (using iTime, CopyTime, or CopyBuffer on a different timeframe) is one of the more expensive operations in MQL5 OnCalculate. Moving these checks to a "lazy loading" pattern—where they only execute if a primary signal has already been confirmed on the current timeframe—can save significant CPU resources, as signals typically occur on less than 5% of bars.
**Action:** Always defer Multi-Timeframe (MTF) confirmation logic until after all primary single-timeframe signal conditions are met.

## 2026-02-05 - Native ArrayFill vs. Scripted Loops for Buffer Clearing
**Learning:** Native functions like ArrayFill and ArrayInitialize are implemented in optimized C++ within the MetaTrader terminal and are significantly faster than manual for-loops in MQL5 for clearing or initializing large indicator buffers. This is especially noticeable when calculating indicators on charts with thousands of bars.
**Action:** Use ArrayFill() to clear specific ranges of indicator buffers in OnCalculate instead of manual loops.
