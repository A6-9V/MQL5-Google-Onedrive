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
    files: list[Path] = []
    for p in MQL5_DIR.rglob("*"):
        if p.is_file() and p.suffix.lower() in {".mq5", ".mqh"}:
            files.append(p)
    if not files:
        fail(f"No .mq5/.mqh files found under {MQL5_DIR}")
    return sorted(files)


def validate_files(files: list[Path]) -> None:
    for p in files:
        # Check size first to avoid reading large files
        sz = p.stat().st_size
        if sz > 5_000_000:
            fail(f"Unexpectedly large source file (>5MB): {p.relative_to(REPO_ROOT)} ({sz} bytes)")

        # Check for NUL bytes
        data = p.read_bytes()
        if b"\x00" in data:
            fail(f"NUL byte found in {p.relative_to(REPO_ROOT)}")


def main() -> int:
    files = iter_source_files()
    validate_files(files)

    rel = [str(p.relative_to(REPO_ROOT)) for p in files]
    print("OK: found source files:")
    for r in rel:
        print(f"- {r}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
