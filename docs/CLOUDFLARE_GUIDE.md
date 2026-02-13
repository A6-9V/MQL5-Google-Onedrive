# Cloudflare Management & Tunnel Guide

This guide explains how to manage your Cloudflare settings and set up a secure tunnel for `lengkundee01.org`.
## Nameservers

If you are using Cloudflare to manage your DNS, ensure your domain nameservers are set to:
- `daisy.ns.cloudflare.com`
- `rocco.ns.cloudflare.com`


## Prerequisite: API Token

1.  Log in to the [Cloudflare Dashboard](https://dash.cloudflare.com/).
2.  Go to **My Profile** -> **API Tokens**.
3.  Create a token with the following permissions:
    *   **Zone - Zone Settings - Edit** (for changing security levels)
    *   **Zone - DNS - Edit** (for tunnel DNS routing)
    *   **Account - Cloudflare Tunnel - Edit** (for managing tunnels)
4.  Copy the token.
5.  Edit `config/vault.json` and paste your token:
    ```json
    "api_token": "YOUR_ACTUAL_TOKEN_HERE"
    ```

## Managing Security Level

You can check or change the "Under Attack Mode" or security level using the provided script.

**Check Status:**
```bash
python scripts/manage_cloudflare.py --status
```

**Set Security Level:**
Available levels: `off`, `essentially_off`, `low`, `medium`, `high`, `under_attack`.

```bash
# Enable Under Attack Mode
python scripts/manage_cloudflare.py --set under_attack

# Set to Medium
python scripts/manage_cloudflare.py --set medium
```

## Setting up Cloudflare Tunnel (1.1.1.1 / WARP)

To securely expose your local service or connect to your private network:

1.  **Install `cloudflared`**:
    ```bash
    sudo ./scripts/setup_cloudflare_tunnel.sh
    ```

2.  **Login**:
    ```bash
    cloudflared tunnel login
    ```

3.  **Create a Tunnel**:
    ```bash
    cloudflared tunnel create genx_tunnel
    ```
    *Copy the Tunnel ID provided in the output.*

4.  **Configure Tunnel**:
    Create a file named `config.yml` (or `~/.cloudflared/config.yml`):
    ```yaml
    tunnel: <Tunnel-UUID>
    credentials-file: /root/.cloudflared/<Tunnel-UUID>.json

    ingress:
      - hostname: lengkundee01.org
        service: http://localhost:8080
      - service: http_status:404
    ```

5.  **Route DNS**:
    ```bash
    cloudflared tunnel route dns genx_tunnel lengkundee01.org
    ```

6.  **Run the Tunnel**:
    ```bash
    cloudflared tunnel run genx_tunnel
    ```

## 1.1.1.1 WARP Connection

To use the 1.1.1.1 WARP client to access private resources:
1.  Ensure "Zero Trust" is configured in your Cloudflare Dashboard.
2.  Enroll your device in your Zero Trust organization.
3.  Connect via the WARP client.

## DNS Configuration
For a detailed guide on how to configure your DNS records for `lengkundee01.org`, including cleaning up conflicts and pointing to various hosting methods, see [DNS Configuration Recommendation](DNS_CONFIG_RECOMMENDATION.md).
