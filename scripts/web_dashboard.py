import os
import sys
from flask import Flask, render_template_string, jsonify, request
import markdown
import time
import requests
import subprocess

app = Flask(__name__)

# Cache storage: filepath -> (mtime, html_content)
_content_cache = {}

# Constants for paths to avoid re-calculating on every request
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
README_PATH = os.path.join(BASE_DIR, '..', 'README.md')
VERIFICATION_PATH = os.path.join(BASE_DIR, '..', 'VERIFICATION.md')

# HTML Template
DASHBOARD_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <title>MQL5 Trading Automation Dashboard</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; max-width: 1000px; margin: 0 auto; padding: 20px; background: #f0f2f5; color: #1c1e21; }
        .card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px; }
        h1, h2 { color: #050505; border-bottom: 1px solid #ddd; padding-bottom: 10px; }
        pre { background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; border: 1px solid #eee; }
        .status-badge { display: inline-block; padding: 4px 12px; border-radius: 15px; font-weight: bold; background: #42b983; color: white; }
        .nav { margin-bottom: 20px; background: #fff; padding: 10px 20px; border-radius: 8px; box-shadow: 0 1px 2px rgba(0,0,0,0.1); }
        .nav a { margin-right: 15px; color: #1877f2; text-decoration: none; font-weight: bold; }
        .nav a:hover { text-decoration: underline; }
        footer { text-align: center; margin-top: 40px; color: #65676b; font-size: 0.9em; }
        img { max-width: 100%; height: auto; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 1em; }
        th, td { text-align: left; padding: 8px; border-bottom: 1px solid #ddd; }
        th { background-color: #f8f9fa; }
        .skip-link { position: absolute; top: -40px; left: 0; background: #42b983; color: white; padding: 8px; z-index: 100; transition: top 0.3s; text-decoration: none; border-radius: 0 0 8px 0; font-weight: 600; }
        .skip-link:focus { top: 0; }
        .webhook-info { background: #e7f3ff; padding: 15px; border-left: 5px solid #1877f2; margin-top: 15px; border-radius: 4px; }
    </style>
</head>
<body>
    <a href="#status" class="skip-link">Skip to main content</a>
    <div class="nav">
        <a href="#status">System Status</a>
        <a href="#webhook">Webhook API</a>
        <a href="#docs">Documentation</a>
    </div>

    <div id="status" class="card">
        <h1>System Status <span class="status-badge">ONLINE</span></h1>
        <p>MQL5 Trading Automation is running.</p>
        {{ html_verification|safe }}
    </div>

    <div id="webhook" class="card">
        <h2>Webhook API Status</h2>
        <div class="webhook-info">
            <p><strong>Endpoint:</strong> <code>/api/signal</code></p>
            <p><strong>Method:</strong> <code>POST</code></p>
            <p><strong>Status:</strong> <span style="color: green; font-weight: bold;">Active</span></p>
            <p>This endpoint receives signals from MQL5 Expert Advisors and forwards them to Telegram.</p>
        </div>
    </div>

    <div id="docs" class="card">
        <h2>Project Documentation</h2>
        {{ html_readme|safe }}
    </div>

    <footer>
        <p>&copy; {{ year }} MQL5 Trading Automation | Dashboard v1.1.0</p>
    </footer>
</body>
</html>
"""

# Global to store compiled template
DASHBOARD_TEMPLATE = None

def get_cached_markdown(filepath):
    try:
        stat_result = os.stat(filepath)
    except OSError:
        return None

    try:
        mtime = stat_result.st_mtime
        if filepath in _content_cache:
            cached_mtime, cached_html = _content_cache[filepath]
            if cached_mtime == mtime:
                return cached_html

        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        html_content = markdown.markdown(content)
        _content_cache[filepath] = (mtime, html_content)
        return html_content
    except Exception as e:
        print(f"Error reading/converting {filepath}: {e}")
        return None

@app.route('/health')
def health_check():
    return jsonify({
        "status": "healthy",
        "webhook_active": True,
        "timestamp": time.time()
    })

@app.route('/api/signal', methods=['POST'])
def handle_signal():
    try:
        webhook_key = os.environ.get('SIGNAL_WEBHOOK_KEY')
        if webhook_key:
            provided_key = request.headers.get('X-Api-Key') or request.args.get('key')
            if provided_key != webhook_key:
                return jsonify({"status": "error", "message": "Unauthorized"}), 401

        data = request.get_json()
        if not data:
            return jsonify({"status": "error", "message": "Invalid JSON payload"}), 400

        event = data.get('event', 'signal')
        message = data.get('message', '')

        if not message:
            return jsonify({"status": "error", "message": "Missing message field"}), 400

        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Webhook received: {event}")

        # Forward to Telegram
        bot_token = os.environ.get('TELEGRAM_BOT_TOKEN')
        allowed_users_raw = os.environ.get('TELEGRAM_ALLOWED_USER_IDS', '')

        if bot_token and allowed_users_raw:
            allowed_users = [u.strip() for u in allowed_users_raw.split(',') if u.strip()]

            for user_id in allowed_users:
                try:
                    tel_url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
                    payload = {
                        "chat_id": user_id,
                        "text": f"🔔 <b>MQL5 Signal: {event}</b>\n\n<code>{message}</code>",
                        "parse_mode": "HTML"
                    }
                    resp = requests.post(tel_url, json=payload, timeout=5)
                    if not resp.ok:
                        print(f"Telegram API error for user {user_id}: {resp.text}")
                except Exception as e:
                    print(f"Failed to send Telegram notification to {user_id}: {e}")

        return jsonify({
            "status": "success",
            "message": "Signal processed and forwarded",
            "timestamp": time.time()
        })

    except Exception as e:
        print(f"Error in webhook handler: {e}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500

@app.after_request
def add_security_headers(response):
    csp = "default-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self'"
    response.headers['Content-Security-Policy'] = csp
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    return response

@app.route('/')
def dashboard():
    global DASHBOARD_TEMPLATE
    try:
        html_readme = get_cached_markdown(README_PATH) or "<p>README.md not found.</p>"
        html_verification = get_cached_markdown(VERIFICATION_PATH) or "<p>VERIFICATION.md not found.</p>"

        if DASHBOARD_TEMPLATE is None:
            DASHBOARD_TEMPLATE = app.jinja_env.from_string(DASHBOARD_HTML)

        return DASHBOARD_TEMPLATE.render(html_readme=html_readme, html_verification=html_verification, year=2026)
    except Exception as e:
        print(f"Dashboard render error: {e}")
        return "Internal Server Error", 500

def start_bot():
    """Start the telegram bot in the background."""
    bot_path = os.path.join(BASE_DIR, "telegram_deploy_bot.py")
    if os.path.exists(bot_path):
        try:
            print("Starting Telegram Deployment Bot in the background...")
            subprocess.Popen([sys.executable, bot_path])
        except Exception as e:
            print(f"Failed to start Telegram bot: {e}")

if __name__ == '__main__':
    # Start the telegram bot in the background
    start_bot()

    port = int(os.environ.get('PORT', 8080))
    print(f"Starting web dashboard with Webhook support on port {port}...")
    app.run(host='0.0.0.0', port=port)
