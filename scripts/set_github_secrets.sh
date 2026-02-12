#!/bin/bash
# Script to set GitHub Secrets for Cloudflare and Docker Hub configuration
# Requires GitHub CLI (gh) installed and authenticated

set -e

# Configuration
VAULT_FILE="config/vault.json"
ENV_FILE=".env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function show_usage() {
    echo "Usage: $0 [vault|env]"
    echo ""
    echo "Arguments:"
    echo "  vault    Read credentials from config/vault.json (default)"
    echo "  env      Read credentials from .env file"
}

function set_secret() {
    local name=$1
    local value=$2
    if [ -z "$value" ]; then
        echo -e "${RED}Error: Value for $name is empty.${NC}"
        return 1
    fi
    echo "Setting secret $name..."
    gh secret set "$name" --body "$value"
}

# Source of truth
SOURCE=${1:-vault}

if [ "$SOURCE" == "vault" ]; then
    if [ -f "$VAULT_FILE" ]; then
        echo "Reading credentials from $VAULT_FILE..."
        # Check if python3 is available for robust JSON parsing
        if command -v python3 >/dev/null 2>&1; then
            ZONE_ID=$(python3 -c "import json; v=json.load(open('$VAULT_FILE')); print(v.get('cloudflare', {}).get('zone_id', ''))")
            ACCOUNT_ID=$(python3 -c "import json; v=json.load(open('$VAULT_FILE')); print(v.get('cloudflare', {}).get('account_id', ''))")
            DOMAIN=$(python3 -c "import json; v=json.load(open('$VAULT_FILE')); print(v.get('cloudflare', {}).get('domain', ''))")
            DOCKER_USERNAME=$(python3 -c "import json; v=json.load(open('$VAULT_FILE')); print(v.get('docker', {}).get('username', ''))")
            DOCKER_PASSWORD=$(python3 -c "import json; v=json.load(open('$VAULT_FILE')); print(v.get('docker', {}).get('password', ''))")
        else
            echo -e "${RED}Error: python3 not found for JSON parsing.${NC}"
            return 1
        fi
    else
        echo -e "${RED}Error: $VAULT_FILE not found.${NC}"
        echo "Please create it with the following structure:"
        echo '{
    "cloudflare": {
        "zone_id": "your_zone_id",
        "account_id": "your_account_id",
        "domain": "your_domain.com"
    },
    "docker": {
        "username": "your_docker_hub_username",
        "password": "your_docker_hub_password_or_token"
    }
}'
        return 1
    fi
elif [ "$SOURCE" == "env" ]; then
    if [ -f "$ENV_FILE" ]; then
        echo "Reading credentials from $ENV_FILE..."
        ZONE_ID=$(grep CLOUDFLARE_ZONE_ID "$ENV_FILE" | cut -d '=' -f2)
        ACCOUNT_ID=$(grep CLOUDFLARE_ACCOUNT_ID "$ENV_FILE" | cut -d '=' -f2)
        DOMAIN=$(grep DOMAIN_NAME "$ENV_FILE" | cut -d '=' -f2)
        DOCKER_USERNAME=$(grep DOCKER_USERNAME "$ENV_FILE" | cut -d '=' -f2)
        DOCKER_PASSWORD=$(grep DOCKER_PASSWORD "$ENV_FILE" | cut -d '=' -f2)
    else
        echo -e "${RED}Error: $ENV_FILE not found.${NC}"
        return 1
    fi
else
    show_usage
    return 1
fi

# Set the secrets
set_secret CLOUDFLARE_ZONE_ID "$ZONE_ID"
set_secret CLOUDFLARE_ACCOUNT_ID "$ACCOUNT_ID"
set_secret DOMAIN_NAME "$DOMAIN"

if [ -n "$DOCKER_USERNAME" ]; then
    set_secret DOCKER_USERNAME "$DOCKER_USERNAME"
fi

if [ -n "$DOCKER_PASSWORD" ]; then
    set_secret DOCKER_PASSWORD "$DOCKER_PASSWORD"
fi

echo -e "${GREEN}✅ GitHub Secrets set successfully!${NC}"
