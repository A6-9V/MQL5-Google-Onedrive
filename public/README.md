# Vercel Deployment - Quick Start

This directory contains the static website that will be deployed to Vercel.

## What Gets Deployed

- `index.html` - Main documentation landing page
- `404.html` - Custom error page

## Deployment Options

### 1. Automatic Deployment (Recommended)

Once you connect this repository to Vercel:
- Every push to `main` automatically deploys to production
- Every pull request gets a preview deployment
- No manual intervention needed

### 2. Manual Deployment

Using Vercel CLI:

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy (from repository root)
vercel

# Deploy to production
vercel --prod
```

## How It Works

1. Vercel reads `vercel.json` in the repository root
2. It serves files from this `public/` directory
3. The site is deployed to Vercel's global CDN
4. You get a URL like: `https://mql5-google-onedrive-docs.vercel.app`

## Customization

To customize the site:
1. Edit `index.html` for the main page
2. Edit `404.html` for the error page
3. Commit and push changes
4. Vercel automatically redeploys

## Full Documentation

See [../docs/Vercel_CLI_setup.md](../docs/Vercel_CLI_setup.md) for complete setup instructions.
