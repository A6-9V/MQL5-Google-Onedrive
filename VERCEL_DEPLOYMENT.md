# Vercel Deployment Instructions

## 🎯 Quick Summary

This repository is now configured for Vercel deployment with:
- ✅ Static documentation site
- ✅ Free tier (unlimited deployments)
- ✅ Automatic deployments from GitHub
- ✅ Preview deployments for PRs
- ✅ Custom 404 page
- ✅ Security headers

## 🚀 Getting Started (3 Steps)

### Step 1: Create Vercel Account
1. Go to https://vercel.com
2. Click "Sign Up"
3. Choose "Continue with GitHub"

### Step 2: Import Repository
1. In Vercel dashboard, click "Add New Project"
2. Select "Import Git Repository"
3. Find and select `A6-9V/MQL5-Google-Onedrive`
4. Click "Import"

### Step 3: Deploy
1. Vercel auto-detects the configuration
2. Click "Deploy"
3. Wait 30-60 seconds
4. Your site is live! 🎉

## 📋 What Was Set Up

### Files Created
- `vercel.json` - Main configuration file
- `public/index.html` - Beautiful documentation landing page
- `public/404.html` - Custom error page
- `.vercelignore` - Files to exclude from deployment
- `docs/Vercel_CLI_setup.md` - Complete setup guide

### Configuration
The `vercel.json` includes:
- Output directory: `public/`
- Clean URLs (no .html extensions)
- Security headers
- Git deployment enabled
- Redirects configured

## 🌐 After Deployment

You'll get a URL like:
```
https://mql5-google-onedrive-docs.vercel.app
```

### Automatic Updates
- Push to `main` → Production deployment
- Open PR → Preview deployment
- Each commit → New preview URL

## 💡 Optional: Custom Domain

Want your own domain? (e.g., `docs.yourdomain.com`)

1. In Vercel, go to Project Settings → Domains
2. Add your domain
3. Configure DNS:
   ```
   Type: CNAME
   Name: docs (or @)
   Value: cname.vercel-dns.com
   ```
4. Wait for SSL certificate (automatic)

## 📚 Documentation

For detailed instructions, see:
- [docs/Vercel_CLI_setup.md](docs/Vercel_CLI_setup.md) - Full setup guide
- [public/README.md](public/README.md) - Deployment directory info

## 🔧 Using Vercel CLI (Optional)

Install CLI:
```bash
npm install -g vercel
```

Deploy from command line:
```bash
vercel          # Preview deployment
vercel --prod   # Production deployment
```

## 🎨 Customizing the Site

1. Edit files in `public/` directory
2. Commit and push changes
3. Vercel automatically redeploys

## 💰 Free Tier Includes

- ✅ Unlimited deployments
- ✅ 100GB bandwidth/month
- ✅ Automatic HTTPS
- ✅ Global CDN
- ✅ Preview deployments
- ✅ Custom domains

## ❓ Troubleshooting

**Deployment failed?**
- Check build logs in Vercel dashboard
- Ensure `public/` directory exists
- Verify `vercel.json` is valid JSON

**Site not updating?**
- Check deployment status in Vercel
- Verify commits are pushed to GitHub
- Clear browser cache

## 📞 Support

- **Vercel Docs**: https://vercel.com/docs
- **Project Issues**: https://github.com/A6-9V/MQL5-Google-Onedrive/issues
- **WhatsApp Community**: https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF

---

**Ready?** Follow the 3 steps above to deploy in minutes! 🚀
