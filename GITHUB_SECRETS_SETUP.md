# GitHub Actions Secrets Setup

This document provides guidance on setting up GitHub Secrets for the repository's CI/CD workflows.

## Required Secrets

The following secrets should be configured in your GitHub repository settings:

### Telegram Bot Configuration

- **`TELEGRAM_BOT_TOKEN`** or **`TELEGRAM_BOT_API`**
  - Value: `your_bot_token_here`
  - Used by: Telegram bot deployment scripts
  - Reference: https://core.telegram.org/bots/api

- **`TELEGRAM_ALLOWED_USER_IDS`** (Optional)
  - Value: Comma-separated list of Telegram user IDs authorized to use the bot
  - Example: `123456789,987654321`
  - Used by: Telegram bot for access control

### GitHub Automation

- **`GITHUB_PAT`** (Optional)
  - Value: `your_github_personal_access_token_here`
  - Used by: Scripts that need enhanced GitHub API access
  - Scopes required: `repo`, `workflow`, `write:packages`

### Existing Secrets (Already Configured)

- **`RCLONE_CONFIG_B64`** - For OneDrive sync
- **`CLOUDFLARE_ZONE_ID`** - Cloudflare zone ID
- **`CLOUDFLARE_ACCOUNT_ID`** - Cloudflare account ID
- **`DOMAIN_NAME`** - Your domain name
- **`SCRSOR`** - Firefox Relay API key
- **`COPILOT`** - Firefox Relay API key
- **`SLACK_WEBHOOK`** (Optional) - For Slack notifications

## Setting Secrets via GitHub CLI

If you have the GitHub CLI installed, you can set secrets using:

```bash
# Set Telegram bot token
gh secret set TELEGRAM_BOT_TOKEN --body "your_bot_token_here"

# Set GitHub PAT
gh secret set GITHUB_PAT --body "your_github_personal_access_token_here"

# Set allowed users (replace with your actual Telegram user ID)
gh secret set TELEGRAM_ALLOWED_USER_IDS --body "your_telegram_user_id"
```

## Setting Secrets via GitHub Web UI

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with its name and value

## Using the Automated Script

You can also use the provided script to sync from your local vault:

```bash
# Make sure config/vault.json is properly configured
bash scripts/set_github_secrets.sh vault
```

This will read from `config/vault.json` and set the appropriate GitHub secrets.

## Verification

After setting secrets, you can verify they're available in your workflows:

1. Go to **Actions** tab in your repository
2. Run a workflow that uses these secrets
3. Check the workflow logs to ensure secrets are being loaded (values will be masked)

## Security Notes

- **Never log or print secret values in workflows**
- GitHub automatically masks secret values in logs
- Rotate secrets regularly for security
- Use the minimum required scopes for tokens
- Store the actual values in a secure password manager

> If a real token was ever committed to git, treat it as compromised:
> rotate/revoke it immediately (BotFather for Telegram, GitHub settings for PATs).

## Troubleshooting

If secrets aren't working:

1. **Check secret names** - They're case-sensitive
2. **Verify workflow permissions** - Some secrets require specific permissions
3. **Check repository visibility** - Public repos have different secret handling
4. **Review workflow syntax** - Ensure you're accessing secrets correctly: `${{ secrets.SECRET_NAME }}`
