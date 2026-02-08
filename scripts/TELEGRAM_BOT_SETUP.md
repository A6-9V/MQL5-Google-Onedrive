# Telegram Deployment Bot Setup Guide

This bot allows you to deploy your MQL5 Trading Automation to Fly.io, Render, and Railway via Telegram commands.

**Bot API Reference:** https://core.telegram.org/bots/api

## 🚀 Quick Start

### 1. Configure the Bot Credentials

This repository supports Telegram bot integration for deployment automation. To use it:
- Create your own bot using @BotFather on Telegram
- Get your bot token from @BotFather
- Get your Telegram user ID from @userinfobot
- Add credentials to your vault.json file (see config/vault.json.example)

### 2. Set Environment Variables

**Windows (PowerShell):**
```powershell
$env:TELEGRAM_BOT_TOKEN = "your_bot_token_here"
$env:TELEGRAM_ALLOWED_USER_IDS = "123456789,987654321"  # Required: restrict to specific user IDs
```

**Windows (CMD):**
```cmd
set TELEGRAM_BOT_TOKEN=your_bot_token_here
set TELEGRAM_ALLOWED_USER_IDS=123456789,987654321
```

**Linux/WSL:**
```bash
export TELEGRAM_BOT_TOKEN="your_bot_token_here"
export TELEGRAM_ALLOWED_USER_IDS="123456789,987654321"
```

**Permanent (Windows):**
```powershell
[System.Environment]::SetEnvironmentVariable('TELEGRAM_BOT_TOKEN', 'your_bot_token_here', 'User')
[System.Environment]::SetEnvironmentVariable('TELEGRAM_ALLOWED_USER_IDS', '123456789', 'User')
```

### 3. Install Dependencies

```bash
pip install -r scripts/requirements_bot.txt
```

### 4. Run the Bot

**From repository root:**
```bash
cd C:\Users\USER\Documents\repos\MQL5-Google-Onedrive
python scripts/telegram_deploy_bot.py
```

**Or from scripts directory:**
```bash
cd scripts
python telegram_deploy_bot.py
```

## 📱 Bot Commands

Once the bot is running, open your bot on Telegram and send:

- `/start` - Initialize the bot and see welcome message
- `/help` - Show all available commands
- `/deploy_flyio` - Deploy to Fly.io cloud platform
- `/deploy_render` - Deploy to Render.com
- `/deploy_railway` - Deploy to Railway.app
- `/deploy_docker` - Build Docker image locally
- `/status` - Check Fly.io app deployment status

## 🔒 Security

### Restrict Access by User ID

1. Get your Telegram user ID:
   - Send a message to @userinfobot on Telegram
   - It will reply with your user ID

2. Set `TELEGRAM_ALLOWED_USER_IDS` environment variable with your user ID(s):
   ```powershell
   $env:TELEGRAM_ALLOWED_USER_IDS = "123456789"
   ```

If `TELEGRAM_ALLOWED_USER_IDS` is not set, the bot will deny all users for security.

## 🐳 Running as a Service

### Windows (Task Scheduler)

1. Create a PowerShell script `start_bot.ps1`:
   ```powershell
   $env:TELEGRAM_BOT_TOKEN = "your_token"
   cd C:\Users\USER\Documents\repos\MQL5-Google-Onedrive
   python scripts/telegram_deploy_bot.py
   ```

2. Open Task Scheduler → Create Basic Task
3. Set trigger (e.g., "At startup")
4. Action: Start a program → `powershell.exe`
5. Arguments: `-ExecutionPolicy Bypass -File "C:\path\to\start_bot.ps1"`

### Linux/WSL (systemd)

Create `/etc/systemd/system/telegram-deploy-bot.service`:

```ini
[Unit]
Description=Telegram Deployment Bot
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/path/to/MQL5-Google-Onedrive
Environment="TELEGRAM_BOT_TOKEN=your_token"
Environment="TELEGRAM_ALLOWED_USER_IDS=123456789"
ExecStart=/usr/bin/python3 scripts/telegram_deploy_bot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable telegram-deploy-bot
sudo systemctl start telegram-deploy-bot
sudo systemctl status telegram-deploy-bot
```

## 🚀 Deploying the Bot Itself to Fly.io

You can also deploy this bot to Fly.io so it runs in the cloud:

1. **Create a separate Fly.io app for the bot:**
   ```bash
   flyctl launch --name telegram-deploy-bot
   ```

2. **Set secrets:**
   ```bash
   flyctl secrets set TELEGRAM_BOT_TOKEN=your_token
   flyctl secrets set TELEGRAM_ALLOWED_USER_IDS=123456789
   ```

3. **Update fly.toml** to run the bot:
   ```toml
   [build]
   
   [env]
     PYTHONUNBUFFERED = "1"
   
   # No HTTP services needed for polling bot
   ```

4. **Deploy:**
   ```bash
   flyctl deploy
   ```

## 📝 Notes

- The bot uses **long polling** (not webhooks), so it works on any server
- Deployments run in background and may take several minutes
- Make sure `flyctl` is in your PATH for Fly.io deployments
- Check logs if deployments fail: `flyctl logs` or bot console output

## 🆘 Troubleshooting

**Bot doesn't respond:**
- Check if bot token is correct
- Verify bot is running (check console output)
- Make sure you're messaging the correct bot

**Deployment fails:**
- Check if flyctl/railway CLI is installed and authenticated
- Verify repository has necessary config files (fly.toml, etc.)
- Check bot logs for detailed error messages

**Permission denied:**
- Verify your user ID is in `TELEGRAM_ALLOWED_USER_IDS`
