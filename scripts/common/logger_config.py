"""
Shared logging configuration for automation scripts.
Reduces duplication of logging setup code.
"""

import logging
import sys
from pathlib import Path
from datetime import datetime
from typing import Optional


def setup_logger(
    name: Optional[str] = None,
    level: int = logging.INFO,
    log_file: Optional[Path] = None,
    console: bool = True
) -> logging.Logger:
    """
    Setup and configure a logger with consistent formatting.
    
    Args:
        name: Logger name (defaults to __name__ of caller)
        level: Logging level (default: INFO)
        log_file: Optional path to log file
        console: Whether to log to console (default: True)
    
    Returns:
        Configured logger instance
    """
    logger = logging.getLogger(name or __name__)
    
    # Avoid duplicate handlers if already configured
    if logger.handlers:
        return logger
    
    logger.setLevel(level)
    
    # Standard format for all scripts
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    
    # Console handler
    if console:
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
    
    # File handler
    if log_file:
        log_file.parent.mkdir(parents=True, exist_ok=True)
        file_handler = logging.FileHandler(log_file)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    
    return logger


def setup_basic_logging(level: int = logging.INFO) -> logging.Logger:
    """
    Setup basic logging configuration (console only).
    This is a convenience function for simple scripts.
    
    Args:
        level: Logging level (default: INFO)
    
    Returns:
        Root logger instance
    """
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )
    return logging.getLogger(__name__)
