# Sentinel's Journal

## 2026-02-07 - Telegram Bot Authorization Bypass
**Vulnerability:** The Telegram Deployment Bot (`scripts/telegram_deploy_bot.py`) contained a "Fail Open" vulnerability where omitting the `TELEGRAM_ALLOWED_USER_IDS` environment variable resulted in granting access to *all* Telegram users instead of *none*.
**Learning:** Security controls must default to deny (Fail Closed). Implicitly allowing access when configuration is missing creates silent vulnerabilities that are hard to detect until exploited.
**Prevention:** Ensure all authorization checks explicitly return `False` or throw an exception if the access control list is empty or undefined. Never default to `True` in security-critical paths.
## 2026-02-10 - [Networking & IP Support]
- Users often provide private IP addresses (192.168.x.x) when troubleshooting connectivity issues.
- Private IPs are not routable on the public internet, requiring bridges or tunnels (like Cloudflare Tunnel) to connect local services to cloud platforms.
- Added a comprehensive Networking & IP Troubleshooting Guide and integrated local IP detection into management scripts to proactively guide users.
