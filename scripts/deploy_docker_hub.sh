#!/usr/bin/env bash
# ============================================================================
# Docker Hub Deployment Script
# ============================================================================
# Builds and pushes the Docker image to Docker Hub.
# Usage: ./scripts/deploy_docker_hub.sh <USERNAME> <TOKEN/PASSWORD>
# ============================================================================

set -e

USERNAME=$1
PASSWORD=$2
IMAGE_NAME="mouyleng/mql5-trading-automation"
TAG="latest"

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <USERNAME> <TOKEN/PASSWORD>"
    echo "Example: $0 mouyleng dckr_pat_..."
    exit 1
fi

echo "Logging in to Docker Hub as $USERNAME..."
echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin

echo "Building Docker image..."
docker build -t "$IMAGE_NAME:$TAG" .

echo "Pushing image to Docker Hub..."
docker push "$IMAGE_NAME:$TAG"

echo "✅ Deployment to Docker Hub complete!"
echo "Image: $IMAGE_NAME:$TAG"
