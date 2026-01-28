# Deploy Web Dashboard to Cloud Platforms
# Supports: Fly.io, Render.com, GitHub Pages, and local preview

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("flyio", "render", "github", "local", "all")]
    [string]$Platform = "all",
    
    [switch]$OpenBrowser = $false
)

$ErrorActionPreference = "Stop"

# Repository paths
$repoRoot = Split-Path -Parent $PSScriptRoot
$dashboardDir = Join-Path $repoRoot "dashboard"
$docsDir = Join-Path $repoRoot "docs"

Write-Host "=========================================="
Write-Host "Web Dashboard Deployment Script"
Write-Host "=========================================="
Write-Host ""

# Create dashboard directory if it doesn't exist
if (-not (Test-Path $dashboardDir)) {
    Write-Host "📁 Creating dashboard directory..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $dashboardDir -Force | Out-Null
}

Write-Host "✅ Dashboard directory: $dashboardDir" -ForegroundColor Green
Write-Host ""

# Deployment functions
function Deploy-FlyIO {
    Write-Host "🚀 Deploying dashboard to Fly.io..." -ForegroundColor Cyan
    
    $flyToml = Join-Path $dashboardDir "fly.toml"
    
    # Create fly.toml for dashboard
    $flyConfig = @"
app = "mql5-dashboard"
primary_region = "iad"

[build]
  command = ""

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0
  processes = ["app"]

  [[http_service.checks]]
    grace_period = "10s"
    interval = "30s"
    timeout = "5s"
    method = "GET"
    path = "/"

[env]
  PORT = "8080"
"@
    
    Set-Content -Path $flyToml -Value $flyConfig
    Write-Host "✅ Created fly.toml" -ForegroundColor Green
    
    # Check for Dockerfile or create simple one
    $dockerfile = Join-Path $dashboardDir "Dockerfile"
    if (-not (Test-Path $dockerfile)) {
        $dockerfileContent = @"
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
"@
        Set-Content -Path $dockerfile -Value $dockerfileContent
        Write-Host "✅ Created Dockerfile for static hosting" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "To deploy:" -ForegroundColor Yellow
    Write-Host "  cd dashboard" -ForegroundColor Yellow
    Write-Host "  flyctl launch" -ForegroundColor Yellow
    Write-Host "  flyctl deploy" -ForegroundColor Yellow
}

function Deploy-Render {
    Write-Host "🚀 Setting up Render.com deployment..." -ForegroundColor Cyan
    
    $renderYaml = Join-Path $dashboardDir "render.yaml"
    
    $renderConfig = @"
services:
  - type: web
    name: mql5-dashboard
    env: static
    buildCommand: ""
    staticPublishPath: .
    routes:
      - type: rewrite
        source: /*
        destination: /index.html
"@
    
    Set-Content -Path $renderYaml -Value $renderConfig
    Write-Host "✅ Created render.yaml" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "To deploy:" -ForegroundColor Yellow
    Write-Host "1. Push dashboard folder to GitHub" -ForegroundColor Yellow
    Write-Host "2. Go to https://render.com" -ForegroundColor Yellow
    Write-Host "3. Create new Static Site" -ForegroundColor Yellow
    Write-Host "4. Connect GitHub repository" -ForegroundColor Yellow
}

function Deploy-GitHubPages {
    Write-Host "🚀 Setting up GitHub Pages deployment..." -ForegroundColor Cyan
    
    $workflowDir = Join-Path $repoRoot ".github\workflows"
    if (-not (Test-Path $workflowDir)) {
        New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null
    }
    
    $workflowFile = Join-Path $workflowDir "deploy-dashboard.yml"
    
    $workflowContent = @"
name: Deploy Dashboard to GitHub Pages

on:
  push:
    branches:
      - main
    paths:
      - 'dashboard/**'
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  deploy:
    environment:
      name: github-pages
      url: `${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Pages
        uses: actions/configure-pages@v4
      
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: './dashboard'
      
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
"@
    
    Set-Content -Path $workflowFile -Value $workflowContent
    Write-Host "✅ Created GitHub Pages workflow" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "To deploy:" -ForegroundColor Yellow
    Write-Host "1. Push to GitHub" -ForegroundColor Yellow
    Write-Host "2. Go to repository Settings → Pages" -ForegroundColor Yellow
    Write-Host "3. Select GitHub Actions as source" -ForegroundColor Yellow
    Write-Host "4. Dashboard will auto-deploy on push" -ForegroundColor Yellow
}

function Start-LocalServer {
    Write-Host "🌐 Starting local dashboard server..." -ForegroundColor Cyan
    
    $port = 8000
    $url = "http://localhost:$port"
    
    # Check if Python is available
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCmd) {
        Write-Host "Starting Python HTTP server on port $port..." -ForegroundColor Green
        Write-Host "Dashboard URL: $url" -ForegroundColor Green
        Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
        Write-Host ""
        
        Set-Location $dashboardDir
        Start-Process python -ArgumentList "-m", "http.server", $port -NoNewWindow
        
        if ($OpenBrowser) {
            Start-Sleep -Seconds 2
            Start-Process $url
        }
    } else {
        Write-Host "❌ Python not found. Install Python to run local server." -ForegroundColor Red
        Write-Host "Alternatively, use a simple HTTP server like 'npx serve' or 'live-server'" -ForegroundColor Yellow
    }
}

# Execute based on platform
switch ($Platform) {
    "flyio" { Deploy-FlyIO }
    "render" { Deploy-Render }
    "github" { Deploy-GitHubPages }
    "local" { Start-LocalServer }
    "all" {
        Deploy-FlyIO
        Write-Host ""
        Deploy-Render
        Write-Host ""
        Deploy-GitHubPages
    }
}

Write-Host ""
Write-Host "=========================================="
Write-Host "✅ Dashboard deployment setup complete!" -ForegroundColor Green
Write-Host "=========================================="
