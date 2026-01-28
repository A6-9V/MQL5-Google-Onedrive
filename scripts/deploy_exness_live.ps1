# Deploy MQL5 Indicators and EAs to Exness MT5 for LIVE Trading
# ⚠️ WARNING: This script deploys to LIVE ACCOUNT - Use with caution!

param(
    [string]$MT5DataFolder = "",
    [switch]$AutoDetectMT5 = $true,
    [switch]$SkipSafetyCheck = $false
)

$ErrorActionPreference = "Stop"

# Repository paths
$repoRoot = Split-Path -Parent $PSScriptRoot
$mql5Source = Join-Path $repoRoot "mt5\MQL5"
$indicatorsSource = Join-Path $mql5Source "Indicators"
$expertsSource = Join-Path $mql5Source "Experts"

Write-Host "==========================================" -ForegroundColor Red
Write-Host "⚠️  EXNESS LIVE ACCOUNT DEPLOYMENT  ⚠️" -ForegroundColor Red
Write-Host "==========================================" -ForegroundColor Red
Write-Host ""

# Safety warning
if (-not $SkipSafetyCheck) {
    Write-Host "WARNING: You are about to deploy to a LIVE trading account!" -ForegroundColor Red
    Write-Host ""
    Write-Host "⚠️  Important Safety Reminders:" -ForegroundColor Yellow
    Write-Host "  1. Test thoroughly on DEMO account first" -ForegroundColor Yellow
    Write-Host "  2. Start with MINIMAL position sizes" -ForegroundColor Yellow
    Write-Host "  3. Monitor closely for the first few trades" -ForegroundColor Yellow
    Write-Host "  4. Set appropriate risk parameters (RiskPercent)" -ForegroundColor Yellow
    Write-Host "  5. Use Stop Loss (SL) on ALL trades" -ForegroundColor Yellow
    Write-Host "  6. Never risk more than you can afford to lose" -ForegroundColor Yellow
    Write-Host ""

    $confirm = Read-Host "Do you understand the risks and want to continue? (type 'YES' to proceed)"
    if ($confirm -ne "YES") {
        Write-Host ""
        Write-Host "Deployment cancelled. Stay safe!" -ForegroundColor Green
        exit 0
    }
    Write-Host ""
}

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
    Write-Host "🔍 Auto-detecting MT5 data folder..." -ForegroundColor Cyan

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
    $MT5DataFolder = Read-Host "Enter MT5 data folder path"

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
    Write-Host "✅ Created Indicators directory" -ForegroundColor Green
}

if (-not (Test-Path $targetExperts)) {
    New-Item -ItemType Directory -Path $targetExperts -Force | Out-Null
    Write-Host "✅ Created Experts directory" -ForegroundColor Green
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
Write-Host "==========================================" -ForegroundColor Green
Write-Host "✅ Deployment Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files copied: $copiedFiles"
Write-Host ""
Write-Host "📋 Next Steps for LIVE Trading:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open Exness MT5 and log in to your LIVE account" -ForegroundColor Cyan
Write-Host "2. Press F4 to open MetaEditor" -ForegroundColor Cyan
Write-Host "3. Compile the copied files (select files → press F7)" -ForegroundColor Cyan
Write-Host "4. Back in MT5, refresh Navigator (Ctrl+N, right-click → Refresh)" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. IMPORTANT: Configure EA parameters for LIVE trading:" -ForegroundColor Red
Write-Host "   - Set RiskPercent to a conservative value (1-2%)" -ForegroundColor Yellow
Write-Host "   - Enable Stop Loss (SLMode: SL_ATR or SL_SWING)" -ForegroundColor Yellow
Write-Host "   - Set appropriate Take Profit (TPMode)" -ForegroundColor Yellow
Write-Host "   - Test on a DEMO chart first!" -ForegroundColor Yellow
Write-Host ""
Write-Host "6. Attach EA to chart:" -ForegroundColor Cyan
Write-Host "   - Drag SMC_TrendBreakout_MTF_EA from Navigator to chart" -ForegroundColor Cyan
Write-Host "   - Configure parameters in the EA settings" -ForegroundColor Cyan
Write-Host "   - Enable AutoTrading button (Ctrl+E)" -ForegroundColor Cyan
Write-Host ""
Write-Host "7. Monitor first trades closely!" -ForegroundColor Red
Write-Host ""
Write-Host "⚠️  REMEMBER:" -ForegroundColor Red
Write-Host "   - Start with small position sizes" -ForegroundColor Red
Write-Host "   - Never risk more than you can afford" -ForegroundColor Red
Write-Host "   - Monitor the first few trades manually" -ForegroundColor Red
Write-Host ""
Write-Host "📚 Documentation: docs/Exness_Deployment_Guide.md" -ForegroundColor Gray
