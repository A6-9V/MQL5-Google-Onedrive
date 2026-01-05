## SMC + Trend Breakout (MTF) for Exness MT5

This repo contains:

- `mt5/MQL5/Indicators/SMC_TrendBreakout_MTF.mq5`: visual indicator (BOS/CHoCH + Donchian breakout + lower-timeframe confirmation).
- `mt5/MQL5/Experts/SMC_TrendBreakout_MTF_EA.mq5`: Expert Advisor (alerts + optional auto-trading).

### Render workspace

My Blue watermelon Workspace  
tea-d1joqqi4d50c738aiujg

### Install into Exness MetaTrader 5

1. Open **Exness MT5**.
2. Go to **File → Open Data Folder**.
3. Copy:
   - `SMC_TrendBreakout_MTF.mq5` to `MQL5/Indicators/`
   - `SMC_TrendBreakout_MTF_EA.mq5` to `MQL5/Experts/`
4. In MT5, open **MetaEditor** (or press **F4**) and compile the files.
5. Back in MT5: **Navigator → Refresh**.

### Optional: package / deploy helpers

- Create a zip you can copy to your PC:
  - `bash scripts/package_mt5.sh` → outputs `dist/Exness_MT5_MQL5.zip`
- Copy directly into your MT5 Data Folder (run this on the machine that has MT5 installed):
  - `bash scripts/deploy_mt5.sh "/path/from/MT5/File->Open Data Folder"`

### GitHub automation (reviews, CI, auto-merge, OneDrive sync)

This repo includes GitHub Actions workflows under `.github/workflows/`:

- **CI (`CI`)**: runs on pull requests and pushes to `main/master`
  - Validates repo structure
  - Builds `dist/Exness_MT5_MQL5.zip` and uploads it as an artifact
- **Auto-merge enablement (`Enable auto-merge (label-driven)`)**: if a PR has the label **`automerge`**, it will enable GitHub’s auto-merge (squash). Your branch protection rules still control *when* it can merge (required reviews, required CI, etc.).
- **OneDrive sync (`Sync to OneDrive (rclone)`)**: on pushes to `main` (and manual runs), syncs `mt5/MQL5` to OneDrive via `rclone`.

Recommended repo settings (GitHub → **Settings**):

- **Branch protection (main)**:
  - Require pull request reviews (at least 1)
  - Require status checks: `CI / validate-and-package`
  - (Optional) Require CODEOWNERS review
- **Auto-merge**: enable “Allow auto-merge” in repo settings

OneDrive sync setup (required secrets):

- **`RCLONE_CONFIG_B64`**: base64 of your `rclone.conf` containing a OneDrive remote.

Example (run locally, then paste into GitHub Secrets):

```bash
rclone config
base64 -w0 ~/.config/rclone/rclone.conf
```

Optional secrets:

- **`ONEDRIVE_REMOTE`**: remote name in `rclone.conf` (default: `onedrive`)
- **`ONEDRIVE_PATH`**: destination folder path (default: `Apps/MT5/MQL5`)

### Use the indicator

- Attach `SMC_TrendBreakout_MTF` to a chart (your main timeframe).
- Set **LowerTF** to a smaller timeframe (ex: main = M15, lower = M5 or M1).
- Signals require lower-TF confirmation by default (EMA fast/slow direction).

### Use the EA (push to terminal + optional auto trading)

- Attach `SMC_TrendBreakout_MTF_EA` to a chart.
- Enable **Algo Trading** in MT5 if you want auto entries.
- If you want phone push alerts:
  - MT5 → **Tools → Options → Notifications**
  - enable push notifications and set your MetaQuotes ID.
- For web request integrations (ZOLO-A6-9V-NUNA- plugin):
  - Enable `EnableWebRequest` parameter
  - Add `https://soloist.ai/a6-9v` to MT5's allowed URLs list:
    - MT5 → **Tools → Options → Expert Advisors**
    - Check "Allow WebRequest for listed URL"
    - Add the URL: `https://soloist.ai/a6-9v`

### Auto SL/TP + risk management (EA)

In `SMC_TrendBreakout_MTF_EA`:

- **SLMode**
  - `SL_ATR`: SL = ATR × `ATR_SL_Mult`
  - `SL_SWING`: SL beyond last confirmed fractal swing (with `SwingSLBufferPoints`), fallback to ATR if swing is missing/invalid
  - `SL_FIXED_POINTS`: SL = `FixedSLPoints`
- **TPMode**
  - `TP_RR`: TP = `RR` × SL distance
  - `TP_FIXED_POINTS`: TP = `FixedTPPoints`
  - `TP_DONCHIAN_WIDTH`: TP = Donchian channel width × `DonchianTP_Mult` (fallback to ATR width if needed)
- **RiskPercent**
  - If `RiskPercent > 0`, lots are calculated from SL distance so the **money at risk ≈ RiskPercent of Equity** (or Balance if you disable `RiskUseEquity`).
  - `RiskClampToFreeMargin` can reduce lots if required margin is too high.

### Notes / safety

- This is a rules-based implementation of common “SMC” ideas (fractal swing BOS/CHoCH) and a Donchian breakout.
- Test in Strategy Tester and/or demo before using real funds.

### Project links

- Developer tip window project: https://chatgpt.com/g/g-p-691e9c0ace5c8191a1b409c09251cc2b-window-for-developer-tip/project
- Plugin Integration: ZOLO-A6-9V-NUNA-
- GitHub Pages: https://github.com/Mouy-leng/-LengKundee-mql5.github.io.git
- Soloist.ai Endpoint: https://soloist.ai/a6-9v

### Contact

- Email: `Lengkundee01.org@domain.com`
- WhatsApp: [Agent community](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)
