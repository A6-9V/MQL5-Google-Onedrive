# Deploy MQL5 Indicators and EAs to Exness MetaTrader 5
# Note: This script works with Desktop MT5, NOT the web terminal

param(
    [string]$MT5DataFolder = "",
    [switch]$OpenWebTerminal = $false,
    [switch]$AutoDetectMT5 = $true
)

$ErrorActionPreference = "Stop"

# Repository paths
$repoRoot = Split-Path -Parent $PSScriptRoot
$mql5Source = Join-Path $repoRoot "mt5\MQL5"
$indicatorsSource = Join-Path $mql5Source "Indicators"
$expertsSource = Join-Path $mql5Source "Experts"

Write-Host "=========================================="
Write-Host "Exness MT5 Deployment Script"
Write-Host "=========================================="
Write-Host ""

# Check if source files exist
if (-not (Test-Path $indicatorsSource)) {
    Write-Host "❌ Indicators source folder not found: $indicatorsSource" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $expertsSource)) {
    Write-Host "❌ Experts source folder not found: $expertsSource" -ForegroundColor Red
    exit 1
}

# Auto-detect MT5 data folder
if ($AutoDetectMT5 -and [string]::IsNullOrEmpty($MT5DataFolder)) {
    Write-Host "🔍 Auto-detecting MT5 data folder..." -ForegroundColor Yellow
    
    # Common MT5 installation paths
    $possiblePaths = @(
        "$env:APPDATA\MetaQuotes\Terminal",
        "$env:LOCALAPPDATA\Programs\MetaTrader 5",
        "C:\Program Files\MetaTrader 5",
        "$env:USERPROFILE\AppData\Roaming\MetaQuotes\Terminal"
    )
    
    foreach ($basePath in $possiblePaths) {
        if (Test-Path $basePath) {
            $terminals = Get-ChildItem $basePath -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "^\w{32}$" }
            if ($terminals) {
                # Look for MQL5 folder in the terminal directory
                foreach ($terminal in $terminals) {
                    $mql5Path = Join-Path $terminal.FullName "MQL5"
                    if (Test-Path $mql5Path) {
                        $MT5DataFolder = $terminal.FullName
                        Write-Host "✅ Found MT5 data folder: $MT5DataFolder" -ForegroundColor Green
                        break
                    }
                }
            }
        }
        if (-not [string]::IsNullOrEmpty($MT5DataFolder)) { break }
    }
}

# Prompt for MT5 data folder if not found
if ([string]::IsNullOrEmpty($MT5DataFolder)) {
    Write-Host ""
    Write-Host "⚠️ Could not auto-detect MT5 data folder." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To find your MT5 data folder:" -ForegroundColor Cyan
    Write-Host "1. Open Exness MT5" -ForegroundColor Cyan
    Write-Host "2. Go to File → Open Data Folder" -ForegroundColor Cyan
    Write-Host "3. Copy the full path from the address bar" -ForegroundColor Cyan
    Write-Host ""
    $MT5DataFolder = Read-Host "Enter MT5 data folder path (or press Enter to skip)"
    
    if ([string]::IsNullOrEmpty($MT5DataFolder)) {
        Write-Host ""
        Write-Host "❌ Deployment cancelled. No MT5 data folder specified." -ForegroundColor Red
        exit 1
    }
}

# Validate MT5 data folder
if (-not (Test-Path $MT5DataFolder)) {
    Write-Host "❌ MT5 data folder not found: $MT5DataFolder" -ForegroundColor Red
    exit 1
}

$targetIndicators = Join-Path $MT5DataFolder "MQL5\Indicators"
$targetExperts = Join-Path $MT5DataFolder "MQL5\Experts"

# Create target directories if they don't exist
if (-not (Test-Path $targetIndicators)) {
    New-Item -ItemType Directory -Path $targetIndicators -Force | Out-Null
    Write-Host "✅ Created Indicators directory: $targetIndicators" -ForegroundColor Green
}

if (-not (Test-Path $targetExperts)) {
    New-Item -ItemType Directory -Path $targetExperts -Force | Out-Null
    Write-Host "✅ Created Experts directory: $targetExperts" -ForegroundColor Green
}

# Copy files
Write-Host ""
Write-Host "📦 Copying files..." -ForegroundColor Cyan

$copiedFiles = 0

# Copy indicators
Get-ChildItem $indicatorsSource -Filter "*.mq5" -File | ForEach-Object {
    $destFile = Join-Path $targetIndicators $_.Name
    Copy-Item $_.FullName -Destination $destFile -Force
    Write-Host "  ✅ Copied indicator: $($_.Name)" -ForegroundColor Green
    $copiedFiles++
}

# Copy experts
Get-ChildItem $expertsSource -Filter "*.mq5" -File | ForEach-Object {
    $destFile = Join-Path $targetExperts $_.Name
    Copy-Item $_.FullName -Destination $destFile -Force
    Write-Host "  ✅ Copied EA: $($_.Name)" -ForegroundColor Green
    $copiedFiles++
}

Write-Host ""
Write-Host "=========================================="
Write-Host "✅ Deployment Complete!" -ForegroundColor Green
Write-Host "=========================================="
Write-Host ""
Write-Host "Files copied: $copiedFiles"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Open Exness MT5" -ForegroundColor Cyan
Write-Host "2. Press F4 to open MetaEditor" -ForegroundColor Cyan
Write-Host "3. Navigate to the copied files and compile them (F7)" -ForegroundColor Cyan
Write-Host "4. Back in MT5, refresh Navigator (Ctrl+N, then right-click → Refresh)" -ForegroundColor Cyan
Write-Host ""

# Open web terminal if requested
if ($OpenWebTerminal) {
    Write-Host "🌐 Opening Exness Web Terminal..." -ForegroundColor Cyan
    Start-Process "https://my.exness.global/webtrading/"
    Write-Host ""
    Write-Host "⚠️ Note: Custom Indicators and EAs are NOT supported on the web terminal." -ForegroundColor Yellow
    Write-Host "   They only work in the Desktop MT5 application." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "📚 For more information, see: docs/Exness_Deployment_Guide.md" -ForegroundColor Gray
