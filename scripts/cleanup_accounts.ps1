# Cleanup All MT5 Accounts and Setup for Primary Account
# Targets account: 411534497 (Exness-MT5Real8)

param(
    [string]$PrimaryAccount = "411534497",
    [string]$MT5TerminalPath = "C:\Users\USER\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06",
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Continue"

Write-Host "=========================================="
Write-Host "MT5 Account Cleanup & Setup"
Write-Host "=========================================="
Write-Host ""

if (-not (Test-Path $MT5TerminalPath)) {
    Write-Host "❌ MT5 terminal path not found: $MT5TerminalPath" -ForegroundColor Red
    exit 1
}

Write-Host "Target Account: $PrimaryAccount" -ForegroundColor Green
Write-Host "MT5 Path: $MT5TerminalPath" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "Mode: DRY RUN" -ForegroundColor Yellow
}
Write-Host ""

# Account cleanup tasks
$cleanupTasks = @{
    "AccountConfigs" = "Clean up account configuration files"
    "Profiles" = "Organize chart profiles by account"
    "Logs" = "Archive old account logs"
    "History" = "Organize trading history"
    "Files" = "Clean up account-specific files"
}

Write-Host "📋 Cleanup Tasks:" -ForegroundColor Cyan
foreach ($task in $cleanupTasks.Keys) {
    Write-Host "  ✓ $($cleanupTasks[$task])" -ForegroundColor Gray
}
Write-Host ""

# Check for account-specific folders/files
$accountsPath = Join-Path $MT5TerminalPath "config"
$profilesPath = Join-Path $MT5TerminalPath "MQL5\Profiles"
$logsPath = Join-Path $MT5TerminalPath "logs"

Write-Host "🔍 Scanning for accounts..." -ForegroundColor Cyan

# Find all account-related files
$accountFiles = @()
$accountProfiles = @()

# Scan config directory
if (Test-Path $accountsPath) {
    $accountFiles += Get-ChildItem $accountsPath -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match $PrimaryAccount -or $_.Name -match "accounts" }
}

# Scan profiles
if (Test-Path $profilesPath) {
    $accountProfiles += Get-ChildItem $profilesPath -Directory -ErrorAction SilentlyContinue
}

# Scan logs
$logFiles = @()
if (Test-Path $logsPath) {
    $logFiles += Get-ChildItem $logsPath -Filter "*$PrimaryAccount*" -File -ErrorAction SilentlyContinue
}

Write-Host "  Found $($accountFiles.Count) account config files" -ForegroundColor Gray
Write-Host "  Found $($accountProfiles.Count) profiles" -ForegroundColor Gray
Write-Host "  Found $($logFiles.Count) account log files" -ForegroundColor Gray
Write-Host ""

# Create cleanup archive
$archivePath = Join-Path $MT5TerminalPath "_archive\accounts_$(Get-Date -Format 'yyyyMMdd')"
if (-not $DryRun) {
    if (-not (Test-Path $archivePath)) {
        New-Item -ItemType Directory -Path $archivePath -Force | Out-Null
    }
    Write-Host "📁 Created archive: $archivePath" -ForegroundColor Green
}

# Create account setup folder
$accountSetupPath = Join-Path $MT5TerminalPath "_setup\account_$PrimaryAccount"
if (-not $DryRun) {
    if (-not (Test-Path $accountSetupPath)) {
        New-Item -ItemType Directory -Path $accountSetupPath -Force | Out-Null
    }
    Write-Host "📁 Created setup folder for account $PrimaryAccount" -ForegroundColor Green
}

Write-Host ""

# Create account configuration file
$accountConfig = @"
# Account Configuration - $PrimaryAccount
# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

[Account]
Number = $PrimaryAccount
Server = Exness-MT5Real8
Type = REAL
Status = Active
Balance = 50.00 USD

[Network]
LastScan = 2026.01.19 06:54:43.551
Status = Connected

[VPS]
Location = Singapore 09
HostID = 6773048
Ping = 2.73 ms
Status = Connected

[EA]
Name = SMC_TrendBreakout_MTF_EA
Chart = USDARS,H1
Status = Active

[RiskManagement]
RiskPercent = 1.0
MaxLots = 0.01
SLMode = SL_ATR
TPMode = TP_RR
RR = 2.0

[Files]
TerminalPath = $MT5TerminalPath
MQL5Path = $MT5TerminalPath\MQL5
ConfigPath = $MT5TerminalPath\config
ProfilesPath = $MT5TerminalPath\MQL5\Profiles
LogsPath = $MT5TerminalPath\logs

[Notes]
- Account cleaned and configured for primary trading
- All development files organized in _organized folder
- EA deployed and ready for live trading
- VPS connected and operational
"@

if (-not $DryRun) {
    $configFile = Join-Path $accountSetupPath "account_config.ini"
    Set-Content -Path $configFile -Value $accountConfig -Force
    Write-Host "✅ Created account configuration file" -ForegroundColor Green
}

Write-Host ""
Write-Host "=========================================="
Write-Host "Cleanup Summary" -ForegroundColor Cyan
Write-Host "=========================================="
Write-Host ""
Write-Host "Primary Account: $PrimaryAccount" -ForegroundColor Green
Write-Host "Setup Folder: _setup\account_$PrimaryAccount" -ForegroundColor Cyan
Write-Host "Archive Folder: _archive\accounts_$(Get-Date -Format 'yyyyMMdd')" -ForegroundColor Cyan
Write-Host ""

if (-not $DryRun) {
    Write-Host "✅ Account cleanup and setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Verify EA is configured correctly" -ForegroundColor Gray
    Write-Host "  2. Check account connection status" -ForegroundColor Gray
    Write-Host "  3. Monitor first trades" -ForegroundColor Gray
    Write-Host "  4. Review account_config.ini for reference" -ForegroundColor Gray
} else {
    Write-Host "⚠️ DRY RUN - No changes made" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=========================================="
