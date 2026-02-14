#!/usr/bin/env python3
"""
Integration test for automation scripts (Sequential version for performance testing).
"""

import json
import subprocess
import sys
import time
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = REPO_ROOT / "scripts"
CONFIG_DIR = REPO_ROOT / "config"

def test_python_orchestrator():
    print("Testing Python orchestrator...")
    result = subprocess.run([sys.executable, str(SCRIPTS_DIR / "startup_orchestrator.py"), "--help"], capture_output=True, text=True)
    assert result.returncode == 0
    result = subprocess.run([sys.executable, str(SCRIPTS_DIR / "startup_orchestrator.py"), "--dry-run"], capture_output=True, text=True)
    assert result.returncode == 0
    print("✓ Python orchestrator OK")

def test_example_script():
    print("Testing example custom script...")
    result = subprocess.run([sys.executable, str(SCRIPTS_DIR / "example_custom_script.py"), "--help"], capture_output=True, text=True)
    assert result.returncode == 0
    result = subprocess.run([sys.executable, str(SCRIPTS_DIR / "example_custom_script.py")], capture_output=True, text=True)
    assert result.returncode == 0
    print("✓ Example script OK")

def test_echo_hello():
    print("Testing echo and hello window scripts...")
    result = subprocess.run([sys.executable, str(SCRIPTS_DIR / "echo_hello.py"), "--help"], capture_output=True, text=True)
    assert result.returncode == 0
    result = subprocess.run([sys.executable, str(SCRIPTS_DIR / "echo_hello.py")], capture_output=True, text=True)
    assert result.returncode == 0
    script = SCRIPTS_DIR / "echo_hello.sh"
    result = subprocess.run(["bash", "-n", str(script)], capture_output=True, text=True)
    assert result.returncode == 0
    result = subprocess.run(["bash", str(script)], capture_output=True, text=True)
    assert result.returncode == 0
    print("✓ Echo and hello window scripts OK")

def test_config_file():
    print("Testing configuration file...")
    config_file = CONFIG_DIR / "startup_config.json"
    assert config_file.exists()
    with open(config_file, 'r') as f:
        config = json.load(f)
    assert "components" in config
    print("✓ Configuration file OK")

def test_shell_script():
    print("Testing shell script...")
    script = SCRIPTS_DIR / "startup.sh"
    assert script.exists()
    result = subprocess.run(["bash", "-n", str(script)], capture_output=True, text=True)
    assert result.returncode == 0
    print("✓ Shell script OK")

def test_validator():
    print("Testing repository validator...")
    result = subprocess.run([sys.executable, str(SCRIPTS_DIR / "ci_validate_repo.py")], capture_output=True, text=True)
    assert result.returncode == 0
    print("✓ Repository validator OK")

def main():
    start = time.time()
    print("=" * 60)
    print("Running Integration Tests (SEQUENTIAL)")
    print("=" * 60)

    test_config_file()
    test_python_orchestrator()
    test_example_script()
    test_echo_hello()
    test_shell_script()
    test_validator()

    end = time.time()
    print("=" * 60)
    print(f"All tests passed! Time: {end - start:.4f}s")
    print("=" * 60)

if __name__ == "__main__":
    main()
