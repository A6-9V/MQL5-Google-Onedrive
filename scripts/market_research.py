#!/usr/bin/env python3
"""
Market Research Script
Connects to Gemini and Jules to analyze market data and generate research reports.
"""

import os
import sys
import json
import logging
import requests
import concurrent.futures
import google.generativeai as genai
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv

# Try to import yfinance
try:
    import yfinance as yf
    YFINANCE_AVAILABLE = True
except ImportError:
    YFINANCE_AVAILABLE = False

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

REPO_ROOT = Path(__file__).resolve().parents[1]
DOCS_DIR = REPO_ROOT / "docs"
DATA_DIR = REPO_ROOT / "data"

# Load environment variables
load_dotenv()

def get_market_data():
    """
    Fetch market data using yfinance if available, otherwise use simulation.
    """
    data = None
    if YFINANCE_AVAILABLE:
        try:
            logger.info("Fetching real market data via yfinance...")
            symbols = ["EURUSD=X", "GBPUSD=X", "GC=F", "BTC-USD"]
            market_data = {"timestamp": datetime.now().isoformat(), "symbols": {}}

            for sym in symbols:
                try:
                    ticker = yf.Ticker(sym)
                    # Fetch last 14 days to calculate simple RSI or just pass history
                    hist = ticker.history(period="14d", interval="1d")

                    if not hist.empty:
                        current_price = hist['Close'].iloc[-1]
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
                    logger.warning(f"Failed to fetch {sym}: {e}")

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
    Send data to Gemini for analysis.
    """
    api_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        logger.warning("GEMINI_API_KEY/GOOGLE_API_KEY not found. Skipping Gemini analysis.")
        return None

    try:
        genai.configure(api_key=api_key)
        # Fallback models if one isn't available
        model_name = os.environ.get("GEMINI_MODEL", 'gemini-1.5-flash')
        model = genai.GenerativeModel(model_name)

        prompt = f"""
        Analyze the following market data and provide a research report for a trading bot.
        Focus on:
        1. Current market regime (Trending, Ranging, Volatile).
        2. Potential trade setups based on Price Action and Trend.
        3. Risk management suggestions.

        Data:
        {json.dumps(data, indent=2)}
        """

        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        logger.error(f"Gemini analysis failed: {e}")
        return f"Gemini analysis failed: {e}"

def analyze_with_jules(data):
    """
    Send data to Jules for analysis.
    """
    api_key = os.environ.get("JULES_API_KEY")
    api_url = os.environ.get("JULES_API_URL")
    model = os.environ.get("JULES_MODEL", "jules-v1")

    if not api_key or not api_url:
        logger.warning("JULES_API_KEY or JULES_API_URL not found. Skipping Jules analysis.")
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

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    payload = {
        "model": model,
        "prompt": prompt
    }

    try:
        response = requests.post(api_url, json=payload, headers=headers, timeout=60)
        response.raise_for_status()

        # Try to parse JSON response if applicable, or return text
        try:
            resp_json = response.json()
            # Adjust based on actual API response structure
            if "response" in resp_json:
                return resp_json["response"]
            elif "choices" in resp_json and len(resp_json["choices"]) > 0:
                return resp_json["choices"][0].get("text", str(resp_json))
            else:
                return str(resp_json)
        except ValueError:
            return response.text

    except Exception as e:
        logger.error(f"Jules analysis failed: {e}")
        return f"Jules analysis failed: {e}"

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

    # Optimization: Run AI analysis in parallel
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
