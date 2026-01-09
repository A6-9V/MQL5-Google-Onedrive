#!/usr/bin/env python3
"""
Working Tree Review Script
Reviews all git branches, stashes, and working trees for the repository
"""

import subprocess
import sys
from pathlib import Path
from datetime import datetime
from collections import defaultdict

REPO_ROOT = Path(__file__).resolve().parents[1]


def run_git_command(cmd, capture_output=True):
    """Run a git command and return the result."""
    try:
        result = subprocess.run(
            ["git"] + cmd,
            cwd=REPO_ROOT,
            capture_output=capture_output,
            text=True,
            timeout=30,
            encoding='utf-8',
            errors='replace'
        )
        return result
    except subprocess.TimeoutExpired:
        return None
    except Exception as e:
        print(f"Error running git command: {e}", file=sys.stderr)
        return None


def get_branch_info():
    """Get information about all branches."""
    print("=" * 80)
    print("BRANCH REVIEW")
    print("=" * 80)
    print()
    
    # Local branches
    result = run_git_command(["branch"])
    local_branches = []
    if result and result.returncode == 0:
        local_branches = [b.strip().replace("*", "").strip() for b in result.stdout.strip().split("\n") if b.strip()]
        print(f"📌 Local Branches: {len(local_branches)}")
        for branch in local_branches:
            current = "*" if branch == local_branches[0] else " "
            print(f"  {current} {branch}")
    print()
    
    # Remote branches
    result = run_git_command(["branch", "-r"])
    remote_branches = []
    if result and result.returncode == 0:
        remote_branches = [b.strip() for b in result.stdout.strip().split("\n") if b.strip() and "HEAD" not in b]
        print(f"🌐 Remote Branches: {len(remote_branches)}")
        
        # Group by prefix
        branch_groups = defaultdict(list)
        for branch in remote_branches:
            parts = branch.replace("origin/", "").split("/")
            prefix = parts[0] if len(parts) > 1 else "other"
            branch_groups[prefix].append(branch)
        
        for prefix, branches in sorted(branch_groups.items()):
            print(f"\n  {prefix.upper()}: {len(branches)} branches")
            for branch in branches[:5]:  # Show first 5
                print(f"    - {branch}")
            if len(branches) > 5:
                print(f"    ... and {len(branches) - 5} more")
    print()
    
    # Merged branches
    result = run_git_command(["branch", "-r", "--merged", "main"])
    merged_branches = []
    if result and result.returncode == 0:
        merged_branches = [b.strip() for b in result.stdout.strip().split("\n") 
                          if b.strip() and "origin/main" not in b and "HEAD" not in b]
        if merged_branches:
            print(f"✅ Merged into main: {len(merged_branches)} branches")
            print("   (These can potentially be deleted)")
    print()
    
    # Unmerged branches
    result = run_git_command(["branch", "-r", "--no-merged", "main"])
    unmerged_branches = []
    if result and result.returncode == 0:
        unmerged_branches = [b.strip() for b in result.stdout.strip().split("\n") 
                            if b.strip() and "origin/main" not in b and "HEAD" not in b]
        if unmerged_branches:
            print(f"⚠️  Not merged into main: {len(unmerged_branches)} branches")
            print("   (These may contain unmerged changes)")
    print()


def get_stash_info():
    """Get information about stashes."""
    print("=" * 80)
    print("STASH REVIEW")
    print("=" * 80)
    print()
    
    result = run_git_command(["stash", "list"])
    if result and result.returncode == 0 and result.stdout.strip():
        stashes = result.stdout.strip().split("\n")
        print(f"📦 Stashes: {len(stashes)}")
        for stash in stashes:
            print(f"  - {stash}")
    else:
        print("📦 No stashes found")
    print()


def get_worktree_info():
    """Get information about git worktrees."""
    print("=" * 80)
    print("WORKTREE REVIEW")
    print("=" * 80)
    print()
    
    result = run_git_command(["worktree", "list"])
    if result and result.returncode == 0:
        worktrees = [w.strip() for w in result.stdout.strip().split("\n") if w.strip()]
        print(f"🌳 Worktrees: {len(worktrees)}")
        for worktree in worktrees:
            print(f"  - {worktree}")
    else:
        print("🌳 No additional worktrees found")
    print()


def get_status_info():
    """Get current working tree status."""
    print("=" * 80)
    print("WORKING TREE STATUS")
    print("=" * 80)
    print()
    
    result = run_git_command(["status", "--short"])
    if result and result.returncode == 0:
        if result.stdout.strip():
            print("⚠️  Uncommitted changes:")
            print(result.stdout)
        else:
            print("✅ Working tree is clean")
    print()
    
    # Check if ahead/behind
    result = run_git_command(["status", "-sb"])
    if result and result.returncode == 0:
        status_lines = result.stdout.strip().split("\n")
        for line in status_lines:
            if "ahead" in line or "behind" in line:
                print(f"📊 {line}")
    print()


def get_unpushed_commits():
    """Get commits that haven't been pushed."""
    print("=" * 80)
    print("UNPUSHED COMMITS")
    print("=" * 80)
    print()
    
    result = run_git_command(["log", "--oneline", "origin/main..HEAD"])
    if result and result.returncode == 0 and result.stdout.strip():
        commits = result.stdout.strip().split("\n")
        print(f"📤 Unpushed commits: {len(commits)}")
        for commit in commits:
            print(f"  - {commit}")
    else:
        print("✅ All commits are pushed")
    print()


def get_recent_activity():
    """Get recent commit activity."""
    print("=" * 80)
    print("RECENT ACTIVITY")
    print("=" * 80)
    print()
    
    result = run_git_command(["log", "--all", "--oneline", "--graph", "--decorate", "-15"])
    if result and result.returncode == 0:
        print(result.stdout)
    print()


def main():
    """Main review function."""
    print("\n" + "=" * 80)
    print(f"WORKING TREE REVIEW REPORT")
    print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80)
    print()
    
    get_status_info()
    get_unpushed_commits()
    get_branch_info()
    get_stash_info()
    get_worktree_info()
    get_recent_activity()
    
    print("=" * 80)
    print("REVIEW COMPLETE")
    print("=" * 80)
    print()
    print("Recommendations:")
    print("1. Push any unpushed commits")
    print("2. Review and potentially delete merged branches")
    print("3. Consider merging or closing unmerged branches")
    print("4. Clean up old stashes if no longer needed")
    print()


if __name__ == "__main__":
    main()
