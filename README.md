## SMC + Trend Breakout (MTF) for Exness MT5

This repo contains:

- `mt5/MQL5/Indicators/SMC_TrendBreakout_MTF.mq5`: visual indicator (BOS/CHoCH + Donchian breakout + lower-timeframe confirmation).
- `mt5/MQL5/Experts/SMC_TrendBreakout_MTF_EA.mq5`: Expert Advisor (alerts + optional auto-trading).

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
