# Start Telegram Deployment Bot
# This script loads credentials (vault/env) and starts the bot.

# Load credentials from personal vault
$vaultScript = Join-Path $PSScriptRoot "load_vault.ps1"
if (Test-Path $vaultScript) {
    . $vaultScript
} else {
    # Fallback: use environment variable if vault not available
    if (-not $env:TELEGRAM_BOT_TOKEN) {
        Write-Host "❌ Vault loader not found and TELEGRAM_BOT_TOKEN is not set." -ForegroundColor Red
        Write-Host "   Set TELEGRAM_BOT_TOKEN in your environment, or create config/vault.json and use scripts/load_vault.ps1." -ForegroundColor Yellow
        exit 1
    }
}

# Optional: Set allowed user IDs (comma-separated)
# Get your user ID from @userinfobot on Telegram
# $env:TELEGRAM_ALLOWED_USER_IDS = "123456789"

# Change to repository directory
$repoPath = Split-Path -Parent $PSScriptRoot
Set-Location $repoPath

Write-Host "=========================================="
Write-Host "Starting Telegram Deployment Bot"
Write-Host "=========================================="
if ($env:TELEGRAM_BOT_NAME) {
    Write-Host "Bot Name: $($env:TELEGRAM_BOT_NAME)"
}
Write-Host ""
Write-Host "Press Ctrl+C to stop the bot"
Write-Host "=========================================="
Write-Host ""

# Start the bot
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) { $pythonCmd = Get-Command py -ErrorAction SilentlyContinue }
if (-not $pythonCmd) { $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue }

if (-not $pythonCmd) {
    Write-Host "❌ Python was not found on PATH." -ForegroundColor Red
    Write-Host "   Install Python 3 and ensure 'python' (or 'py') is available." -ForegroundColor Yellow
    exit 1
}

& $pythonCmd.Source "scripts/telegram_deploy_bot.py"
