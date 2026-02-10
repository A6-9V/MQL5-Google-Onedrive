#!/usr/bin/env python3
"""
Integration test for automation scripts.
Run this to verify all scripts are working correctly.
"""

import json
import subprocess
import sys
import concurrent.futures
import contextlib
import io
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


def test_echo_hello():
    """Test echo and hello window scripts."""
    print("Testing echo and hello window scripts...")
    
    # Test Python version
    result = subprocess.run(
        [sys.executable, str(SCRIPTS_DIR / "echo_hello.py"), "--help"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Echo hello help failed"
    
    result = subprocess.run(
        [sys.executable, str(SCRIPTS_DIR / "echo_hello.py")],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Echo hello execution failed"
    output = (result.stdout + result.stderr).lower()
    assert "hello window" in output, "Hello window not displayed"
    assert "echo" in output, "Echo not working"
    
    # Test shell version
    script = SCRIPTS_DIR / "echo_hello.sh"
    assert script.exists(), "Shell echo_hello script not found"
    
    result = subprocess.run(
        ["bash", "-n", str(script)],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, f"Shell script syntax error: {result.stderr}"
    
    result = subprocess.run(
        ["bash", str(script)],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Shell echo hello execution failed"
    output = (result.stdout + result.stderr).lower()
    assert "hello window" in output, "Hello window not displayed in shell version"
    
    print("✓ Echo and hello window scripts OK")


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


def run_test_captured(test_func):
    """Run a test function and capture its output."""
    output_capture = io.StringIO()
    success = False
    error_info = None

    try:
        with contextlib.redirect_stdout(output_capture), contextlib.redirect_stderr(output_capture):
            test_func()
        success = True
    except AssertionError as e:
        error_info = (str(e), "FAILED")
    except Exception as e:
        error_info = (str(e), "ERROR")

    return {
        "func_name": test_func.__name__,
        "output": output_capture.getvalue(),
        "success": success,
        "error_info": error_info
    }


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
        test_echo_hello,
        test_shell_script,
        test_validator,
    ]
    
    failed = []
    
    # Run tests in parallel
    # Use ProcessPoolExecutor because contextlib.redirect_stdout is not thread-safe
    # (sys.stdout is global). Processes provide isolation for output capturing.
    with concurrent.futures.ProcessPoolExecutor() as executor:
        # Submit all tests
        future_to_test = {executor.submit(run_test_captured, test): test for test in tests}

        # Process results as they complete
        for future in concurrent.futures.as_completed(future_to_test):
            result = future.result()

            # Print the captured output
            # Tests typically print newline at the end of their last print statement,
            # or we rely on the fact that print() adds a newline.
            # However, if we print `result["output"]` which ends in newline, and then `print()`,
            # we might get double newlines.
            # But the original code loop had `print()` after `try/except`.
            # So `test()` runs (prints stuff), then `print()` (newline).
            # So I should preserve that `print()`.

            output = result["output"]
            if output:
                print(output, end="")
                # If the last character was not a newline, we might want one.
                # But typically print() adds one.
                # Let's assume captured output ends with newline if the last call was print().
                # Actually, print("foo") -> "foo\n".
                # So output is "Testing...\n✓ ... OK\n"

            if not result["success"]:
                msg, type_ = result["error_info"]
                print(f"✗ {result['func_name']} {type_}: {msg}")
                failed.append((result['func_name'], msg))

            print() # Spacer between tests

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
