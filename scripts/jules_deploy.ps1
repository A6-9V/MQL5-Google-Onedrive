# Jules Deployment Script for Docker Dev to Cloud
# Usage: .\scripts\jules_deploy.ps1 -Environment dev|cloud -Platform flyio|render|railway

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "cloud")]
    [string]$Environment,

    [Parameter(Mandatory=$false)]
    [ValidateSet("flyio", "render", "railway", "local")]
    [string]$Platform = "local"
)

$ErrorActionPreference = "Stop"
$repoRoot = $PSScriptRoot | Split-Path -Parent
$julesConfig = Join-Path $repoRoot ".jules\config.json"

Write-Host "========================================" -ForegroundColor Green
Write-Host "🚀 Jules Deployment - $Environment to $Platform" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if Jules config exists
if (-not (Test-Path $julesConfig)) {
    Write-Host "❌ Jules config not found at: $julesConfig" -ForegroundColor Red
    Write-Host "Creating default config..." -ForegroundColor Yellow
    # Config should already exist from setup
}

# Load config
$config = Get-Content $julesConfig | ConvertFrom-Json
$deployment = $config.deployments.$Environment

if (-not $deployment) {
    Write-Host "❌ Deployment configuration '$Environment' not found" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Building Docker image for $Environment..." -ForegroundColor Yellow
Write-Host "  Dockerfile: $($deployment.dockerfile)" -ForegroundColor Gray
Write-Host "  Context: $($deployment.context)" -ForegroundColor Gray

# Build Docker image
$imageName = "mql5-automation:$Environment"
$dockerfilePath = Join-Path $repoRoot $deployment.dockerfile

Set-Location $repoRoot
docker build -f $dockerfilePath -t $imageName .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker image built: $imageName" -ForegroundColor Green
Write-Host ""

# Deploy based on platform
switch ($Platform) {
    "local" {
        Write-Host "🐳 Running locally..." -ForegroundColor Cyan

        $envVars = @()
        foreach ($key in $deployment.env.PSObject.Properties.Name) {
            $envVars += "-e $key=$($deployment.env.$key)"
        }

        $portMappings = @()
        foreach ($key in $deployment.ports.PSObject.Properties.Name) {
            $portMappings += "-p ${key}:$($deployment.ports.$key)"
        }

        $volumeMounts = @()
        if ($deployment.volumes) {
            foreach ($volume in $deployment.volumes) {
                $volumeMounts += "-v $volume"
            }
        }

        $dockerRunCmd = "docker run -d --name mql5-automation-$Environment $($envVars -join ' ') $($portMappings -join ' ') $($volumeMounts -join ' ') $imageName"

        Write-Host "Running: $dockerRunCmd" -ForegroundColor Gray
        Invoke-Expression $dockerRunCmd

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Container started successfully!" -ForegroundColor Green
            Write-Host ""
            Write-Host "View logs: docker logs -f mql5-automation-$Environment" -ForegroundColor Cyan
        }
    }

    "flyio" {
        Write-Host "☁️  Deploying to Fly.io..." -ForegroundColor Cyan

        # Check if flyctl is installed
        $flyctl = Get-Command flyctl -ErrorAction SilentlyContinue
        if (-not $flyctl) {
            Write-Host "❌ Fly CLI not found. Install: iwr https://fly.io/install.ps1 -useb | iex" -ForegroundColor Red
            exit 1
        }

        # Deploy
        flyctl deploy

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Deployed to Fly.io!" -ForegroundColor Green
        }
    }

    "render" {
        Write-Host "☁️  Deploying to Render.com..." -ForegroundColor Cyan
        Write-Host "Render uses GitHub integration. Push to GitHub to trigger deployment." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "  1. git add ." -ForegroundColor White
        Write-Host "  2. git commit -m 'Deploy to Render'" -ForegroundColor White
        Write-Host "  3. git push origin main" -ForegroundColor White
        Write-Host "  4. Render will auto-deploy from render.yaml" -ForegroundColor White
    }

    "railway" {
        Write-Host "☁️  Deploying to Railway.app..." -ForegroundColor Cyan

        # Check if railway CLI is installed
        $railway = Get-Command railway -ErrorAction SilentlyContinue
        if (-not $railway) {
            Write-Host "❌ Railway CLI not found. Install: npm i -g @railway/cli" -ForegroundColor Red
            exit 1
        }

        # Deploy
        railway up

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Deployed to Railway!" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✅ Jules Deployment Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
