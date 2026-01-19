# Cloud Deployment Guide

This guide covers deploying the MQL5 Trading Automation system to various cloud platforms.

## Supported Platforms

- ✅ **Fly.io** - Fast, global deployment
- ✅ **Render.com** - Simple, automatic deployments
- ✅ **Railway.app** - Developer-friendly platform
- ✅ **Docker Hub** - Container registry

## Prerequisites

- Docker installed locally
- Accounts on target cloud platforms
- GitHub repository (for automatic deployments)

## Quick Deploy Commands

### Fly.io

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Login
flyctl auth login

# Deploy
flyctl deploy

# Check status
flyctl status
```

### Render.com

1. Push code to GitHub
2. Go to https://render.com
3. Create new Web Service
4. Connect GitHub repository
5. Render auto-detects `render.yaml`
6. Deploy!

### Railway.app

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Initialize project
railway init

# Deploy
railway up
```

## Configuration Files

### Dockerfile.cloud

Production-optimized Docker image:
- Minimal dependencies
- Health checks
- Security best practices

### render.yaml

Render.com configuration:
- Auto-deployment from GitHub
- Environment variables
- Health checks

### fly.toml

Fly.io configuration:
- Region selection
- Port mapping
- Scaling options

### railway.json

Railway.app configuration:
- Build settings
- Start commands
- Restart policies

## Environment Variables

Set these in your cloud platform dashboard:

### Required

```bash
PYTHONUNBUFFERED=1
TZ=UTC
ENV=production
```

### Optional (for Telegram Bot)

```bash
TELEGRAM_BOT_TOKEN=your_token_here
TELEGRAM_ALLOWED_USER_IDS=123456789
```

### Secrets Management

**Never commit secrets to Git!**

- Use platform secret management:
  - Fly.io: `flyctl secrets set KEY=value`
  - Render: Dashboard → Environment → Secrets
  - Railway: Dashboard → Variables

## Deployment Workflow

### 1. Local Testing

```bash
# Build production image locally
docker build -f Dockerfile.cloud -t mql5-automation:latest .

# Test locally
docker run -p 8080:8080 mql5-automation:latest
```

### 2. Push to GitHub

```bash
git add .
git commit -m "Deploy to cloud"
git push origin main
```

### 3. Deploy to Cloud

**Fly.io:**
```bash
flyctl deploy
```

**Render:**
- Automatic on push (if auto-deploy enabled)

**Railway:**
```bash
railway up
```

## Monitoring

### Fly.io

```bash
# View logs
flyctl logs

# Check metrics
flyctl status
```

### Render

- Dashboard → Logs tab
- Dashboard → Metrics tab

### Railway

```bash
# View logs
railway logs

# Check status
railway status
```

## Troubleshooting

### Build Fails

1. **Check Dockerfile syntax**
   ```bash
   docker build -f Dockerfile.cloud -t test .
   ```

2. **Check requirements.txt**
   ```bash
   pip install -r requirements.txt
   ```

### Container Crashes

1. **Check logs**
   ```bash
   # Fly.io
   flyctl logs
   
   # Render
   # Dashboard → Logs
   
   # Railway
   railway logs
   ```

2. **Test locally first**
   ```bash
   docker run mql5-automation:latest
   ```

### Environment Variables Not Working

1. **Verify in platform dashboard**
2. **Check variable names (case-sensitive)**
3. **Restart service after adding variables**

## Cost Optimization

### Fly.io

- Free tier: 3 shared-cpu-1x VMs
- Pay-as-you-go for additional resources

### Render

- Free tier: 750 hours/month
- Paid plans start at $7/month

### Railway

- Free tier: $5 credit/month
- Pay-as-you-go pricing

## Security Best Practices

1. **Never commit secrets**
   - Use `.gitignore` for sensitive files
   - Use platform secret management

2. **Use HTTPS**
   - All platforms provide SSL certificates

3. **Limit access**
   - Use `TELEGRAM_ALLOWED_USER_IDS` for bot access

4. **Regular updates**
   - Keep dependencies updated
   - Monitor security advisories

## Next Steps

- [Development Container Setup](./DEV_CONTAINER_SETUP.md)
- [Telegram Bot Configuration](../scripts/TELEGRAM_BOT_SETUP.md)
- [Local Development Guide](./LOCAL_DEVELOPMENT.md)
