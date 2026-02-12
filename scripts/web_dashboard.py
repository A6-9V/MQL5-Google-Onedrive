import os
import sys
import time
from flask import Flask, render_template_string
import markdown

app = Flask(__name__)

# ⚡ Bolt: Pre-calculate absolute paths once to avoid redundant os.path.join calls on every request.
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
README_PATH = os.path.join(BASE_DIR, 'README.md')
VERIFICATION_PATH = os.path.join(BASE_DIR, 'VERIFICATION.md')

# ⚡ Bolt: MarkdownCache class to optimize rendering performance.
# Caches the rendered HTML and only re-renders if the file's modification time (mtime) changes.
# This eliminates redundant I/O and CPU-intensive markdown processing for static content.
class MarkdownCache:
    def __init__(self, filepath, fallback_text):
        self.filepath = filepath
        self.fallback_text = fallback_text
        self.cached_html = None
        self.last_mtime = 0

    def get_html(self):
        try:
            if not os.path.exists(self.filepath):
                return self.fallback_text

            current_mtime = os.path.getmtime(self.filepath)
            if self.cached_html is None or current_mtime > self.last_mtime:
                with open(self.filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                self.cached_html = markdown.markdown(content)
                self.last_mtime = current_mtime
                # print(f"DEBUG: Cache refreshed for {self.filepath}")

            return self.cached_html
        except Exception as e:
            return f"<p>Error loading content: {str(e)}</p>"

# Initialize caches
readme_cache = MarkdownCache(README_PATH, "<p>README.md not found.</p>")
verification_cache = MarkdownCache(VERIFICATION_PATH, "<p>VERIFICATION.md not found.</p>")

@app.route('/')
@app.route('/health')
def health_check():
    try:
        # ⚡ Bolt: Use cached HTML instead of reading and rendering on every request.
        html_readme = readme_cache.get_html()
        html_verification = verification_cache.get_html()

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
            
            <!-- Vercel Web Analytics -->
            <script>
                window.va = window.va || function () { (window.vaq = window.vaq || []).push(arguments); };
            </script>
            <script defer src="/_vercel/insights/script.js"></script>
        </body>
        </html>
        """, html_readme=html_readme, html_verification=html_verification, year=time.strftime("%Y"))
    except Exception as e:
        return f"Error: {str(e)}", 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    print(f"Starting web dashboard on port {port}...")
    app.run(host='0.0.0.0', port=port)
