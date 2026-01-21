#!/usr/bin/env python3
"""
Sync/Monitor Logs Script
This script monitors the latest log file in the logs/ directory and prints new lines to the console.
It serves as a tool to "keep up running" by surfacing logs automatically.
"""

import os
import time
import glob
from pathlib import Path

LOG_DIR = Path("logs")

def get_latest_log_file():
    """Returns the path to the latest log file in the logs directory."""
    if not LOG_DIR.exists():
        return None

    files = list(LOG_DIR.glob("*.log"))
    if not files:
        return None

    # Sort by modification time
    return max(files, key=os.path.getmtime)

def tail_file(filepath):
    """Tails the specified file, printing new lines as they are added."""
    print(f"Monitoring log file: {filepath}")
    print("Press Ctrl+C to stop.")

    with open(filepath, "r") as f:
        # Move to the end of the file
        f.seek(0, os.SEEK_END)

        while True:
            line = f.readline()
            if not line:
                time.sleep(1.0)
                continue

            print(line, end="")

def main():
    print("Starting log sync/monitor...")

    if not LOG_DIR.exists():
        print(f"Log directory '{LOG_DIR}' does not exist. Waiting...")

    filepath = None
    while not filepath:
        filepath = get_latest_log_file()
        if not filepath:
            time.sleep(5)
            # Check again
            if LOG_DIR.exists():
                print("Waiting for log files to appear...")

    try:
        tail_file(filepath)
    except KeyboardInterrupt:
        print("\nStopping log monitor.")
    except Exception as e:
        print(f"\nError monitoring log: {e}")

if __name__ == "__main__":
    main()
