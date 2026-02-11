#!/usr/bin/env python3
"""
Scalping Strategy Research Script
Queries AI for optimal scalping parameters for M5, M15, M30 timeframes.
"""

# Use shared utilities to reduce code duplication
from common.logger_config import setup_basic_logging
from common.config_loader import load_env
from common.ai_client import ask_gemini

# Setup logging using shared config
logger = setup_basic_logging()

# Load environment variables
load_env()

def ask_ai_strategy():
    logger.info("Querying Gemini for scalping strategy...")
    
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

    response = ask_gemini(prompt)
    if response:
        print(response)
        
        # Save to file
        try:
            with open("docs/SCALPING_STRATEGY.md", "w") as f:
                f.write("# Scalping Strategy Research\n\n")
                f.write(response)
            logger.info("Research saved to docs/SCALPING_STRATEGY.md")
        except Exception as e:
            logger.error(f"Failed to save research: {e}")
    else:
        logger.error("Failed to get AI response. Check your API key configuration.")

if __name__ == "__main__":
    ask_ai_strategy()
