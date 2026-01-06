#!/usr/bin/env python3
"""
Integration test for automation scripts.
Run this to verify all scripts are working correctly.
"""

import json
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = REPO_ROOT / "scripts"
CONFIG_DIR = REPO_ROOT / "config"


def test_python_orchestrator():
    """Test Python orchestrator."""
    print("Testing Python orchestrator...")
    
    # Test help
    result = subprocess.run(
        [sys.executable, str(SCRIPTS_DIR / "startup_orchestrator.py"), "--help"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Orchestrator help failed"
    assert "usage:" in result.stdout.lower(), "Help output missing"
    
    # Test dry-run
    result = subprocess.run(
        [sys.executable, str(SCRIPTS_DIR / "startup_orchestrator.py"), "--dry-run"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Dry-run failed"
    assert "DRY RUN" in result.stdout or "dry run" in result.stdout.lower(), "Dry-run not executed"
    
    print("✓ Python orchestrator OK")


def test_example_script():
    """Test example custom script."""
    print("Testing example custom script...")
    
    result = subprocess.run(
        [sys.executable, str(SCRIPTS_DIR / "example_custom_script.py"), "--help"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Example script help failed"
    
    result = subprocess.run(
        [sys.executable, str(SCRIPTS_DIR / "example_custom_script.py")],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Example script execution failed"
    # Check both stdout and stderr since logging can go to either
    output = (result.stdout + result.stderr).lower()
    assert "script completed" in output or "completed successfully" in output, "Script didn't complete"
    
    print("✓ Example script OK")


def test_config_file():
    """Test configuration file."""
    print("Testing configuration file...")
    
    config_file = CONFIG_DIR / "startup_config.json"
    assert config_file.exists(), f"Config file not found: {config_file}"
    
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    assert "components" in config, "Config missing 'components' key"
    assert isinstance(config["components"], list), "Components must be a list"
    assert len(config["components"]) > 0, "No components defined"
    
    for comp in config["components"]:
        assert "name" in comp, "Component missing 'name'"
        assert "executable" in comp, "Component missing 'executable'"
        assert "args" in comp, "Component missing 'args'"
    
    print("✓ Configuration file OK")


def test_shell_script():
    """Test shell script syntax."""
    print("Testing shell script...")
    
    script = SCRIPTS_DIR / "startup.sh"
    assert script.exists(), f"Shell script not found: {script}"
    
    # Check syntax
    result = subprocess.run(
        ["bash", "-n", str(script)],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, f"Shell script syntax error: {result.stderr}"
    
    # Check executable
    assert script.stat().st_mode & 0o111, "Shell script not executable"
    
    print("✓ Shell script OK")


def test_validator():
    """Test repository validator."""
    print("Testing repository validator...")
    
    result = subprocess.run(
        [sys.executable, str(SCRIPTS_DIR / "ci_validate_repo.py")],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, f"Validator failed: {result.stderr}"
    assert "OK:" in result.stdout, "Validator output unexpected"
    
    print("✓ Repository validator OK")


def main():
    """Run all tests."""
    print("=" * 60)
    print("Running Integration Tests")
    print("=" * 60)
    print()
    
    tests = [
        test_config_file,
        test_python_orchestrator,
        test_example_script,
        test_shell_script,
        test_validator,
    ]
    
    failed = []
    for test in tests:
        try:
            test()
        except AssertionError as e:
            print(f"✗ {test.__name__} FAILED: {e}")
            failed.append((test.__name__, str(e)))
        except Exception as e:
            print(f"✗ {test.__name__} ERROR: {e}")
            failed.append((test.__name__, str(e)))
        print()
    
    print("=" * 60)
    if not failed:
        print("All tests passed! ✓")
        print("=" * 60)
        return 0
    else:
        print(f"{len(failed)} test(s) failed:")
        for name, error in failed:
            print(f"  - {name}: {error}")
        print("=" * 60)
        return 1


if __name__ == "__main__":
    sys.exit(main())
