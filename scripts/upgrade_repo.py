#!/usr/bin/env python3
"""
Upgrade Repo Script
Reads market research and suggests code upgrades using Gemini and Jules.
"""

import concurrent.futures
from datetime import datetime

# Use shared utilities to reduce code duplication
from common.logger_config import setup_basic_logging
from common.paths import REPO_ROOT, DOCS_DIR
from common.config_loader import load_env
from common.ai_client import ask_gemini, ask_jules

# Setup logging using shared config
logger = setup_basic_logging()

# Load environment variables
load_env()

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
            logger.info("Loaded NotebookLM context.")

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

    # ⚡ Optimization: Parallelize AI requests (~2x speedup)
    with concurrent.futures.ThreadPoolExecutor() as executor:
        future_gemini = executor.submit(ask_gemini, prompt)
        future_jules = executor.submit(ask_jules, prompt)

        gemini_suggestions = future_gemini.result()
        jules_suggestions = future_jules.result()

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
