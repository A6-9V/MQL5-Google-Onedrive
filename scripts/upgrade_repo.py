#!/usr/bin/env python3
"""
Upgrade Repo Script
Reads market research and suggests code upgrades using Gemini.
"""

import os
import logging
import google.generativeai as genai
from pathlib import Path
from datetime import datetime

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

REPO_ROOT = Path(__file__).resolve().parents[1]
DOCS_DIR = REPO_ROOT / "docs"

def main():
    logger.info("Starting Code Upgrade Analysis...")

    report_path = DOCS_DIR / "market_research_report.md"
    if not report_path.exists():
        logger.warning("No market research report found. Skipping upgrade analysis.")
        return

    with open(report_path, 'r') as f:
        research_content = f.read()

    api_key = os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        logger.warning("GOOGLE_API_KEY not found. Skipping Gemini analysis.")
        return

    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-1.5-flash')

        # We could also read the EA code to give context
        ea_path = REPO_ROOT / "mt5/MQL5/Experts/SMC_TrendBreakout_MTF_EA.mq5"
        ea_code = ""
        if ea_path.exists():
            with open(ea_path, 'r') as f:
                ea_code = f.read()[:5000] # Truncate to avoid token limits if necessary

        prompt = f"""
        Based on the following market research, suggest 3 specific code upgrades or parameter adjustments for the trading bot.

        Market Research:
        {research_content}

        Current EA Code Snippet (Top 5000 chars):
        {ea_code}

        Output format:
        1. [File Name]: [Suggestion] - [Reasoning]
        """

        response = model.generate_content(prompt)
        suggestions = response.text

        suggestion_path = DOCS_DIR / "upgrade_suggestions.md"
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        content = f"# Upgrade Suggestions\n\nGenerated: {timestamp}\n\n{suggestions}\n"

        with open(suggestion_path, 'w') as f:
            f.write(content)

        logger.info(f"Suggestions saved to {suggestion_path}")

    except Exception as e:
        logger.error(f"Upgrade analysis failed: {e}")

if __name__ == "__main__":
    main()
