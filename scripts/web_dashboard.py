import os
import sys
from flask import Flask, render_template_string
import markdown

app = Flask(__name__)

@app.route('/')
@app.route('/health')
def health_check():
    try:
        readme_path = os.path.join(os.path.dirname(__file__), '..', 'README.md')
        verification_path = os.path.join(os.path.dirname(__file__), '..', 'VERIFICATION.md')

        readme_content = ""
        if os.path.exists(readme_path):
            with open(readme_path, 'r', encoding='utf-8') as f:
                readme_content = f.read()

        verification_content = ""
        if os.path.exists(verification_path):
            with open(verification_path, 'r', encoding='utf-8') as f:
                verification_content = f.read()

        html_readme = markdown.markdown(readme_content) if readme_content else "<p>README.md not found.</p>"
        html_verification = markdown.markdown(verification_content) if verification_content else "<p>VERIFICATION.md not found.</p>"

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
