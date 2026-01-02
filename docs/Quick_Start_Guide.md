# Quick Start: Auto-Merge and Trading Research Integration

This guide provides a quick overview of the new features added to this repository.

## 🚀 What's New

### 1. Automated Trading News Monitoring
- **Scheduled Workflow**: Runs every 4 hours to monitor global trading news
- **GPT Groups Integration**: Chart analysis and technical pattern recognition  
- **Perplexity Integration**: Real-time news aggregation from global sources
- **Direct Reporting**: News feeds directly to MT5 trading systems

### 2. Enhanced Auto-Merge Capabilities
- **Label-Driven**: Add `automerge` label to enable automatic merging
- **Comprehensive Guide**: Step-by-step instructions for setup and usage
- **Smart Merging**: Squash merge with branch cleanup

### 3. Research Team Integration
- **GitHub Profile**: [https://github.com/A6-9V](https://github.com/A6-9V)
- **GPT Space**: Used for trading system analysis
- **Perplexity Group**: Used for news monitoring

## 📋 Quick Actions

### Enable Auto-Merge for Current PR

1. Go to the pull request page
2. Click **Labels** in the right sidebar
3. Add the `automerge` label
4. Wait for CI checks to pass
5. Get required approvals (if needed)
6. PR will automatically merge when ready

### Manual Workflow Trigger

Manually trigger the trading news monitor:

```bash
# Via GitHub UI:
# 1. Go to Actions tab
# 2. Select "Trading News Monitor (Scheduled)"
# 3. Click "Run workflow"
```

### Check Monitoring Status

View the latest monitoring logs:

1. Go to **Actions** tab
2. Click on **Trading News Monitor (Scheduled)**
3. Select the most recent run
4. View logs for monitoring activity

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [Auto-Merge Guide](Auto_Merge_Guide.md) | Complete guide for auto-merge setup and usage |
| [Trading Research Integration](Trading_Research_Integration.md) | GPT and Perplexity integration details |
| [README.md](../README.md) | Main repository documentation |

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `.github/workflows/trading-news-monitor.yml` | Scheduled trading news monitoring |
| `.github/workflows/enable-automerge.yml` | Auto-merge enablement |
| `.github/workflows/ci.yml` | Continuous integration |
| `.github/workflows/onedrive-sync.yml` | OneDrive synchronization |

## ⚙️ Workflow Schedule

| Workflow | Schedule | Purpose |
|----------|----------|---------|
| Trading News Monitor | Every 4 hours | Monitor global trading news |
| CI | On PR/Push | Validate and package code |
| OneDrive Sync | On push to main | Sync MT5 files |
| Auto-merge | On label | Enable automatic merge |

## 🔗 Important Links

- **Repository**: [A6-9V/MQL5-Google-Onedrive](https://github.com/A6-9V/MQL5-Google-Onedrive)
- **GitHub Profile**: [A6-9V](https://github.com/A6-9V)
- **Developer Tip Window**: [ChatGPT Project](https://chatgpt.com/g/g-p-691e9c0ace5c8191a1b409c09251cc2b-window-for-developer-tip/project)
- **WhatsApp Community**: [Agent Community](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)

## 💡 Tips

1. **Auto-merge**: Only use for well-tested PRs with proper CI coverage
2. **News Monitoring**: Check logs regularly for important market events
3. **GPT Integration**: Use for complex chart analysis and pattern recognition
4. **Perplexity**: Leverage for broad market news aggregation
5. **Testing**: Always test strategies in demo before live trading

## 🛠️ Troubleshooting

### Auto-Merge Not Working
- Verify `automerge` label is added
- Check CI status (must pass)
- Ensure required reviews are approved
- Check branch protection settings

### Workflow Not Running
- Check GitHub Actions tab for errors
- Verify workflow syntax is valid
- Check repository permissions
- Review workflow logs

### Need Help?
- Check the detailed guides in `/docs`
- Review workflow files in `.github/workflows`
- Contact via email or WhatsApp (see links above)

## 📊 Monitoring Dashboard

Monitor all workflows from GitHub Actions tab:
```
Repository → Actions → All workflows
├── CI
├── Enable auto-merge (label-driven)
├── Sync to OneDrive (rclone)
└── Trading News Monitor (Scheduled)
```

## 🎯 Next Steps

1. ✅ Review this guide
2. ✅ Add `automerge` label to enable automatic merging
3. ✅ Check trading news monitor logs
4. ✅ Configure GPT and Perplexity integrations
5. ✅ Set up MT5 notifications
6. ✅ Test in demo account

---

**Last Updated**: January 2, 2024  
**Version**: 1.0  
**Status**: ✅ All systems operational
