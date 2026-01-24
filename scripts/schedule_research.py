#!/usr/bin/env python3
"""
Schedule Research Script
Runs market research and upgrade suggestions on a schedule.
"""

import schedule
import time
import subprocess
import logging
import sys
import os
from pathlib import Path
from dotenv import load_dotenv

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

REPO_ROOT = Path(__file__).resolve().parents[1]

def job():
    logger.info("Running scheduled research task...")

    # Run market research
    research_script = REPO_ROOT / "scripts" / "market_research.py"
    try:
        subprocess.run([sys.executable, str(research_script)], check=True)
    except subprocess.CalledProcessError as e:
        logger.error(f"Market research failed: {e}")
        return

    # Run upgrade repo
    upgrade_script = REPO_ROOT / "scripts" / "upgrade_repo.py"
    try:
        subprocess.run([sys.executable, str(upgrade_script)], check=True)
    except subprocess.CalledProcessError as e:
        logger.error(f"Upgrade repo failed: {e}")
        return

    logger.info("Scheduled task completed successfully.")

def main():
    # Load env vars
    load_dotenv()

    if not os.environ.get("GEMINI_API_KEY") or not os.environ.get("JULES_API_KEY"):
        logger.warning("Missing API keys in environment. Please check .env file.")

    logger.info("Starting Schedule Research Service...")

    # Run immediately on start
    job()

    # Schedule every 4 hours
    schedule.every(4).hours.do(job)

    while True:
        schedule.run_pending()
        time.sleep(60)

if __name__ == "__main__":
    main()
