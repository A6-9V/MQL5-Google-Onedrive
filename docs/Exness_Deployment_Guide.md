# Exness Terminal Deployment Guide

This guide explains how to deploy the SMC + Trend Breakout (MTF) indicators and Expert Advisors to your Exness MetaTrader 5 terminal.

## Prerequisites

- **Exness MetaTrader 5** installed on your computer
- Access to this repository (downloaded or cloned)

## Deployment Methods

### Method 1: Manual Deployment (Recommended for Beginners)

This method involves manually copying files to your MT5 data folder.

1. **Open Exness MT5** on your computer

2. **Find your MT5 Data Folder:**
   - In MT5, go to **File → Open Data Folder**
   - This will open Windows Explorer (or Finder on Mac) showing your MT5 data directory
   - Note this path for the next steps

3. **Copy the MQL5 files:**
   - Navigate to the repository's `mt5/MQL5/` folder
   - Copy `Indicators/SMC_TrendBreakout_MTF.mq5` to `[MT5 Data Folder]/MQL5/Indicators/`
   - Copy `Experts/SMC_TrendBreakout_MTF_EA.mq5` to `[MT5 Data Folder]/MQL5/Experts/`

4. **Compile the files:**
   - In MT5, press **F4** to open MetaEditor
   - In MetaEditor, navigate to the files you just copied
   - Right-click each file and select **Compile**, or press **F7**
   - Check for any compilation errors in the Toolbox window

5. **Refresh Navigator:**
   - Back in MT5, go to **Navigator** panel (press **Ctrl+N** if not visible)
   - Right-click in the Navigator and select **Refresh**
   - You should now see your indicators and Expert Advisors listed

### Method 2: Automated Deployment (Using Script)

This method uses the provided deployment script for faster deployment.

**Note:** This script must be run on the same machine where Exness MT5 is installed.

1. **Find your MT5 Data Folder path** (as described in Method 1, step 2)

2. **Open a terminal/command prompt** in the repository root directory

3. **Run the deployment script:**
   ```bash
   bash scripts/deploy_mt5.sh "/path/to/your/MT5/Data/Folder"
   ```
   
   Example (replace `ABC123DEF456` with your actual terminal ID):
   ```bash
   bash scripts/deploy_mt5.sh "C:/Users/YourName/AppData/Roaming/MetaQuotes/Terminal/ABC123DEF456/MQL5"
   ```
   
   **Note:** The terminal ID (like `ABC123DEF456`) is a unique identifier for your MT5 installation. You can find it by opening File → Open Data Folder in MT5.

4. **Compile and refresh** (as described in Method 1, steps 4-5)

### Method 3: Package Deployment (Using Pre-built ZIP)

This method creates a portable ZIP package that can be easily transferred and deployed.

#### Creating the Package

1. **In the repository root directory**, run:
   ```bash
   bash scripts/package_mt5.sh
   ```

2. **Locate the package:**
   - The script creates `dist/Exness_MT5_MQL5.zip`
   - This ZIP file contains the MQL5 source files in the correct folder structure

#### Installing from Package

1. **Extract the ZIP file** to your MT5 Data Folder
   - The ZIP contains a `MQL5/` folder with `Indicators/` and `Experts/` subdirectories
   - Extract so that the contents merge with your existing MT5 data folder structure

2. **Compile and refresh** (as described in Method 1, steps 4-5)

## Using the Indicator

After successful deployment:

1. **Attach the indicator to a chart:**
   - In MT5, open a chart for your desired symbol
   - In Navigator, find **Indicators → Custom → SMC_TrendBreakout_MTF**
   - Drag it onto your chart, or double-click to attach

2. **Configure the indicator:**
   - Set **LowerTF** to a smaller timeframe (e.g., if main chart is M15, use M5 or M1)
   - Signals require lower-TF confirmation by default (EMA fast/slow direction)
   - Adjust other parameters as needed

## Using the Expert Advisor (EA)

After successful deployment:

1. **Attach the EA to a chart:**
   - In Navigator, find **Expert Advisors → SMC_TrendBreakout_MTF_EA**
   - Drag it onto your chart

2. **Enable Algorithmic Trading:**
   - Click the **AutoTrading** button in the MT5 toolbar (or press **Ctrl+E**)
   - The button should be highlighted/green when enabled

3. **Configure push notifications (optional):**
   - Go to **Tools → Options → Notifications**
   - Enable push notifications
   - Set your MetaQuotes ID (get this from the MetaTrader mobile app)

4. **Configure EA parameters:**
   - **SLMode:** Choose stop-loss calculation method (ATR, SWING, or FIXED_POINTS)
   - **TPMode:** Choose take-profit calculation method (RR, FIXED_POINTS, or DONCHIAN_WIDTH)
   - **RiskPercent:** Set risk percentage per trade (0 to disable auto-sizing)
   - Adjust other parameters based on your trading strategy

## Verification Steps

After deployment, verify that everything is working:

1. **Check compilation:** No errors in MetaEditor's Toolbox window
2. **Check Navigator:** Files appear under Indicators/Experts
3. **Test on demo:** Attach to a demo chart and observe behavior
4. **Check logs:** View the Experts tab in MT5's Toolbox for any runtime errors

## Troubleshooting

### Files not showing in Navigator

- Ensure files are in the correct folders (`MQL5/Indicators/` or `MQL5/Experts/`)
- Try restarting MT5
- Check that you're looking in the **Custom** section of Navigator

### Compilation errors

- Ensure you're using MetaTrader 5 (not MetaTrader 4)
- Check that the MQL5 build is up to date (MetaEditor → Help → About)
- Review error messages in the Toolbox window for specific issues

### EA not trading

- Verify **AutoTrading** is enabled (green button in toolbar)
- Check **Tools → Options → Expert Advisors** and ensure:
  - "Allow algorithmic trading" is checked
  - "Allow DLL imports" is checked (not required for this EA, but good to enable)
  - Trading URLs are allowed if using notifications
- Review the Experts log for error messages

### Permission errors when deploying

- Run your terminal/command prompt with administrator privileges
- Ensure Exness MT5 is closed when copying files
- Check that antivirus software isn't blocking file operations

## CI/CD and Automated Builds

This repository includes GitHub Actions workflows that automatically:

- **Validate** the repository structure on every push/PR
- **Build** the deployment package (`Exness_MT5_MQL5.zip`)
- **Upload** the package as a GitHub Actions artifact

You can download pre-built packages from the Actions tab in GitHub instead of building locally.

## Additional Resources

- **README.md**: Overview and feature descriptions
- **Repository Issues**: Report problems or request features
- **MT5 Documentation**: [MQL5 Language Reference](https://www.mql5.com/en/docs)

## Safety Notice

This is a rules-based implementation of Smart Money Concepts (SMC) and Donchian breakout strategies. Always:

- Test thoroughly in the **Strategy Tester** before live trading
- Use a **demo account** to validate behavior
- Start with **small position sizes** on live accounts
- Monitor performance and adjust parameters as needed
- Never risk more than you can afford to lose

## Support

- Email: `support@example.com`
- WhatsApp: [Agent community](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)
