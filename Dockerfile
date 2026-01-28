# Dockerfile for MQL5 Trading Automation System
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    bash \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies (if any)
RUN pip install --no-cache-dir -r requirements.txt || echo "No requirements to install"

# Copy application files
COPY . .

# Create logs directory
RUN mkdir -p logs

# Make scripts executable
RUN chmod +x scripts/*.py scripts/*.sh 2>/dev/null || true

# Set Python path
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Default command - run startup orchestrator
CMD ["python", "scripts/startup_orchestrator.py", "--monitor", "0"]
