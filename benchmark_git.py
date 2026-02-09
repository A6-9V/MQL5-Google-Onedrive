
import subprocess
import time
import sys

def run_command(cmd):
    start = time.time()
    subprocess.run(cmd, capture_output=True)
    end = time.time()
    return end - start

def main():
    print("Benchmarking git commands...")

    # Baseline: current implementation (all refs)
    cmd_all = ["git", "for-each-ref", "--format=%(refname:short)|%(committerdate:iso8601)|%(ahead-behind:origin/main)", "refs/remotes/origin"]
    time_all = run_command(cmd_all)
    print(f"Time for all refs: {time_all:.4f}s")

    # Optimized: only unmerged refs
    cmd_unmerged = ["git", "for-each-ref", "--no-merged", "origin/main", "--format=%(refname:short)|%(committerdate:iso8601)|%(ahead-behind:origin/main)", "refs/remotes/origin"]
    time_unmerged = run_command(cmd_unmerged)
    print(f"Time for unmerged refs: {time_unmerged:.4f}s")

    diff = time_all - time_unmerged
    print(f"Difference: {diff:.4f}s")

if __name__ == "__main__":
    main()
