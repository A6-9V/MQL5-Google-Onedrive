# ExpertMAPSAR Tuning & Usage Guide

## Overview

This guide covers the **ExpertMAPSAR** family of Expert Advisors. These EAs are trend-following systems based on Moving Averages (MA) and Parabolic SAR (PSAR), designed for MetaTrader 5.

The core logic is:
- **Signal**: Moving Average crossover/shift.
- **Trailing**: Parabolic SAR (or Fixed Risk in the RiskBased version).
- **Money Management**: Lot size optimization based on consecutive wins/losses.

## Included Versions

We have provided four variations of the EA to suit different trading styles:

1.  **`ExpertMAPSARSizeOptimized.mq5` (Original)**
    - The base version provided.
    - Uses SMA (Simple Moving Average).
    - Best for: Understanding the core logic.

2.  **`ExpertMAPSAR_Improved.mq5` (Recommended)**
    - **Key Change**: Defaults tuned for modern markets (EMA instead of SMA, tighter shift).
    - **Optimization**: All key parameters are exposed for the Strategy Tester.
    - Best for: General purpose trend trading on XAUUSD and Indices.

3.  **`ExpertMAPSAR_Filtered.mq5` (Conservative)**
    - **Key Change**: Adds an **RSI Filter**.
    - **Logic**: Trades are only taken if the MA signal is confirmed by the RSI filter (based on weightings).
    - Best for: Reducing false signals in choppy/sideways markets.

4.  **`ExpertMAPSAR_RiskBased.mq5` (Risk Controlled)**
    - **Key Change**: Replaces PSAR trailing with **Fixed Stop Loss and Take Profit**.
    - **Logic**: Sets a hard Stop Loss and Take Profit in points immediately upon entry.
    - Best for: Traders who prefer a set-and-forget Risk:Reward ratio (e.g., 1:2) over trailing stops.

## Best Symbols & Timeframes

This strategy thrives on **Volatility** and **Direction**. It struggles in tight ranges.

### ✅ Top Symbols
| Symbol | Characteristics | Why it works |
|--------|----------------|--------------|
| **XAUUSD (Gold)** | High volatility, long trends | The "King" of trend following. |
| **NAS100 (USTEC)** | Strong directional moves | Perfect for PSAR trailing. |
| **US30 (DJ30)** | Big swings | Captures large daily moves. |
| **GBPJPY** | Volatile "Guppy" | Classic trend-following pair. |

### 🕒 Recommended Timeframes
- **H1 (1 Hour)**: Best balance of signal frequency and reliability.
- **H4 (4 Hours)**: More robust, fewer trades, higher win rate.
- **D1 (Daily)**: Very slow, but captures massive macro trends.
- *Avoid M1/M5/M15 unless highly optimized.*

## Optimization Guide

To make this EA powerful, you must run the **Strategy Tester** in MetaTrader 5.

### 1. Moving Average Settings
- **Period**: Test range `10` to `50`. (Shorter = faster signals, Longer = smoother).
- **Shift**: Test range `0` to `10`. (Crucial for timing entries).
- **Method**: Compare `MODE_SMA` vs `MODE_EMA`. EMA is usually faster.

### 2. Parabolic SAR (Trailing)
- **Step**: Test `0.005` to `0.05`. (Lower = looser trail, Higher = tighter trail).
- **Maximum**: Test `0.1` to `0.3`.

### 3. Risk Management
- **Percent**: Default is `3.0` (3%). Adjust based on your risk appetite.
- **DecreaseFactor**: Controls how fast lot size drops after losses. Test `2.0` to `4.0`.

## Theoretical Optimized Parameter Sets

*Note: These are starting points. Always backtest on your specific broker's data.*

### Set A: XAUUSD (Gold) - Aggressive H1
*Captures breakouts in Gold.*
- **MA Period**: 14
- **MA Shift**: 3
- **MA Method**: EMA
- **PSAR Step**: 0.025
- **PSAR Max**: 0.2
- **Risk %**: 3%

### Set B: NAS100 - Trend Rider H4
*Smoother settings for Indices.*
- **MA Period**: 21
- **MA Shift**: 5
- **MA Method**: SMA
- **PSAR Step**: 0.015
- **PSAR Max**: 0.15
- **Risk %**: 5%

### Set C: EURJPY - Balanced H1
- **MA Period**: 18
- **MA Shift**: 4
- **MA Method**: EMA
- **PSAR Step**: 0.02
- **PSAR Max**: 0.2
- **Risk %**: 2%

## How to Install

1.  Copy the `.mq5` files to your **MQL5/Experts/** folder.
2.  Open **MetaEditor** and compile them (F7).
3.  Restart **MetaTrader 5** or refresh the Navigator.
4.  Drag the EA onto a chart (e.g., XAUUSD H1).
5.  Allow **Algo Trading** in the toolbar.

## Disclaimer

Trading involves risk. These tools are provided for educational purposes. Always test on a Demo account before using real funds.
