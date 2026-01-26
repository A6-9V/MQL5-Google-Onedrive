#!/usr/bin/env python3
"""
Upgrade Repo Script
Reads market research and suggests code upgrades using Gemini and Jules.
"""

import os
import logging
import requests
# TODO: google.generativeai is deprecated, migrate to google.genai in future
# import google.genai as genai
import google.generativeai as genai
from pathlib import Path
from datetime import datetime
from dotenv import load_dotenv

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

REPO_ROOT = Path(__file__).resolve().parents[1]
DOCS_DIR = REPO_ROOT / "docs"

# Load env vars
load_dotenv()

def ask_jules(prompt):
    api_key = os.environ.get("JULES_API_KEY")
    api_url = os.environ.get("JULES_API_URL")
    model = os.environ.get("JULES_MODEL", "jules-v1")

    if not api_key or not api_url:
        logger.warning("Skipping Jules (Key/URL missing)")
        return None

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
        try:
            resp_json = response.json()
            if "response" in resp_json:
                return resp_json["response"]
            elif "choices" in resp_json and len(resp_json["choices"]) > 0:
                return resp_json["choices"][0].get("text", str(resp_json))
            else:
                return str(resp_json)
        except ValueError:
            return response.text
    except Exception as e:
        logger.error(f"Jules request failed: {e}")
        return None

def ask_gemini(prompt):
    api_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        logger.warning("Skipping Gemini (Key missing)")
        return None

    try:
        genai.configure(api_key=api_key)
        model_name = os.environ.get("GEMINI_MODEL", 'gemini-flash-latest')
        model = genai.GenerativeModel(model_name)
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        logger.error(f"Gemini request failed: {e}")
        return None

def main():
    logger.info("Starting Code Upgrade Analysis...")

    report_path = DOCS_DIR / "market_research_report.md"
    if not report_path.exists():
        logger.warning("No market research report found. Skipping upgrade analysis.")
        return

    with open(report_path, 'r') as f:
        research_content = f.read()

    # Read NotebookLM context if available
    notebook_context = ""
    notebook_path = DOCS_DIR / "NOTEBOOK_LM_CONTEXT.txt"
    if notebook_path.exists():
        with open(notebook_path, 'r') as f:
            notebook_context = f.read()

    # Get EA code context
    ea_path = REPO_ROOT / "mt5/MQL5/Experts/SMC_TrendBreakout_MTF_EA.mq5"
    ea_code = ""
    if ea_path.exists():
        with open(ea_path, 'r') as f:
            ea_code = f.read()[:5000]

    prompt = f"""
    Based on the following market research and optional NotebookLM context, suggest 3 specific code upgrades or parameter adjustments for the trading bot.

    Market Research:
    {research_content}

    NotebookLM Context:
    {notebook_context}

    Current EA Code Snippet (Top 5000 chars):
    {ea_code}

    Output format:
    1. [File Name]: [Suggestion] - [Reasoning]
    """

    gemini_suggestions = ask_gemini(prompt)
    jules_suggestions = ask_jules(prompt)

    if not gemini_suggestions and not jules_suggestions:
        logger.warning("Both AI providers failed or keys missing.")
        return

    suggestion_path = DOCS_DIR / "upgrade_suggestions.md"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    content = f"# Upgrade Suggestions\n\nGenerated: {timestamp}\n\n"

    if gemini_suggestions:
        content += f"## Gemini Suggestions\n\n{gemini_suggestions}\n\n"

    if jules_suggestions:
        content += f"## Jules Suggestions\n\n{jules_suggestions}\n\n"

    with open(suggestion_path, 'w') as f:
        f.write(content)

    logger.info(f"Suggestions saved to {suggestion_path}")

if __name__ == "__main__":
    main()
