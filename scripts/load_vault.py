#!/usr/bin/env python3
"""
Load credentials from personal vault (config/vault.json)
Used by Python scripts to securely access credentials
"""

import json
import os
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
VAULT_PATH = REPO_ROOT / "config" / "vault.json"

# Default values
DEFAULT_TELEGRAM_BOT_NAME = "t.me/your_bot_name"
DEFAULT_TELEGRAM_WEBHOOK_URL = "https://core.telegram.org/bots/api"


def load_vault():
    """Load credentials from vault.json"""
    if not VAULT_PATH.exists():
        print(f"⚠️ Vault file not found at: {VAULT_PATH}")
        return None
    
    try:
        with open(VAULT_PATH, 'r') as f:
            vault = json.load(f)
        return vault
    except json.JSONDecodeError as e:
        print(f"❌ Error parsing vault.json: {e}")
        return None
    except Exception as e:
        print(f"❌ Error loading vault: {e}")
        return None


def get_telegram_token():
    """Get Telegram bot token from vault
    
    Note: Prefers 'token' field over 'api' field if both exist.
    Both fields are supported for backward compatibility.
    """
    vault = load_vault()
    if vault and 'telegram_bot' in vault:
        return vault['telegram_bot'].get('token') or vault['telegram_bot'].get('api')
    return None


def get_telegram_bot_name():
    """Get Telegram bot name from vault"""
    vault = load_vault()
    if vault and 'telegram_bot' in vault:
        return vault['telegram_bot'].get('name', DEFAULT_TELEGRAM_BOT_NAME)
    return DEFAULT_TELEGRAM_BOT_NAME


def get_telegram_webhook_url():
    """Get Telegram webhook URL from vault"""
    vault = load_vault()
    if vault and 'telegram_bot' in vault:
        return vault['telegram_bot'].get('webhook_url', DEFAULT_TELEGRAM_WEBHOOK_URL)
    return DEFAULT_TELEGRAM_WEBHOOK_URL


def get_telegram_allowed_users():
    """Get allowed Telegram user IDs from vault"""
    vault = load_vault()
    if vault and 'telegram_bot' in vault:
        return vault['telegram_bot'].get('allowed_user_ids', [])
    return []


def get_github_pat():
    """Get GitHub Personal Access Token from vault"""
    vault = load_vault()
    if vault and 'github' in vault:
        return vault['github'].get('pat')
    return None


if __name__ == "__main__":
    # Set environment variables when run directly
    token = get_telegram_token()
    if token:
        os.environ['TELEGRAM_BOT_TOKEN'] = token
        print("✅ Telegram bot token loaded from vault")
    
    bot_name = get_telegram_bot_name()
    if bot_name:
        os.environ['TELEGRAM_BOT_NAME'] = bot_name
        print(f"✅ Telegram bot name: {bot_name}")
    
    webhook_url = get_telegram_webhook_url()
    if webhook_url:
        os.environ['TELEGRAM_WEBHOOK_URL'] = webhook_url
        print(f"✅ Telegram webhook URL: {webhook_url}")
    
    allowed_users = get_telegram_allowed_users()
    if allowed_users:
        os.environ['TELEGRAM_ALLOWED_USER_IDS'] = ','.join(map(str, allowed_users))
        print(f"✅ Allowed users loaded: {len(allowed_users)}")
    
    github_pat = get_github_pat()
    if github_pat:
        os.environ['GITHUB_PAT'] = github_pat
        print("✅ GitHub PAT loaded from vault")