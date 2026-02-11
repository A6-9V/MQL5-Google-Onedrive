## 📓 Knowledge Base
- **NotebookLM**: [Access here](https://notebooklm.google.com/notebook/e8f4c29d-9aec-4d5f-8f51-2ca168687616)
- **Note**: This notebook is available for reading and writing. AI agents must read it before starting work.

## SMC + Trend Breakout (MTF) for Exness MT5

This repo contains:

- `mt5/MQL5/Indicators/SMC_TrendBreakout_MTF.mq5`: visual indicator (BOS/CHoCH + Donchian breakout + lower-timeframe confirmation).
- `mt5/MQL5/Experts/SMC_TrendBreakout_MTF_EA.mq5`: Expert Advisor (alerts + optional auto-trading).

### ☁️ Cloud Deployment

**Deploy to cloud platforms:**
- **Render.com**: Auto-deploy with `render.yaml`
- **Railway.app**: Deploy with `railway.json`
- **Fly.io**: Deploy with `fly.toml`
- **Docker**: Build and deploy anywhere

**Quick Deploy:**
```bash
# Setup all platform configs
python scripts/deploy_cloud.py all

# Deploy to specific platform
python scripts/deploy_cloud.py render
python scripts/deploy_cloud.py railway
python scripts/deploy_cloud.py flyio
python scripts/deploy_cloud.py docker --build
```

**🐳 Docker Hub Deployment:**

1. **Publish Image** (Run locally):
   ```bash
   ./scripts/deploy_docker_hub.sh <USERNAME> <TOKEN>
   ```

2. **Run on VPS/Laptop**:
   ```bash
   # Update and run
   ./scripts/update_vps.sh <USERNAME> <TOKEN>
   ```

📖 **For detailed cloud deployment instructions, see [Cloud Deployment Guide](docs/Cloud_Deployment_Guide.md)**

### 🤖 Telegram Bot Deployment

**Deploy and manage your trading system via Telegram!**

- **API Reference**: https://core.telegram.org/bots/api

**Available Commands:**
- `/deploy_flyio` - Deploy to Fly.io
- `/deploy_render` - Deploy to Render.com
- `/deploy_railway` - Deploy to Railway.app
- `/status` - Check deployment status

**Setup:**
```bash
# Set your Telegram user ID for access control
export TELEGRAM_ALLOWED_USER_IDS="your_telegram_user_id"

# Start the bot
python scripts/telegram_deploy_bot.py
```

📖 **For detailed setup instructions, see [Telegram Bot Setup Guide](scripts/TELEGRAM_BOT_SETUP.md)**

### Render workspace

My Blue watermelon Workspace
tea-d1joqqi4d50c738aiujg

### Quick Start: Full Setup

Run the automated setup script to validate your environment and get started:

```bash
bash setup.sh
```

This interactive script will:
- Check for required dependencies (Python 3, Bash, Git)
- Validate repository structure and shell scripts
- Show CLI tools installation status (GitHub CLI, Firebase, Docker, Cursor, Jules)
- Help you package MT5 files

For non-interactive/CI environments:
```bash
bash setup.sh --ci
```

### Install into Exness MetaTrader 5

> **⚠️ Note:** Custom Indicators and EAs are **not supported** on the Exness Web Terminal. You must use the **Desktop** version of MT5.

**📖 For detailed deployment instructions, see [Exness Deployment Guide](docs/Exness_Deployment_Guide.md)**

Quick start:

1. Open **Exness MT5**.
2. Go to **File → Open Data Folder**.
3. Copy:
   - `SMC_TrendBreakout_MTF.mq5` to `MQL5/Indicators/`
   - `SMC_TrendBreakout_MTF_EA.mq5` to `MQL5/Experts/`
4. In MT5, open **MetaEditor** (or press **F4**) and compile the files.
5. Back in MT5: **Navigator → Refresh**.

### 🚀 Automated Startup (NEW!)

**Quick Start:**
- **Windows**: `powershell -ExecutionPolicy Bypass -File scripts\startup.ps1`
- **Ubuntu/VPS**:
  ```bash
  # First time setup (installs Python, Wine, etc.)
  bash scripts/setup_ubuntu.sh

  # Start the system
  ./scripts/startup.sh
  ```
- **Linux/WSL**: `./scripts/startup.sh`

**Auto-Start on Boot:**
- **Windows**: `powershell -ExecutionPolicy Bypass -File scripts\startup.ps1 -CreateScheduledTask`
- **Linux**: `./scripts/startup.sh --setup-systemd`

📚 **Documentation**:
- [**Full Documentation Index**](docs/INDEX.md) - 👈 Start here for all guides
- [**Setup & Deployment (Comprehensive)**](docs/SETUP_AND_DEPLOY.md) - 🛠️ Start here for manual setup & GCP
- [WSL & VPS Guide](docs/WSL_AND_VPS_DEPLOYMENT.md) - Windows/Linux setup guide
- [Quick Reference Guide](QUICK_REFERENCE.md) - Command cheat sheet
- [Verification Report](VERIFICATION.md) - System status and test results
- [Startup Automation Guide](docs/Startup_Automation_Guide.md) - Complete guide
- [Quick Start](docs/Quick_Start_Automation.md) - Quick start instructions
- [Release Process](docs/RELEASE_PROCESS.md) - Creating and managing releases
- [Changelog](CHANGELOG.md) - Version history and changes

📖 **GitHub Features**:
- [GitHub Profile README Guide](docs/GitHub_Profile_README_Guide.md) - Create an impressive profile page
- [GitHub Gists Guide](docs/GitHub_Gists_Guide.md) - Share code snippets easily

The automation system handles:
- MT5 Terminal startup
- Python scripts execution
- Scheduled tasks configuration
- Process monitoring and logging
- Windows Task Scheduler integration
- Linux systemd/cron integration

### Optional: package / deploy helpers

- Create a zip you can copy to your PC:
  - `bash scripts/package_mt5.sh` → outputs `dist/Exness_MT5_MQL5.zip`
- Copy directly into your MT5 Data Folder (run this on the machine that has MT5 installed):
  - `bash scripts/deploy_mt5.sh "/path/from/MT5/File->Open Data Folder"`

### 📺 Demo Scripts

**Echo and Hello Window Demo:**
- `python3 scripts/echo_hello.py` - Run echo and hello window demo (Python version)
- `bash scripts/echo_hello.sh` - Run echo and hello window demo (Shell version)

These simple demonstration scripts showcase basic functionality:
- Echo messages to console
- Display formatted hello window
- Cross-platform support

📖 **See [Echo and Hello Window Guide](docs/Echo_Hello_Guide.md) for details**

### GitHub automation (reviews, CI, auto-merge, OneDrive sync)

This repo includes GitHub Actions workflows under `.github/workflows/`:

- **CD (`CD - Continuous Deployment`)**: comprehensive deployment automation
  - Triggered on push to main, tag creation, or manual dispatch
  - Builds MT5 package and Docker images
  - Deploys to cloud platforms (Render, Railway, Fly.io)
  - Deploys dashboard to GitHub Pages
  - Creates GitHub releases with assets
  - 📖 See [CD Workflow Guide](docs/CD_WORKFLOW_GUIDE.md) for details
- **CI (`CI`)**: runs on pull requests and pushes to `main/master`
  - Validates repo structure
  - Builds `dist/Exness_MT5_MQL5.zip` and uploads it as an artifact
- **Auto-merge enablement (`Enable auto-merge (label-driven)`)**: if a PR has the label **`automerge`**, it will enable GitHub’s auto-merge (squash). Your branch protection rules still control *when* it can merge (required reviews, required CI, etc.).
- **OneDrive sync (`Sync to OneDrive (rclone)`)**: on pushes to `main` (and manual runs), syncs `mt5/MQL5` to OneDrive via `rclone`.

Recommended repo settings (GitHub → **Settings**):

- **Branch protection (main)**:
  - Require pull request reviews (at least 1)
  - Require status checks: `CI / validate-and-package`
  - (Optional) Require CODEOWNERS review
- **Auto-merge**: enable “Allow auto-merge” in repo settings

OneDrive sync setup (required secrets):

- **`RCLONE_CONFIG_B64`**: base64 of your `rclone.conf` containing a OneDrive remote.

Example (run locally, then paste into GitHub Secrets):

```bash
rclone config
base64 -w0 ~/.config/rclone/rclone.conf
```

Optional secrets:

- **`ONEDRIVE_REMOTE`**: remote name in `rclone.conf` (default: `onedrive`)
- **`ONEDRIVE_PATH`**: destination folder path (default: `Apps/MT5/MQL5`)

Firefox Relay API key (optional secrets):

- **`SCRSOR`**
- **`COPILOT`**

Set both to your Firefox Relay profile API key (`https://relay.firefox.com/accounts/profile/`). Store these as GitHub Secrets or in a local `.env` file (see `.env.example`). Do not commit secret values.

Cloudflare Configuration (required for domain registration/management):

- **`CLOUDFLARE_ZONE_ID`**: Your Cloudflare Zone ID.
- **`CLOUDFLARE_ACCOUNT_ID`**: Your Cloudflare Account ID.
- **`DOMAIN_NAME`**: Your domain name (e.g., `Lengkundee01.org`).

Store these as GitHub Secrets or in a local `.env` file. See [Secrets Management Guide](docs/Secrets_Management.md) for more details.

You can use the helper script to set these secrets if you have the GitHub CLI installed:

```bash
# First, update config/vault.json with your credentials
# Then run:
bash scripts/set_github_secrets.sh vault
```

### Use the indicator

- Attach `SMC_TrendBreakout_MTF` to a chart (your main timeframe).
- Set **LowerTF** to a smaller timeframe (ex: main = M15, lower = M5 or M1).
- Signals require lower-TF confirmation by default (EMA fast/slow direction).

### Use the EA (push to terminal + optional auto trading)

- Attach `SMC_TrendBreakout_MTF_EA` to a chart.
- Enable **Algo Trading** in MT5 if you want auto entries.
- If you want phone push alerts:
  - MT5 → **Tools → Options → Notifications**
  - enable push notifications and set your MetaQuotes ID.
- For web request integrations (ZOLO-A6-9V-NUNA- plugin):
  - Set the EA input `WebRequestURL` to your bridge endpoint (example: `https://your-bridge.example/api/signal`)
  - Enable the EA input `EnableWebRequest`
  - Add your bridge URL to MT5's allowed URLs list:
    - MT5 → **Tools → Options → Expert Advisors**
    - Check "Allow WebRequest for listed URL"
    - Add the URL: `https://your-bridge.example`

### 🤖 AI Integration (Gemini & Jules)

The EA supports **Google Gemini** and **Jules AI** to confirm trades before entry.

**Setup:**
1.  **Get an API Key**:
    *   Gemini: [Google AI Studio](https://aistudio.google.com/)
    *   Jules: Your Jules API Dashboard
2.  **Configure MT5**:
    *   Go to **Tools → Options → Expert Advisors**.
    *   Check **"Allow WebRequest for listed URL"**.
    *   Add the URLs:
        *   `https://generativelanguage.googleapis.com` (for Gemini)
        *   Your Jules API URL (e.g., `https://api.jules.ai` or similar)
3.  **Configure the EA**:
    *   Set `UseGeminiFilter` to `true` (Enable AI).
    *   Select `AiProvider`: `PROVIDER_GEMINI` or `PROVIDER_JULES`.
    *   Paste your API Key into `GeminiApiKey` or `JulesApiKey`.

    **Shared/Default Keys:**
    *   **Gemini**: `[INSERT_GEMINI_API_KEY]`
    *   **Jules**: `[INSERT_JULES_API_KEY]`

### 🧠 AI Market Research & Upgrade Automation (New!)

Automate market analysis and code upgrades using Gemini and Jules.

**Setup:**
1.  Run the setup script:
    ```bash
    ./scripts/setup_research.sh
    ```
2.  Add your API keys to the `.env` file generated:
    ```
    GEMINI_API_KEY=...
    JULES_API_KEY=...
    JULES_API_URL=...
    ```

**Features:**
- **Market Research**: Fetches real market data (via `yfinance`) and generates a report (`docs/market_research_report.md`).
- **Code Upgrades**: Suggests EA improvements based on the research (`docs/upgrade_suggestions.md`).
- **Scheduling**: Runs automatically every 4 hours via `scripts/schedule_research.py`.

### Auto SL/TP + risk management (EA)

In `SMC_TrendBreakout_MTF_EA`:

- **SLMode**
  - `SL_ATR`: SL = ATR × `ATR_SL_Mult`
  - `SL_SWING`: SL beyond last confirmed fractal swing (with `SwingSLBufferPoints`), fallback to ATR if swing is missing/invalid
  - `SL_FIXED_POINTS`: SL = `FixedSLPoints`
- **TPMode**
  - `TP_RR`: TP = `RR` × SL distance
  - `TP_FIXED_POINTS`: TP = `FixedTPPoints`
  - `TP_DONCHIAN_WIDTH`: TP = Donchian channel width × `DonchianTP_Mult` (fallback to ATR width if needed)
- **RiskPercent**
  - If `RiskPercent > 0`, lots are calculated from SL distance so the **money at risk ≈ RiskPercent of Equity** (or Balance if you disable `RiskUseEquity`).
  - `RiskClampToFreeMargin` can reduce lots if required margin is too high.

### Notes / safety

- This is a rules-based implementation of common “SMC” ideas (fractal swing BOS/CHoCH) and a Donchian breakout.
- Test in Strategy Tester and/or demo before using real funds.

### Project links

- [**User Notes & References**](docs/USER_NOTES.md) - 📝 Personal notes and external links
- **OneDrive Vault Password**: `[ACCESS_CODE_REQUIRED]` (Access Code)
- **NotebookLM Context**: [NotebookLM](https://notebooklm.google.com/notebook/e8f4c29d-9aec-4d5f-8f51-2ca168687616)
- **Cursor Connect**: [Join Session](https://prod.liveshare.vsengsaas.visualstudio.com/join?9C5AED55D7D6624FE2E1B50AD9F14D1339A5)
- Developer tip window project: https://chatgpt.com/g/g-p-691e9c0ace5c8191a1b409c09251cc2b-window-for-developer-tip/project
- GenX Workspace (VSCode): [OneDrive Folder](https://1drv.ms/f/c/8F247B1B46E82304/IgCPaN4jwMKZTar1XBwn8W9zAYFz0tYoNz7alcAhiiI9oIQ)
- Samurai All Branch Structure: [OneDrive Folder](https://1drv.ms/f/c/8F247B1B46E82304/IgDpUzdplXkDTpiyCkdNDZpXASUMJEccVuNGxAaY3MxB1sA)
- Plugin Integration: [ZOLO-A6-9V-NUNA-](https://1drv.ms/f/c/8F247B1B46E82304/IgBYRTEjjPv-SKHi70WnmmU8AZb3Mr5X1o3a0QNU_mKgAZg)
- GitHub Pages: https://github.com/Mouy-leng/-LengKundee-mql5.github.io.git
- ZOLO Bridge Endpoint: (set this privately in EA inputs / vault)

### Contact

- Email: `Lengkundee01.org@domain.com`
- WhatsApp: [Agent community](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)
