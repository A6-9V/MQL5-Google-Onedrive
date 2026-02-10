# Sentinel's Journal

## 2026-02-07 - Telegram Bot Authorization Bypass
**Vulnerability:** The Telegram Deployment Bot (`scripts/telegram_deploy_bot.py`) contained a "Fail Open" vulnerability where omitting the `TELEGRAM_ALLOWED_USER_IDS` environment variable resulted in granting access to *all* Telegram users instead of *none*.
**Learning:** Security controls must default to deny (Fail Closed). Implicitly allowing access when configuration is missing creates silent vulnerabilities that are hard to detect until exploited.
**Prevention:** Ensure all authorization checks explicitly return `False` or throw an exception if the access control list is empty or undefined. Never default to `True` in security-critical paths.

## 2026-02-10 - Web Dashboard Information Leakage
**Vulnerability:** The web dashboard (`scripts/web_dashboard.py`) caught all exceptions and returned the raw exception message to the user (`return f"Error: {str(e)}", 500`).
**Learning:** Returning raw exception messages can leak sensitive internal state, file paths, or configuration details to attackers.
**Prevention:** Always catch exceptions, log the full details securely on the server, and return a generic error message (e.g., "Internal Server Error") to the user.
