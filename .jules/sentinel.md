# Sentinel's Journal

## 2026-02-07 - Telegram Bot Authorization Bypass
**Vulnerability:** The Telegram Deployment Bot (`scripts/telegram_deploy_bot.py`) contained a "Fail Open" vulnerability where omitting the `TELEGRAM_ALLOWED_USER_IDS` environment variable resulted in granting access to *all* Telegram users instead of *none*.
**Learning:** Security controls must default to deny (Fail Closed). Implicitly allowing access when configuration is missing creates silent vulnerabilities that are hard to detect until exploited.
**Prevention:** Ensure all authorization checks explicitly return `False` or throw an exception if the access control list is empty or undefined. Never default to `True` in security-critical paths.

## 2026-02-11 - Web Dashboard Error Leakage
**Vulnerability:** The web dashboard (`scripts/web_dashboard.py`) returned raw exception messages to the client on error, potentially exposing sensitive system paths or configuration details.
**Learning:** Detailed error messages intended for developers can become information disclosure vectors when exposed to end-users.
**Prevention:** Implement generic error responses (e.g., "Internal Server Error") for client-facing endpoints while logging detailed stack traces securely on the server side.
