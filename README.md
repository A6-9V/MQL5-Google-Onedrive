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

### Notes / safety

- This is a rules-based implementation of common “SMC” ideas (fractal swing BOS/CHoCH) and a Donchian breakout.
- Test in Strategy Tester and/or demo before using real funds.

### Secrets / workspace encryption (optional)

- **Do not commit secrets**: put local credentials in `.env` (ignored by git). Use `.env.example` as a template.
- **If you pasted a real API key into chat/logs, rotate it** with the provider (treat it as exposed).

If you want an encrypted snapshot of this repository on disk, you can create an encrypted archive:

```bash
export ENCRYPTION_PASSPHRASE='your-strong-passphrase'
./scripts/encrypt_workspace.sh
```

To decrypt/extract it:

```bash
export ENCRYPTION_PASSPHRASE='your-strong-passphrase'
./scripts/decrypt_workspace.sh workspace.tar.gz.enc ./_decrypted_workspace
```
