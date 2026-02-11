#!/usr/bin/env python3
"""
Tests for common utility modules.
Ensures shared utilities work correctly after refactoring.
"""

import sys
import os
import logging
from pathlib import Path

# Add scripts to path
REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "scripts"))

from common import paths, logger_config, config_loader, ai_client


def test_paths():
    """Test path definitions."""
    print("Testing paths module...")
    
    # Verify paths are Path objects
    assert isinstance(paths.REPO_ROOT, Path), "REPO_ROOT should be Path"
    assert isinstance(paths.SCRIPTS_DIR, Path), "SCRIPTS_DIR should be Path"
    assert isinstance(paths.CONFIG_DIR, Path), "CONFIG_DIR should be Path"
    
    # Verify paths exist
    assert paths.REPO_ROOT.exists(), "REPO_ROOT should exist"
    assert paths.SCRIPTS_DIR.exists(), "SCRIPTS_DIR should exist"
    
    # Verify directory structure
    assert paths.SCRIPTS_DIR.parent == paths.REPO_ROOT, "SCRIPTS_DIR should be under REPO_ROOT"
    
    print("✓ Paths module OK")


def test_logger_config():
    """Test logging configuration."""
    print("Testing logger_config module...")
    
    # Test basic logging setup
    logger = logger_config.setup_basic_logging()
    assert isinstance(logger, logging.Logger), "Should return logger"
    
    # Test custom logger setup
    custom_logger = logger_config.setup_logger(
        name="test_logger",
        level=logging.DEBUG
    )
    assert custom_logger.name == "test_logger", "Should have correct name"
    assert custom_logger.level == logging.DEBUG, "Should have correct level"
    
    print("✓ Logger config module OK")


def test_config_loader():
    """Test configuration loading."""
    print("Testing config_loader module...")
    
    # Test env var with fallbacks
    os.environ["TEST_VAR"] = "test_value"
    value = config_loader.get_env_var("TEST_VAR")
    assert value == "test_value", "Should get env var"
    
    # Test fallback
    value = config_loader.get_env_var("NONEXISTENT", fallback_keys=["TEST_VAR"])
    assert value == "test_value", "Should use fallback"
    
    # Test default
    value = config_loader.get_env_var("NONEXISTENT", default="default")
    assert value == "default", "Should use default"
    
    # Test required (should raise)
    try:
        config_loader.get_env_var("NONEXISTENT", required=True)
        assert False, "Should raise ValueError"
    except ValueError:
        pass
    
    # Clean up
    del os.environ["TEST_VAR"]
    
    print("✓ Config loader module OK")


def test_ai_client():
    """Test AI client creation (without actual API calls)."""
    print("Testing ai_client module...")
    
    # Test client creation
    gemini = ai_client.GeminiClient()
    jules = ai_client.JulesClient()
    
    assert isinstance(gemini, ai_client.GeminiClient), "Should create Gemini client"
    assert isinstance(jules, ai_client.JulesClient), "Should create Jules client"
    
    # Test availability check (should be false without API keys)
    if not os.environ.get("GEMINI_API_KEY") and not os.environ.get("GOOGLE_API_KEY"):
        assert not gemini.is_available(), "Should not be available without API key"
    
    if not os.environ.get("JULES_API_KEY") or not os.environ.get("JULES_API_URL"):
        assert not jules.is_available(), "Should not be available without API key/URL"
    
    # Test convenience functions
    gemini_client, jules_client = ai_client.create_ai_clients()
    assert isinstance(gemini_client, ai_client.GeminiClient), "Should create Gemini client"
    assert isinstance(jules_client, ai_client.JulesClient), "Should create Jules client"
    
    print("✓ AI client module OK")


def main():
    """Run all tests."""
    print("=" * 60)
    print("Running Common Utilities Tests")
    print("=" * 60)
    
    try:
        test_paths()
        test_logger_config()
        test_config_loader()
        test_ai_client()
        
        print("=" * 60)
        print("✓ All tests passed!")
        print("=" * 60)
        return 0
    except Exception as e:
        print(f"\n✗ Test failed: {e}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
