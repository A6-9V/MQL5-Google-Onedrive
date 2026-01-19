# Live Trading Setup Guide for Exness MT5

This guide walks you through deploying and running the SMC Trend Breakout EA on your **LIVE Exness trading account**.

## ⚠️ CRITICAL SAFETY WARNINGS

**Before proceeding, understand these risks:**

1. **Trading involves real money** - You can lose your investment
2. **Start small** - Use minimal position sizes initially
3. **Test first** - Always test on DEMO before going live
4. **Monitor closely** - Watch the first trades carefully
5. **Use stop losses** - Never trade without risk management
6. **Risk only what you can afford to lose**

## 📋 Prerequisites

- [x] Exness MT5 Desktop application installed
- [x] Exness LIVE account created and funded
- [x] Repository files downloaded locally
- [x] You understand the risks of automated trading

## 🚀 Deployment Steps

### Step 1: Deploy Files to MT5

Run the deployment script:

```powershell
cd C:\Users\USER\Documents\repos\MQL5-Google-Onedrive
.\scripts\deploy_exness_live.ps1
```

The script will:
- Auto-detect your MT5 installation
- Copy indicators and EAs to the correct folders
- Provide next-step instructions

**Alternative (manual):**
1. Open Exness MT5
2. Go to **File → Open Data Folder**
3. Copy `mt5/MQL5/Indicators/*.mq5` to `MQL5/Indicators/`
4. Copy `mt5/MQL5/Experts/*.mq5` to `MQL5/Experts/`

### Step 2: Compile Files in MetaEditor

1. In MT5, press **F4** (or go to **Tools → MetaQuotes Language Editor**)
2. Navigate to the copied files in MetaEditor
3. Select each `.mq5` file:
   - `Indicators/SMC_TrendBreakout_MTF.mq5`
   - `Experts/SMC_TrendBreakout_MTF_EA.mq5`
4. Press **F7** (or right-click → **Compile**)
5. Check the **Toolbox** window for any compilation errors
6. Fix any errors before proceeding

### Step 3: Refresh Navigator

1. Back in MT5, open **Navigator** panel (press **Ctrl+N** if not visible)
2. Right-click in Navigator → **Refresh**
3. Verify files appear:
   - **Indicators → Custom → SMC_TrendBreakout_MTF**
   - **Expert Advisors → SMC_TrendBreakout_MTF_EA**

### Step 4: Log In to LIVE Account

1. In MT5, click **File → Login to Trade Account**
2. Enter your Exness LIVE account credentials:
   - **Login**: Your live account number
   - **Password**: Your trading password
   - **Server**: Exness-Live (or your specific server)
3. Click **Login**

**Verify you're on LIVE:**
- Check account number (should match your live account)
- Account type should show "Real" or "Live"
- Balance should reflect your funded amount

### Step 5: Configure EA Parameters (CRITICAL!)

Before attaching the EA to a chart:

1. Open a chart (e.g., EURUSD, M15 or H1)
2. Drag **SMC_TrendBreakout_MTF_EA** from Navigator onto the chart
3. In the EA settings dialog, configure:

#### Essential Settings:

**Risk Management:**
- **RiskPercent**: `1.0` to `2.0` (start conservative!)
  - This is % of account equity at risk per trade
  - Example: 1.0% means risking $10 on a $1000 account per trade
  
- **SLMode**: `SL_ATR` or `SL_SWING` (recommended)
  - `SL_ATR`: Stop loss based on ATR (Average True Range)
  - `SL_SWING`: Stop loss beyond last swing point
  
- **TPMode**: `TP_RR` (recommended)
  - Take profit based on Risk:Reward ratio
  
- **RR (Risk:Reward)**: `2.0` or `3.0`
  - Means TP = 2x or 3x the SL distance
  - Higher RR = fewer winners needed to profit

**Trading Settings:**
- **EnableTrading**: `true` ✓
- **LowerTF**: Smaller timeframe for confirmation (e.g., M5 if main is M15)
- **DonchianPeriod**: `20` (default)
- **ATR_Period**: `14` (default)

#### Recommended Conservative Settings (for first live trades):

```
RiskPercent: 1.0
SLMode: SL_ATR
ATR_SL_Mult: 2.0
TPMode: TP_RR
RR: 2.0
EnableTrading: true
```

### Step 6: Enable AutoTrading

1. Click the **AutoTrading** button in MT5 toolbar (or press **Ctrl+E**)
   - Button should turn green/highlighted when enabled
2. Verify EA is active:
   - Check that EA shows a smiley face (😊) on the chart
   - If it shows a cross (❌), check the Experts log for errors

### Step 7: Monitor First Trades

**IMPORTANT: Don't walk away immediately!**

1. Watch the chart for the first few signals
2. Monitor the **Experts** tab in Toolbox for any errors
3. Check that trades open with:
   - Stop Loss set correctly
   - Take Profit set correctly
   - Position size appropriate for your account
4. Verify trades appear in **Trade** tab

## 📊 Monitoring & Management

### Check EA Status

- **Smiley face (😊)** = EA is running correctly
- **Cross (❌)** = EA has an error (check Experts log)
- **Clock (🕐)** = EA is waiting for next bar/tick

### View EA Logs

1. Open **Toolbox** (Ctrl+T)
2. Click **Experts** tab
3. Review messages for:
   - Trade entries/exits
   - Error messages
   - Parameter changes

### Pause Trading

- Click **AutoTrading** button again (Ctrl+E) to disable
- Or remove EA from chart
- Or change `EnableTrading` to `false` in EA settings

## 🛡️ Risk Management Best Practices

### Before Live Trading:

1. **Test on DEMO first** (at least 1-2 weeks)
   - Verify EA behavior
   - Check performance
   - Understand entry/exit logic

2. **Start with minimum risk:**
   - `RiskPercent: 0.5` to `1.0`
   - Small account or separate "testing" account

3. **Use proper Stop Loss:**
   - Always enabled (SLMode: SL_ATR or SL_SWING)
   - Never disable stop loss

4. **Set realistic expectations:**
   - No EA wins 100% of trades
   - Expect drawdowns
   - Focus on long-term performance

### While Trading:

1. **Monitor daily** - Check account at least once per day
2. **Review trades** - Analyze wins and losses
3. **Adjust if needed** - But don't change too frequently
4. **Track performance** - Keep a trading journal

### Warning Signs (Stop Trading if):

- EA stops working (shows ❌)
- Multiple losing trades in a row (5+)
- Account drawdown exceeds 20%
- Unexpected position sizes
- No stop loss on trades

## 🔧 Troubleshooting

### EA Not Trading

1. Check AutoTrading is enabled (green button)
2. Verify `EnableTrading: true` in EA settings
3. Check Experts log for errors
4. Ensure chart timeframe matches EA settings

### Trades Opening Without Stop Loss

1. Check `SLMode` is not set to `SL_FIXED_POINTS` with `FixedSLPoints: 0`
2. Verify ATR or swing calculation is working
3. Check Experts log for SL calculation errors

### Position Sizes Too Large/Small

1. Adjust `RiskPercent` (lower = smaller positions)
2. Check `RiskUseEquity` setting
3. Verify account balance is correct

### Connection Issues

1. Check internet connection
2. Verify Exness server status
3. Try logging out and back in
4. Restart MT5 if needed

## 📈 Performance Tracking

Keep track of:

- Number of trades
- Win rate (%)
- Average profit/loss
- Maximum drawdown
- Risk:Reward ratio achieved
- Account equity curve

## 🆘 Emergency Actions

If something goes wrong:

1. **Disable AutoTrading immediately** (Ctrl+E)
2. **Remove EA from chart**
3. **Close any unwanted positions manually** (if safe to do so)
4. **Check Experts log** for errors
5. **Review EA settings** for incorrect parameters

## 📚 Additional Resources

- **Exness Support**: https://www.exness.com/support/
- **MT5 Documentation**: https://www.metatrader5.com/en/automated-trading
- **Repository Docs**: `docs/Exness_Deployment_Guide.md`
- **EA Source Code**: `mt5/MQL5/Experts/SMC_TrendBreakout_MTF_EA.mq5`

## ✅ Checklist Before Going Live

- [ ] Tested on DEMO account for at least 1 week
- [ ] Understand how the EA works
- [ ] Set conservative risk parameters (RiskPercent ≤ 2%)
- [ ] Stop Loss enabled (SLMode configured)
- [ ] Take Profit configured
- [ ] Account has sufficient margin for trading
- [ ] Ready to monitor first trades
- [ ] Understand you can lose money
- [ ] Have emergency stop plan

---

**Remember: Automated trading carries risk. Only trade with money you can afford to lose. Past performance does not guarantee future results.**
