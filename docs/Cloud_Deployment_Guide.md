# Cloud Deployment Guide

This guide explains how to deploy the MQL5 Trading Automation system to various cloud platforms.

## Supported Platforms

- **Render.com** - Simple web service deployment
- **Railway.app** - Container-based deployment
- **Fly.io** - Global edge deployment
- **Docker** - Container deployment (any platform)
- **Heroku** - Legacy support (via Docker)

## Prerequisites

- GitHub repository pushed and accessible
- Account on chosen cloud platform
- Python 3.8+ support on platform

## Platform-Specific Deployment

### 1. Render.com Deployment

**Configuration File:** `render.yaml`

**Steps:**

1. **Push to GitHub:**
   ```bash
   git push origin main
   ```

2. **Create Render Service:**
   - Go to https://render.com
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Render will auto-detect `render.yaml`

3. **Configure Environment Variables** (if needed):
   - `PYTHONUNBUFFERED=1`
   - `TZ=UTC` (or your timezone)

4. **Deploy:**
   - Click "Create Web Service"
   - Render will build and deploy automatically

**Manual Deploy Script:**
```bash
python scripts/deploy_cloud.py render
```

### 2. Railway.app Deployment

**Configuration File:** `railway.json`

**Steps:**

1. **Install Railway CLI:**
   ```bash
   npm i -g @railway/cli
   ```

2. **Login:**
   ```bash
   railway login
   ```

3. **Initialize Project:**
   ```bash
   railway init
   ```

4. **Deploy:**
   ```bash
   railway up
   ```

**Or use Railway Dashboard:**
- Go to https://railway.app
- Create new project
- Connect GitHub repository
- Railway will auto-detect `railway.json`

**Manual Deploy Script:**
```bash
python scripts/deploy_cloud.py railway
```

### 3. Fly.io Deployment

**Configuration File:** `fly.toml`

**Steps:**

1. **Install Fly CLI:**
   ```bash
   # Windows (PowerShell)
   powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"
   
   # macOS/Linux
   curl -L https://fly.io/install.sh | sh
   ```

2. **Login:**
   ```bash
   fly auth login
   ```

3. **Launch App:**
   ```bash
   fly launch
   ```

4. **Deploy:**
   ```bash
   fly deploy
   ```

**Manual Deploy Script:**
```bash
python scripts/deploy_cloud.py flyio
```

### 4. Docker Deployment

**Configuration Files:** `Dockerfile`, `docker-compose.yml`

**Local Docker Build:**

```bash
# Build image
docker build -t mql5-automation .

# Run container
docker run -d --name mql5-automation \
  -v $(pwd)/config:/app/config \
  -v $(pwd)/logs:/app/logs \
  mql5-automation

# Or use docker-compose
docker-compose up -d
```

**Deploy to Cloud with Docker:**

Any platform that supports Docker:
- **AWS ECS/Fargate**
- **Google Cloud Run**
- **Azure Container Instances**
- **DigitalOcean App Platform**
- **Vercel** (with Docker support)

**Manual Deploy Script:**
```bash
python scripts/deploy_cloud.py docker --build
```

### 5. Heroku Deployment

**Using Docker:**

1. **Create `heroku.yml`:**
   ```yaml
   build:
     docker:
       web: Dockerfile
   ```

2. **Deploy:**
   ```bash
   heroku container:push web
   heroku container:release web
   ```

## Configuration

### Environment Variables

All platforms support these environment variables:

```bash
PYTHONUNBUFFERED=1          # Python output buffering
TZ=UTC                      # Timezone
LOG_LEVEL=INFO              # Logging level
MAX_RETRIES=3               # Component retry count
```

### Volume Mounts

For persistent storage (logs, config):
- **Render:** Use Render Disk (paid plans)
- **Railway:** Use Railway Volumes
- **Fly.io:** Use Fly Volumes
- **Docker:** Use bind mounts or volumes

## Monitoring

### Health Checks

All platforms support health checks:
- **Render:** Configured in `render.yaml`
- **Railway:** Automatic
- **Fly.io:** Configured in `fly.toml`
- **Docker:** Use `docker-compose.yml` healthcheck

### Logs

Access logs on each platform:
- **Render:** Dashboard → Logs tab
- **Railway:** Dashboard → Deployments → View Logs
- **Fly.io:** `fly logs`
- **Docker:** `docker logs mql5-automation`

## Continuous Deployment

### GitHub Actions Integration

All platforms support automatic deployment on push:

1. **Render:** Enable "Auto-Deploy" in settings
2. **Railway:** Enable "Auto Deploy" in project settings
3. **Fly.io:** Use GitHub Actions workflow (see below)

### GitHub Actions Workflow

Create `.github/workflows/deploy-cloud.yml`:

```yaml
name: Deploy to Cloud

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Render
        uses: johnletey/railway-deploy@master
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

## Cost Considerations

### Free Tiers

- **Render:** Free tier available (limited hours)
- **Railway:** $5 credit/month
- **Fly.io:** Free tier with limits
- **Docker:** Free on self-hosted

### Paid Plans

- **Render:** $7/month for always-on
- **Railway:** Pay-as-you-go
- **Fly.io:** Pay-as-you-go
- **Docker:** Varies by platform

## Troubleshooting

### Common Issues

**1. Build Failures:**
- Check Python version compatibility
- Verify all dependencies in `requirements.txt`
- Review build logs

**2. Runtime Errors:**
- Check environment variables
- Verify file permissions
- Review application logs

**3. Connection Issues:**
- Verify network configuration
- Check firewall rules
- Review platform-specific networking docs

### Getting Help

- **Render:** https://render.com/docs
- **Railway:** https://docs.railway.app
- **Fly.io:** https://fly.io/docs
- **Docker:** https://docs.docker.com

## Quick Deploy Commands

```bash
# Setup all platform configs
python scripts/deploy_cloud.py all

# Deploy to specific platform
python scripts/deploy_cloud.py render
python scripts/deploy_cloud.py railway
python scripts/deploy_cloud.py flyio
python scripts/deploy_cloud.py docker --build
```

## Next Steps

After deployment:

1. **Monitor Logs:** Check platform dashboard for logs
2. **Test Functionality:** Verify automation is running
3. **Set Up Alerts:** Configure notifications for failures
4. **Scale if Needed:** Adjust resources based on usage

## Support

For deployment issues:
- Email: Lengkundee01.org@domain.com
- GitHub Issues: https://github.com/A6-9V/MQL5-Google-Onedrive/issues
- WhatsApp: [Agent community](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)
