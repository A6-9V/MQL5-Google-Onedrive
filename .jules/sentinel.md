# Sentinel's Journal

## 2026-02-07 - Telegram Bot Authorization Bypass
**Vulnerability:** The Telegram Deployment Bot (`scripts/telegram_deploy_bot.py`) contained a "Fail Open" vulnerability where omitting the `TELEGRAM_ALLOWED_USER_IDS` environment variable resulted in granting access to *all* Telegram users instead of *none*.
**Learning:** Security controls must default to deny (Fail Closed). Implicitly allowing access when configuration is missing creates silent vulnerabilities that are hard to detect until exploited.
**Prevention:** Ensure all authorization checks explicitly return `False` or throw an exception if the access control list is empty or undefined. Never default to `True` in security-critical paths.

## 2026-02-13 - [Documentation] Cloudflare Nameservers and Domain Unification
- Updated Cloudflare nameservers to daisy.ns.cloudflare.com and rocco.ns.cloudflare.com.
- Unified domain name to lengkundee01.org across CNAME and PWA documentation.
