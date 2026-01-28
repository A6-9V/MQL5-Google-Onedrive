#!/usr/bin/env python3
"""
Scalping Strategy Research Script
Queries AI for optimal scalping parameters for M5, M15, M30 timeframes.
"""

import os
import logging
from dotenv import load_dotenv

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

load_dotenv()

def ask_ai_strategy():
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        logger.error("GEMINI_API_KEY not found.")
        return

    try:
        import google.generativeai as genai
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-2.0-flash')

        prompt = """
        I need a robust scalping strategy configuration for an MQL5 Expert Advisor.
        The EA uses SMC (Smart Money Concepts), Donchian Breakout, and MTF EMA confirmation.

        Please provide optimal settings for the following timeframes:
        1. 5 Minutes (M5)
        2. 15 Minutes (M15)
        3. 30 Minutes (M30)

        For each timeframe, provide:
        - Stop Loss (in points or ATR multiplier)
        - Take Profit (in points or Risk:Reward ratio)
        - Trailing Stop settings (Start, Step in points)
        - Break Even settings (Trigger, Plus points)
        - Indicator settings (EMA Fast/Slow periods, RSI period)

        Focus on EURUSD and GBPUSD pairs.
        Format the output clearly as a configuration guide.
        """

        logger.info("Querying Gemini for scalping strategy...")
        response = model.generate_content(prompt)
        print(response.text)

        # Save to file
        with open("docs/SCALPING_STRATEGY.md", "w") as f:
            f.write("# Scalping Strategy Research\n\n")
            f.write(response.text)

        logger.info("Research saved to docs/SCALPING_STRATEGY.md")

    except Exception as e:
        logger.error(f"Analysis failed: {e}")

if __name__ == "__main__":
    ask_ai_strategy()
