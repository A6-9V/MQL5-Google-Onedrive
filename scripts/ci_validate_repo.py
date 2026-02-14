#!/usr/bin/env python3
"""
Lightweight repository sanity checks suitable for GitHub Actions.
This is intentionally NOT a compiler for MQL5 (MetaEditor isn't available on CI).
"""

from __future__ import annotations

import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
MQL5_DIR = REPO_ROOT / "mt5" / "MQL5"


def fail(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    raise SystemExit(1)


def iter_source_files() -> list[Path]:
    if not MQL5_DIR.exists():
        fail(f"Missing directory: {MQL5_DIR}")

    # ⚡ Bolt: Performance optimization - use specific globs to avoid iterating over
    # every file in the directory tree (like .git or other non-source files).
    files: list[Path] = []
    for ext in ("*.mq5", "*.mqh"):
        files.extend(MQL5_DIR.rglob(ext))

    if not files:
        fail(f"No .mq5/.mqh files found under {MQL5_DIR}")
    return sorted(files)


def check_no_nul_bytes(files: list[Path]) -> None:
    for p in files:
        # Note: check_reasonable_size should be called before this to avoid reading huge files.
        data = p.read_bytes()
        if b"\x00" in data:
            fail(f"NUL byte found in {p.relative_to(REPO_ROOT)}")


def check_reasonable_size(files: list[Path]) -> None:
    # Avoid accidentally committing huge build artifacts.
    for p in files:
        sz = p.stat().st_size
        if sz > 5_000_000:
            fail(f"Unexpectedly large source file (>5MB): {p.relative_to(REPO_ROOT)} ({sz} bytes)")


def main() -> int:
    files = iter_source_files()

    # ⚡ Bolt: Reorder checks - verify size BEFORE reading content to prevent memory issues with large files.
    check_reasonable_size(files)
    check_no_nul_bytes(files)

    rel = [str(p.relative_to(REPO_ROOT)) for p in files]
    print("OK: found source files:")
    for r in rel:
        print(f"- {r}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
