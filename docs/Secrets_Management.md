# Secrets Management Guide

This guide explains how to manage sensitive information (API keys, tokens, etc.) in this repository.

## Local Secrets

### 1. `.env` File
You can use a `.env` file for local development and automation.
- **File**: `.env` (copy from `.env.example`)
- **Status**: Gitignored (never committed)
- **Usage**: Automatically loaded by many scripts or can be sourced in shell.

### 2. `config/vault.json`
A more structured way to store credentials, used by specific scripts like `scripts/load_vault.py`.
- **File**: `config/vault.json`
- **Status**: Gitignored (never committed)
- **Structure**:
```json
{
    "cloudflare": {
        "zone_id": "your_zone_id",
        "account_id": "your_account_id",
        "domain": "your_domain.com"
    },
    "telegram_bot": {
        "token": "your_bot_token",
        "allowed_user_ids": [123456789]
    }
}
```

## GitHub Secrets

GitHub Secrets are used for CI/CD workflows (GitHub Actions).

### Required Secrets
- `RCLONE_CONFIG_B64`: Required for OneDrive sync.
- `CLOUDFLARE_ZONE_ID`: Required for Cloudflare automation.
- `CLOUDFLARE_ACCOUNT_ID`: Required for Cloudflare automation.
- `DOMAIN_NAME`: Required for domain management.

### Optional Secrets
- `SCRSOR`: Firefox Relay API key.
- `COPILOT`: Firefox Relay API key.
- `TELEGRAM_BOT_TOKEN`: For Telegram notifications.

## Automation Tools

### Setting GitHub Secrets Automatically
If you have the [GitHub CLI (gh)](https://cli.github.com/) installed and authenticated, you can use the provided script to upload your local secrets to GitHub:

```bash
# Upload from vault.json (default)
bash scripts/set_github_secrets.sh vault

# Upload from .env
bash scripts/set_github_secrets.sh env
```

## Best Practices
1. **Never commit secrets**: Always verify that your secret files are listed in `.gitignore`.
2. **Use placeholders**: When adding new secrets, update `.env.example` with placeholders.
3. **Rotate regularly**: Change your API keys and tokens periodically.
4. **Minimal permissions**: Create API tokens with the minimum required scopes.
