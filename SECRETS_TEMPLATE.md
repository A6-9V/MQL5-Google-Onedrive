# Secrets & Credentials Management

This project requires certain credentials to fully function. **Do not commit these values to the repository.**

## Environment Variables (CI/CD & Scripts)

When running deployment scripts (`scripts/deploy_docker_hub.sh`, `scripts/update_vps.sh`), use environment variables:

- `DOCKER_USERNAME`: Your Docker Hub username.
- `DOCKER_PASSWORD`: Your Docker Hub access token or password.

Example:
```bash
export DOCKER_USERNAME="your_user"
export DOCKER_PASSWORD="your_token"
./scripts/update_vps.sh
```

## MQL5 Expert Advisor Inputs

When configuring the EAs in MetaTrader 5, use the Inputs tab. Do not hardcode these in `.mq5` files.

- **GeminiApiKey**: Your Google Gemini API Key (for `SMC_TrendBreakout_MTF_EA`).
- **WebRequestURL**: The ZOLO Bridge URL.
  - Default: `https://genx-fx.com/api/signal` (Secure)
  - Ensure this URL uses `https://` to encrypt traffic.

## Windows Credential Manager

For local automation, store sensitive tokens in Windows Credential Manager if required by custom scripts.
