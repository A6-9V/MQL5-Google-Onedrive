# VPS Setup and Management Guide

## Current VPS Status

**Account**: 411534497  
**Server**: Exness-MT5Real8  
**VPS Location**: Singapore 09  
**Subscription ID**: 6773048  
**Plan**: 1 month ($15.00)  
**Auto-renewal**: Enabled  
**Status**: ⚠️ **STOPPED** (needs to be started)

## VPS Status: STOPPED

### What This Means
- Your VPS is currently **not running**
- Expert Advisors (EAs) will **NOT execute** while VPS is stopped
- You need to **start the VPS** for 24/7 trading

### How to Start VPS

1. **In MetaTrader 5:**
   - Open the VPS window (Tools → VPS or press Ctrl+Shift+V)
   - Click the **"Start"** button
   - Wait 1-2 minutes for initialization

2. **Verify Status:**
   - Status should change from "stopped" (red) to "running" (green)
   - Check connection indicator in MT5

3. **Check EA Status:**
   - Open Navigator → Expert Advisors
   - Verify your EA shows as attached to chart
   - Check Expert tab for EA activity logs

## Migration Settings

### Current Status
- **Last migration**: Not migrated yet
- **Migration option**: "Migrate all: account, signal, charts, experts, indicators and settings"

### When to Migrate

**Migrate if:**
- ✅ First time setting up VPS
- ✅ Want to copy all settings from local MT5
- ✅ Need to transfer EA configurations
- ✅ Want charts and indicators synced

**Don't migrate if:**
- ❌ Already have settings on VPS
- ❌ Want to keep VPS settings separate
- ❌ Only need EA to run (can attach manually)

### How to Migrate

1. **Select Migration Option:**
   - Choose "Migrate all" (already selected in your screenshot)
   - OR select specific items to migrate

2. **Start Migration:**
   - Click "Migrate" or "Start Migration" button
   - Wait for process to complete (5-10 minutes)

3. **Verify Migration:**
   - Check that EA appears in VPS MT5
   - Verify charts and indicators are present
   - Confirm account settings are correct

## VPS Benefits

### Why Use VPS?

1. **24/7 Trading**
   - EA runs continuously even when your PC is off
   - No internet disconnection issues
   - Stable connection to broker

2. **Low Latency**
   - VPS located near broker servers
   - Faster order execution
   - Reduced slippage

3. **Reliability**
   - No power outages affecting trading
   - No computer crashes stopping EA
   - Professional infrastructure

## Troubleshooting

### VPS Won't Start

1. **Check Subscription:**
   - Verify subscription is active
   - Check payment status
   - Ensure auto-renewal is enabled

2. **Check Account:**
   - Verify account 411534497 is correct
   - Confirm server: Exness-MT5Real8
   - Check account balance

3. **Contact Support:**
   - If VPS won't start, contact MetaQuotes support
   - Provide Subscription ID: 6773048

### EA Not Running on VPS

1. **Verify VPS Status:**
   - Must be "Running" (green), not "Stopped" (red)

2. **Check EA Attachment:**
   - EA must be attached to chart on VPS
   - AutoTrading must be enabled
   - Check Expert tab for errors

3. **Verify Settings:**
   - EA parameters are correct
   - Magic number matches
   - Trading is enabled in EA

### Connection Issues

1. **Check Internet:**
   - VPS has stable internet connection
   - Broker server is accessible

2. **Verify Account:**
   - Account credentials are correct
   - Server name matches: Exness-MT5Real8

## Best Practices

### Daily Checks

1. **Morning:**
   - Verify VPS status is "Running"
   - Check EA logs for overnight activity
   - Review any open positions

2. **Evening:**
   - Review daily trading statistics
   - Check for any errors in logs
   - Verify EA is still running

### Weekly Maintenance

1. **Review Performance:**
   - Check EA performance metrics
   - Review win/loss ratio
   - Analyze risk management

2. **Update Settings:**
   - Adjust parameters if needed
   - Update risk management limits
   - Review daily profit/loss limits

### Monthly Tasks

1. **Subscription:**
   - Verify auto-renewal is working
   - Check payment method
   - Review subscription plan

2. **Optimization:**
   - Review EA performance
   - Consider parameter optimization
   - Update EA if new version available

## Current Configuration

```
Account: 411534497
Server: Exness-MT5Real8
VPS Location: Singapore 09
Subscription ID: 6773048
Plan: 1 month ($15.00)
Auto-renewal: ✅ Enabled
Status: ⚠️ STOPPED (needs to be started)
Balance: $0.00 USD
```

## Quick Start Checklist

- [ ] Start VPS (click "Start" button)
- [ ] Wait for status to change to "Running"
- [ ] Verify connection to broker
- [ ] Check EA is attached to chart
- [ ] Enable AutoTrading
- [ ] Verify EA is executing trades
- [ ] Monitor first few trades
- [ ] Check logs for any errors

## Support Resources

- **MetaQuotes VPS Support**: https://www.mql5.com/en/vps
- **Exness Support**: https://help.exness.com
- **VPS Documentation**: Check MetaTrader 5 Help (F1)

## Notes

- VPS subscription auto-renews monthly
- Balance shown ($0.00) is VPS account balance, not trading account
- Migration can be done anytime, not just on first setup
- EA will only run when VPS status is "Running"
