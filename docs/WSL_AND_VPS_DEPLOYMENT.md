# WSL and VPS Deployment Guide

This guide covers the setup and deployment of the MQL5 Trading Automation system, specifically for users running on **Windows with WSL (Ubuntu)** and deploying to a **VPS**.

## 1. Local Setup (Windows & WSL)

### Windows Side ("Window")
For the MetaTrader 5 terminal and general orchestration on Windows:

1.  **Reset Environment** (If you need a fresh start):
    Run the reset script in PowerShell to clean logs and temporary files.

    *Optional: Clean specific MT5 Terminal Logs*
    If your MT5 Logs folder is cluttered (e.g., contains `.git` or random files), pass the path to your Data Folder:
    ```powershell
    .\scripts\reset_environment.ps1 -MT5DataPath "C:\Users\USER\AppData\Roaming\MetaQuotes\Terminal\YOUR_ID"
    ```

    *Standard Reset:*
    ```powershell
    .\scripts\reset_environment.ps1
    ```

2.  **Startup**:
    To start the automation (MT5 Terminal + Python Orchestrator):
    ```powershell
    .\scripts\startup.ps1
    ```

### WSL Side ("Ubuntu WSL")
If you are using WSL (Windows Subsystem for Linux) to manage the code or run Linux-specific tools:

1.  **Install Prerequisites**:
    Open your Ubuntu terminal (WSL) and run:
    ```bash
    sudo ./scripts/setup_ubuntu.sh
    ```
    This installs Python, Node.js, and other dependencies within the WSL environment.

2.  **Validate Repository**:
    ```bash
    python3 scripts/ci_validate_repo.py
    ```

## 2. Deploy to VPS

To deploy your changes to a VPS (Virtual Private Server), typically running Ubuntu:

### Option A: Using Docker Hub (Recommended)
This method builds the image locally (or in CI) and pushes it to Docker Hub, then pulls it on the VPS.

1.  **Build and Push**:
    ```bash
    ./scripts/deploy_docker_hub.sh [YOUR_DOCKER_USERNAME] [YOUR_TOKEN]
    ```

2.  **Update VPS**:
    SSH into your VPS and run:
    ```bash
    ./scripts/update_vps.sh
    ```

### Option B: Manual File Transfer (SCP/Git)
If you don't use Docker Hub:

1.  **SSH into VPS**:
    ```bash
    ssh user@your-vps-ip
    ```

2.  **Pull Changes** (if using Git on VPS):
    ```bash
    cd /path/to/repo
    git pull
    ```

3.  **Run Setup/Update**:
    ```bash
    sudo ./scripts/setup_ubuntu.sh
    ```

## 3. Magic Number Update

The Magic Number for the Expert Advisors has been updated to **81001**.
Ensure your running EA instances on the VPS or local terminal are restarted to pick up this change.

- `EXNESS_GenX_Trader.mq5`: Default `Expert_MagicNumber` = 81001
- `SMC_TrendBreakout_MTF_EA.mq5`: Default `MagicNumber` = 81001
