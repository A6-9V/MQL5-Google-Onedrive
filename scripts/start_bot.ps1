# Start Telegram Deployment Bot for GenX_FX_bot
# This script sets up the environment and starts the bot

# Load credentials from personal vault
$vaultScript = Join-Path $PSScriptRoot "load_vault.ps1"
if (Test-Path $vaultScript) {
    . $vaultScript
} else {
    # Fallback: use environment variable if vault not available
    if (-not $env:TELEGRAM_BOT_TOKEN) {
        Write-Host "⚠️ Vault loader not found. Using environment variable or default token" -ForegroundColor Yellow
        $env:TELEGRAM_BOT_TOKEN = "8260686409:AAHEcrZxhDve9vE1QR49ngcCmvOf_Q9NYHg"
    }
}

# Optional: Set allowed user IDs (comma-separated)
# Get your user ID from @userinfobot on Telegram
# $env:TELEGRAM_ALLOWED_USER_IDS = "123456789"

# Change to repository directory
$repoPath = Split-Path -Parent $PSScriptRoot
Set-Location $repoPath

Write-Host "=========================================="
Write-Host "Starting GenX_FX_bot Deployment Bot"
Write-Host "=========================================="
Write-Host "Bot Username: @GenX_FX_bot"
Write-Host "Bot Link: https://t.me/GenX_FX_bot"
Write-Host ""
Write-Host "Press Ctrl+C to stop the bot"
Write-Host "=========================================="
Write-Host ""

# Start the bot
python scripts/telegram_deploy_bot.py
