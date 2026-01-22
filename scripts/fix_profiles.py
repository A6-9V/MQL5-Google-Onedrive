#!/usr/bin/env python3
import os
import shutil
import sys
from pathlib import Path

def fix_profiles(mql5_dir):
    """
    Copies files from 'Default' profile to other profiles if they are empty.
    """
    mql5_path = Path(mql5_dir)

    # Handle case where user passes the root folder containing MQL5
    if (mql5_path / "MQL5").exists():
        mql5_path = mql5_path / "MQL5"

    charts_dir = mql5_path / "Profiles" / "Charts"
    if not charts_dir.exists():
        print(f"❌ Profiles/Charts directory not found at {charts_dir}")
        print("Please provide the path to the MQL5 data folder.")
        return

    default_dir = charts_dir / "Default"
    if not default_dir.exists():
        print(f"❌ 'Default' profile not found at {default_dir}. Cannot restore defaults.")
        return

    print(f"✅ Using 'Default' profile source: {default_dir}")

    # Iterate over all subdirectories in Charts
    count_fixed = 0
    for profile_dir in charts_dir.iterdir():
        if not profile_dir.is_dir():
            continue

        if profile_dir.name.lower() == "default":
            continue

        # Check if empty (no files)
        # We look for any file to be safe, or maybe specific .chr files
        has_files = any(f.is_file() for f in profile_dir.iterdir())

        if not has_files:
            print(f"⚠️ Profile '{profile_dir.name}' is empty. Copying defaults...")
            try:
                # Copy all files from Default to this profile
                for item in default_dir.iterdir():
                    if item.is_file():
                        shutil.copy2(item, profile_dir)
                print(f"  ✅ Restored defaults for '{profile_dir.name}'")
                count_fixed += 1
            except Exception as e:
                print(f"  ❌ Failed to restore '{profile_dir.name}': {e}")
        else:
            # print(f"  Profile '{profile_dir.name}' is intact.")
            pass

    if count_fixed == 0:
        print("All profiles are intact. No changes made.")
    else:
        print(f"Fixed {count_fixed} profiles.")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        target = sys.argv[1]
    else:
        # Try to guess
        cwd = Path.cwd()
        if (cwd / "mt5" / "MQL5").exists():
            target = cwd / "mt5"
        elif (cwd / "MQL5").exists():
            target = cwd
        else:
            target = cwd

    print(f"Running Profile Fixer on: {target}")
    fix_profiles(target)
