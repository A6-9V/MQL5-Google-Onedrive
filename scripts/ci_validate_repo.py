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


def validate_and_collect_files() -> list[Path]:
    """
    Iterates through MQL5 source files, validates them (size & content),
    and returns a sorted list of valid files.
    """
    if not MQL5_DIR.exists():
        fail(f"Missing directory: {MQL5_DIR}")

    files: list[Path] = []

    # Single pass to find and validate files
    for p in MQL5_DIR.rglob("*"):
        if not p.is_file():
            continue

        if p.suffix.lower() not in {".mq5", ".mqh"}:
            continue

        # Optimization: Check size BEFORE reading content
        # Avoid accidentally committing huge build artifacts.
        sz = p.stat().st_size
        if sz > 5_000_000:
            fail(f"Unexpectedly large source file (>5MB): {p.relative_to(REPO_ROOT)} ({sz} bytes)")

        # Check for NUL bytes
        try:
            data = p.read_bytes()
            if b"\x00" in data:
                fail(f"NUL byte found in {p.relative_to(REPO_ROOT)}")
        except Exception as e:
            fail(f"Failed to read file {p.relative_to(REPO_ROOT)}: {e}")

        files.append(p)

    if not files:
        fail(f"No .mq5/.mqh files found under {MQL5_DIR}")

    return sorted(files)


def main() -> int:
    # Combined iteration and validation
    files = validate_and_collect_files()

    rel = [str(p.relative_to(REPO_ROOT)) for p in files]
    print("OK: found source files:")
    for r in rel:
        print(f"- {r}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
