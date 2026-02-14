#!/usr/bin/env bash
#
# Set GitLab CI/CD Variables from vault configuration
#
# Usage:
#   bash scripts/set_gitlab_secrets.sh <vault_file>
#   bash scripts/set_gitlab_secrets.sh gitlab_vault
#
# Prerequisites:
#   - glab CLI installed (https://gitlab.com/gitlab-org/cli)
#   - Authenticated to GitLab (run: glab auth login)
#   - config/<vault_file>.json exists with credentials

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$ROOT_DIR/config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if glab is installed
if ! command -v glab &> /dev/null; then
    print_error "glab CLI is not installed"
    echo ""
    echo "Install glab CLI:"
    echo "  macOS:  brew install glab"
    echo "  Linux:  https://gitlab.com/gitlab-org/cli/-/releases"
    echo ""
    echo "After installation, authenticate:"
    echo "  glab auth login"
    exit 1
fi

# Check if authenticated
if ! glab auth status &> /dev/null; then
    print_error "Not authenticated to GitLab"
    echo "Run: glab auth login"
    exit 1
fi

# Get vault file name from argument
VAULT_NAME="${1:-vault}"
VAULT_FILE="$CONFIG_DIR/${VAULT_NAME}.json"

if [[ ! -f "$VAULT_FILE" ]]; then
    print_error "Vault file not found: $VAULT_FILE"
    echo ""
    echo "Create the vault file from template:"
    echo "  cp config/vault.json.example config/${VAULT_NAME}.json"
    echo "  # Edit the file with your credentials"
    exit 1
fi

print_info "Reading vault from: $VAULT_FILE"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_error "jq is not installed"
    echo "Install jq:"
    echo "  macOS:  brew install jq"
    echo "  Linux:  apt-get install jq"
    exit 1
fi

# Function to set a GitLab variable
set_gitlab_variable() {
    local key="$1"
    local value="$2"
    local protected="${3:-false}"
    local masked="${4:-false}"
    
    if [[ -z "$value" ]] || [[ "$value" == "null" ]] || [[ "$value" == "your_"* ]]; then
        print_warning "Skipping $key (empty or placeholder value)"
        return
    fi
    
    local flags=""
    if [[ "$protected" == "true" ]]; then
        flags="$flags --protected"
    fi
    if [[ "$masked" == "true" ]]; then
        flags="$flags --masked"
    fi
    
    if glab variable set "$key" "$value" $flags 2>/dev/null; then
        print_success "Set $key"
    else
        # Try updating if it already exists
        if glab variable update "$key" "$value" $flags 2>/dev/null; then
            print_success "Updated $key"
        else
            print_error "Failed to set $key"
        fi
    fi
}

# Parse and set variables from vault
print_info "Setting GitLab CI/CD variables..."
echo ""

# Cloudflare variables
print_info "Setting Cloudflare variables..."
CLOUDFLARE_ZONE_ID=$(jq -r '.cloudflare.zone_id // empty' "$VAULT_FILE")
CLOUDFLARE_ACCOUNT_ID=$(jq -r '.cloudflare.account_id // empty' "$VAULT_FILE")
DOMAIN_NAME=$(jq -r '.cloudflare.domain // empty' "$VAULT_FILE")

set_gitlab_variable "CLOUDFLARE_ZONE_ID" "$CLOUDFLARE_ZONE_ID" "true" "false"
set_gitlab_variable "CLOUDFLARE_ACCOUNT_ID" "$CLOUDFLARE_ACCOUNT_ID" "true" "false"
set_gitlab_variable "DOMAIN_NAME" "$DOMAIN_NAME" "false" "false"

# Telegram Bot variables
print_info "Setting Telegram Bot variables..."
TELEGRAM_BOT_TOKEN=$(jq -r '.telegram_bot.token // .telegram_bot.api // empty' "$VAULT_FILE")
TELEGRAM_ALLOWED_USER_IDS=$(jq -r '.telegram_bot.allowed_user_ids | if type == "array" then join(",") else . end // empty' "$VAULT_FILE")

set_gitlab_variable "TELEGRAM_BOT_TOKEN" "$TELEGRAM_BOT_TOKEN" "true" "true"
set_gitlab_variable "TELEGRAM_BOT_API" "$TELEGRAM_BOT_TOKEN" "true" "true"
set_gitlab_variable "TELEGRAM_ALLOWED_USER_IDS" "$TELEGRAM_ALLOWED_USER_IDS" "true" "false"

# GitHub PAT (for integration)
print_info "Setting GitHub integration variables..."
GITHUB_PAT=$(jq -r '.github.pat // empty' "$VAULT_FILE")
set_gitlab_variable "GITHUB_PAT" "$GITHUB_PAT" "true" "true"

# API Keys (if present in vault)
print_info "Setting API keys..."
GEMINI_API_KEY=$(jq -r '.api_keys.gemini // empty' "$VAULT_FILE")
JULES_API_KEY=$(jq -r '.api_keys.jules // empty' "$VAULT_FILE")

set_gitlab_variable "GEMINI_API_KEY" "$GEMINI_API_KEY" "true" "true"
set_gitlab_variable "JULES_API_KEY" "$JULES_API_KEY" "true" "true"

# Cloud platform tokens (if present)
print_info "Setting cloud platform tokens..."
RENDER_API_KEY=$(jq -r '.cloud.render_api_key // empty' "$VAULT_FILE")
RAILWAY_TOKEN=$(jq -r '.cloud.railway_token // empty' "$VAULT_FILE")
FLY_API_TOKEN=$(jq -r '.cloud.fly_api_token // empty' "$VAULT_FILE")
DOCKER_USERNAME=$(jq -r '.docker.username // empty' "$VAULT_FILE")
DOCKER_PASSWORD=$(jq -r '.docker.password // empty' "$VAULT_FILE")

set_gitlab_variable "RENDER_API_KEY" "$RENDER_API_KEY" "true" "true"
set_gitlab_variable "RAILWAY_TOKEN" "$RAILWAY_TOKEN" "true" "true"
set_gitlab_variable "FLY_API_TOKEN" "$FLY_API_TOKEN" "true" "true"
set_gitlab_variable "DOCKER_USERNAME" "$DOCKER_USERNAME" "false" "false"
set_gitlab_variable "DOCKER_PASSWORD" "$DOCKER_PASSWORD" "true" "true"

echo ""
print_success "GitLab CI/CD variables configured!"
echo ""
print_info "View variables at: Settings → CI/CD → Variables"
echo ""
print_warning "Remember to:"
echo "  1. Never commit vault.json files to the repository"
echo "  2. Add config/*vault*.json to .gitignore"
echo "  3. Keep your vault file secure and backed up"
echo "  4. Rotate credentials regularly"
