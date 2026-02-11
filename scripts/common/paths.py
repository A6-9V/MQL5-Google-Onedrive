"""
Shared path definitions for automation scripts.
Centralizes path resolution logic.
"""

from pathlib import Path


# Repository root - one level up from scripts directory
REPO_ROOT = Path(__file__).resolve().parents[2]

# Common directories
SCRIPTS_DIR = REPO_ROOT / "scripts"
CONFIG_DIR = REPO_ROOT / "config"
DOCS_DIR = REPO_ROOT / "docs"
DATA_DIR = REPO_ROOT / "data"
LOGS_DIR = REPO_ROOT / "logs"
MT5_DIR = REPO_ROOT / "mt5" / "MQL5"
DASHBOARD_DIR = REPO_ROOT / "dashboard"


def ensure_dirs(*dirs: Path) -> None:
    """
    Ensure directories exist, creating them if necessary.
    
    Args:
        *dirs: Variable number of Path objects to create
    """
    for directory in dirs:
        directory.mkdir(parents=True, exist_ok=True)
