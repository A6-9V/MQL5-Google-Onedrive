# Quick Cloud Deployment Guide

## Prerequisites

1. **Docker Desktop** - Must be running
2. **Fly.io CLI** (for Fly.io deployment)
3. **GitHub account** (for Render.com)

## Quick Deploy Commands

### Option 1: PowerShell Script (Recommended)

```powershell
# Deploy to Fly.io
.\scripts\deploy_cloud_simple.ps1 -Platform flyio

# Deploy to Render (instructions)
.\scripts\deploy_cloud_simple.ps1 -Platform render

# Deploy to Railway
.\scripts\deploy_cloud_simple.ps1 -Platform railway
```

### Option 2: Python Script

```powershell
# Deploy to Fly.io
python scripts/deploy_cloud.py flyio

# Deploy to Render
python scripts/deploy_cloud.py render

# Deploy to Railway
python scripts/deploy_cloud.py railway
```

### Option 3: Manual Deployment

#### Fly.io

1. **Install Fly CLI** (if not installed):
   ```powershell
   iwr https://fly.io/install.ps1 -useb | iex
   ```

2. **Login**:
   ```powershell
   flyctl auth login
   ```

3. **Deploy**:
   ```powershell
   flyctl deploy
   ```

#### Render.com

1. **Push to GitHub**:
   ```powershell
   git add .
   git commit -m "Deploy to Render"
   git push origin main
   ```

2. **Go to Render.com**:
   - Visit https://render.com
   - Create new Web Service
   - Connect GitHub repository
   - Render auto-detects `render.yaml`
   - Deploy!

#### Railway.app

1. **Install Railway CLI**:
   ```powershell
   npm i -g @railway/cli
   ```

2. **Login and Deploy**:
   ```powershell
   railway login
   railway init
   railway up
   ```

## Environment Variables

Set these secrets in your cloud platform:

### Required
- `PYTHONUNBUFFERED=1`
- `TZ=UTC`
- `ENV=production`

### Optional (for Telegram Bot)
- `TELEGRAM_BOT_TOKEN` (from config/vault.json)
- `TELEGRAM_ALLOWED_USER_IDS` (comma-separated user IDs - REQUIRED for access)

### Setting Secrets

**Fly.io:**
```powershell
flyctl secrets set TELEGRAM_BOT_TOKEN=your_token_here
```

**Render.com:**
- Dashboard → Environment → Add Secret

**Railway:**
- Dashboard → Variables → Add Variable

## Troubleshooting

### Docker Not Running
```powershell
# Start Docker Desktop manually, or:
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
```

### Build Fails
```powershell
# Test Docker build locally
docker build -f Dockerfile.cloud -t mql5-automation:latest .
```

### Deployment Fails
1. Check logs: `flyctl logs` (or platform equivalent)
2. Verify environment variables are set
3. Check Dockerfile.cloud syntax
4. Ensure requirements.txt is up to date

## Next Steps

After deployment:
- ✅ Check app status: `flyctl status`
- ✅ View logs: `flyctl logs`
- ✅ Test Telegram bot: Send `/start` to your bot
- ✅ Monitor: Use platform dashboard
