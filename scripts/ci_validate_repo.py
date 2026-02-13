#!/usr/bin/env python3
"""
⚡ Bolt: Optimized repository sanity checks.
Consolidated loops, chunked reading for NUL bytes, and size-first validation.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
MQL5_DIR = REPO_ROOT / "mt5" / "MQL5"
MAX_FILE_SIZE = 5_000_000  # 5MB
CHUNK_SIZE = 65536         # 64KB


def fail(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    raise SystemExit(1)


def validate_repo() -> list[str]:
    """⚡ Bolt: Consolidated validation in a single pass for maximum performance."""
    if not MQL5_DIR.exists():
        fail(f"Missing directory: {MQL5_DIR}")

    found_files: list[str] = []

    # Use os.walk for efficient recursive traversal (faster than rglob for this purpose)
    for root, _, files in os.walk(MQL5_DIR):
        for filename in files:
            if not (filename.lower().endswith('.mq5') or filename.lower().endswith('.mqh')):
                continue

            filepath = os.path.join(root, filename)
            rel_path = os.path.relpath(filepath, REPO_ROOT)
            found_files.append(rel_path)

            # ⚡ Bolt: Check size BEFORE reading to avoid memory pressure and unnecessary I/O.
            try:
                file_stat = os.stat(filepath)
                if file_stat.st_size > MAX_FILE_SIZE:
                    fail(f"Unexpectedly large source file (>5MB): {rel_path} ({file_stat.st_size} bytes)")

                # ⚡ Bolt: Read in chunks to efficiently find NUL bytes without loading whole file.
                # Allows early exit if NUL is found in the first chunk.
                with open(filepath, 'rb') as f:
                    while True:
                        chunk = f.read(CHUNK_SIZE)
                        if not chunk:
                            break
                        if b"\x00" in chunk:
                            fail(f"NUL byte found in {rel_path}")
            except OSError as e:
                fail(f"Could not validate {rel_path}: {e}")

    if not found_files:
        fail(f"No .mq5/.mqh files found under {MQL5_DIR}")

    return sorted(found_files)


def main() -> int:
    files = validate_repo()

    print("OK: found source files:")
    for r in files:
        print(f"- {r}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
