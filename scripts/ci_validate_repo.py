#!/usr/bin/env python3
"""
Lightweight repository sanity checks suitable for GitHub Actions.
This is intentionally NOT a compiler for MQL5 (MetaEditor isn't available on CI).
"""

from __future__ import annotations

import re
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


def scan_for_secrets() -> None:
    """
    Best-effort check to prevent accidentally committing credentials.

    Keep patterns targeted to avoid false positives and avoid printing the
    matched secret to CI logs (only path + line number are reported).
    """

    # Known credential formats (targeted)
    patterns: list[tuple[str, re.Pattern[str]]] = [
        ("telegram_bot_token", re.compile(r"\b\d{8,}:[A-Za-z0-9_-]{20,}\b")),
        ("github_pat", re.compile(r"\bgithub_pat_[A-Za-z0-9_]{20,}\b")),
        ("github_classic_pat", re.compile(r"\bghp_[A-Za-z0-9]{30,}\b")),
        ("github_actions_token", re.compile(r"\bghs_[A-Za-z0-9]{30,}\b")),
        ("aws_access_key_id", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
        # Very rough GCP API key format; still specific enough to avoid most noise.
        ("gcp_api_key", re.compile(r"\bAIza[0-9A-Za-z\-_]{30,}\b")),
    ]

    # Keep this scan fast and avoid binary/large files.
    scan_suffixes = {
        ".json", ".yml", ".yaml", ".toml", ".ini", ".cfg",
        ".py", ".ps1", ".sh", ".bat",
        ".mq5", ".mqh",
        ".html", ".js", ".css",
    }
    # Exclude documentation files from secret scanning (they contain examples)
    exclude_doc_paths = {
        "docs/API_ENVIRONMENT_SECRETS.md",
        "docs/GITLAB_CI_CD_SETUP.md", 
        "docs/Secrets_Management.md",
        "GITHUB_SECRETS_SETUP.md",
        "SECRETS_TEMPLATE.md",
    }
    scan_filenames = {"Dockerfile", "docker-compose.yml", "docker-compose.dev.yml"}
    excluded_dirnames = {
        ".git",
        "dist", "logs", "data",
        "__pycache__", "venv", "env", ".venv",
        "node_modules",
    }

    findings: list[tuple[str, Path, int]] = []

    for p in REPO_ROOT.rglob("*"):
        if not p.is_file():
            continue

        # Skip excluded directories anywhere in path
        if any(part in excluded_dirnames for part in p.parts):
            continue
        
        # Skip documentation files with example credentials
        rel_path = str(p.relative_to(REPO_ROOT))
        if rel_path in exclude_doc_paths:
            continue

        if p.name not in scan_filenames and p.suffix.lower() not in scan_suffixes:
            continue

        try:
            if p.stat().st_size > 2_000_000:
                continue
        except OSError:
            continue

        try:
            text = p.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            # Not critical; skip unreadable files rather than failing.
            continue

        # Line-by-line scan (lets us report line numbers without leaking the secret)
        for i, line in enumerate(text.splitlines(), start=1):
            for name, rx in patterns:
                if rx.search(line):
                    findings.append((name, p, i))
                    # Stop after the first matched pattern for this line
                    break

    if findings:
        msg_lines = ["Potential secret(s) detected in tracked files:"]
        for name, path, line_no in findings[:25]:
            msg_lines.append(f"- {name}: {path.relative_to(REPO_ROOT)}:{line_no}")
        if len(findings) > 25:
            msg_lines.append(f"... and {len(findings) - 25} more")
        msg_lines.append("Remove the credential from the repository and rotate/revoke it.")
        fail("\n".join(msg_lines))


def main() -> int:
    # Combined iteration and validation
    files = validate_and_collect_files()
    scan_for_secrets()

    rel = [str(p.relative_to(REPO_ROOT)) for p in files]
    print("OK: found source files:")
    for r in rel:
        print(f"- {r}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
