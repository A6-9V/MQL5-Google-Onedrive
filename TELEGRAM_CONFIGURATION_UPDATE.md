# Telegram Bot & Webhook Configuration Update

This document summarizes the changes made to configure the Telegram bot and webhook defaults in the repository.

## Overview

The repository has been updated to support Telegram bot integration for deployment automation. The actual credentials are stored securely in `config/vault.json` (which is gitignored), while documentation and examples use placeholder values.

## Changes Made

### 1. Configuration Files

#### `.env.example`
- Added `TELEGRAM_BOT_NAME`, `TELEGRAM_BOT_API`, and `TELEGRAM_BOT_TOKEN` fields
- Uses placeholder values to demonstrate the format

#### `config/vault.json.example`
- Created a template showing the proper structure for `vault.json`
- Includes sections for Cloudflare, Telegram bot, and GitHub PAT
- Uses placeholder values for all sensitive fields

#### `config/startup_config.json`
- Updated `notifications` section to include Telegram bot configuration
- Added `telegram` subsection with `bot_name`, `bot_token`, and `enabled` fields
- Set webhook URL to Telegram Bot API reference

#### `config/vault.json` (gitignored)
- Create a local vault file with your credentials
- This file is never committed to version control (see `.gitignore`)
- Contains your Telegram bot credentials and (optionally) a GitHub PAT

### 2. Documentation Updates

#### `scripts/TELEGRAM_BOT_SETUP.md`
- Removed references to specific bot credentials
- Updated to use generic placeholder values
- Added guidance on how to create and configure your own bot

#### `docs/Secrets_Management.md`
- Updated vault.json structure documentation
- Added new fields for Telegram bot configuration
- Includes GitHub PAT configuration

#### `README.md`
- Added a new section on Telegram Bot Deployment
- Provides quick reference to bot commands
- Links to detailed setup guide

### 3. Code Updates

#### `scripts/load_vault.py`
- Added new helper functions:
  - `get_telegram_bot_name()` - Gets bot name with default fallback
  - `get_telegram_webhook_url()` - Gets webhook URL with default
  - `get_github_pat()` - Gets GitHub Personal Access Token
- Added constants for default values (`DEFAULT_TELEGRAM_BOT_NAME`, `DEFAULT_TELEGRAM_WEBHOOK_URL`)
- Enhanced `get_telegram_token()` to support both 'token' and 'api' fields
- Updated main block to export all new environment variables

## Credentials (Example / Template)

Store your real credentials in `config/vault.json` (gitignored). Example structure:

```json
{
  "telegram_bot": {
    "name": "t.me/your_bot_name",
    "token": "your_bot_token_here",
    "webhook_url": "https://core.telegram.org/bots/api"
  },
  "github": {
    "pat": "your_github_personal_access_token_here"
  }
}
```

**Note:** If you accidentally committed a real token, rotate it immediately.

## Usage

### Loading Credentials

```bash
# (Optional) Verify vault.json is readable by Python
python3 scripts/load_vault.py
```

### Starting the Telegram Bot

```bash
# With credentials from vault.json
python3 scripts/telegram_deploy_bot.py

# Or with environment variables
export TELEGRAM_BOT_TOKEN="your_bot_token_here"
export TELEGRAM_ALLOWED_USER_IDS="your_user_id"
python3 scripts/telegram_deploy_bot.py
```

## Security

- All actual credentials are stored in `config/vault.json` which is gitignored
- Documentation and example files use placeholder values only
- GitHub PAT is available for automation scripts that need GitHub API access
- Telegram bot token is used for deployment automation via Telegram

## Testing

All changes have been validated:
- ✅ Repository validation passed (`python scripts/ci_validate_repo.py`)
- ✅ CodeQL security scan passed (0 alerts)
- ✅ `load_vault.py` tested and working correctly
- ✅ Credentials properly isolated from version control

## Next Steps

1. Ensure your Telegram user ID is added to `allowed_user_ids` in `vault.json`
2. Test the bot by running `python scripts/telegram_deploy_bot.py`
3. Send `/start` to your bot on Telegram to verify it's working
4. Use the deployment commands to automate your workflows
