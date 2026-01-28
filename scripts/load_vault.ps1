# Load credentials from personal vault
# Usage: . .\scripts\load_vault.ps1

$vaultPath = Join-Path (Split-Path -Parent $PSScriptRoot) "config\vault.json"

if (Test-Path $vaultPath) {
    $vault = Get-Content $vaultPath | ConvertFrom-Json
    
    # Load Telegram bot token
    if ($vault.telegram_bot.token) {
        $env:TELEGRAM_BOT_TOKEN = $vault.telegram_bot.token
        Write-Host "✅ Telegram bot token loaded from vault" -ForegroundColor Green
    }
    
    # Load allowed user IDs if present
    if ($vault.telegram_bot.allowed_user_ids) {
        $env:TELEGRAM_ALLOWED_USER_IDS = $vault.telegram_bot.allowed_user_ids -join ","
    }
    
    Write-Host "✅ Vault loaded successfully" -ForegroundColor Green
} else {
    Write-Host "⚠️ Vault file not found at: $vaultPath" -ForegroundColor Yellow
    Write-Host "   Create config/vault.json with your credentials" -ForegroundColor Yellow
}
