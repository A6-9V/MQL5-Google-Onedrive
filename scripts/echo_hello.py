#!/usr/bin/env python3
"""
Echo and Hello Window Demo Script
Demonstrates simple echo output and hello window display functionality.
"""

from __future__ import annotations

import argparse
import sys
from datetime import datetime

# Use shared utilities to reduce code duplication
from common.logger_config import setup_basic_logging

# Setup logging using shared config
logger = setup_basic_logging()


def print_echo(message: str) -> None:
    """Echo a message to the console."""
    logger.info(f"ECHO: {message}")
    print(f">>> {message}")


def show_hello_window() -> None:
    """Display a hello window (console-based)."""
    border = "=" * 60
    title = "HELLO WINDOW"
    greeting = "Hello from MQL5 Trading Automation!"
    timestamp = f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    
    # Print the window
    print()
    print(border)
    print(f"{title:^60}")
    print(border)
    print(f"{greeting:^60}")
    print(f"{timestamp:^60}")
    print(border)
    print()


def run_demo() -> None:
    """Run the full echo and hello window demo."""
    logger.info("Starting echo and hello window demo...")
    
    # Echo some messages
    print_echo("Welcome to the demo!")
    print_echo("This script demonstrates echo functionality")
    print_echo("And displays a hello window")
    
    # Show the hello window
    show_hello_window()
    
    logger.info("Demo completed successfully")


def main() -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Echo and Hello Window Demo Script"
    )
    parser.add_argument(
        "--message",
        type=str,
        help="Custom message to echo"
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose logging"
    )
    
    args = parser.parse_args()
    
    if args.verbose:
        import logging
        logger.setLevel(logging.DEBUG)
    
    try:
        if args.message:
            # Just echo the custom message
            print_echo(args.message)
        else:
            # Run full demo
            run_demo()
        
        return 0
        
    except Exception as e:
        logger.error(f"Script failed: {e}", exc_info=True)
        return 1


if __name__ == "__main__":
    sys.exit(main())
