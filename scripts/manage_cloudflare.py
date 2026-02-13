#!/usr/bin/env python3
"""
Script to manage Cloudflare settings for the configured zone.
Reads credentials from config/vault.json or environment variables.
"""

import os
import json
import argparse
import sys
import requests

# Constants
VAULT_FILE = "config/vault.json"
BASE_URL = "https://api.cloudflare.com/client/v4"
# OPTIMIZATION: Set reasonable timeout for API requests
REQUEST_TIMEOUT = 10  # seconds

def load_config():
    """Load configuration from vault.json or environment variables."""
    config = {
        "zone_id": os.environ.get("CLOUDFLARE_ZONE_ID"),
        "account_id": os.environ.get("CLOUDFLARE_ACCOUNT_ID"),
        "api_token": os.environ.get("CLOUDFLARE_API_TOKEN"),
        "domain": os.environ.get("DOMAIN_NAME")
    }

    if os.path.exists(VAULT_FILE):
        try:
            with open(VAULT_FILE, 'r') as f:
                vault = json.load(f)
                cf_vault = vault.get("cloudflare", {})
                if not config["zone_id"]:
                    config["zone_id"] = cf_vault.get("zone_id")
                if not config["account_id"]:
                    config["account_id"] = cf_vault.get("account_id")
                if not config["api_token"]:
                    config["api_token"] = cf_vault.get("api_token")
                if not config["domain"]:
                    config["domain"] = cf_vault.get("domain")
        except Exception as e:
            print(f"Warning: Failed to read {VAULT_FILE}: {e}")

    return config

def get_headers(api_token):
    return {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/json"
    }

def get_security_level(zone_id, api_token):
    """Get the current security level."""
    url = f"{BASE_URL}/zones/{zone_id}/settings/security_level"
    try:
        # OPTIMIZATION: Add timeout to prevent hanging
        response = requests.get(url, headers=get_headers(api_token), timeout=REQUEST_TIMEOUT)
        response.raise_for_status()
        data = response.json()
        if data.get("success"):
            return data["result"]["value"]
        else:
            print(f"Error: {data.get('errors')}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"HTTP Request failed: {e}")
        return None

def set_security_level(zone_id, api_token, level):
    """Set the security level."""
    valid_levels = ["off", "essentially_off", "low", "medium", "high", "under_attack"]
    if level not in valid_levels:
        print(f"Error: Invalid security level. Must be one of: {', '.join(valid_levels)}")
        return False

    url = f"{BASE_URL}/zones/{zone_id}/settings/security_level"
    payload = {"value": level}

    try:
        # OPTIMIZATION: Add timeout to prevent hanging
        response = requests.patch(url, headers=get_headers(api_token), json=payload, timeout=REQUEST_TIMEOUT)
        response.raise_for_status()
        data = response.json()
        if data.get("success"):
            print(f"Successfully set security level to: {data['result']['value']}")
            return True
        else:
            print(f"Error: {data.get('errors')}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"HTTP Request failed: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description="Manage Cloudflare Zone Settings")
    parser.add_argument("--status", action="store_true", help="Get current security level")
    parser.add_argument("--set", dest="security_level", help="Set security level (off, essentially_off, low, medium, high, under_attack)")

    args = parser.parse_args()

    config = load_config()

    # Check required config
    missing = []
    if not config["zone_id"]: missing.append("Zone ID")
    if not config["api_token"] or config["api_token"] == "YOUR_CLOUDFLARE_API_TOKEN": missing.append("API Token")

    if missing:
        print("Error: Missing configuration. Please update config/vault.json or set env vars.")
        print(f"Missing: {', '.join(missing)}")
        sys.exit(1)

    if args.status:
        level = get_security_level(config["zone_id"], config["api_token"])
        if level:
            print(f"Current Security Level: {level}")

    elif args.security_level:
        set_security_level(config["zone_id"], config["api_token"], args.security_level)

    else:
        parser.print_help()

if __name__ == "__main__":
    main()
