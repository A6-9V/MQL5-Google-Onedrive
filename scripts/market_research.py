#!/usr/bin/env python3
"""
Market Research Script
Connects to Gemini to analyze market data and generate research reports.
"""

import os
import sys
import json
import logging
import google.generativeai as genai
from datetime import datetime
from pathlib import Path

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

REPO_ROOT = Path(__file__).resolve().parents[1]
DOCS_DIR = REPO_ROOT / "docs"
DATA_DIR = REPO_ROOT / "data"

def get_market_data():
    """
    Fetch market data.
    In a real scenario, this would connect to an API or read from MT5 logs.
    For now, we simulate data or read from a JSON file if it exists.
    """
    data_file = DATA_DIR / "market_snapshot.json"

    if data_file.exists():
        try:
            with open(data_file, 'r') as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"Failed to read data file: {e}")

    # Simulated data if file doesn't exist
    return {
        "timestamp": datetime.now().isoformat(),
        "symbols": {
            "EURUSD": {"price": 1.0850, "trend": "UP", "rsi": 65.5, "volatility": "MEDIUM"},
            "GBPUSD": {"price": 1.2700, "trend": "SIDEWAYS", "rsi": 50.2, "volatility": "LOW"},
            "XAUUSD": {"price": 2030.50, "trend": "DOWN", "rsi": 35.0, "volatility": "HIGH"}
        }
    }

def analyze_with_gemini(data):
    """
    Send data to Gemini for analysis.
    """
    api_key = os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        logger.warning("GOOGLE_API_KEY not found. Skipping Gemini analysis.")
        return "Gemini analysis skipped (API Key missing)."

    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-1.5-flash')

        prompt = f"""
        Analyze the following market data and provide a research report for a trading bot.
        Focus on:
        1. Current market regime (Trending, Ranging, Volatile).
        2. Potential trade setups based on RSI and Trend.
        3. Risk management suggestions.

        Data:
        {json.dumps(data, indent=2)}
        """

        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        logger.error(f"Gemini analysis failed: {e}")
        return f"Gemini analysis failed: {e}"

def main():
    logger.info("Starting Market Research...")

    # Ensure directories exist
    DOCS_DIR.mkdir(exist_ok=True)
    DATA_DIR.mkdir(exist_ok=True)

    data = get_market_data()
    logger.info(f"Market data loaded for {len(data.get('symbols', {}))} symbols.")

    analysis = analyze_with_gemini(data)

    report_path = DOCS_DIR / "market_research_report.md"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    content = f"# Market Research Report\n\nGenerated: {timestamp}\n\n## Analysis\n\n{analysis}\n"

    with open(report_path, 'w') as f:
        f.write(content)

    logger.info(f"Report saved to {report_path}")

if __name__ == "__main__":
    main()
