#!/usr/bin/env python3
"""
Telegram Bot for Cloud Deployment Automation
Allows deploying to Fly.io, Render, Railway via Telegram commands
"""

import os
import sys
import subprocess
import logging
import asyncio
from pathlib import Path
from typing import Optional, Tuple

try:
    from telegram import Update
    from telegram.ext import Application, CommandHandler, ContextTypes
except ImportError:
    print("python-telegram-bot not installed. Install with: pip install python-telegram-bot")
    sys.exit(1)

# Setup logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# Repository root (assuming script is in scripts/ directory)
REPO_ROOT = Path(__file__).resolve().parents[1]
ALLOWED_USER_IDS = os.getenv('TELEGRAM_ALLOWED_USER_IDS', '').split(',')
ALLOWED_USER_IDS = [uid.strip() for uid in ALLOWED_USER_IDS if uid.strip()]

# Deployment commands mapping
DEPLOY_COMMANDS = {
    'flyio': ['python', str(REPO_ROOT / 'scripts' / 'deploy_cloud.py'), 'flyio'],
    'render': ['python', str(REPO_ROOT / 'scripts' / 'deploy_cloud.py'), 'render'],
    'railway': ['python', str(REPO_ROOT / 'scripts' / 'deploy_cloud.py'), 'railway'],
    'docker': ['python', str(REPO_ROOT / 'scripts' / 'deploy_cloud.py'), 'docker'],
}


def check_authorized(user_id: int) -> bool:
    """Check if user is authorized to use deployment commands"""
    if not ALLOWED_USER_IDS:
        logger.warning("No ALLOWED_USER_IDS set - allowing all users")
        return True
    return str(user_id) in ALLOWED_USER_IDS


async def run_deployment(platform: str) -> Tuple[bool, str]:
    """Run deployment command and capture output"""
    if platform not in DEPLOY_COMMANDS:
        return False, f"Unknown platform: {platform}"
    
    cmd = DEPLOY_COMMANDS[platform]
    try:
        logger.info(f"Running deployment: {' '.join(cmd)}")
        result = subprocess.run(
            cmd,
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )
        
        output = result.stdout + result.stderr
        if result.returncode == 0:
            return True, f"✅ Deployment to {platform} successful!\n\n{output[:1000]}"
        else:
            return False, f"❌ Deployment to {platform} failed:\n\n{output[:1000]}"
    except subprocess.TimeoutExpired:
        return False, f"⏱️ Deployment to {platform} timed out after 5 minutes"
    except Exception as e:
        return False, f"❌ Error running deployment: {str(e)}"


async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /start command"""
    user_id = update.effective_user.id
    
    if not check_authorized(user_id):
        await update.message.reply_text("❌ You are not authorized to use this bot.")
        return
    
    welcome_msg = """
🤖 <b>Deployment Bot Ready!</b>

Available commands:
/deploy_flyio - Deploy to Fly.io
/deploy_render - Deploy to Render.com
/deploy_railway - Deploy to Railway.app
/deploy_docker - Build Docker image
/deploy_exness - Deploy to Exness MT5
/deploy_dashboard - Deploy web dashboard
/status - Check deployment status
/help - Show this help message

Made for MQL5 Trading Automation
    """
    await update.message.reply_text(welcome_msg, parse_mode='HTML')


async def deploy_flyio(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /deploy_flyio command"""
    user_id = update.effective_user.id
    
    if not check_authorized(user_id):
        await update.message.reply_text("❌ You are not authorized to use this bot.")
        return
    
    await update.message.reply_text("🚀 Starting Fly.io deployment...\n⏳ This may take a few minutes...")
    
    success, message = await run_deployment('flyio')
    await update.message.reply_text(message)


async def deploy_render(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /deploy_render command"""
    user_id = update.effective_user.id
    
    if not check_authorized(user_id):
        await update.message.reply_text("❌ You are not authorized to use this bot.")
        return
    
    await update.message.reply_text("🚀 Starting Render deployment...\n⏳ This may take a few minutes...")
    
    success, message = await run_deployment('render')
    await update.message.reply_text(message)


async def deploy_railway(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /deploy_railway command"""
    user_id = update.effective_user.id
    
    if not check_authorized(user_id):
        await update.message.reply_text("❌ You are not authorized to use this bot.")
        return
    
    await update.message.reply_text("🚀 Starting Railway deployment...\n⏳ This may take a few minutes...")
    
    success, message = await run_deployment('railway')
    await update.message.reply_text(message)


async def deploy_docker(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /deploy_docker command"""
    user_id = update.effective_user.id
    
    if not check_authorized(user_id):
        await update.message.reply_text("❌ You are not authorized to use this bot.")
        return
    
    await update.message.reply_text("🐳 Building Docker image...\n⏳ This may take a few minutes...")
    
    success, message = await run_deployment('docker')
    await update.message.reply_text(message)


async def status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /status command - Check Fly.io app status"""
    user_id = update.effective_user.id
    
    if not check_authorized(user_id):
        await update.message.reply_text("❌ You are not authorized to use this bot.")
        return
    
    try:
        result = subprocess.run(
            ['flyctl', 'status'],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            await update.message.reply_text(f"📊 <b>Fly.io Status:</b>\n\n<code>{result.stdout}</code>", parse_mode='HTML')
        else:
            await update.message.reply_text(f"❌ Status check failed:\n\n{result.stderr}")
    except FileNotFoundError:
        await update.message.reply_text("❌ flyctl not found. Is Fly CLI installed?")
    except Exception as e:
        await update.message.reply_text(f"❌ Error checking status: {str(e)}")


async def deploy_exness(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /deploy_exness command"""
    user_id = update.effective_user.id
    
    if not check_authorized(user_id):
        await update.message.reply_text("❌ You are not authorized to use this bot.")
        return
    
    await update.message.reply_text(
        "📊 <b>Exness Terminal Deployment</b>\n\n"
        "⚠️ <b>Important:</b> Custom Indicators and EAs are <b>NOT supported</b> on the Exness Web Terminal.\n"
        "They only work in the <b>Desktop MT5</b> application.\n\n"
        "To deploy to Desktop MT5:\n"
        "1. Run the deployment script on your Windows machine:\n"
        "   <code>powershell -ExecutionPolicy Bypass -File scripts\\deploy_exness.ps1</code>\n\n"
        "2. Or open web terminal:\n"
        "   <a href='https://my.exness.global/webtrading/'>https://my.exness.global/webtrading/</a>\n\n"
        "For detailed instructions, see:\n"
        "docs/Exness_Deployment_Guide.md",
        parse_mode='HTML',
        disable_web_page_preview=True
    )


async def deploy_dashboard(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /deploy_dashboard command"""
    user_id = update.effective_user.id
    
    if not check_authorized(user_id):
        await update.message.reply_text("❌ You are not authorized to use this bot.")
        return
    
    platform = context.args[0].lower() if context.args else "all"
    
    if platform not in ["flyio", "render", "github", "local", "all"]:
        await update.message.reply_text(
            "❌ Invalid platform. Use: flyio, render, github, local, or all"
        )
        return
    
    await update.message.reply_text(
        f"🌐 <b>Deploying Dashboard</b>\n\n"
        f"Platform: <b>{platform}</b>\n\n"
        f"Run on your machine:\n"
        f"<code>powershell -ExecutionPolicy Bypass -File scripts\\deploy_dashboard.ps1 -Platform {platform}</code>\n\n"
        f"Or for all platforms:\n"
        f"<code>powershell -ExecutionPolicy Bypass -File scripts\\deploy_dashboard.ps1</code>\n\n"
        f"📁 Dashboard files: <code>dashboard/</code>",
        parse_mode='HTML'
    )


async def help_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /help command"""
    user_id = update.effective_user.id
    
    if not check_authorized(user_id):
        await update.message.reply_text("❌ You are not authorized to use this bot.")
        return
    
    help_text = """
📖 <b>Deployment Bot Commands</b>

/deploy_flyio - Deploy to Fly.io cloud platform
/deploy_render - Deploy to Render.com
/deploy_railway - Deploy to Railway.app
/deploy_docker - Build Docker image locally
/deploy_exness - Deploy to Exness MT5 (Desktop only)
/deploy_dashboard [platform] - Deploy web dashboard (flyio/render/github/local/all)
/status - Check Fly.io app deployment status
/help - Show this help message

<b>Note:</b> Deployments may take several minutes. Be patient!
    """
    await update.message.reply_text(help_text, parse_mode='HTML')


def main():
    """Main function to start the bot"""
    bot_token = os.getenv('TELEGRAM_BOT_TOKEN')
    
    # Try to load from vault if not in environment
    if not bot_token:
        try:
            from load_vault import get_telegram_token
            bot_token = get_telegram_token()
        except ImportError:
            pass
    
    if not bot_token:
        logger.error("TELEGRAM_BOT_TOKEN environment variable not set!")
        logger.info("Get a token from @BotFather on Telegram")
        logger.info("Save it in config/vault.json or set: export TELEGRAM_BOT_TOKEN=your_token_here")
        return
    
    logger.info("Starting Telegram Deployment Bot...")
    
    # Create application
    application = Application.builder().token(bot_token).build()
    
    # Register command handlers
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("help", help_cmd))
    application.add_handler(CommandHandler("deploy_flyio", deploy_flyio))
    application.add_handler(CommandHandler("deploy_render", deploy_render))
    application.add_handler(CommandHandler("deploy_railway", deploy_railway))
    application.add_handler(CommandHandler("deploy_docker", deploy_docker))
    application.add_handler(CommandHandler("deploy_exness", deploy_exness))
    application.add_handler(CommandHandler("deploy_dashboard", deploy_dashboard))
    application.add_handler(CommandHandler("status", status))
    
    # Start the bot
    logger.info("Bot is running. Press Ctrl+C to stop.")
    application.run_polling(allowed_updates=Update.ALL_TYPES)


if __name__ == '__main__':
    main()
