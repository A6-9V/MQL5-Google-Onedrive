#!/usr/bin/env bash
# ============================================================================
# VPS Update Script
# ============================================================================
# Pulls the latest Docker image and restarts the service.
# Run this on your VPS/Laptop.
# Usage: ./scripts/update_vps.sh [USERNAME] [TOKEN]
# ============================================================================

set -e

# Optional login if arguments are provided
USERNAME=$1
PASSWORD=$2

if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
    echo "Logging in to Docker Hub..."
    echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin
fi

echo "Pulling latest image..."
docker-compose pull

echo "Restarting services..."
docker-compose up -d --remove-orphans

echo "✅ VPS updated and running!"
docker-compose ps
