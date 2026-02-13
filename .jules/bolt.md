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

## 2026-02-13 - Git Branch Logic and N+1 Calls
**Learning:** Optimizing N+1 subprocess calls by batching with `git for-each-ref` is highly effective, but replacing filtering logic (like `git branch --no-merged`) requires careful verification. A simple function rename (`get_unmerged_branch_details`) and explicit safety checks (e.g., `ahead > 0`) clarify intent and prevent regressions where merged branches might slip through due to subtle differences or misunderstandings of command flags.
**Action:** When replacing a loop of subprocess calls with a single batch command, explicitly verify edge cases (like merged branches appearing as unmerged) and use descriptive function names to reflect the data scope.
