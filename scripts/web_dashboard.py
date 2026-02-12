import os
import sys
from flask import Flask, render_template_string
import markdown

app = Flask(__name__)

# --- ⚡ Bolt: Performance optimization - Cache rendered Markdown to avoid redundant processing.
# Module-level path definitions to avoid repeated path joining.
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
README_PATH = os.path.join(BASE_DIR, 'README.md')
VERIFICATION_PATH = os.path.join(BASE_DIR, 'VERIFICATION.md')

class MarkdownCache:
    """⚡ Bolt: Simple cache for rendered markdown files with mtime validation."""
    def __init__(self, filepath, name):
        self.filepath = filepath
        self.name = name
        self.cached_html = ""
        self.last_mtime = 0

    def get_html(self):
        """Returns cached HTML or re-renders if the file has changed."""
        try:
            # ⚡ Bolt: Use os.stat() to get metadata in a single system call instead of exists() + getmtime()
            try:
                stat_result = os.stat(self.filepath)
            except FileNotFoundError:
                return f"<p>{self.name} not found.</p>"

            current_mtime = stat_result.st_mtime
            if current_mtime > self.last_mtime:
                # File has changed or was never loaded
                with open(self.filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                self.cached_html = markdown.markdown(content)
                self.last_mtime = current_mtime

            return self.cached_html
        except Exception as e:
            return f"<p>Error loading {self.name}: {str(e)}</p>"

# Initialize caches
readme_cache = MarkdownCache(README_PATH, "README.md")
verification_cache = MarkdownCache(VERIFICATION_PATH, "VERIFICATION.md")

# ⚡ Bolt: Define template as a module-level constant to avoid re-allocation on every request.
# ⚡ Bolt: Hardcode year=2026 to simplify rendering and avoid passing constant values.
DASHBOARD_TEMPLATE = """
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
        <p>&copy; 2026 MQL5 Trading Automation | Dashboard v1.0.0</p>
    </footer>

    <!-- Vercel Web Analytics -->
    <script>
        window.va = window.va || function () { (window.vaq = window.vaq || []).push(arguments); };
    </script>
    <script defer src="/_vercel/insights/script.js"></script>
</body>
</html>
"""

@app.route('/')
@app.route('/health')
def health_check():
    try:
        # ⚡ Bolt: Use cached content to avoid redundant I/O and markdown rendering on every request.
        html_readme = readme_cache.get_html()
        html_verification = verification_cache.get_html()

        return render_template_string(DASHBOARD_TEMPLATE,
                                     html_readme=html_readme,
                                     html_verification=html_verification)
    except Exception as e:
        return f"Error: {str(e)}", 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    print(f"Starting web dashboard on port {port}...")
    app.run(host='0.0.0.0', port=port)
