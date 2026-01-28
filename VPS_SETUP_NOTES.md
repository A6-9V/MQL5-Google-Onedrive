# VPS Setup Notes - MT5 Trading

## VPS Connection Status

**Date**: 2026-01-19 06:57:01
**Status**: ✅ Connected
**Location**: Singapore 09
**Host ID**: 6773048
**Account**: 411534497 (Exness-MT5Real8)

## What is VPS for MT5?

Virtual Private Server (VPS) allows your MT5 terminal to run 24/7 on a remote server, ensuring:

- **24/7 Trading**: EA runs continuously even when your PC is off
- **Low Latency**: Fast connection to Exness trading servers
- **Stability**: Reliable internet connection without interruptions
- **Performance**: Dedicated resources for optimal EA execution

## VPS Benefits for Live Trading

### ✅ Advantages

1. **Continuous Operation**
   - EA never stops trading (unless you disable it)
   - No need to keep your computer running 24/7
   - Trades execute even when you're asleep or away

2. **Reduced Latency**
   - VPS is typically closer to broker servers
   - Faster trade execution
   - Lower slippage

3. **Reliability**
   - No power outages affecting your PC
   - Stable internet connection
   - No computer crashes interrupting trading

4. **Convenience**
   - Access MT5 from anywhere
   - Manage trades remotely
   - Monitor performance 24/7

### ⚠️ Important Considerations

1. **VPS Costs**
   - Monthly subscription fees (usually $10-30/month)
   - Check your VPS provider's pricing

2. **Remote Access**
   - You'll need to connect to VPS to manage EA settings
   - Use MT5's remote access or VNC/RDP

3. **Monitoring**
   - Set up alerts/notifications for trade activity
   - Regular check-ins to verify EA is running
   - Monitor account balance and performance

## Using VPS with Your EA

### Current Setup

Your EA is now deployed to:
- **Local MT5**: `C:\Users\USER\AppData\Roaming\MetaQuotes\Terminal\11FA83D175E503C18ECB4DB736B2214D`
- **VPS**: Connected (Singapore 09)

### Recommendations

1. **Verify EA is Running on VPS**
   - Connect to your VPS MT5 instance
   - Check that EA is attached to charts
   - Verify AutoTrading is enabled

2. **Monitor Performance**
   - Check trades are executing properly
   - Verify Stop Loss and Take Profit are set
   - Monitor Experts log for errors

3. **Set Up Alerts**
   - Configure Telegram notifications (if using bot)
   - Set up email alerts for trade execution
   - Monitor account balance changes

4. **Regular Maintenance**
   - Weekly check-ins to review performance
   - Update EA parameters if needed
   - Check for any error messages

## VPS Management Tips

### Accessing Your VPS MT5

1. **Via MT5 Remote Access** (if enabled)
   - Connect from your local MT5
   - View trades and charts remotely

2. **Via VNC/RDP** (VPS provider)
   - Log into VPS desktop
   - Access MT5 directly on VPS

3. **Via Mobile MT5 App**
   - Monitor trades on your phone
   - Check account status
   - View charts (limited functionality)

### Best Practices

1. **Security**
   - Use strong passwords for VPS access
   - Enable 2FA if available
   - Keep VPS software updated

2. **Backup Settings**
   - Save EA parameter presets
   - Document your trading configuration
   - Keep local copy of MT5 settings

3. **Monitoring**
   - Set up regular alerts
   - Check logs daily (at minimum)
   - Review performance weekly

## Troubleshooting VPS Issues

### EA Not Trading on VPS

1. Check AutoTrading is enabled
2. Verify EA is attached to chart
3. Check Experts log for errors
4. Ensure account has sufficient margin
5. Verify internet connection on VPS

### Connection Issues

1. Check VPS status with provider
2. Verify MT5 connection to broker
3. Check account credentials
4. Restart MT5 on VPS if needed

### Performance Issues

1. Check VPS resource usage (CPU/RAM)
2. Close unnecessary programs on VPS
3. Consider upgrading VPS plan if needed
4. Optimize EA settings if using too many resources

## Current Configuration

- **Account**: 411534497
- **Server**: Exness-MT5Real8
- **VPS Location**: Singapore 09
- **VPS Host ID**: 6773048
- **Status**: ✅ Connected and Active

## Next Steps

1. ✅ Verify EA is running on VPS
2. ✅ Check first trades are executing correctly
3. ✅ Set up monitoring/alert system
4. ✅ Schedule regular performance reviews

---

**Note**: Keep this document updated with any VPS configuration changes or issues encountered.
