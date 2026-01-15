#!/usr/bin/env python3
"""
Sync MQL5 files and documentation to GitHub Pages repository.
This script helps synchronize content with Mouy-leng's GitHub Pages repository.
"""

import argparse
import subprocess
import sys
from pathlib import Path
from datetime import datetime

REPO_ROOT = Path(__file__).resolve().parents[1]
PAGES_REPO = "https://github.com/Mouy-leng/-LengKundee-mql5.github.io.git"
PAGES_BRANCH = "main"


def run_command(cmd, cwd=None, check=True):
    """Run a shell command and return the result."""
    print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if check and result.returncode != 0:
        print(f"Error: {result.stderr}", file=sys.stderr)
        sys.exit(result.returncode)
    return result


def sync_to_pages(dry_run=False):
    """Sync MQL5 files and docs to GitHub Pages repository."""
    pages_dir = REPO_ROOT / "pages-repo"
    
    print("=" * 60)
    print("GitHub Pages Sync Script")
    print("=" * 60)
    print(f"Source: {REPO_ROOT}")
    print(f"Target: {PAGES_REPO}")
    print(f"Branch: {PAGES_BRANCH}")
    print()
    
    if dry_run:
        print("[DRY RUN] Would sync the following:")
        print(f"  - mt5/MQL5/ -> pages-repo/mql5/")
        print(f"  - docs/ -> pages-repo/docs/")
        print(f"  - README.md -> pages-repo/README.md")
        return
    
    # Clone or update pages repository
    if pages_dir.exists():
        print("Updating existing pages repository...")
        run_command(["git", "pull"], cwd=pages_dir)
    else:
        print("Cloning pages repository...")
        run_command(["git", "clone", PAGES_REPO, str(pages_dir)])
        run_command(["git", "checkout", PAGES_BRANCH], cwd=pages_dir)
    
    # Sync MQL5 files
    print("\nSyncing MQL5 files...")
    mql5_source = REPO_ROOT / "mt5" / "MQL5"
    mql5_dest = pages_dir / "mql5"
    if mql5_source.exists():
        mql5_dest.mkdir(parents=True, exist_ok=True)
        run_command(["xcopy", "/E", "/I", "/Y", str(mql5_source), str(mql5_dest)], 
                   shell=True, check=False)
        print(f"  ✓ Synced MQL5 files")
    
    # Sync documentation
    print("\nSyncing documentation...")
    docs_source = REPO_ROOT / "docs"
    docs_dest = pages_dir / "docs"
    if docs_source.exists():
        docs_dest.mkdir(parents=True, exist_ok=True)
        run_command(["xcopy", "/E", "/I", "/Y", str(docs_source), str(docs_dest)], 
                   shell=True, check=False)
        print(f"  ✓ Synced documentation")
    
    # Copy README
    print("\nCopying README...")
    readme_source = REPO_ROOT / "README.md"
    if readme_source.exists():
        run_command(["copy", str(readme_source), str(pages_dir / "README.md")], 
                   shell=True, check=False)
        print(f"  ✓ Copied README.md")
    
    # Commit and push
    print("\nCommitting changes...")
    run_command(["git", "add", "-A"], cwd=pages_dir)
    
    # Check if there are changes
    result = run_command(["git", "diff", "--staged", "--quiet"], cwd=pages_dir, check=False)
    if result.returncode != 0:
        commit_msg = f"Auto-sync from MQL5-Google-Onedrive: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        run_command(["git", "commit", "-m", commit_msg], cwd=pages_dir)
        print(f"  ✓ Committed changes")
        
        print("\nPushing to GitHub Pages...")
        run_command(["git", "push", "origin", PAGES_BRANCH], cwd=pages_dir)
        print(f"  ✓ Pushed to {PAGES_BRANCH}")
    else:
        print("  ℹ No changes to commit")
    
    print("\n" + "=" * 60)
    print("✅ Sync completed successfully!")
    print("=" * 60)


def main():
    parser = argparse.ArgumentParser(
        description="Sync MQL5 files and documentation to GitHub Pages repository"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be synced without making changes"
    )
    
    args = parser.parse_args()
    sync_to_pages(dry_run=args.dry_run)


if __name__ == "__main__":
    main()
