#!/bin/bash
# ============================================================================
# Container Entrypoint Script for MQL5 Trading Automation
# ============================================================================

# Setup Xvfb (Virtual Framebuffer)
echo "Starting Xvfb on display $DISPLAY..."
Xvfb :99 -screen 0 1024x768x16 &
XVFB_PID=$!

# Wait for Xvfb to start
sleep 3

# Check if Xvfb is running
if ps -p $XVFB_PID > /dev/null; then
    echo "✅ Xvfb is running (PID: $XVFB_PID)"
else
    echo "❌ Xvfb failed to start"
fi

# Run the Python orchestrator
echo "Starting Python Orchestrator..."
python scripts/startup_orchestrator.py --monitor 0

# Keep the script running
wait $XVFB_PID
