#!/usr/bin/env python3
"""
Script to merge best PRs and close duplicates
"""

import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]


def run_command(cmd, check=True):
    """Run a command."""
    try:
        result = subprocess.run(
            cmd,
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            timeout=30,
            encoding='utf-8',
            errors='replace'
        )
        if check and result.returncode != 0:
            print(f"Error: {result.stderr}", file=sys.stderr)
            return None
        return result.stdout
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return None


def merge_pr(pr_number, method="squash"):
    """Merge a PR."""
    print(f"Merging PR #{pr_number}...")
    result = run_command(["gh", "pr", "merge", str(pr_number), f"--{method}", "--delete-branch=false"], check=False)
    if result:
        print(f"✓ PR #{pr_number} merged successfully")
        return True
    else:
        print(f"✗ Failed to merge PR #{pr_number}")
        return False


def close_pr(pr_number, comment):
    """Close a PR with a comment."""
    print(f"Closing PR #{pr_number}...")
    result = run_command(["gh", "pr", "close", str(pr_number), "--comment", comment], check=False)
    if result:
        print(f"✓ PR #{pr_number} closed")
        return True
    else:
        print(f"✗ Failed to close PR #{pr_number}")
        return False


def main():
    """Main function."""
    print("=" * 80)
    print("PR MERGE AND CONSOLIDATION")
    print("=" * 80)
    print()
    
    # Step 1: Merge best PRs
    print("Step 1: Merging best PRs...")
    print()
    
    # PR #76: Early exit optimization
    if merge_pr(76):
        print("  ✓ PR #76 merged")
    else:
        print("  ✗ PR #76 merge failed or already merged")
    
    # PR #75: New bar check + CopyRates optimization
    if merge_pr(75):
        print("  ✓ PR #75 merged")
    else:
        print("  ✗ PR #75 merge failed or already merged")
    
    print()
    
    # Step 2: Close duplicates
    print("Step 2: Closing duplicate PRs...")
    print()
    
    # New bar check duplicates (if PR #75 merged)
    new_bar_duplicates = [74, 73, 72, 71, 70, 69, 65, 62, 58, 57, 56, 54, 52]
    for pr_num in new_bar_duplicates:
        close_pr(pr_num, "Merged via PR #75 - New bar check optimization")
    
    # Early exit duplicates (if PR #76 merged)
    early_exit_duplicates = [65, 56, 54]  # Note: some overlap with new_bar
    for pr_num in early_exit_duplicates:
        if pr_num not in new_bar_duplicates:  # Don't close twice
            close_pr(pr_num, "Merged via PR #76 - Early exit optimization")
    
    print()
    print("=" * 80)
    print("CONSOLIDATION COMPLETE")
    print("=" * 80)


if __name__ == "__main__":
    main()
