#!/usr/bin/env python3
"""
Jules Execution Helper Script
Helps execute tasks using Jules CLI for GitHub automation
"""

import subprocess
import sys
import json
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]


def run_jules_command(cmd_args):
    """Run a Jules command and return the result."""
    try:
        cmd = ["jules"] + cmd_args
        print(f"Executing: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=REPO_ROOT)
        
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)
        
        return result.returncode == 0
    except FileNotFoundError:
        print("❌ Jules CLI not found. Please install it first:")
        print("   npm install -g @google/jules")
        print("   jules login")
        return False


def main():
    """Execute Jules commands for repository automation."""
    
    print("=" * 60)
    print("Jules Execution Helper")
    print("=" * 60)
    print()
    
    # Check if Jules is installed
    try:
        result = subprocess.run(["jules", "--version"], capture_output=True, text=True, timeout=5)
        if result.returncode != 0:
            raise FileNotFoundError
    except (FileNotFoundError, subprocess.TimeoutExpired):
        print("❌ Jules CLI is not installed or not authenticated.")
        print("\nTo set up Jules:")
        print("1. Install: npm install -g @google/jules")
        print("2. Login: jules login")
        print("3. Authorize GitHub App for your organization")
        print("\nSee docs/Jules_CLI_setup.md for details")
        print("\nSee docs/Jules_Execution_Guide.md for usage instructions")
        return 1
    
    print("✅ Jules CLI is available")
    print()
    
    # List available repos
    print("Checking repository access...")
    run_jules_command(["remote", "list", "--repo"])
    print()
    
    # Show Jules help
    print("Jules commands available:")
    run_jules_command(["--help"])
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
