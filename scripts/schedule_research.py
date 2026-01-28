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
from datetime import datetime, timedelta
from dotenv import load_dotenv

REPO_ROOT = Path(__file__).resolve().parents[1]
LOGS_DIR = REPO_ROOT / "logs"

# Setup logging
LOGS_DIR.mkdir(exist_ok=True)
log_file = LOGS_DIR / "scheduler.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

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

    # Calculate next run
    next_run = datetime.now() + timedelta(hours=4)
    logger.info(f"Next scheduled run at: {next_run.strftime('%Y-%m-%d %H:%M:%S')}")

def main():
    # Load env vars
    load_dotenv()

    if not os.environ.get("GEMINI_API_KEY") and not os.environ.get("GOOGLE_API_KEY"):
        logger.warning("Missing GEMINI_API_KEY or GOOGLE_API_KEY in environment.")

    if not os.environ.get("JULES_API_KEY"):
        logger.warning("Missing JULES_API_KEY in environment.")

    logger.info("Starting Schedule Research Service...")
    logger.info(f"Logs will be written to {log_file}")

    # Run immediately on start
    job()

    # Schedule every 4 hours
    schedule.every(4).hours.do(job)

    while True:
        schedule.run_pending()
        time.sleep(60)

if __name__ == "__main__":
    main()
