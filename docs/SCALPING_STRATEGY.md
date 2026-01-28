# Scalping Strategy Research

## Overview
This document outlines optimal settings for the `SMC_TrendBreakout_MTF_EA` for scalping on M5, M15, and M30 timeframes.

## Timeframe Configurations

### 1. 5 Minute (M5) - High Frequency
* **Focus:** Quick momentum bursts.
* **Stop Loss:** 50-80 points (5-8 pips) or ATR * 1.5.
* **Take Profit:** 80-120 points (8-12 pips) or RR 1:1.5.
* **Trailing Stop:** Start at 50 points, Step 20 points.
* **Break Even:** Trigger at 50 points, Lock 10 points.
* **Indicators:**
    * EMA Fast: 9
    * EMA Slow: 21
    * Donchian Lookback: 10 (tighter for M5)

### 2. 15 Minute (M15) - Intraday
* **Focus:** Intraday trend continuation.
* **Stop Loss:** 100-150 points (10-15 pips).
* **Take Profit:** 150-250 points (15-25 pips).
* **Trailing Stop:** Start at 100 points, Step 50 points.
* **Break Even:** Trigger at 100 points, Lock 20 points.
* **Indicators:**
    * EMA Fast: 20
    * EMA Slow: 50
    * Donchian Lookback: 20

### 3. 30 Minute (M30) - Swing Scalp
* **Focus:** Trend reversals and larger breakouts.
* **Stop Loss:** 200-300 points (20-30 pips).
* **Take Profit:** 300-500 points (30-50 pips).
* **Trailing Stop:** Start at 200 points, Step 100 points.
* **Break Even:** Trigger at 200 points, Lock 50 points.
* **Indicators:**
    * EMA Fast: 20
    * EMA Slow: 50
    * Donchian Lookback: 20

## Recommended Inputs for EA

### M5 Preset
* `EnableTrading`: true
* `SignalTF`: PERIOD_M5
* `DonchianLookback`: 10
* `SLMode`: SL_ATR
* `ATR_SL_Mult`: 1.5
* `TPMode`: TP_RR
* `RR`: 1.5
* `UseSMC`: true (for structure)
* `UseDonchianBreakout`: true (for momentum)
* `ManagePositions`: Enabled
    * `CFG_Use_BreakEven`: true
    * `CFG_BE_Trigger_Pips`: 5
    * `CFG_BE_Plus_Pips`: 1
    * `CFG_Use_Trailing`: true
    * `CFG_Trail_Start_Pips`: 5
    * `CFG_Trail_Step_Pips`: 2

### M15 Preset
* `SignalTF`: PERIOD_M15
* `DonchianLookback`: 20
* `SLMode`: SL_ATR
* `ATR_SL_Mult`: 1.5
* `RR`: 2.0
* `ManagePositions`: Enabled
    * `CFG_Use_BreakEven`: true
    * `CFG_BE_Trigger_Pips`: 10
    * `CFG_BE_Plus_Pips`: 2
    * `CFG_Use_Trailing`: true
    * `CFG_Trail_Start_Pips`: 10
    * `CFG_Trail_Step_Pips`: 5
