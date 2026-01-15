#!/usr/bin/env python3
"""
Cloud Deployment Script for MQL5 Trading Automation
Supports multiple cloud platforms: Render, Railway, Fly.io, Heroku, etc.
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
CONFIG_DIR = REPO_ROOT / "config"


def deploy_render():
    """Deploy to Render.com"""
    print("=" * 60)
    print("Deploying to Render.com")
    print("=" * 60)
    
    # Check if render.yaml exists
    render_yaml = REPO_ROOT / "render.yaml"
    if not render_yaml.exists():
        print("❌ render.yaml not found. Creating it...")
        return False
    
    print("✅ render.yaml found")
    print("\nTo deploy to Render:")
    print("1. Push this repository to GitHub")
    print("2. Go to https://render.com")
    print("3. Create a new Web Service")
    print("4. Connect your GitHub repository")
    print("5. Render will auto-detect render.yaml")
    print("6. Deploy!")
    
    return True


def deploy_railway():
    """Deploy to Railway.app"""
    print("=" * 60)
    print("Deploying to Railway.app")
    print("=" * 60)
    
    railway_json = REPO_ROOT / "railway.json"
    if not railway_json.exists():
        print("Creating railway.json...")
        config = {
            "build": {
                "builder": "NIXPACKS"
            },
            "deploy": {
                "startCommand": "python scripts/startup_orchestrator.py --monitor 0",
                "restartPolicyType": "ON_FAILURE",
                "restartPolicyMaxRetries": 10
            }
        }
        with open(railway_json, 'w') as f:
            json.dump(config, f, indent=2)
        print("✅ Created railway.json")
    
    print("\nTo deploy to Railway:")
    print("1. Install Railway CLI: npm i -g @railway/cli")
    print("2. Run: railway login")
    print("3. Run: railway init")
    print("4. Run: railway up")
    
    return True


def deploy_docker(dockerfile_path=None):
    """Build and deploy Docker container"""
    print("=" * 60)
    print("Docker Deployment")
    print("=" * 60)
    
    dockerfile = dockerfile_path or REPO_ROOT / "Dockerfile"
    if not dockerfile.exists():
        print("❌ Dockerfile not found")
        return False
    
    print("Building Docker image...")
    try:
        subprocess.run(
            ["docker", "build", "-t", "mql5-automation", "."],
            cwd=REPO_ROOT,
            check=True
        )
        print("✅ Docker image built successfully")
        print("\nTo run locally:")
        print("  docker run -d --name mql5-automation mql5-automation")
        print("\nOr use docker-compose:")
        print("  docker-compose up -d")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Docker build failed: {e}")
        return False
    except FileNotFoundError:
        print("❌ Docker not installed. Please install Docker first.")
        return False


def deploy_flyio():
    """Deploy to Fly.io"""
    print("=" * 60)
    print("Deploying to Fly.io")
    print("=" * 60)
    
    fly_toml = REPO_ROOT / "fly.toml"
    if not fly_toml.exists():
        print("Creating fly.toml...")
        config = """app = "mql5-automation"
primary_region = "iad"

[build]

[env]
  PYTHONUNBUFFERED = "1"

[[services]]
  internal_port = 8080
  processes = ["app"]
  protocol = "tcp"
  script_checks = []

  [services.concurrency]
    hard_limit = 25
    soft_limit = 20
    type = "connections"

  [[services.ports]]
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443

  [[services.tcp_checks]]
    interval = "15s"
    timeout = "2s"
    grace_period = "1s"
"""
        with open(fly_toml, 'w') as f:
            f.write(config)
        print("✅ Created fly.toml")
    
    print("\nTo deploy to Fly.io:")
    print("1. Install Fly CLI: https://fly.io/docs/getting-started/installing-flyctl/")
    print("2. Run: fly auth login")
    print("3. Run: fly launch")
    print("4. Run: fly deploy")
    
    return True


def main():
    parser = argparse.ArgumentParser(
        description="Deploy MQL5 Trading Automation to cloud platforms"
    )
    parser.add_argument(
        "platform",
        choices=["render", "railway", "docker", "flyio", "all"],
        help="Cloud platform to deploy to"
    )
    parser.add_argument(
        "--build",
        action="store_true",
        help="Build Docker image (for docker platform)"
    )
    
    args = parser.parse_args()
    
    if args.platform == "render":
        deploy_render()
    elif args.platform == "railway":
        deploy_railway()
    elif args.platform == "docker":
        deploy_docker()
    elif args.platform == "flyio":
        deploy_flyio()
    elif args.platform == "all":
        print("Setting up configurations for all platforms...\n")
        deploy_render()
        print()
        deploy_railway()
        print()
        deploy_flyio()
        print()
        if args.build:
            deploy_docker()


if __name__ == "__main__":
    main()
