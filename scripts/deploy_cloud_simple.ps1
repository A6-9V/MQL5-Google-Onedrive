# Simple Cloud Deployment Script
# Supports: Fly.io, Render, Railway

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("flyio", "render", "railway", "all")]
    [string]$Platform
)

$ErrorActionPreference = "Stop"
$repoRoot = $PSScriptRoot | Split-Path -Parent

Write-Host "========================================" -ForegroundColor Green
Write-Host "☁️  Cloud Deployment - $Platform" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if Docker is running
try {
    docker ps | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Build production image locally first
Write-Host "📦 Building production Docker image..." -ForegroundColor Yellow
Set-Location $repoRoot
docker build -f Dockerfile.cloud -t mql5-automation:latest .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker image built successfully" -ForegroundColor Green
Write-Host ""

# Deploy based on platform
switch ($Platform) {
    "flyio" {
        Write-Host "🚀 Deploying to Fly.io..." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Checking Fly CLI..." -ForegroundColor Yellow
        
        # Check if flyctl is installed
        $flyctlPath = Get-Command flyctl -ErrorAction SilentlyContinue
        if (-not $flyctlPath) {
            Write-Host "⚠️  Fly CLI not found. Installing..." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Please install Fly CLI:" -ForegroundColor Cyan
            Write-Host "  PowerShell: iwr https://fly.io/install.ps1 -useb | iex" -ForegroundColor Gray
            Write-Host "  Or visit: https://fly.io/docs/getting-started/installing-flyctl/" -ForegroundColor Gray
            Write-Host ""
            Write-Host "After installing, run:" -ForegroundColor Yellow
            Write-Host "  flyctl auth login" -ForegroundColor White
            Write-Host "  flyctl deploy" -ForegroundColor White
            exit 0
        }
        
        # Check if logged in
        Write-Host "Checking authentication..." -ForegroundColor Yellow
        flyctl auth whoami 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "⚠️  Not logged in to Fly.io" -ForegroundColor Yellow
            Write-Host "Running: flyctl auth login" -ForegroundColor Cyan
            flyctl auth login
        }
        
        Write-Host "Deploying to Fly.io..." -ForegroundColor Yellow
        flyctl deploy
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ Deployment successful!" -ForegroundColor Green
            Write-Host ""
            Write-Host "View your app:" -ForegroundColor Cyan
            flyctl status
        } else {
            Write-Host "❌ Deployment failed!" -ForegroundColor Red
            exit 1
        }
    }
    
    "render" {
        Write-Host "🚀 Deploying to Render.com..." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Render.com uses GitHub integration for auto-deployment." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Steps:" -ForegroundColor Cyan
        Write-Host "  1. Push this repository to GitHub" -ForegroundColor White
        Write-Host "  2. Go to https://render.com" -ForegroundColor White
        Write-Host "  3. Create a new Web Service" -ForegroundColor White
        Write-Host "  4. Connect your GitHub repository" -ForegroundColor White
        Write-Host "  5. Render will auto-detect render.yaml" -ForegroundColor White
        Write-Host "  6. Deploy!" -ForegroundColor White
        Write-Host ""
        Write-Host "Current status: Docker image built and ready" -ForegroundColor Green
        Write-Host "Next: Push to GitHub and connect to Render" -ForegroundColor Yellow
    }
    
    "railway" {
        Write-Host "🚀 Deploying to Railway.app..." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Checking Railway CLI..." -ForegroundColor Yellow
        
        # Check if railway CLI is installed
        $railwayPath = Get-Command railway -ErrorAction SilentlyContinue
        if (-not $railwayPath) {
            Write-Host "⚠️  Railway CLI not found. Installing..." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Please install Railway CLI:" -ForegroundColor Cyan
            Write-Host "  npm i -g @railway/cli" -ForegroundColor Gray
            Write-Host "  Or visit: https://docs.railway.app/develop/cli" -ForegroundColor Gray
            Write-Host ""
            Write-Host "After installing, run:" -ForegroundColor Yellow
            Write-Host "  railway login" -ForegroundColor White
            Write-Host "  railway up" -ForegroundColor White
            exit 0
        }
        
        Write-Host "Deploying to Railway..." -ForegroundColor Yellow
        railway up
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ Deployment successful!" -ForegroundColor Green
        } else {
            Write-Host "❌ Deployment failed!" -ForegroundColor Red
            exit 1
        }
    }
    
    "all" {
        Write-Host "🚀 Deploying to all platforms..." -ForegroundColor Cyan
        Write-Host ""
        
        # Fly.io
        & $PSScriptRoot\deploy_cloud_simple.ps1 -Platform flyio
        
        # Render (just instructions)
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        & $PSScriptRoot\deploy_cloud_simple.ps1 -Platform render
        
        # Railway
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        & $PSScriptRoot\deploy_cloud_simple.ps1 -Platform railway
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✅ Deployment process completed" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
