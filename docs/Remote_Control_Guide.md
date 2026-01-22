# Remote Control & Intelligence Tools Guide

This guide describes how to set up the **Remote Control Version** and **Intelligence Tools** (Gemini AI) for the Exness GenX Trader / SMC Trend Breakout EA.

## 🔗 Remote Control Version (ZOLO Bridge)

The "Remote Control Version" allows your EA to communicate with external systems (like the ZOLO bridge) for signal broadcasting or remote management.

### Setup Instructions

1.  **Download Bridge Files**:
    *   Access the ZOLO Plugin files here: [ZOLO-A6-9V-NUNA-](https://1drv.ms/f/c/8F247B1B46E82304/IgBYRTEjjPv-SKHi70WnmmU8AZb3Mr5X1o3a0QNU_mKgAZg)
    *   Follow the instructions inside the folder to install any required bridge software.

2.  **Configure MetaTrader 5**:
    *   Open MT5 and go to **Tools** → **Options** → **Expert Advisors**.
    *   Check **"Allow WebRequest for listed URL"**.
    *   Add the following URL to the list:
        ```
        http://203.147.134.90
        ```

3.  **Configure the EA**:
    *   Attach `SMC_TrendBreakout_MTF_EA` to your chart.
    *   In the inputs, set:
        *   `EnableWebRequest` = `true`
        *   `WebRequestURL` = `http://203.147.134.90`

Once enabled, the EA will send signal data to the bridge endpoint.

---

## 🧠 Intelligence Tools (Google Gemini AI)

The EA integrates Google's Gemini AI to "validate" trades before they are taken. The AI analyzes the market context (trend, price action) and gives a GO/NO-GO decision.

### Setup Instructions

1.  **Get a Free API Key**:
    *   Visit [Google AI Studio](https://aistudio.google.com/).
    *   Create a new API key.

2.  **Configure MetaTrader 5**:
    *   Go to **Tools** → **Options** → **Expert Advisors**.
    *   Add the Google API URL to the allowed WebRequest list:
        ```
        https://generativelanguage.googleapis.com
        ```

3.  **Configure the EA**:
    *   In the EA inputs, set `UseGeminiFilter` = `true`.
    *   Paste your key into `GeminiApiKey`.
    *   **Model Selection**:
        *   Default: `gemini-1.5-pro` (More intelligent, slightly slower).
        *   Faster Option: `gemini-1.5-flash` (Faster, good for scalping). You can type this into the `GeminiModel` input.

---

## 📱 Telegram Remote Deployment

You can use the included Telegram Bot to deploy your trading environment to cloud platforms (Fly.io, Render, Railway) remotely.

### Setup

1.  **Get a Bot Token**:
    *   Message [@BotFather](https://t.me/BotFather) on Telegram to create a new bot and get a token.

2.  **Run the Bot**:
    *   On your local machine or VPS:
        ```bash
        # Linux/Mac
        export TELEGRAM_BOT_TOKEN="your_token_here"
        python scripts/telegram_deploy_bot.py

        # Windows PowerShell
        $env:TELEGRAM_BOT_TOKEN="your_token_here"
        python scripts/telegram_deploy_bot.py
        ```

3.  **Commands**:
    *   `/deploy_flyio`: Deploy to Fly.io
    *   `/deploy_render`: Deploy to Render
    *   `/deploy_docker`: Build Docker image
    *   `/status`: Check deployment status
