# DNS Configuration Recommendation for lengkundee01.org

Based on the DNS zone export provided, here is the recommended configuration to clean up conflicts and point the domain to your GenX Trading services.

## Identified Issues
1.  **Duplicate Name Servers**: The zone currently lists both Cloudflare and Namecheap name servers. This can cause inconsistent DNS resolution.
2.  **Parking Page Records**: Both the apex domain (`lengkundee01.org`) and the `www` subdomain are pointing to Namecheap's parking page.
3.  **Low TTLs**: TTL values of `1` are generally used for Cloudflare's "Auto" setting but can be confusing in an export.

## Recommended "Clean" Zone Configuration (Cloudflare)

If you are using Cloudflare to manage your DNS, your zone file should look like this:

```bind
;; SOA Record
lengkundee01.org    3600    IN    SOA    daisy.ns.cloudflare.com. dns.cloudflare.com. 2051944674 10000 2400 604800 3600

;; NS Records (Use ONLY Cloudflare)
lengkundee01.org.    86400    IN    NS    daisy.ns.cloudflare.com.
lengkundee01.org.    86400    IN    NS    rocco.ns.cloudflare.com.

;; MX Records (Preserved for Namecheap Email Forwarding)
lengkundee01.org.    3600    IN    MX    10 eforward3.registrar-servers.com.
lengkundee01.org.    3600    IN    MX    10 eforward2.registrar-servers.com.
lengkundee01.org.    3600    IN    MX    10 eforward1.registrar-servers.com.
lengkundee01.org.    3600    IN    MX    15 eforward4.registrar-servers.com.
lengkundee01.org.    3600    IN    MX    20 eforward5.registrar-servers.com.

;; TXT Records
lengkundee01.org.    3600    IN    TXT    "v=spf1 include:spf.efwd.registrar-servers.com ~all"

;; Subdomains
www.lengkundee01.org. 3600    IN    CNAME    lengkundee01.org.
```

## Pointing to your Service

Choose **ONE** of the following methods depending on your deployment:

### Method A: Cloudflare Tunnel (Recommended)
If you are running the project locally or in a private container, use `cloudflared`.
1. Run: `cloudflared tunnel route dns <TUNNEL_NAME> lengkundee01.org`
2. This will automatically add a CNAME record pointing to your tunnel.

### Method B: Render Hosting
If you are using the `mql5-automation` service on Render:
1. Add `lengkundee01.org` to the **Custom Domains** section in your Render Dashboard.
2. Render will provide an IP address or a CNAME (`mql5-automation.onrender.com`).
3. Add an **A Record** for `lengkundee01.org` pointing to the Render IP, OR a **CNAME** if supported by your DNS provider (Cloudflare supports CNAME Flattening for apex domains).

## Action Steps
1.  **Remove Namecheap NS Records**: In your Namecheap account dashboard, ensure that the Name Servers are set to **Cloudflare Custom DNS** only (`daisy.ns.cloudflare.com`, `rocco.ns.cloudflare.com`).
2.  **Delete Parking Records**: In the Cloudflare DNS dashboard, delete the A record pointing to `162.255.119.221` and the CNAME for `www` pointing to `parkingpage.namecheap.com`.
3.  **Apply New Service Record**: Follow either Method A or Method B above.

### Method C: GitHub Pages
If you are using GitHub Pages for the `dashboard/` content:
1. Go to your GitHub repository **Settings** -> **Pages**.
2. Under **Custom domain**, enter `lengkundee01.org` and click **Save**.
3. In Cloudflare DNS, add the following **A Records** pointing to GitHub's server IPs:
   - `185.199.108.153`
   - `185.199.109.153`
   - `185.199.110.153`
   - `185.199.111.153`
4. Ensure `www` is a **CNAME** pointing to your GitHub Pages URL (e.g., `mouy-leng.github.io`).
