# MQL5 EA Container CI/CD Deployment Guide

This guide describes the unified containerized deployment system for the MQL5 Trading Automation platform.

## Architecture

The system supports two deployment modes:
1. **Lightweight (Python Only)**: Runs management bots and dashboards. Assumes MetaTrader 5 is running elsewhere.
2. **Full (MT5 + Wine)**: Runs MetaTrader 5 inside the container using Wine and Xvfb.

## Deployment Options

### 1. Local Deployment (Docker Compose)

To run the full MT5-enabled container:
```bash
docker-compose up -d mql5-ea-full
```

To run the lightweight version:
```bash
docker-compose up -d mql5-automation
```

### 2. CI/CD Deployment (GitHub Actions)

The repository is configured with a central CI/CD pipeline: `.github/workflows/container-ci-cd.yml`.

#### Automatic Deployment
- On every push to `main`, the MT5-enabled Docker image is built and pushed to **GitHub Container Registry (GHCR)**.
- Image: `ghcr.io/a6-9v/mql5-google-onedrive:mt5-latest`

#### Manual Deployment
1. Go to **Actions** -> **Container CI/CD Deployment**.
2. Click **Run workflow**.
3. Select the **Target**:
   - `ghcr`: Build and push only.
   - `render`: Deploy to Render.com.
   - `railway`: Deploy to Railway.app.
   - `flyio`: Deploy to Fly.io.
   - `gcp`: Deploy to Google Cloud Platform.
   - `all`: All of the above.

## Prerequisites

### Required Secrets (GitHub Settings)
Set these in **Settings > Secrets and variables > Actions**:

- `FLY_API_TOKEN`: Required for Fly.io.
- `RENDER_API_KEY`: Optional, for Render API.
- `RAILWAY_TOKEN`: Optional, for Railway API.
- `GITHUB_TOKEN`: Provided automatically by GitHub.

## Container Configuration

### Environment Variables
- `DISPLAY`: Set to `:99` for Xvfb.
- `WINEPREFIX`: Location of the Wine environment (`/app/.wine`).
- `WINEDEBUG`: Set to `-all` to reduce log noise.
- `PYTHONUNBUFFERED`: Ensures logs are visible in real-time.

### Volumes
- `/app/config`: Configuration files.
- `/app/logs`: Application logs.
- `/app/mt5`: MetaTrader 5 data and MQL5 files.

## Troubleshooting

### Container fails to start
Check logs using:
```bash
docker logs mql5-ea-full
```

### Wine issues
If Wine fails to initialize, ensure the container has enough memory (at least 2GB recommended for MT5).

### Xvfb issues
The entrypoint script `scripts/container_entrypoint.sh` handles Xvfb startup. Ensure it is executable.

---
Created by Jules - Software Engineer
