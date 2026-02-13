# Vercel CLI Setup Guide

## What is Vercel?

Vercel is a cloud platform for deploying and hosting modern web applications and static sites. It offers:

- **Free Tier**: Perfect for personal projects, documentation sites, and open source
- **Automatic Deployments**: Every push triggers a deployment
- **Preview Deployments**: Each PR gets its own preview URL
- **Global CDN**: Fast content delivery worldwide
- **Custom Domains**: Free SSL/HTTPS for your domains
- **Zero Configuration**: Deploy with minimal setup

## Free Tier Benefits

The Vercel Hobby (Free) plan includes:
- ✅ Unlimited deployments
- ✅ 100GB bandwidth per month
- ✅ Automatic HTTPS/SSL
- ✅ Preview deployments for PRs
- ✅ Custom domains
- ✅ Serverless functions (100 hours/month)
- ✅ Edge network (global CDN)

## Setting Up Vercel for This Repository

### Option 1: Vercel Dashboard (Recommended for Beginners)

#### Step 1: Create Vercel Account

1. Go to [vercel.com](https://vercel.com)
2. Click **"Sign Up"**
3. Choose **"Continue with GitHub"**
4. Authorize Vercel to access your GitHub account

#### Step 2: Import Repository

1. From the Vercel dashboard, click **"Add New Project"**
2. Click **"Import Git Repository"**
3. Find and select **"A6-9V/MQL5-Google-Onedrive"**
4. Click **"Import"**

#### Step 3: Configure Project

Vercel will auto-detect the configuration from `vercel.json`:

- **Framework Preset**: Other (static site)
- **Root Directory**: `./`
- **Build Command**: (none needed)
- **Output Directory**: `public`

Click **"Deploy"** and wait for deployment to complete.

#### Step 4: Get Your Live URL

After deployment completes:
- You'll get a URL like: `https://mql5-google-onedrive-docs.vercel.app`
- Every push to `main` will automatically deploy
- Every PR will get a unique preview URL

### Option 2: Vercel CLI (For Advanced Users)

#### Install Vercel CLI

```bash
npm install -g vercel
```

Or with yarn:

```bash
yarn global add vercel
```

#### Login to Vercel

```bash
vercel login
```

This will open a browser to authenticate with GitHub.

#### Deploy from Local Machine

```bash
# Navigate to repository
cd /path/to/MQL5-Google-Onedrive

# Deploy to Vercel
vercel

# Follow the prompts:
# - Set up and deploy? Y
# - Which scope? (select your account)
# - Link to existing project? N
# - What's your project's name? mql5-google-onedrive-docs
# - In which directory is your code located? ./
```

#### Deploy to Production

```bash
vercel --prod
```

### Option 3: GitHub Actions (Automated CI/CD)

If you want more control over deployments, you can use GitHub Actions.

#### Step 1: Get Vercel Token

1. Go to [vercel.com/account/tokens](https://vercel.com/account/tokens)
2. Create a new token
3. Copy the token

#### Step 2: Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings → Secrets and variables → Actions**
3. Add these secrets:
   - `VERCEL_TOKEN`: Your Vercel token
   - `VERCEL_ORG_ID`: Your Vercel organization ID
   - `VERCEL_PROJECT_ID`: Your Vercel project ID

To find your Org ID and Project ID:

```bash
# Install Vercel CLI
npm install -g vercel

# Link your project
vercel link

# This creates .vercel/project.json with the IDs
cat .vercel/project.json
```

#### Step 3: Create GitHub Workflow

Create `.github/workflows/vercel-deploy.yml`:

```yaml
name: Deploy to Vercel

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Vercel (Production)
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
      
      - name: Deploy to Vercel (Preview)
        if: github.event_name == 'pull_request'
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
```

## Configuration Files

### vercel.json

The repository includes a `vercel.json` configuration file:

```json
{
  "version": 2,
  "name": "mql5-google-onedrive-docs",
  "outputDirectory": "public",
  "public": true
}
```

This tells Vercel:
- Use the `public/` directory for static files
- Enable public access
- Use configuration version 2

### public/index.html

The main landing page is located at `public/index.html`. This is the entry point for your documentation site.

## Custom Domain Setup (Optional)

### Step 1: Add Domain in Vercel

1. Go to your project in Vercel
2. Click **"Settings"** → **"Domains"**
3. Add your custom domain (e.g., `docs.yourdomain.com`)

### Step 2: Configure DNS

Add one of these DNS records:

**Option A: CNAME (recommended for subdomains)**
```
Type: CNAME
Name: docs
Value: cname.vercel-dns.com
```

**Option B: A Record (for root domains)**
```
Type: A
Name: @
Value: 76.76.21.21
```

### Step 3: Wait for Verification

Vercel will automatically verify your domain and issue an SSL certificate.

## Environment Variables

If your project needs environment variables:

1. Go to **Project Settings → Environment Variables**
2. Add variables for:
   - **Production**: Used in production deployments
   - **Preview**: Used in PR previews
   - **Development**: Used locally with `vercel dev`

## Vercel Features for This Project

### Automatic Deployments

- **Main Branch**: Every push to `main` deploys to production
- **Pull Requests**: Each PR gets a unique preview URL
- **Branches**: Each branch can have its own deployment

### Preview Comments

Vercel automatically comments on PRs with:
- Preview URL
- Deployment status
- Build logs

### Analytics (Free)

Enable Web Analytics in project settings:
- Page views
- Top pages
- Referrers
- No cookies required (privacy-friendly)

## Monitoring & Logs

### View Deployment Logs

1. Go to your project dashboard
2. Click on a deployment
3. View build logs and runtime logs

### Check Deployment Status

```bash
vercel ls
```

### View Logs in Real-Time

```bash
vercel logs [deployment-url]
```

## Common Commands

```bash
# Deploy to preview
vercel

# Deploy to production
vercel --prod

# List deployments
vercel ls

# View project info
vercel inspect

# Remove deployment
vercel rm [deployment-url]

# Open project in browser
vercel open

# Run locally
vercel dev
```

## Troubleshooting

### Deployment Failed

Check build logs in Vercel dashboard or run:

```bash
vercel logs
```

### Wrong Directory Deployed

Ensure `vercel.json` has correct `outputDirectory`:

```json
{
  "outputDirectory": "public"
}
```

### Domain Not Verified

1. Check DNS propagation: [whatsmydns.net](https://www.whatsmydns.net)
2. Wait up to 48 hours for DNS changes
3. Try removing and re-adding the domain

### Build Command Issues

For static sites, you typically don't need a build command. If specified, ensure it's correct:

```json
{
  "buildCommand": "npm run build"
}
```

## Best Practices

1. **Keep vercel.json Simple**: Only include what you need
2. **Use Environment Variables**: Don't commit secrets
3. **Enable Branch Deployments**: Test changes before merging
4. **Set Up Custom Domain**: Professional appearance
5. **Monitor Analytics**: Understand your traffic
6. **Review Preview Deployments**: Catch issues early

## Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Vercel CLI Reference](https://vercel.com/docs/cli)
- [vercel.json Configuration](https://vercel.com/docs/project-configuration)
- [GitHub Integration](https://vercel.com/docs/git/vercel-for-github)

## Support

For Vercel-specific issues:
- [Vercel Community](https://github.com/vercel/vercel/discussions)
- [Vercel Support](https://vercel.com/support)

For project-specific issues:
- GitHub Issues: [A6-9V/MQL5-Google-Onedrive/issues](https://github.com/A6-9V/MQL5-Google-Onedrive/issues)
- WhatsApp Community: [Join here](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)

---

**Ready to Deploy?** Follow Option 1 above to get started in minutes! 🚀
