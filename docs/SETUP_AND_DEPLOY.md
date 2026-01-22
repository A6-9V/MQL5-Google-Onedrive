# Setup, Compilation, and Deployment Guide

This guide outlines the steps to setup the environment, compile the MQL5 Expert Advisors, and redeploy the VPS.

## 1. Setup and Preparation

### Validate Repository
Ensure the repository meets all quality standards (file sizes, no binary trash, etc.).
```bash
python scripts/ci_validate_repo.py
```

### Package MQL5 Files
Prepare the MQL5 source code for distribution/compilation. This creates a ZIP file in `dist/`.
```bash
./scripts/package_mt5.sh
```
Output: `dist/Exness_MT5_MQL5.zip`

## 2. Compilation (Manual Step)

Since the environment is Linux-based, MQL5 compilation must be done on a Windows machine or using MetaEditor.

1.  **Download** the `dist/Exness_MT5_MQL5.zip` file.
2.  **Extract** it to your MetaTrader 5 `MQL5` folder (e.g., `%APPDATA%\MetaQuotes\Terminal\...\MQL5`).
3.  **Open MetaEditor**.
4.  **Compile** `Experts\EXNESS_GenX_Trader.mq5` and `Experts\SMC_TrendBreakout_MTF_EA.mq5`.
5.  Ensure `Include\ZoloBridge.mqh` and `Include\AiAssistant.mqh` are available.

## 3. Redeploy VPS

To update the VPS with the latest dashboard and automation scripts:

### Option A: Via Docker Hub (Requires Credentials)
If you have Docker Hub credentials configured:
```bash
./scripts/deploy_docker_hub.sh [USERNAME] [TOKEN]
```

### Option B: On the VPS
SSH into your VPS and run:
```bash
./scripts/update_vps.sh
```
This will pull the latest `mouyleng/mql5-trading-automation:latest` image and restart the services.

## 4. Verification

Check the health of the deployment:
```bash
python scripts/test_web_dashboard.py
```
