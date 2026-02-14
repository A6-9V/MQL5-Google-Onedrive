# Bolt's Journal ⚡

This journal is for CRITICAL, non-routine performance learnings ONLY.

- Codebase-specific bottlenecks
- Failed optimizations (and why)
- Surprising performance patterns
- Rejected changes with valuable lessons

## 2024-07-25 - MQL5 Native Functions vs. Scripted Loops
**Learning:** My assumption that a manual MQL5 loop over a pre-cached array would be faster than built-in functions like `iHighest()` and `iLowest()` was incorrect. The code review pointed out that MQL5's native, built-in functions are implemented in highly optimized C++ and are significantly faster than loops executed in the MQL5 scripting layer. The original comment stating this was correct.
**Action:** Always prefer using MQL5's built-in, native functions for calculations like finding highs/lows over manual loops, even if the data is already in a local array. The performance gain from the native implementation outweighs the overhead of the function call.

## 2026-01-23 - Python File System Checks
**Learning:** Checking for file existence (`os.path.exists`) before getting metadata (`os.path.getmtime`) introduces a redundant syscall. `os.stat()` provides both pieces of information in a single syscall and uses the EAFP (Easier to Ask for Forgiveness than Permission) pattern, which is more Pythonic and slightly faster, especially in high-frequency loops or handlers.
**Action:** Use `os.stat()` when both existence and metadata are needed, wrapping it in a `try...except OSError` block.

## 2026-01-26 - yfinance Bulk Download
**Learning:** `yfinance` Ticker.history in a loop is significantly slower than `yf.download` with a list of tickers due to sequential HTTP requests. `yf.download` with `group_by='ticker'` provides a consistent MultiIndex structure even for single tickers, simplifying bulk processing.
**Action:** Always prefer `yf.download(tickers)` over iterating `yf.Ticker(t)` when fetching data for multiple symbols.

## 2026-02-09 - Git Command Performance
**Learning:** `git for-each-ref` is a powerful tool for batch data retrieval, but without filtering, it processes *all* refs, including thousands of stale merged branches in older repositories. Calculating `ahead-behind` counts for these stale branches is O(N) where N is total branches, which can be significantly slower than O(M) where M is active branches.
**Action:** Always filter `git for-each-ref` with `--no-merged` (or `--merged` depending on use case) when only interested in a subset of branches, especially when expensive formatting options like `ahead-behind` are used.

## 2026-05-22 - MQL5 Trade Allowance Caching
**Learning:** In high-frequency MQL5 trading environments, repeated calls to `TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)` and `MQLInfoInteger(MQL_TRADE_ALLOWED)` within `OnTick` or `OnCalculate` can introduce significant cross-process latency. Even if these states rarely change, the overhead of the system call is incurred on every tick.
**Action:** Implement 1-second caching for trade allowance checks using `static` variables. Additionally, reorder execution flow to perform internal logic checks (e.g., daily limits, new bar checks) before any terminal API calls.
