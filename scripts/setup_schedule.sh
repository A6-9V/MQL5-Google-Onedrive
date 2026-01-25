#!/bin/bash
# Setup and start the Research Scheduler (Gemini & Jules)
# This script ensures the scheduler is running.

# Ensure logs directory exists
mkdir -p logs

# 1. Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# 2. Check for .env
if [ ! -f ".env" ]; then
    echo ".env file not found. Creating empty .env..."
    touch .env
    echo "Please add your GEMINI_API_KEY, JULES_API_KEY, and JULES_API_URL to .env"
fi

# 3. Start Scheduler in background
echo "Starting Research Scheduler..."
nohup python3 scripts/schedule_research.py > logs/research.log 2>&1 &
PID=$!
echo "Scheduler started with PID $PID. Logs are in logs/research.log"
