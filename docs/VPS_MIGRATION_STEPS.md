# VPS Migration Steps - Account 411534497

## Current Status
- **VPS Status**: STOPPED (needs to be started first)
- **Migration Option**: "Migrate all: account, signal, charts, experts, indicators and settings"
- **Account**: 411534497
- **Server**: Exness-MT5Real8

## Step-by-Step Migration Process

### Step 1: Start the VPS
1. In the VPS window, click the **"Start"** button
2. Wait 1-2 minutes for VPS to initialize
3. Verify status changes from "stopped" (red) to "running" (green)
4. You should see connection indicators turn green

### Step 2: Initiate Migration
1. In the VPS window, ensure **"Migrate all"** is selected (already selected)
2. Click the **"Migrate"** or **"Start Migration"** button
3. A confirmation dialog may appear - click **"Yes"** or **"OK"**

### Step 3: Wait for Migration
- Migration process takes **5-10 minutes**
- Do NOT close MT5 during migration
- You'll see progress indicators
- Status will update when complete

### Step 4: Verify Migration
After migration completes, verify:

#### Account Settings
- [ ] Account 411534497 is connected
- [ ] Server: Exness-MT5Real8 is correct
- [ ] Balance is displayed correctly

#### Expert Advisors
- [ ] EA files are present in VPS
- [ ] EA can be attached to charts
- [ ] EA parameters are saved

#### Charts & Indicators
- [ ] Chart templates are migrated
- [ ] Custom indicators are present
- [ ] Chart settings are preserved

#### Settings
- [ ] Trading parameters are correct
- [ ] Risk management settings are saved
- [ ] EA configurations are intact

### Step 5: Attach EA to Chart
1. Open a chart on the VPS MT5
2. Navigate to **Navigator → Expert Advisors**
3. Drag your EA to the chart
4. Configure EA parameters:
   - Magic Number: 27893 (or your preferred)
   - Enable Trading: ✅
   - Risk Management settings
   - SL/TP settings
5. Click **"OK"** to attach

### Step 6: Enable AutoTrading
1. Click **"AutoTrading"** button in toolbar (or press F7)
2. Verify button turns green
3. Check Expert tab for EA activity
4. EA should show "smiley face" icon when running

### Step 7: Final Verification
- [ ] VPS status: **Running** (green)
- [ ] EA attached to chart
- [ ] AutoTrading enabled
- [ ] EA shows in Expert tab
- [ ] No errors in logs
- [ ] EA is ready to trade

## What Gets Migrated

With "Migrate all" selected, the following will be copied:

✅ **Account Settings**
- Account credentials
- Server configuration
- Trading parameters

✅ **Expert Advisors**
- All .ex5 files
- EA configurations
- Input parameters

✅ **Indicators**
- Custom indicators
- Indicator settings
- Applied indicators on charts

✅ **Charts**
- Chart templates
- Chart settings
- Applied timeframes
- Chart layouts

✅ **Signals**
- Signal subscriptions
- Signal settings

✅ **Settings**
- Platform settings
- Trading preferences
- Risk management parameters

## Troubleshooting

### Migration Fails
1. **Check VPS Status**: Must be "Running"
2. **Check Internet**: Stable connection required
3. **Check Account**: Verify account is accessible
4. **Retry Migration**: Close and reopen VPS window, try again

### EA Not Found After Migration
1. Check Expert Advisors folder in VPS
2. Verify EA was compiled (.ex5 file exists)
3. Re-attach EA manually if needed

### Settings Not Migrated
1. Some settings may need manual configuration
2. Check EA input parameters
3. Verify risk management settings
4. Re-configure if necessary

### Connection Issues
1. Verify VPS is running
2. Check broker server connection
3. Verify account credentials
4. Contact support if persistent

## Post-Migration Checklist

- [ ] VPS is running
- [ ] Account connected
- [ ] EA attached to chart
- [ ] AutoTrading enabled
- [ ] EA parameters configured
- [ ] Risk management set
- [ ] SL/TP settings correct
- [ ] First trade monitored
- [ ] Logs checked for errors

## Important Notes

⚠️ **Before Migration:**
- Ensure local MT5 has all settings you want
- Verify EA is compiled and working locally
- Check that account is accessible

⚠️ **During Migration:**
- Do NOT close MT5
- Do NOT disconnect from internet
- Wait for completion message

⚠️ **After Migration:**
- Verify all settings are correct
- Test EA on demo first (if possible)
- Monitor first few trades closely
- Check logs regularly

## Support

If migration fails or issues occur:
1. Check VPS status
2. Review error messages
3. Try migration again
4. Contact MetaQuotes support if needed
5. Provide Subscription ID: 6773048
