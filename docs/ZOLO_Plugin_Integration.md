# ZOLO-A6-9V-NUNA- Plugin Integration

## Overview

This repository is integrated with the ZOLO-A6-9V-NUNA- plugin system, providing enhanced functionality and external integrations for the MQL5 trading system.

## Integration Points

### 1. GitHub Pages Repository
- **Repository**: https://github.com/Mouy-leng/-LengKundee-mql5.github.io.git
- **Purpose**: Hosts the web interface and documentation for the trading system
- **Integration**: Pull, push, and merge commits are synchronized with this repository

### 2. Soloist.ai Endpoint
- **Endpoint**: https://soloist.ai/a6-9v
- **Purpose**: Provides real-time signal notifications and integration with the ZOLO platform
- **Usage**: WebRequest calls from the Expert Advisor are sent to this endpoint

## Setup Instructions

### For Developers

1. **Clone both repositories**:
   ```bash
   git clone https://github.com/A6-9V/MQL5-Google-Onedrive.git
   git clone https://github.com/Mouy-leng/-LengKundee-mql5.github.io.git
   ```

2. **Configure the integration**:
   - Ensure the EA parameter `WebRequestURL` is set to `https://soloist.ai/a6-9v`
   - Enable `EnableWebRequest` in the EA settings when needed

### For Traders

1. **Add the URL to MT5's allowed list**:
   - Open **Exness MetaTrader 5 Desktop Application** (Web Terminal is not supported)
   - Go to **Tools → Options → Expert Advisors**
   - Check "Allow WebRequest for listed URL"
   - Add: `https://soloist.ai/a6-9v`

2. **Enable the integration in EA settings**:
   - Attach the EA to a chart
   - Set `EnableWebRequest = true`
   - The EA will now send signal notifications to the ZOLO platform

## Signal Format

When a trading signal is generated, the EA sends a JSON payload to the endpoint:

```json
{
  "event": "signal",
  "message": "Signal details and parameters"
}
```

## Security Considerations

- Always verify the endpoint URL before enabling web requests
- The URL must be explicitly allowed in MT5 settings for security
- Web requests have a 5-second timeout
- Failed requests are logged but do not interrupt EA operation

## Support

For issues related to the ZOLO plugin integration:
- Email: Lengkundee01.org@domain.com
- WhatsApp: [Agent community](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)
