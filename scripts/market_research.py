#!/usr/bin/env python3
"""
Market Research Script
Connects to Gemini and Jules to analyze market data and generate research reports.
"""

import json
import concurrent.futures
from datetime import datetime

# Use shared utilities to reduce code duplication
from common.logger_config import setup_basic_logging
from common.paths import DOCS_DIR, DATA_DIR
from common.config_loader import load_env
from common.ai_client import GeminiClient, JulesClient

# Setup logging using shared config
logger = setup_basic_logging()

# Load environment variables
load_env()

def get_market_data():
    """
    Fetch market data using yfinance if available, otherwise use simulation.
    """
    data = None

    # ⚡ Optimization: Lazy import heavy dependencies
    try:
        import yfinance as yf
        import pandas as pd
        yfinance_available = True
    except ImportError:
        yfinance_available = False

    if yfinance_available:
        try:
            logger.info("Fetching real market data via yfinance...")
            symbols = ["EURUSD=X", "GBPUSD=X", "GC=F", "BTC-USD"]
            market_data = {"timestamp": datetime.now().isoformat(), "symbols": {}}

            # ⚡ Performance Optimization: Batch fetch all symbols to reduce HTTP requests (~3x speedup)
            try:
                # group_by='ticker' ensures consistent structure (MultiIndex if >1 symbol)
                tickers_data = yf.download(symbols, period="14d", interval="1d", group_by='ticker', progress=False)
            except Exception as e:
                logger.error(f"Bulk download failed: {e}")
                tickers_data = None

            if tickers_data is not None and not tickers_data.empty:
                # ⚡ Performance Optimization: Move structural checks outside the loop
                is_multi = isinstance(tickers_data.columns, pd.MultiIndex)

                # Determine which symbols are actually available in the downloaded data
                if is_multi:
                    available_symbols = [s for s in symbols if s in tickers_data.columns.levels[0]]
                elif len(symbols) == 1:
                    # If not MultiIndex and only 1 symbol requested, it's that symbol
                    available_symbols = symbols
                else:
                    # Logic Error Fix: If structure is flat but multiple symbols requested,
                    # we can't safely assign it to any/all symbols.
                    available_symbols = []

                for sym in available_symbols:
                    try:
                        hist = tickers_data[sym] if is_multi else tickers_data

                        if hist is not None and not hist.empty:
                            # Clean up data
                            if 'Close' in hist.columns:
                                hist = hist.dropna(subset=['Close'])
                            else:
                                continue

                            if hist.empty:
                                continue

                            current_price = hist['Close'].iloc[-1]
                            # Check if we have enough data
                            prev_price = hist['Close'].iloc[-2] if len(hist) > 1 else current_price

                            # Simple Trend (Price vs 5-day SMA)
                            sma_5 = hist['Close'].tail(5).mean()
                            trend = "UP" if current_price > sma_5 else "DOWN"

                            # Volatility (High - Low)
                            daily_range = hist['High'].iloc[-1] - hist['Low'].iloc[-1]
                            volatility = "HIGH" if daily_range > (current_price * 0.01) else "LOW" # Arbitrary threshold

                            market_data["symbols"][sym] = {
                                "price": round(current_price, 4),
                                "trend": trend,
                                "volatility": volatility,
                                "history_last_5_closes": [round(x, 4) for x in hist['Close'].tail(5).tolist()]
                            }
                    except Exception as e:
                        logger.warning(f"Failed to process {sym}: {e}")

            if market_data["symbols"]:
                data = market_data
        except Exception as e:
            logger.error(f"yfinance failed: {e}")

    if data:
        return data

    logger.info("Using simulated/fallback market data.")
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
    Send data to Gemini for analysis using shared AI client.
    """
    gemini = GeminiClient()
    if not gemini.is_available():
        logger.warning("GEMINI_API_KEY/GOOGLE_API_KEY not found. Skipping Gemini analysis.")
        return None

    prompt = f"""
    Analyze the following market data and provide a research report for a trading bot.
    Focus on:
    1. Current market regime (Trending, Ranging, Volatile).
    2. Potential trade setups based on Price Action and Trend.
    3. Risk management suggestions.

    Data:
    {json.dumps(data, indent=2)}
    """

    try:
        response = gemini.generate(prompt)
        return response if response else f"Gemini analysis failed"
    except Exception as e:
        logger.error(f"Gemini analysis failed: {e}")
        return f"Gemini analysis failed: {e}"

def analyze_with_jules(data):
    """
    Send data to Jules for analysis using shared AI client.
    """
    jules = JulesClient()
    if not jules.is_available():
        return None

    prompt = f"""
    You are an expert market analyst. Analyze the following market data and provide a research report for a trading bot.
    Focus on:
    1. Macro view and Sentiment.
    2. Specific trade ideas.
    3. Correlation analysis if multiple symbols provided.

    Data:
    {json.dumps(data, indent=2)}
    """

    try:
        response = jules.generate(prompt)
        return response if response else "Jules analysis failed"
    except Exception as e:
        logger.error(f"Jules analysis failed: {e}")
        error_msg = f"Jules analysis failed: {e}"
        if "NameResolutionError" in str(e) or "Failed to resolve" in str(e):
            error_msg += "\n\n**Hint:** The Jules API URL might be incorrect. Please check `JULES_API_URL` in `.env`."
        return error_msg

def main():
    logger.info("Starting Market Research...")

    # Ensure directories exist
    DOCS_DIR.mkdir(exist_ok=True)
    DATA_DIR.mkdir(exist_ok=True)

    data = get_market_data()
    logger.info(f"Market data loaded for {len(data.get('symbols', {}))} symbols.")

    # Save raw data snapshot
    with open(DATA_DIR / "market_snapshot.json", 'w') as f:
        json.dump(data, f, indent=2)

    # Parallelize AI analysis calls
    with concurrent.futures.ThreadPoolExecutor() as executor:
        future_gemini = executor.submit(analyze_with_gemini, data)
        future_jules = executor.submit(analyze_with_jules, data)

        gemini_report = future_gemini.result()
        jules_report = future_jules.result()

    report_path = DOCS_DIR / "market_research_report.md"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    content = f"# Market Research Report\n\nGenerated: {timestamp}\n\n"

    if gemini_report:
        content += f"## Gemini Analysis\n\n{gemini_report}\n\n"

    if jules_report:
        content += f"## Jules Analysis\n\n{jules_report}\n\n"

    if not gemini_report and not jules_report:
        content += "## Analysis Failed\n\nNo AI providers were available or both failed."

    with open(report_path, 'w') as f:
        f.write(content)

    logger.info(f"Report saved to {report_path}")

if __name__ == "__main__":
    main()
