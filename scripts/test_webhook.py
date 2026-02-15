#!/usr/bin/env python3
"""
Test script for the MQL5 Signal Webhook.
Usage: python scripts/test_webhook.py [URL] [API_KEY]
"""

import requests
import json
import sys
import os

def test_webhook(url=None, api_key=None):
    if not url:
        url = os.environ.get('WEBHOOK_URL', "http://localhost:8080/api/signal")

    if not api_key:
        api_key = os.environ.get('SIGNAL_WEBHOOK_KEY')

    payload = {
        "event": "SIGNAL_BUY",
        "message": "EURUSD Buy at 1.0850, SL: 1.0800, TP: 1.0950 (Test Signal)"
    }

    headers = {
        "Content-Type": "application/json"
    }

    if api_key:
        headers["X-Api-Key"] = api_key
        print(f"Using API Key: {api_key[:4]}...")

    print(f"Sending test signal to {url}...")
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=10)
        print(f"Status Code: {response.status_code}")

        try:
            print(f"Response: {json.dumps(response.json(), indent=2)}")
        except:
            print(f"Response Text: {response.text}")

        if response.status_code == 200:
            print("✅ Webhook test successful!")
            return True
        else:
            print(f"❌ Webhook test failed with status {response.status_code}")
            return False

    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    target_url = sys.argv[1] if len(sys.argv) > 1 else None
    key = sys.argv[2] if len(sys.argv) > 2 else None

    success = test_webhook(target_url, key)
    sys.exit(0 if success else 1)
