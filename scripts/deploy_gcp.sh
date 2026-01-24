#!/bin/bash

# Deployment script for Google Cloud Platform

PROJECT_ID="gen-lang-client-0535796538"
REGION="us-central1"
SERVICE_NAME="mql5-automation"

echo "=================================================="
echo "   MQL5 Trading Automation - GCP Deployment"
echo "=================================================="

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI is not installed."
    echo "Please install the Google Cloud SDK: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Authenticate if needed (simple check)
echo "Checking authentication..."
gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"
if [ $? -ne 0 ]; then
    echo "Not authenticated. Logging in..."
    gcloud auth login
fi

# Set Project
echo "Setting project to $PROJECT_ID..."
gcloud config set project $PROJECT_ID

# Enable services
echo "Enabling necessary services..."
gcloud services enable cloudbuild.googleapis.com run.googleapis.com containerregistry.googleapis.com

# Choose deployment type
echo ""
echo "Choose deployment target:"
echo "1) Cloud Run (Recommended - Faster, Cheaper)"
echo "2) App Engine Flex (Compatible with app.yaml)"
read -p "Select [1/2]: " choice

if [ "$choice" == "1" ]; then
    echo "Deploying to Cloud Run..."
    # Submit build to Cloud Build which also deploys
    gcloud builds submit --config cloudbuild.yaml .

    echo ""
    echo "Deployment triggered via Cloud Build."
    echo "Check the status in the Google Cloud Console."

elif [ "$choice" == "2" ]; then
    echo "Deploying to App Engine Flex..."
    gcloud app deploy app.yaml --project=$PROJECT_ID

else
    echo "Invalid choice. Exiting."
    exit 1
fi

echo ""
echo "Done."
