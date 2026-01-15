#!/usr/bin/env python3
"""
Pull Request Review Script
Reviews all pull requests and creates a comprehensive summary
"""

import subprocess
import sys
import json
from pathlib import Path
from datetime import datetime
from collections import defaultdict

REPO_ROOT = Path(__file__).resolve().parents[1]


def run_command(cmd, capture_output=True):
    """Run a command and return the result."""
    try:
        result = subprocess.run(
            cmd,
            cwd=REPO_ROOT,
            capture_output=capture_output,
            text=True,
            timeout=30,
            encoding='utf-8',
            errors='replace'
        )
        return result
    except Exception as e:
        print(f"Error running command: {e}", file=sys.stderr)
        return None


def get_prs_via_gh_cli():
    """Get PRs using GitHub CLI."""
    result = run_command(["gh", "pr", "list", "--state", "all", "--json", "number,title,state,author,createdAt,updatedAt,headRefName,baseRefName,isDraft,labels"])
    if result and result.returncode == 0:
        try:
            return json.loads(result.stdout)
        except json.JSONDecodeError:
            return []
    return None


def get_prs_via_git():
    """Get PR information via git branches."""
    # Get all branches that might be PR branches
    result = run_command(["git", "branch", "-r", "--no-merged", "main"])
    branches = []
    if result and result.returncode == 0:
        branches = [b.strip() for b in result.stdout.strip().split("\n") 
                    if b.strip() and "origin/main" not in b and "HEAD" not in b]
    
    # Get merged branches that might have been PRs
    result_merged = run_command(["git", "branch", "-r", "--merged", "main"])
    merged_branches = []
    if result_merged and result_merged.returncode == 0:
        merged_branches = [b.strip() for b in result_merged.stdout.strip().split("\n") 
                          if b.strip() and "origin/main" not in b and "HEAD" not in b]
    
    return {
        "open": branches,
        "merged": merged_branches
    }


def analyze_branch_name(branch_name):
    """Analyze branch name to extract PR information."""
    branch = branch_name.replace("origin/", "")
    
    info = {
        "type": "unknown",
        "category": "other",
        "description": branch
    }
    
    # Categorize branches
    if branch.startswith("Cursor/"):
        info["type"] = "cursor"
        info["category"] = "ai-generated"
        info["description"] = branch.replace("Cursor/A6-9V/", "")
    elif branch.startswith("copilot/"):
        info["type"] = "copilot"
        info["category"] = "ai-generated"
        info["description"] = branch.replace("copilot/", "")
    elif branch.startswith("bolt-"):
        info["type"] = "bolt"
        info["category"] = "optimization"
        info["description"] = branch.replace("bolt-", "")
    elif branch.startswith("feat/"):
        info["type"] = "feature"
        info["category"] = "feature"
        info["description"] = branch.replace("feat/", "")
    elif branch.startswith("feature/"):
        info["type"] = "feature"
        info["category"] = "feature"
        info["description"] = branch.replace("feature/", "")
    
    return info


def get_branch_info(branch_name):
    """Get detailed information about a branch."""
    branch = branch_name.replace("origin/", "")
    
    # Get commit count
    result = run_command(["git", "log", "--oneline", f"main..{branch_name}"])
    commit_count = 0
    commits = []
    if result and result.returncode == 0:
        commits = [c.strip() for c in result.stdout.strip().split("\n") if c.strip()]
        commit_count = len(commits)
    
    # Get last commit date
    result = run_command(["git", "log", "-1", "--format=%ci", branch_name])
    last_commit = None
    if result and result.returncode == 0 and result.stdout.strip():
        last_commit = result.stdout.strip()
    
    return {
        "branch": branch,
        "full_name": branch_name,
        "commit_count": commit_count,
        "commits": commits[:5],  # First 5 commits
        "last_commit_date": last_commit
    }


def main():
    """Main review function."""
    print("=" * 80)
    print("PULL REQUEST REVIEW")
    print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80)
    print()
    
    # Try GitHub CLI first
    prs = get_prs_via_gh_cli()
    
    if prs is not None:
        print(f"Found {len(prs)} pull requests via GitHub CLI")
        print()
        
        # Group by state
        by_state = defaultdict(list)
        for pr in prs:
            by_state[pr.get("state", "unknown")].append(pr)
        
        print("Pull Requests by State:")
        for state, pr_list in sorted(by_state.items()):
            print(f"  {state.upper()}: {len(pr_list)}")
        print()
        
        # Show open PRs
        open_prs = by_state.get("OPEN", [])
        if open_prs:
            print("=" * 80)
            print("OPEN PULL REQUESTS")
            print("=" * 80)
            for pr in open_prs:
                print(f"\nPR #{pr.get('number', 'N/A')}: {pr.get('title', 'No title')}")
                print(f"  Author: {pr.get('author', {}).get('login', 'Unknown')}")
                print(f"  Branch: {pr.get('headRefName', 'N/A')} -> {pr.get('baseRefName', 'main')}")
                print(f"  Created: {pr.get('createdAt', 'N/A')}")
                print(f"  Updated: {pr.get('updatedAt', 'N/A')}")
                print(f"  Draft: {'Yes' if pr.get('isDraft') else 'No'}")
                labels = [l.get('name') for l in pr.get('labels', [])]
                if labels:
                    print(f"  Labels: {', '.join(labels)}")
        
        # Show merged PRs
        merged_prs = by_state.get("MERGED", [])
        if merged_prs:
            print("\n" + "=" * 80)
            print(f"MERGED PULL REQUESTS ({len(merged_prs)} total)")
            print("=" * 80)
            print(f"\nShowing last 10 merged PRs:")
            for pr in merged_prs[-10:]:
                print(f"  PR #{pr.get('number', 'N/A')}: {pr.get('title', 'No title')}")
    
    else:
        # Fallback to git branch analysis
        print("GitHub CLI not available, analyzing branches...")
        print()
        
        branch_info = get_prs_via_git()
        
        open_branches = branch_info["open"]
        merged_branches = branch_info["merged"]
        
        print(f"Open branches (potential PRs): {len(open_branches)}")
        print(f"Merged branches (completed PRs): {len(merged_branches)}")
        print()
        
        # Categorize open branches
        categories = defaultdict(list)
        for branch in open_branches:
            info = analyze_branch_name(branch)
            categories[info["category"]].append((branch, info))
        
        print("=" * 80)
        print("OPEN BRANCHES (Potential Pull Requests)")
        print("=" * 80)
        print()
        
        for category, branches in sorted(categories.items()):
            print(f"{category.upper()}: {len(branches)} branches")
            for branch, info in branches[:10]:  # Show first 10
                branch_details = get_branch_info(branch)
                print(f"  - {info['description']}")
                print(f"    Branch: {branch_details['branch']}")
                print(f"    Commits: {branch_details['commit_count']}")
                if branch_details['last_commit_date']:
                    print(f"    Last commit: {branch_details['last_commit_date']}")
            if len(branches) > 10:
                print(f"    ... and {len(branches) - 10} more")
            print()
        
        print("=" * 80)
        print("MERGED BRANCHES (Completed Pull Requests)")
        print("=" * 80)
        print(f"\nTotal merged: {len(merged_branches)}")
        print("\nRecent merged branches:")
        for branch in merged_branches[:20]:
            info = analyze_branch_name(branch)
            print(f"  - {info['description']}")
    
    print("\n" + "=" * 80)
    print("REVIEW COMPLETE")
    print("=" * 80)
    print("\nNote: GitHub doesn't support 'pinning' pull requests directly.")
    print("Consider:")
    print("1. Creating a tracking issue for important PRs")
    print("2. Using labels to categorize PRs")
    print("3. Adding PRs to project boards")
    print("4. Creating a PR summary document")


if __name__ == "__main__":
    main()
