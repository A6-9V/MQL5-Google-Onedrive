# Development Container Setup Guide

This guide explains how to set up and use the development container for the MQL5 Trading Automation system.

## Prerequisites

- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **VS Code** with the **Dev Containers** extension
- **Git** (for cloning the repository)

## Quick Start

### Option 1: VS Code Dev Container (Recommended)

1. **Open in VS Code**
   ```bash
   code C:\Users\USER\Documents\repos\MQL5-Google-Onedrive
   ```

2. **Reopen in Container**
   - Press `F1` or `Ctrl+Shift+P`
   - Type: `Dev Containers: Reopen in Container`
   - Select the command
   - Wait for the container to build (first time takes ~5-10 minutes)

3. **Container is Ready!**
   - All dependencies are installed
   - Python environment is configured
   - You can start coding immediately

### Option 2: Docker Compose (Local Development)

1. **Start Development Environment**
   ```bash
   docker-compose -f docker-compose.dev.yml up -d
   ```

2. **Access the Container**
   ```bash
   docker exec -it mql5-trading-dev bash
   ```

3. **Run Commands**
   ```bash
   # Install dependencies (if needed)
   pip install -r requirements.txt
   
   # Run Telegram bot
   python scripts/telegram_deploy_bot.py
   
   # Run deployment script
   python scripts/deploy_cloud.py flyio
   ```

4. **Stop the Container**
   ```bash
   docker-compose -f docker-compose.dev.yml down
   ```

## Container Features

### Pre-installed Tools

- **Python 3.11** with pip
- **Git** for version control
- **Development Tools**: black, pylint, pytest, ipython
- **System Tools**: vim, nano, curl, wget

### VS Code Extensions (Auto-installed)

- Python
- Pylance
- Black Formatter
- Docker
- GitHub Copilot
- GitLens
- PowerShell

### Port Forwarding

- **8080**: Main application
- **5000**: API server (if needed)
- **3000**: Dashboard (if needed)

## Development Workflow

### 1. Making Changes

- Edit files directly in VS Code
- Changes are synced to the container via volume mounts
- No need to rebuild the container

### 2. Running Scripts

```bash
# In VS Code terminal (inside container)
python scripts/telegram_deploy_bot.py
python scripts/deploy_cloud.py flyio
```

### 3. Testing

```bash
# Run tests (if available)
pytest

# Format code
black scripts/

# Lint code
pylint scripts/
```

### 4. Installing New Dependencies

```bash
# Add to requirements.txt
pip install new-package
pip freeze > requirements.txt
```

## Cloud Deployment

### Deploy to Fly.io

```bash
# From inside the container
flyctl deploy
```

### Deploy to Render

1. Push to GitHub
2. Connect repository to Render
3. Render auto-detects `render.yaml`

### Deploy to Railway

```bash
# Install Railway CLI
npm i -g @railway/cli

# Deploy
railway up
```

## Troubleshooting

### Container Won't Start

1. **Check Docker is Running**
   ```bash
   docker ps
   ```

2. **Rebuild Container**
   ```bash
   # In VS Code: F1 → Dev Containers: Rebuild Container
   # Or via command line:
   docker-compose -f docker-compose.dev.yml build --no-cache
   ```

### Port Already in Use

1. **Change ports in `docker-compose.dev.yml`**
2. **Or stop the conflicting service**

### Python Module Not Found

1. **Install in container**
   ```bash
   pip install -r requirements.txt
   ```

2. **Check PYTHONPATH**
   ```bash
   echo $PYTHONPATH  # Should be /app
   ```

### Permission Errors

1. **Check file permissions**
   ```bash
   ls -la scripts/
   ```

2. **Make executable**
   ```bash
   chmod +x scripts/*.py
   ```

## File Structure

```
.devcontainer/
  └── devcontainer.json    # VS Code dev container config
Dockerfile.dev              # Development Docker image
Dockerfile.cloud            # Production Docker image
docker-compose.dev.yml      # Local development setup
requirements.txt            # Python dependencies
```

## Next Steps

- [Deploy to Cloud](./CLOUD_DEPLOYMENT.md)
- [Telegram Bot Setup](../scripts/TELEGRAM_BOT_SETUP.md)
- [MT5 Deployment Guide](../docs/Exness_Deployment_Guide.md)
