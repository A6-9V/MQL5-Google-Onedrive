import os
import sys
from flask import Flask, render_template_string
import markdown

app = Flask(__name__)

# Cache storage: filepath -> (mtime, html_content)
_content_cache = {}

def get_cached_markdown(filepath):
    """
    Returns the markdown content of a file converted to HTML, using a cache
    that invalidates based on file modification time.
    """
    if not os.path.exists(filepath):
        return None

    try:
        mtime = os.path.getmtime(filepath)
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

@app.route('/')
@app.route('/health')
def health_check():
    try:
        base_dir = os.path.dirname(os.path.abspath(__file__))
        readme_path = os.path.join(base_dir, '..', 'README.md')
        verification_path = os.path.join(base_dir, '..', 'VERIFICATION.md')

        html_readme = get_cached_markdown(readme_path) or "<p>README.md not found.</p>"
        html_verification = get_cached_markdown(verification_path) or "<p>VERIFICATION.md not found.</p>"

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
