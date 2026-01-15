#!/usr/bin/env python3
"""
Analyze PR optimizations to identify duplicates and best implementations
"""

import subprocess
import sys
from pathlib import Path
from collections import defaultdict

REPO_ROOT = Path(__file__).resolve().parents[1]
EA_FILE = REPO_ROOT / "mt5" / "MQL5" / "Experts" / "SMC_TrendBreakout_MTF_EA.mq5"


def run_git_command(cmd):
    """Run a git command."""
    try:
        result = subprocess.run(
            ["git"] + cmd,
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            timeout=30,
            encoding='utf-8',
            errors='replace'
        )
        return result.stdout if result.returncode == 0 else None
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return None


def fetch_pr(pr_number):
    """Fetch a PR branch."""
    branch_name = f"pr-{pr_number}"
    result = run_git_command(["fetch", "origin", f"pull/{pr_number}/head:{branch_name}"])
    return branch_name if result is not None else None


def get_pr_diff(pr_number, branch_name):
    """Get diff for a PR."""
    diff = run_git_command(["diff", "main.." + branch_name, "--", str(EA_FILE.relative_to(REPO_ROOT))])
    return diff


def analyze_optimization(diff_text):
    """Analyze what optimization a PR implements."""
    optimizations = {
        "new_bar_check": False,
        "early_exit": False,
        "caching": False,
        "copyrates_optimization": False,
        "lines_changed": 0
    }
    
    if not diff_text:
        return optimizations
    
    lines = diff_text.split('\n')
    optimizations["lines_changed"] = len([l for l in lines if l.startswith('+') or l.startswith('-')])
    
    diff_lower = diff_text.lower()
    
    # Check for new bar check patterns
    if any(keyword in diff_lower for keyword in ["new bar", "newbar", "lastbar", "last_bar", "bars(_symbol"]):
        optimizations["new_bar_check"] = True
    
    # Check for early exit patterns
    if any(keyword in diff_lower for keyword in ["return", "early exit", "if.*return"]):
        optimizations["early_exit"] = True
    
    # Check for caching
    if any(keyword in diff_lower for keyword in ["cache", "cached", "static", "global"]):
        optimizations["caching"] = True
    
    # Check for CopyRates optimization
    if "copyrates" in diff_lower or "copy_rates" in diff_lower:
        optimizations["copyrates_optimization"] = True
    
    return optimizations


def main():
    """Main analysis function."""
    print("=" * 80)
    print("PR OPTIMIZATION ANALYSIS")
    print("=" * 80)
    print()
    
    # Priority PRs to analyze
    priority_prs = [78, 76, 75, 74, 73, 72, 71, 70, 69, 65, 62, 58, 57, 56, 54, 52]
    
    print(f"Analyzing {len(priority_prs)} priority PRs...")
    print()
    
    pr_analyses = {}
    
    for pr_num in priority_prs:
        print(f"Fetching PR #{pr_num}...", end=" ")
        branch = fetch_pr(pr_num)
        if branch:
            print("✓")
            diff = get_pr_diff(pr_num, branch)
            analysis = analyze_optimization(diff)
            pr_analyses[pr_num] = {
                "branch": branch,
                "analysis": analysis,
                "diff": diff[:500] if diff else None  # First 500 chars
            }
        else:
            print("✗ Failed")
    
    print()
    print("=" * 80)
    print("OPTIMIZATION SUMMARY")
    print("=" * 80)
    print()
    
    # Group by optimization type
    by_type = defaultdict(list)
    
    for pr_num, data in pr_analyses.items():
        analysis = data["analysis"]
        opt_types = []
        if analysis["new_bar_check"]:
            opt_types.append("new_bar_check")
        if analysis["early_exit"]:
            opt_types.append("early_exit")
        if analysis["caching"]:
            opt_types.append("caching")
        if analysis["copyrates_optimization"]:
            opt_types.append("copyrates")
        
        opt_key = "+".join(opt_types) if opt_types else "unknown"
        by_type[opt_key].append((pr_num, analysis))
    
    # Print summary
    for opt_type, prs in sorted(by_type.items()):
        print(f"\n{opt_type.upper()}: {len(prs)} PRs")
        for pr_num, analysis in prs:
            print(f"  PR #{pr_num}: {analysis['lines_changed']} lines changed")
            if analysis['diff']:
                # Show first few lines of diff
                preview = analysis['diff'][:200].replace('\n', ' ')
                print(f"    Preview: {preview}...")
    
    # Identify duplicates
    print("\n" + "=" * 80)
    print("DUPLICATE DETECTION")
    print("=" * 80)
    print()
    
    # Group PRs with similar changes
    similar_groups = defaultdict(list)
    for pr_num, data in pr_analyses.items():
        analysis = data["analysis"]
        key = (
            analysis["new_bar_check"],
            analysis["early_exit"],
            analysis["caching"],
            analysis["copyrates_optimization"]
        )
        similar_groups[key].append(pr_num)
    
    for key, prs in similar_groups.items():
        if len(prs) > 1:
            print(f"Similar PRs ({len(prs)}): {prs}")
            print(f"  Features: new_bar={key[0]}, early_exit={key[1]}, caching={key[2]}, copyrates={key[3]}")
    
    # Recommendations
    print("\n" + "=" * 80)
    print("RECOMMENDATIONS")
    print("=" * 80)
    print()
    print("1. Review PRs with most comprehensive optimizations")
    print("2. Merge best implementation")
    print("3. Close duplicates")
    print("4. Test merged optimization")
    
    # Cleanup branches
    print("\nCleaning up temporary branches...")
    for pr_num, data in pr_analyses.items():
        run_git_command(["branch", "-D", data["branch"]])


if __name__ == "__main__":
    main()
