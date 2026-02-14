# API Environment Secrets & Credentials Setup Guide

This guide explains how to securely configure API keys, tokens, and credentials for the MQL5 Trading System in GitLab CI/CD.

## Table of Contents

- [Overview](#overview)
- [Security Best Practices](#security-best-practices)
- [Required API Credentials](#required-api-credentials)
- [Setting Up GitLab Variables](#setting-up-gitlab-variables)
- [Local Development](#local-development)
- [Credential Rotation](#credential-rotation)
- [Troubleshooting](#troubleshooting)

## Overview

The MQL5 Trading System integrates with multiple external services and APIs. All sensitive credentials must be stored securely using GitLab CI/CD Variables, never committed to the repository.

## Security Best Practices

### ✅ Do's

1. **Use GitLab CI/CD Variables** for all secrets
2. **Enable "Masked" flag** for sensitive values (tokens, passwords)
3. **Enable "Protected" flag** for production credentials
4. **Rotate credentials regularly** (every 90 days minimum)
5. **Use service accounts** instead of personal credentials
6. **Limit token scopes** to minimum required permissions
7. **Monitor access logs** for unauthorized usage
8. **Use separate credentials** for staging and production

### ❌ Don'ts

1. **Never commit secrets** to git repository
2. **Never log secret values** in CI/CD output
3. **Never share credentials** via email or chat
4. **Never use same credentials** across multiple services
5. **Never disable security flags** without good reason

## Required API Credentials

### 1. Telegram Bot API

**Purpose**: Telegram bot for deployment commands and notifications

**How to obtain**:
1. Open Telegram and message [@BotFather](https://t.me/BotFather)
2. Send `/newbot` and follow instructions
3. Copy the bot token (format: `1234567890:ABCdefGHI...`)

**Required Variables**:
```bash
TELEGRAM_BOT_TOKEN="1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"
TELEGRAM_BOT_API="1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"  # Same as above
TELEGRAM_ALLOWED_USER_IDS="123456789,987654321"  # Your user IDs
```

**Permissions**: `Masked: Yes`, `Protected: Yes`

**Documentation**: https://core.telegram.org/bots/api

---

### 2. Google Gemini API

**Purpose**: AI-powered trade signal filtering and analysis

**How to obtain**:
1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Sign in with Google account
3. Click "Get API Key"
4. Create a new API key or use existing one

**Required Variables**:
```bash
GEMINI_API_KEY="AIzaSyYour-Gemini-API-Key-Here-32-characters"
```

**Permissions**: `Masked: Yes`, `Protected: Yes`

**Rate Limits**: 
- Free tier: 60 requests per minute
- Check quota at: https://console.cloud.google.com/apis/api/generativelanguage.googleapis.com

**Documentation**: https://ai.google.dev/docs

---

### 3. Jules AI API

**Purpose**: Alternative AI provider for trade analysis

**How to obtain**:
1. Sign up at Jules AI platform
2. Navigate to API section in dashboard
3. Generate new API key

**Required Variables**:
```bash
JULES_API_KEY="your_jules_api_key_here"
JULES_API_URL="https://api.jules.ai"  # Or your instance URL
```

**Permissions**: `Masked: Yes`, `Protected: Yes`

---

### 4. GitHub Personal Access Token

**Purpose**: GitHub API integration, mirroring, workflow triggers

**How to obtain**:
1. Go to [GitHub Settings → Tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Select scopes:
   - `repo` - Full control of repositories
   - `workflow` - Update GitHub Actions workflows
   - `read:packages` - Download packages
   - `write:packages` - Upload packages

**Required Variables**:
```bash
GITHUB_PAT="github_pat_11EXAMPLE1234567890ABCDEF"  # New format
# or
GITHUB_PAT="ghp_1234567890abcdefGHIJKLMNOPQRSTUVWXYZ"  # Classic
```

**Permissions**: `Masked: Yes`, `Protected: Yes`

**Expiration**: Set expiration date (recommended: 90 days)

**Documentation**: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

---

### 5. GitLab Personal Access Token

**Purpose**: GitLab API integration for automation

**How to obtain**:
1. Go to [GitLab Settings → Access Tokens](https://gitlab.com/-/profile/personal_access_tokens)
2. Set token name: "MQL5 Trading CI/CD"
3. Select scopes:
   - `api` - Full API access
   - `read_repository` - Read repository
   - `write_repository` - Write to repository

**Required Variables**:
```bash
GITLAB_PAT="glpat-your_gitlab_personal_access_token"
```

**Permissions**: `Masked: Yes`, `Protected: Yes`

---

### 6. Cloud Platform Credentials

#### Render.com

**How to obtain**:
1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Account Settings → API Keys
3. Create new API key

**Required Variables**:
```bash
RENDER_API_KEY="rnd_1234567890abcdefghijklmnopqrstuvwxyz"
```

**Permissions**: `Masked: Yes`, `Protected: Yes`

#### Railway.app

**How to obtain**:
1. Go to [Railway Account Settings](https://railway.app/account/tokens)
2. Create new token

**Required Variables**:
```bash
RAILWAY_TOKEN="your_railway_api_token_here"
```

**Permissions**: `Masked: Yes`, `Protected: Yes`

#### Fly.io

**How to obtain**:
```bash
# Install flyctl CLI
curl -L https://fly.io/install.sh | sh

# Authenticate
flyctl auth login

# Get token
flyctl auth token
```

**Required Variables**:
```bash
FLY_API_TOKEN="fo1_1234567890abcdefghijklmnopqrstuvwxyz"
```

**Permissions**: `Masked: Yes`, `Protected: Yes`

---

### 7. Docker Hub Credentials

**How to obtain**:
1. Go to [Docker Hub Account Settings](https://hub.docker.com/settings/security)
2. Click "New Access Token"
3. Set description: "GitLab CI/CD"
4. Copy the token immediately (shown once)

**Required Variables**:
```bash
DOCKER_USERNAME="your_dockerhub_username"
DOCKER_PASSWORD="dckr_pat_1234567890abcdefghijklmnop"
```

**Permissions**: 
- `DOCKER_USERNAME`: `Masked: No`, `Protected: No`
- `DOCKER_PASSWORD`: `Masked: Yes`, `Protected: Yes`

---

### 8. Cloudflare API Credentials

**Purpose**: Domain management, DNS, CDN configuration

**How to obtain**:
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. My Profile → API Tokens → Create Token
3. Use template "Edit zone DNS" or create custom token

**Required Variables**:
```bash
CLOUDFLARE_API_TOKEN="your_cloudflare_api_token"
CLOUDFLARE_ZONE_ID="your_zone_id_from_overview_page"
CLOUDFLARE_ACCOUNT_ID="your_account_id_from_overview_page"
DOMAIN_NAME="your-domain.com"
```

**Permissions**: 
- `CLOUDFLARE_API_TOKEN`: `Masked: Yes`, `Protected: Yes`
- Others: `Masked: No`, `Protected: Yes`

**Documentation**: https://developers.cloudflare.com/api/

---

### 9. MetaTrader 5 Credentials (Optional)

**Purpose**: Automated trading account access

**Required Variables**:
```bash
MT5_SERVER="Exness-MT5Real"  # or your broker server
MT5_LOGIN="your_mt5_account_number"
MT5_PASSWORD="your_mt5_password"
```

**Permissions**: `Masked: Yes`, `Protected: Yes`

⚠️ **Warning**: Only use demo account credentials for CI/CD testing. Never store live trading credentials in CI/CD.

---

### 10. Notification Services

#### Slack

**How to obtain**:
1. Go to [Slack API Apps](https://api.slack.com/apps)
2. Create New App → From scratch
3. Add "Incoming Webhooks" feature
4. Activate and create webhook URL

**Required Variables**:
```bash
SLACK_WEBHOOK="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX"
```

#### Discord

**How to obtain**:
1. Go to Server Settings → Integrations → Webhooks
2. Create webhook
3. Copy URL

**Required Variables**:
```bash
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1234567890/XXXXXXXXXXXX"
```

**Permissions**: `Masked: Yes`, `Protected: No`

---

### 11. OneDrive Sync (rclone)

**Purpose**: Sync MT5 files to OneDrive

**How to obtain**:
```bash
# Install rclone
curl https://rclone.org/install.sh | sudo bash

# Configure OneDrive
rclone config

# Encode config to base64
base64 -w0 ~/.config/rclone/rclone.conf
```

**Required Variables**:
```bash
RCLONE_CONFIG_B64="base64_encoded_config_string_here"
ONEDRIVE_REMOTE="onedrive"  # Remote name from rclone config
ONEDRIVE_PATH="Apps/MT5/MQL5"  # Destination path
```

**Permissions**: `Masked: Yes`, `Protected: Yes`

---

## Setting Up GitLab Variables

### Method 1: Web Interface

1. Go to your GitLab project
2. Navigate to **Settings** → **CI/CD** → **Variables**
3. Click **Add variable**
4. Fill in:
   - **Key**: Variable name (e.g., `TELEGRAM_BOT_TOKEN`)
   - **Value**: The actual secret value
   - **Type**: Variable
   - **Environment scope**: All (or specific environment)
   - **Protect variable**: Enable for production secrets
   - **Mask variable**: Enable for sensitive values
   - **Expand variable reference**: Usually disabled
5. Click **Add variable**

### Method 2: GitLab CLI (glab)

```bash
# Install glab CLI
brew install glab  # macOS
# or download from https://gitlab.com/gitlab-org/cli

# Authenticate
glab auth login

# Set variables
glab variable set TELEGRAM_BOT_TOKEN "your_token" --masked --protected
glab variable set GEMINI_API_KEY "your_key" --masked --protected
glab variable set RENDER_API_KEY "your_key" --masked --protected

# List all variables
glab variable list
```

### Method 3: Automated Script

Use the provided script:

```bash
# 1. Create vault configuration
cp config/gitlab_vault.json.example config/gitlab_vault.json

# 2. Edit with your credentials
nano config/gitlab_vault.json

# 3. Run the script
bash scripts/set_gitlab_secrets.sh gitlab_vault
```

The script will:
- Read credentials from `config/gitlab_vault.json`
- Set all variables in GitLab
- Apply appropriate flags (masked, protected)
- Skip empty or placeholder values

---

## Local Development

### Using .env File

For local testing, create a `.env` file (never commit this!):

```bash
# Copy example
cp .env.example .env

# Edit with your values
nano .env
```

Example `.env` file:
```bash
# Telegram Bot
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHI...
TELEGRAM_ALLOWED_USER_IDS=123456789

# API Keys
GEMINI_API_KEY=AIzaSy...
JULES_API_KEY=your_key

# Cloud Platforms
RENDER_API_KEY=rnd_...
RAILWAY_TOKEN=...
FLY_API_TOKEN=fo1_...

# Docker
DOCKER_USERNAME=username
DOCKER_PASSWORD=dckr_pat_...
```

### Loading Variables

Python scripts can load from `.env`:
```python
from dotenv import load_dotenv
import os

load_dotenv()
bot_token = os.getenv('TELEGRAM_BOT_TOKEN')
```

Shell scripts:
```bash
# Source .env file
if [ -f .env ]; then
    export $(cat .env | xargs)
fi
```

---

## Credential Rotation

### Rotation Schedule

| Credential Type | Rotation Frequency | Priority |
|----------------|-------------------|----------|
| Bot tokens | Every 90 days | High |
| API keys | Every 180 days | Medium |
| Personal Access Tokens | Every 90 days | High |
| Service account keys | Every 365 days | Medium |
| Passwords | Immediately if compromised | Critical |

### Rotation Process

1. **Generate new credential** in the service
2. **Test new credential** in staging environment
3. **Update GitLab variable** with new value
4. **Verify CI/CD pipelines** work with new credential
5. **Revoke old credential** after verification
6. **Document rotation** in password manager

### Automated Rotation

Consider implementing:
- Hashicorp Vault integration
- AWS Secrets Manager
- Google Secret Manager
- Azure Key Vault

---

## Troubleshooting

### Variable Not Found

**Symptoms**: Pipeline fails with "variable not set" error

**Solutions**:
1. Check variable name is spelled correctly (case-sensitive)
2. Verify variable exists: **Settings** → **CI/CD** → **Variables**
3. Check variable scope matches branch/environment
4. Ensure variable is not protected if running on unprotected branch

### Variable Value Not Working

**Symptoms**: API returns authentication error

**Solutions**:
1. Verify value was copied correctly (no extra spaces)
2. Check token hasn't expired
3. Verify token has required permissions/scopes
4. Test token manually with curl/API client
5. Check service status (may be down)

### Variable Appears Empty

**Symptoms**: Script receives empty value

**Solutions**:
1. Check variable is not just whitespace
2. Verify masked flag isn't hiding a real empty value
3. Use `printenv VARIABLE_NAME` in CI job to debug
4. Check variable expansion is enabled if using references

### Permission Denied

**Symptoms**: API returns 403 Forbidden

**Solutions**:
1. Verify token has required scopes/permissions
2. Check IP allowlist (if service has one)
3. Verify account has access to resource
4. Check rate limits haven't been exceeded
5. Ensure service account is activated

---

## Related Documentation

- [GitLab CI/CD Setup](GITLAB_CI_CD_SETUP.md)
- [GitHub Secrets Setup](../GITHUB_SECRETS_SETUP.md)
- [Secrets Management](Secrets_Management.md)
- [Cloud Deployment Guide](Cloud_Deployment_Guide.md)

---

## Security Checklist

Before going to production:

- [ ] All secrets stored in GitLab Variables
- [ ] Sensitive variables marked as "Masked"
- [ ] Production variables marked as "Protected"
- [ ] No secrets committed to repository
- [ ] `.env` file added to `.gitignore`
- [ ] Vault files added to `.gitignore`
- [ ] Service accounts used instead of personal credentials
- [ ] Token scopes limited to minimum required
- [ ] Expiration dates set on tokens
- [ ] Rotation schedule documented
- [ ] Access logs monitoring enabled
- [ ] Backup of credentials stored securely (password manager)

---

**Last Updated**: 2026-02-14  
**Version**: 1.0.0
