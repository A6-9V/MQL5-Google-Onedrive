import os
import sys
from flask import Flask, render_template_string, jsonify
import markdown
import time

app = Flask(__name__)

# Cache storage: filepath -> (mtime, html_content)
_content_cache = {}

# Constants for paths to avoid re-calculating on every request
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
README_PATH = os.path.join(BASE_DIR, '..', 'README.md')
VERIFICATION_PATH = os.path.join(BASE_DIR, '..', 'VERIFICATION.md')

def get_cached_markdown(filepath):
    """
    Returns the markdown content of a file converted to HTML, using a cache
    that invalidates based on file modification time.

    Optimization: Uses os.stat() to get mtime and check existence in one syscall.
    """
    try:
        # Optimization: os.stat gets existence and mtime in one call
        # removing the need for separate os.path.exists() check
        stat_result = os.stat(filepath)
    except OSError:
        return None

    try:
        mtime = stat_result.st_mtime
        if filepath in _content_cache:
            cached_mtime, cached_html = _content_cache[filepath]
            if cached_mtime == mtime:
                return cached_html

        # Cache miss or file changed
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        html_content = markdown.markdown(content)
        _content_cache[filepath] = (mtime, html_content)
        return html_content
    except Exception as e:
        print(f"Error reading/converting {filepath}: {e}")
        return None

@app.after_request
def add_security_headers(response):
    """Add security headers to the response."""
    # Content Security Policy
    # - default-src 'self': Only allow resources from same origin by default
    # - script-src 'self': Only allow scripts from same origin (blocks inline scripts & external)
    # - style-src 'self' 'unsafe-inline': Allow inline styles (template uses <style>)
    # - img-src 'self' data: https: : Allow images from same origin, data URIs, and HTTPS
    response.headers['Content-Security-Policy'] = (
        "default-src 'self'; "
        "script-src 'self'; "
        "style-src 'self' 'unsafe-inline'; "
        "img-src 'self' data: https:; "
        "font-src 'self' data:;"
    )
    # Prevent MIME sniffing
    response.headers['X-Content-Type-Options'] = 'nosniff'
    # Prevent clickjacking
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    # Control referrer information
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'

    return response

@app.route('/health')
def health_check():
    """Lightweight health check for load balancers."""
    return jsonify({
        "status": "healthy",
        "timestamp": time.time()
    })

@app.route('/')
def dashboard():
    try:
        # Use pre-calculated paths
        html_readme = get_cached_markdown(README_PATH) or "<p>README.md not found.</p>"
        html_verification = get_cached_markdown(VERIFICATION_PATH) or "<p>VERIFICATION.md not found.</p>"

        return render_template_string("""
        <!DOCTYPE html>
        <html>
        <head>
            <title>MQL5 Trading Automation Dashboard</title>
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
            </style>
        </head>
        <body>
            <div class="nav">
                <a href="#status">System Status</a>
                <a href="#docs">Documentation</a>
            </div>

            <div id="status" class="card">
                <h1>System Status <span class="status-badge">ONLINE</span></h1>
                <p>MQL5 Trading Automation is running.</p>
                {{ html_verification|safe }}
            </div>

            <div id="docs" class="card">
                <h2>Project Documentation</h2>
                {{ html_readme|safe }}
            </div>

            <footer>
                <p>&copy; {{ year }} MQL5 Trading Automation | Dashboard v1.0.0</p>
            </footer>
        </body>
        </html>
        """, html_readme=html_readme, html_verification=html_verification, year=2026)
    except Exception as e:
        return f"Error: {str(e)}", 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    print(f"Starting web dashboard on port {port}...")
    app.run(host='0.0.0.0', port=port)
