# Networking and IP Troubleshooting Guide

This guide helps you understand how to handle networking issues, especially when working with private IP addresses and connecting local MetaTrader 5 (MT5) terminals to cloud services.

## 1. Understanding Your IP Address

The IP address you provided (**192.168.18.4**) is a **Private IP Address** (as defined in RFC 1918).

### What is a Private IP?
- **Scope**: Only works within your local network (home or office).
- **Visibility**: It is **not** visible from the internet.
- **Conflict**: Many people around the world use the exact same address (192.168.x.x) in their own private networks.

### Why does this matter?
If you are running a service (like a Web Bridge or Dashboard) on your local machine with IP `192.168.18.4`, an external AI server (like one running on Render or GCP) **cannot** reach it directly.

## 2. Solutions for Connecting Local to Cloud

### Option A: Cloudflare Tunnel (Recommended)
Cloudflare Tunnel creates a secure bridge between your local machine and the Cloudflare network without opening any ports on your router.

1.  **Install `cloudflared`**: Use `scripts/setup_cloudflare_tunnel.sh`.
2.  **Authenticate**: `cloudflared tunnel login`.
3.  **Create Tunnel**: `cloudflared tunnel create my-trading-bridge`.
4.  **Route DNS**: Connect it to your domain (e.g., `bridge.lengkundee01.org`).
5.  **Run**: The tunnel will securely forward traffic from the internet to your local service.

See [Cloudflare Guide](CLOUDFLARE_GUIDE.md) for detailed steps.

### Option B: 1.1.1.1 WARP / Zero Trust
Use the WARP client to join your local machine and your VPS into the same virtual private network. This allows them to talk to each other using internal IPs as if they were on the same LAN.

### Option C: DDNS and Port Forwarding (Not Recommended)
You can use Dynamic DNS and configure "Port Forwarding" on your home router.
- **Risks**: Exposes your home network to the public internet.
- **Complexity**: Requires access to your router settings and handling dynamic IP changes.

## 3. How to find your Public IP
If you need to know your public-facing IP (the one the internet sees):
- Visit: [https://ifconfig.me](https://ifconfig.me)
- Or run: `curl ifconfig.me` in your terminal.

## 4. MT5 WebRequest Configuration
When using the `SMC_TrendBreakout_MTF_EA` or `EXNESS_GenX_Trader`:
- **WebRequestURL**: Should be a **public URL** (e.g., `https://bridge.lengkundee01.org/api/signal`), not a private IP.
- **Allowed URLs**: You must add the public URL to MT5 -> Tools -> Options -> Expert Advisors -> Allow WebRequest.

## 5. Troubleshooting Checklist
- [ ] Is your MT5 "Algo Trading" button green?
- [ ] Have you added the URL to the "Allowed WebRequest" list?
- [ ] Is your local bridge/server running?
- [ ] If using a tunnel, is `cloudflared` active?
- [ ] Check MT5 **Experts** and **Journal** tabs for "Error 4060" (WebRequest not allowed) or "Error 5203" (Failed to connect).

---
*For further assistance, contact: Lengkundee01.org@domain.com*
