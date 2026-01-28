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
    """Get Telegram bot token from vault"""
    vault = load_vault()
    if vault and 'telegram_bot' in vault:
        return vault['telegram_bot'].get('token')
    return None


def get_telegram_allowed_users():
    """Get allowed Telegram user IDs from vault"""
    vault = load_vault()
    if vault and 'telegram_bot' in vault:
        return vault['telegram_bot'].get('allowed_user_ids', [])
    return []


if __name__ == "__main__":
    # Set environment variables when run directly
    token = get_telegram_token()
    if token:
        os.environ['TELEGRAM_BOT_TOKEN'] = token
        print("✅ Telegram bot token loaded from vault")
    
    allowed_users = get_telegram_allowed_users()
    if allowed_users:
        os.environ['TELEGRAM_ALLOWED_USER_IDS'] = ','.join(map(str, allowed_users))
