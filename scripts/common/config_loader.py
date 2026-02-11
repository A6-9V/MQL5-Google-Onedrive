"""
Shared configuration loading utilities.
Reduces duplication of config/env loading code.
"""

import json
import os
import logging
from pathlib import Path
from typing import Optional, Any, Dict
from dotenv import load_dotenv


logger = logging.getLogger(__name__)


def load_env(env_file: Optional[Path] = None) -> None:
    """
    Load environment variables from .env file.
    
    Args:
        env_file: Optional path to .env file (defaults to .env in repo root)
    """
    load_dotenv(env_file)


def load_json_config(config_path: Path) -> Optional[Dict[str, Any]]:
    """
    Load JSON configuration file with error handling.
    
    Args:
        config_path: Path to JSON config file
    
    Returns:
        Parsed JSON data as dictionary, or None if error
    """
    if not config_path.exists():
        logger.warning(f"Config file not found: {config_path}")
        return None
    
    try:
        with open(config_path, 'r') as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in {config_path}: {e}")
        return None
    except Exception as e:
        logger.error(f"Error loading config {config_path}: {e}")
        return None


def get_env_var(
    key: str,
    default: Optional[str] = None,
    required: bool = False,
    fallback_keys: Optional[list[str]] = None
) -> Optional[str]:
    """
    Get environment variable with optional fallbacks.
    
    Args:
        key: Primary environment variable name
        default: Default value if not found
        required: If True, raises ValueError when not found
        fallback_keys: List of fallback environment variable names
    
    Returns:
        Environment variable value or default
    
    Raises:
        ValueError: If required=True and variable not found
    """
    value = os.environ.get(key)
    
    if not value and fallback_keys:
        for fallback in fallback_keys:
            value = os.environ.get(fallback)
            if value:
                break
    
    if not value:
        value = default
    
    if required and not value:
        raise ValueError(f"Required environment variable '{key}' not found")
    
    return value
