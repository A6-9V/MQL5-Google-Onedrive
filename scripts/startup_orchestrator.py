#!/usr/bin/env python3
"""
Startup Orchestrator for MQL5 Trading Automation
Handles automated startup of all trading components with proper sequencing,
logging, and error handling.
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import platform
import subprocess
import sys
import time
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Optional


# Configuration paths
REPO_ROOT = Path(__file__).resolve().parents[1]
CONFIG_DIR = REPO_ROOT / "config"
LOGS_DIR = REPO_ROOT / "logs"
MT5_DIR = REPO_ROOT / "mt5" / "MQL5"


@dataclass
class ComponentConfig:
    """Configuration for a startup component."""
    name: str
    executable: str
    args: list[str]
    working_dir: Optional[str] = None
    wait_seconds: int = 0
    required: bool = True
    platform_specific: Optional[str] = None  # "windows", "linux", or None for all


class StartupOrchestrator:
    """Orchestrates the startup of all trading components."""

    def __init__(self, config_file: Optional[Path] = None, dry_run: bool = False):
        """Initialize the orchestrator."""
        self.config_file = config_file or CONFIG_DIR / "startup_config.json"
        self.dry_run = dry_run
        self.processes: list[subprocess.Popen] = []
        self.setup_logging()
        self.load_config()

    def setup_logging(self) -> None:
        """Setup logging configuration."""
        LOGS_DIR.mkdir(exist_ok=True)
        log_file = LOGS_DIR / f"startup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger(__name__)
        self.logger.info(f"Startup orchestrator initialized. Log file: {log_file}")

    def load_config(self) -> None:
        """Load configuration from JSON file."""
        if not self.config_file.exists():
            self.logger.warning(f"Config file not found: {self.config_file}")
            self.logger.info("Using default configuration")
            self.components = self.get_default_components()
        else:
            with open(self.config_file, 'r') as f:
                config_data = json.load(f)
                self.components = [
                    ComponentConfig(**comp) for comp in config_data.get('components', [])
                ]
            self.logger.info(f"Loaded configuration from {self.config_file}")

    def get_default_components(self) -> list[ComponentConfig]:
        """Return default component configuration."""
        system = platform.system().lower()
        
        components = [
            ComponentConfig(
                name="MT5 Terminal",
                executable="terminal64.exe" if "windows" in system else "wine terminal64.exe",
                args=[],
                wait_seconds=15,
                required=True,
                platform_specific="windows"
            ),
            ComponentConfig(
                name="Repository Validator",
                executable=sys.executable,
                args=[str(REPO_ROOT / "scripts" / "ci_validate_repo.py")],
                working_dir=str(REPO_ROOT),
                wait_seconds=2,
                required=False,
                platform_specific=None
            ),
        ]
        
        return components

    def check_system_requirements(self) -> bool:
        """Check if system meets requirements."""
        self.logger.info("Checking system requirements...")
        system = platform.system()
        self.logger.info(f"Platform: {system} ({platform.machine()})")
        self.logger.info(f"Python version: {sys.version}")
        
        # Check Python version
        if sys.version_info < (3, 8):
            self.logger.error("Python 3.8 or higher is required")
            return False
        
        # Check if MT5 directory exists
        if not MT5_DIR.exists():
            self.logger.error(f"MT5 directory not found: {MT5_DIR}")
            return False
        
        self.logger.info("System requirements check passed")
        return True

    def is_component_compatible(self, component: ComponentConfig) -> bool:
        """Check if component is compatible with current platform."""
        if component.platform_specific is None:
            return True
        
        current_platform = platform.system().lower()
        if "windows" in current_platform:
            return component.platform_specific == "windows"
        elif "linux" in current_platform:
            return component.platform_specific in ["linux", "wsl"]
        else:
            return False

    def start_component(self, component: ComponentConfig) -> bool:
        """Start a single component."""
        if not self.is_component_compatible(component):
            self.logger.info(f"Skipping {component.name} (platform incompatible)")
            return True

        self.logger.info(f"Starting {component.name}...")
        
        if self.dry_run:
            self.logger.info(f"[DRY RUN] Would execute: {component.executable} {' '.join(component.args)}")
            return True

        try:
            cmd = [component.executable] + component.args
            working_dir = component.working_dir or str(REPO_ROOT)
            
            process = subprocess.Popen(
                cmd,
                cwd=working_dir,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                creationflags=subprocess.CREATE_NEW_CONSOLE if platform.system() == "Windows" else 0
            )
            
            self.processes.append(process)
            self.logger.info(f"Started {component.name} (PID: {process.pid})")
            
            if component.wait_seconds > 0:
                self.logger.info(f"Waiting {component.wait_seconds} seconds for {component.name} to initialize...")
                time.sleep(component.wait_seconds)
            
            # Check if process is still running
            if process.poll() is not None:
                stdout, stderr = process.communicate()
                if process.returncode != 0:
                    self.logger.error(f"{component.name} failed with exit code {process.returncode}")
                    if stderr:
                        self.logger.error(f"Error: {stderr.decode()}")
                    return not component.required
                else:
                    self.logger.info(f"{component.name} completed successfully")
            
            return True
            
        except FileNotFoundError:
            self.logger.error(f"Executable not found: {component.executable}")
            return not component.required
        except Exception as e:
            self.logger.error(f"Failed to start {component.name}: {e}")
            return not component.required

    def start_all(self) -> bool:
        """Start all configured components."""
        if not self.check_system_requirements():
            return False

        self.logger.info("=" * 60)
        self.logger.info("Starting all components...")
        self.logger.info("=" * 60)
        
        success = True
        for component in self.components:
            if not self.start_component(component):
                self.logger.error(f"Failed to start required component: {component.name}")
                success = False
                break
        
        if success:
            self.logger.info("=" * 60)
            self.logger.info("All components started successfully")
            self.logger.info(f"Total processes: {len(self.processes)}")
            self.logger.info("=" * 60)
        else:
            self.logger.error("Startup sequence failed")
        
        return success

    def stop_all(self) -> None:
        """Stop all running processes."""
        self.logger.info("Stopping all processes...")
        for process in self.processes:
            try:
                process.terminate()
                process.wait(timeout=5)
                self.logger.info(f"Stopped process {process.pid}")
            except subprocess.TimeoutExpired:
                process.kill()
                self.logger.warning(f"Force killed process {process.pid}")
            except Exception as e:
                self.logger.error(f"Error stopping process {process.pid}: {e}")

    def monitor_processes(self, duration: Optional[int] = None) -> None:
        """Monitor running processes."""
        self.logger.info("Monitoring processes... Press Ctrl+C to stop")
        
        start_time = time.time()
        try:
            while True:
                if duration and (time.time() - start_time) > duration:
                    self.logger.info("Monitoring duration reached")
                    break
                
                # Check process status
                for i, process in enumerate(self.processes):
                    if process.poll() is not None:
                        self.logger.warning(f"Process {process.pid} has exited with code {process.returncode}")
                
                time.sleep(10)  # Check every 10 seconds
                
        except KeyboardInterrupt:
            self.logger.info("Monitoring interrupted by user")

    def create_default_config(self) -> None:
        """Create default configuration file."""
        CONFIG_DIR.mkdir(exist_ok=True)
        
        default_config = {
            "components": [
                {
                    "name": "Repository Validator",
                    "executable": sys.executable,
                    "args": [str(REPO_ROOT / "scripts" / "ci_validate_repo.py")],
                    "working_dir": str(REPO_ROOT),
                    "wait_seconds": 2,
                    "required": False,
                    "platform_specific": None
                },
                {
                    "name": "MT5 Terminal",
                    "executable": "C:\\Program Files\\Exness Terminal\\terminal64.exe",
                    "args": ["/portable"],
                    "wait_seconds": 15,
                    "required": True,
                    "platform_specific": "windows"
                },
                {
                    "name": "Custom Python Script",
                    "executable": sys.executable,
                    "args": [str(REPO_ROOT / "scripts" / "your_custom_script.py")],
                    "working_dir": str(REPO_ROOT),
                    "wait_seconds": 5,
                    "required": False,
                    "platform_specific": None
                }
            ]
        }
        
        with open(self.config_file, 'w') as f:
            json.dump(default_config, f, indent=2)
        
        self.logger.info(f"Created default configuration at {self.config_file}")


def main() -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Startup orchestrator for MQL5 trading automation"
    )
    parser.add_argument(
        "--config",
        type=Path,
        help="Path to configuration file (JSON)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print actions without executing them"
    )
    parser.add_argument(
        "--create-config",
        action="store_true",
        help="Create default configuration file"
    )
    parser.add_argument(
        "--monitor",
        type=int,
        metavar="SECONDS",
        help="Monitor processes for specified duration (0 = infinite)"
    )
    
    args = parser.parse_args()
    
    orchestrator = StartupOrchestrator(
        config_file=args.config,
        dry_run=args.dry_run
    )
    
    if args.create_config:
        orchestrator.create_default_config()
        return 0
    
    try:
        if not orchestrator.start_all():
            return 1
        
        if args.monitor is not None:
            monitor_duration = None if args.monitor == 0 else args.monitor
            orchestrator.monitor_processes(duration=monitor_duration)
        
        return 0
        
    except KeyboardInterrupt:
        orchestrator.logger.info("Interrupted by user")
        return 130
    except Exception as e:
        orchestrator.logger.error(f"Unexpected error: {e}", exc_info=True)
        return 1
    finally:
        if not args.monitor:
            orchestrator.stop_all()


if __name__ == "__main__":
    sys.exit(main())
