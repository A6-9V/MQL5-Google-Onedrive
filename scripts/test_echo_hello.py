#!/usr/bin/env python3
"""
Tests for echo_hello.py functionality
"""

import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = REPO_ROOT / "scripts"


def test_python_echo_hello():
    """Test Python echo_hello script."""
    print("Testing Python echo_hello script...")
    
    # Test help
    result = subprocess.run(
        [sys.executable, str(SCRIPTS_DIR / "echo_hello.py"), "--help"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Echo hello help failed"
    assert "usage:" in result.stdout.lower(), "Help output missing"
    
    # Test default demo
    result = subprocess.run(
        [sys.executable, str(SCRIPTS_DIR / "echo_hello.py")],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Echo hello demo failed"
    output = (result.stdout + result.stderr).lower()
    assert "hello window" in output, "Hello window not displayed"
    assert "echo" in output, "Echo not working"
    assert "demo completed successfully" in output, "Demo didn't complete"
    
    # Test custom message
    result = subprocess.run(
        [sys.executable, str(SCRIPTS_DIR / "echo_hello.py"), "--message", "Test message"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Custom message failed"
    output = result.stdout + result.stderr
    assert "Test message" in output, "Custom message not echoed"
    
    print("✓ Python echo_hello script OK")


def test_shell_echo_hello():
    """Test shell echo_hello script."""
    print("Testing shell echo_hello script...")
    
    script = SCRIPTS_DIR / "echo_hello.sh"
    assert script.exists(), f"Shell script not found: {script}"
    
    # Check syntax
    result = subprocess.run(
        ["bash", "-n", str(script)],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, f"Shell script has syntax errors: {result.stderr}"
    
    # Test help
    result = subprocess.run(
        ["bash", str(script), "--help"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Echo hello help failed"
    assert "usage" in result.stdout.lower(), "Help output missing"
    
    # Test default demo
    result = subprocess.run(
        ["bash", str(script)],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Echo hello demo failed"
    output = (result.stdout + result.stderr).lower()
    assert "hello window" in output, "Hello window not displayed"
    assert "echo" in output, "Echo not working"
    assert "demo completed successfully" in output or "success" in output, "Demo didn't complete"
    
    # Test custom message
    result = subprocess.run(
        ["bash", str(script), "Test", "Shell", "Message"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "Custom message failed"
    output = result.stdout + result.stderr
    assert "Test Shell Message" in output, "Custom message not echoed"
    
    print("✓ Shell echo_hello script OK")


def main():
    """Run all tests."""
    print("=" * 60)
    print("Testing Echo and Hello Window Functionality")
    print("=" * 60)
    
    try:
        test_python_echo_hello()
        test_shell_echo_hello()
        
        print("=" * 60)
        print("All tests passed!")
        print("=" * 60)
        return 0
        
    except AssertionError as e:
        print(f"\n✗ Test failed: {e}")
        return 1
    except Exception as e:
        print(f"\n✗ Unexpected error: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
