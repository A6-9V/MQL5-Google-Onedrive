# PWA Icons

This directory contains Progressive Web App (PWA) icons for the MQL5 Trading Automation application.

## Required Icon Sizes

The manifest.json references the following icon sizes:
- 72x72 (icon-72x72.png)
- 96x96 (icon-96x96.png)
- 128x128 (icon-128x128.png)
- 144x144 (icon-144x144.png)
- 152x152 (icon-152x152.png)
- 192x192 (icon-192x192.png) - Required for PWA
- 384x384 (icon-384x384.png)
- 512x512 (icon-512x512.png) - Required for PWA

## Generating Icons

To generate icons from a source image, you can use:

1. **Online tools:**
   - https://realfavicongenerator.net/
   - https://www.pwabuilder.com/imageGenerator

2. **Command-line tools:**
   ```bash
   # Using ImageMagick
   convert source.png -resize 192x192 icon-192x192.png
   convert source.png -resize 512x512 icon-512x512.png
   ```

3. **PWA Asset Generator:**
   ```bash
   npm install -g pwa-asset-generator
   pwa-asset-generator source.png icons/
   ```

## Icon Design Guidelines

- Use a square source image (recommended: 512x512 or larger)
- Include padding around the main icon to account for masking
- Use a transparent background or the app's theme color (#667eea)
- Ensure the icon is recognizable at small sizes
- Test on both light and dark backgrounds

## Current Status

⚠️ **Placeholder icons needed**: The manifest references these icons, but they need to be created.

For now, the application will work without icons, but users won't see a proper icon when:
- Installing the PWA
- Viewing the app in their app drawer/home screen
- Receiving push notifications

To complete the PWA setup, generate and add the required icon files to this directory.
