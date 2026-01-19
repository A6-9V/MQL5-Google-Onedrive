# PowerShell script to start development container
# Usage: .\scripts\start_dev_container.ps1

param(
    [switch]$Build,
    [switch]$Stop,
    [switch]$Logs,
    [switch]$Shell
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Green
Write-Host "MQL5 Trading Automation - Dev Container" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

if ($Stop) {
    Write-Host "Stopping development container..." -ForegroundColor Yellow
    docker-compose -f docker-compose.dev.yml down
    Write-Host "✅ Container stopped" -ForegroundColor Green
    exit 0
}

if ($Logs) {
    Write-Host "Showing container logs..." -ForegroundColor Yellow
    docker-compose -f docker-compose.dev.yml logs -f
    exit 0
}

if ($Shell) {
    Write-Host "Opening shell in container..." -ForegroundColor Yellow
    docker exec -it mql5-trading-dev bash
    exit 0
}

if ($Build) {
    Write-Host "Building development container..." -ForegroundColor Yellow
    docker-compose -f docker-compose.dev.yml build --no-cache
}

Write-Host "Starting development container..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml up -d

Write-Host ""
Write-Host "✅ Development container is running!" -ForegroundColor Green
Write-Host ""
Write-Host "Available commands:" -ForegroundColor Cyan
Write-Host "  .\scripts\start_dev_container.ps1 -Shell    # Open shell in container" -ForegroundColor Gray
Write-Host "  .\scripts\start_dev_container.ps1 -Logs    # View logs" -ForegroundColor Gray
Write-Host "  .\scripts\start_dev_container.ps1 -Stop    # Stop container" -ForegroundColor Gray
Write-Host ""
Write-Host "Or use VS Code Dev Containers extension:" -ForegroundColor Cyan
Write-Host "  F1 → 'Dev Containers: Reopen in Container'" -ForegroundColor Gray
Write-Host ""
