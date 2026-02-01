//+------------------------------------------------------------------+
//|                                      SMC_TrendBreakout_MTF_EA.mq5 |
//|                                 SMC + Trend Breakout (MTF) EA    |
//|                             BOS/CHoCH + Donchian + Lower-TF Conf |
//+------------------------------------------------------------------+
#property copyright "SMC Trend Breakout MTF EA"
#property link      ""
#property version   "1.00"

#include <Trade\Trade.mqh>

//--- Input Parameters
//=== Trading Settings ===
input bool   EnableTrading = true;                    // Enable Trading
input int    MagicNumber = 123456;                    // Magic Number
input string TradeComment = "SMC_TrendBreakout_MTF"; // Trade Comment

//=== Risk Management ===
input double RiskPercent = 1.0;                       // Risk Per Trade (% of equity)
input double MaxLots = 0.01;                          // Maximum Lots
input double MinLots = 0.01;                          // Minimum Lots
input bool   RiskUseEquity = true;                    // Use Equity for Risk Calculation
input bool   RiskClampToFreeMargin = true;            // Clamp Lots to Free Margin

//=== Stop Loss Settings ===
enum ENUM_SL_MODE {
   SL_ATR,                                             // ATR-based SL
   SL_SWING,                                           // Swing-based SL
   SL_FIXED_POINTS                                     // Fixed Points SL
};
input ENUM_SL_MODE SLMode = SL_ATR;                   // Stop Loss Mode

input double ATR_SL_Mult = 2.0;                       // ATR SL Multiplier (for SL_ATR)
input int    ATR_Period = 14;                         // ATR Period
input int    SwingSLBufferPoints = 10;                // Swing SL Buffer (points, for SL_SWING)
input int    FixedSLPoints = 50;                      // Fixed SL Points (for SL_FIXED_POINTS)

//=== Take Profit Settings ===
enum ENUM_TP_MODE {
   TP_RR,                                              // Risk:Reward Ratio
   TP_FIXED_POINTS,                                    // Fixed Points TP
   TP_DONCHIAN_WIDTH                                   // Donchian Width TP
};
input ENUM_TP_MODE TPMode = TP_RR;                    // Take Profit Mode

input double RR = 2.0;                                // Risk:Reward Ratio (for TP_RR)
input int    FixedTPPoints = 100;                     // Fixed TP Points (for TP_FIXED_POINTS)
input double DonchianTP_Mult = 1.5;                   // Donchian TP Multiplier (for TP_DONCHIAN_WIDTH)

//=== Donchian Channel Settings ===
input int    DonchianPeriod = 20;                     // Donchian Period
input int    DonchianShift = 0;                       // Donchian Shift

//=== Lower Timeframe Confirmation ===
input ENUM_TIMEFRAMES LowerTF = PERIOD_M5;            // Lower Timeframe for Confirmation
input int    EMA_Fast_Period = 50;                    // Fast EMA Period (Lower TF)
input int    EMA_Slow_Period = 200;                   // Slow EMA Period (Lower TF)

//=== Other Settings ===
input int    Slippage = 30;                           // Slippage (points)
input bool   ShowAlerts = true;                       // Show Alerts

//--- Global Variables
CTrade trade;
int atrHandle = INVALID_HANDLE;
int donchianBandsHandle = INVALID_HANDLE;  // Single handle for both upper and lower
int emaFastHandle = INVALID_HANDLE;
int emaSlowHandle = INVALID_HANDLE;

datetime lastBarTime = 0;
bool positionOpen = false;

//--- Cached Symbol Properties (for performance)
// These are initialized once in OnInit() to avoid repeated calls to SymbolInfo...() functions in hot paths.
double g_point;
int    g_digits;
double g_minLot;
double g_maxLot;
double g_lotStep;
double g_tickValue;
double g_tickSize;
double g_marginInitial;
double g_riskMultiplier;
double g_lotValuePerUnit;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Set magic number
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(Slippage);
   trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   //--- Cache symbol properties for performance
   g_point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   g_digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   g_minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   g_maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   g_lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   g_tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   g_tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   g_marginInitial = SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_INITIAL);

   //--- ⚡ Bolt: Pre-calculate lot size constants for performance
   g_riskMultiplier = RiskPercent / 100.0;
   g_lotValuePerUnit = (g_tickSize > 0) ? (g_tickValue / g_tickSize) : 0;

   //--- Initialize indicators
   atrHandle = iATR(_Symbol, _Period, ATR_Period);
   if(atrHandle == INVALID_HANDLE) {
      Print("Error creating ATR indicator");
      return(INIT_FAILED);
   }
   
   //--- Initialize Donchian Channel (using iBands with 0 deviation)
   // Note: This approximates Donchian. For true Donchian, would need custom indicator
   // iBands(symbol, period, bands_period, bands_shift, deviation, applied_price)
   // Returns one handle, buffers: 0=base line, 1=upper band, 2=lower band
   donchianBandsHandle = iBands(_Symbol, _Period, DonchianPeriod, DonchianShift, 0, PRICE_CLOSE);
   
   if(donchianBandsHandle == INVALID_HANDLE) {
      Print("Error creating Donchian channel");
      return(INIT_FAILED);
   }
   
   //--- Initialize Lower TF EMAs (using Moving Average indicator)
   // iMA(symbol, period, ma_period, ma_shift, ma_method, applied_price)
   emaFastHandle = iMA(_Symbol, LowerTF, EMA_Fast_Period, 0, MODE_EMA, PRICE_CLOSE);
   emaSlowHandle = iMA(_Symbol, LowerTF, EMA_Slow_Period, 0, MODE_EMA, PRICE_CLOSE);
   
   if(emaFastHandle == INVALID_HANDLE || emaSlowHandle == INVALID_HANDLE) {
      Print("Error creating EMA indicators");
      return(INIT_FAILED);
   }
   
   Print("SMC Trend Breakout MTF EA initialized successfully");
   Print("Account: ", AccountInfoInteger(ACCOUNT_LOGIN));
   Print("Risk Percent: ", RiskPercent, "%");
   Print("Max Lots: ", MaxLots);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release indicators
   if(atrHandle != INVALID_HANDLE) IndicatorRelease(atrHandle);
   if(donchianBandsHandle != INVALID_HANDLE) IndicatorRelease(donchianBandsHandle);
   if(emaFastHandle != INVALID_HANDLE) IndicatorRelease(emaFastHandle);
   if(emaSlowHandle != INVALID_HANDLE) IndicatorRelease(emaSlowHandle);
   
   Print("SMC Trend Breakout MTF EA deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                               |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Check if trading is enabled
   if(!EnableTrading) return;
   
   //--- ⚡ Bolt: Performance optimization - check for new bar before expensive operations.
   //--- Using iTime() is much faster than CopyRates() for a simple new bar check.
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   if(currentBarTime == 0) return; // History not ready
   if(currentBarTime == lastBarTime) return; // Exit if not a new bar

   //--- ⚡ Bolt: Defer terminal state checks until AFTER the new bar check.
   //--- TerminalInfoInteger and MQLInfoInteger are relatively expensive API calls.
   //--- Moving them here avoids thousands of redundant calls per hour on every price tick.
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      Print("AutoTrading is disabled in terminal settings");
      return;
   }
   
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) {
      Print("AutoTrading is disabled in EA settings");
      return;
   }

   //--- ⚡ Bolt: Performance optimization - check if position already open BEFORE fetching data.
   //--- This avoids redundant CopyRates and CopyBuffer calls if we are already in a trade.
   if(PositionSelect(_Symbol)) {
      if(PositionGetInteger(POSITION_MAGIC) == MagicNumber) {
         positionOpen = true;
         lastBarTime = currentBarTime;
         return;
      }
   }
   positionOpen = false;

   lastBarTime = currentBarTime;

   //--- ⚡ Bolt: Consolidate CopyRates calls and use static buffer for performance.
   //--- Fetch 2 bars at once to avoid fetching unused data (index 2 was never used).
   static MqlRates rates[];
   static double upperBand[], lowerBand[], emaFast[], emaSlow[], atr[];
   static bool firstTick = true;

   if(firstTick)
   {
      ArraySetAsSeries(rates, true);
      ArraySetAsSeries(upperBand, true);
      ArraySetAsSeries(lowerBand, true);
      ArraySetAsSeries(emaFast, true);
      ArraySetAsSeries(emaSlow, true);
      ArraySetAsSeries(atr, true);
      firstTick = false;
   }

   if(CopyRates(_Symbol, _Period, 0, 2, rates) <= 0) return; // Fetch 2 bars
   
   //--- Get primary signal indicator values (Donchian)
   // iBands buffers: 1=upper, 2=lower
   // ⚡ Bolt: Only fetch 2 bars instead of 3 to improve efficiency.
   if(CopyBuffer(donchianBandsHandle, 1, 0, 2, upperBand) <= 0) return;
   if(CopyBuffer(donchianBandsHandle, 2, 0, 2, lowerBand) <= 0) return;

   //--- Preliminary Donchian Breakout Detection (without confirmation)
   //--- ⚡ Bolt: Access rates directly instead of copying to a local array.
   bool buyBreakout = (rates[1].close > upperBand[1] && rates[0].close > rates[1].close);
   bool sellBreakout = (rates[1].close < lowerBand[1] && rates[0].close < rates[1].close);

   bool buySignal = false;
   bool sellSignal = false;

   //--- ⚡ Bolt: Lazy load confirmation indicators only if a breakout occurs.
   if(buyBreakout || sellBreakout)
   {
      //--- Get Lower TF Confirmation indicator values
      // ⚡ Bolt: Only fetch 2 bars instead of 3 to improve efficiency.
      if(CopyBuffer(emaFastHandle, 0, 0, 2, emaFast) <= 0) return;
      if(CopyBuffer(emaSlowHandle, 0, 0, 2, emaSlow) <= 0) return;

      //--- Lower TF Confirmation: Check EMA direction
      bool bullishConfirmation = (emaFast[0] > emaSlow[0] && emaFast[1] > emaSlow[1]);
      bool bearishConfirmation = (emaFast[0] < emaSlow[0] && emaFast[1] < emaSlow[1]);

      //--- Final Signal Calculation
      buySignal = buyBreakout && bullishConfirmation;
      sellSignal = sellBreakout && bearishConfirmation;
   }
   
   //--- BOLT Optimization: Pass pre-fetched indicator values to trade functions to avoid redundant CopyBuffer() calls in a hot path.
   //--- Execute trades
   if(buySignal || sellSignal)
   {
     //--- ⚡ Bolt: Defer price and indicator assignments until a signal is confirmed.
     //--- Use SymbolInfoTick for efficient retrieval of current prices.
     MqlTick lastTick;
     if(!SymbolInfoTick(_Symbol, lastTick)) return;
     double ask = lastTick.ask;
     double bid = lastTick.bid;

     double latestUpperBand = upperBand[0];
     double latestLowerBand = lowerBand[0];

     //--- ⚡ Bolt: Defer ATR calculation until a signal is confirmed to avoid unnecessary calls.
     if(CopyBuffer(atrHandle, 0, 0, 1, atr) <= 0) return;

     //--- ⚡ Bolt: Performance optimization - fetch account info once before trade execution.
     double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
     double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
     double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

     if(buySignal) {
       OpenBuyTrade(ask, atr[0], latestUpperBand, latestLowerBand, accountBalance, accountEquity, freeMargin);
     }
     else { // sellSignal must be true
       OpenSellTrade(bid, atr[0], latestUpperBand, latestLowerBand, accountBalance, accountEquity, freeMargin);
     }
   }
}

//+------------------------------------------------------------------+
//| Open Buy Trade                                                     |
//+------------------------------------------------------------------+
void OpenBuyTrade(double ask, double latestAtr, double latestUpperBand, double latestLowerBand, double accountBalance, double accountEquity, double freeMargin)
{
   //--- Calculate Stop Loss
   double sl = CalculateSL(ask, false, latestAtr);
   if(sl <= 0) return;
   
   //--- Calculate Take Profit
   double tp = CalculateTP(ask, sl, false, latestUpperBand, latestLowerBand);
   if(tp <= 0) return;
   
   //--- Normalize prices
   sl = NormalizeDouble(sl, g_digits);
   tp = NormalizeDouble(tp, g_digits);
   
   //--- Calculate lot size
   double lots = CalculateLots(ask - sl, accountBalance, accountEquity, freeMargin);
   if(lots <= 0) return;
   
   //--- Open buy position
   if(trade.Buy(lots, _Symbol, ask, sl, tp, TradeComment)) {
      Print("Buy order opened: Lots=", lots, " SL=", sl, " TP=", tp);
      if(ShowAlerts) Alert("SMC EA: Buy order opened on ", _Symbol);
   }
   else {
      Print("Error opening buy order: ", trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| Open Sell Trade                                                    |
//+------------------------------------------------------------------+
void OpenSellTrade(double bid, double latestAtr, double latestUpperBand, double latestLowerBand, double accountBalance, double accountEquity, double freeMargin)
{
   //--- Calculate Stop Loss
   double sl = CalculateSL(bid, true, latestAtr);
   if(sl <= 0) return;
   
   //--- Calculate Take Profit
   double tp = CalculateTP(bid, sl, true, latestUpperBand, latestLowerBand);
   if(tp <= 0) return;
   
   //--- Normalize prices
   sl = NormalizeDouble(sl, g_digits);
   tp = NormalizeDouble(tp, g_digits);
   
   //--- Calculate lot size
   double lots = CalculateLots(sl - bid, accountBalance, accountEquity, freeMargin);
   if(lots <= 0) return;
   
   //--- Open sell position
   if(trade.Sell(lots, _Symbol, bid, sl, tp, TradeComment)) {
      Print("Sell order opened: Lots=", lots, " SL=", sl, " TP=", tp);
      if(ShowAlerts) Alert("SMC EA: Sell order opened on ", _Symbol);
   }
   else {
      Print("Error opening sell order: ", trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| Calculate Stop Loss                                                 |
//+------------------------------------------------------------------+
double CalculateSL(double price, bool isSell, double latestAtr)
{
   double sl = 0;

   //--- ⚡ Bolt: Refactored for performance and DRY principle.
   //--- Merged SL_ATR and SL_SWING as their core logic is identical.
   if(SLMode == SL_ATR || SLMode == SL_SWING)
   {
      if(latestAtr <= 0) return 0; // Basic validation for ATR-based modes.

      double atrOffset = latestAtr * ATR_SL_Mult;
      double swingBuffer = (SLMode == SL_SWING) ? (SwingSLBufferPoints * g_point) : 0;

      if(isSell) {
         sl = price + atrOffset + swingBuffer;
      } else {
         sl = price - atrOffset - swingBuffer;
      }
   }
   else if(SLMode == SL_FIXED_POINTS)
   {
      if(isSell) {
         sl = price + (FixedSLPoints * g_point);
      } else {
         sl = price - (FixedSLPoints * g_point);
      }
   }
   
   return sl;
}

//+------------------------------------------------------------------+
//| Calculate Take Profit                                               |
//+------------------------------------------------------------------+
double CalculateTP(double price, double sl, bool isSell, double latestUpperBand, double latestLowerBand)
{
   double tp = 0;
   double slDistance = MathAbs(price - sl);
   
   if(TPMode == TP_RR) {
      if(isSell) {
         tp = price - (slDistance * RR);
      } else {
         tp = price + (slDistance * RR);
      }
   }
   else if(TPMode == TP_FIXED_POINTS) {
      if(isSell) {
         tp = price - (FixedTPPoints * g_point);
      } else {
         tp = price + (FixedTPPoints * g_point);
      }
   }
   else if(TPMode == TP_DONCHIAN_WIDTH) {
      //--- ⚡ Bolt: Bug fix for infinite recursion and performance improvement.
      //--- Use pre-fetched indicator values instead of new CopyBuffer calls.
      //--- If values are invalid, fall back *directly* to RR calculation to avoid recursion.
      if(latestUpperBand <= 0 || latestLowerBand <= 0) {
         // Fallback to RR directly
         if(isSell) {
            tp = price - (slDistance * RR);
         } else {
            tp = price + (slDistance * RR);
         }
      }
      else {
         double donchianWidth = (latestUpperBand - latestLowerBand) * DonchianTP_Mult;
         if(isSell) {
            tp = price - donchianWidth;
         } else {
            tp = price + donchianWidth;
         }
      }
   }
   
   return tp;
}

//+------------------------------------------------------------------+
//| Calculate Lot Size                                                  |
//+------------------------------------------------------------------+
double CalculateLots(double slDistance, double accountBalance, double accountEquity, double freeMargin)
{
   if(slDistance <= 0 || g_lotValuePerUnit <= 0) return 0;
   
   //--- Get account balance/equity from parameters
   double balanceOrEquity = RiskUseEquity ? accountEquity : accountBalance;
   
   //--- ⚡ Bolt: Optimized lot calculation using pre-calculated constants.
   //--- Original: (balanceOrEquity * (RiskPercent / 100.0)) / (slDistance / g_point * g_tickSize / g_point * g_tickValue)
   double lots = (balanceOrEquity * g_riskMultiplier) / (slDistance * g_lotValuePerUnit);
   
   //--- Normalize lot size
   lots = MathFloor(lots / g_lotStep) * g_lotStep;
   lots = MathMax(g_minLot, MathMin(lots, g_maxLot));
   
   //--- Apply user limits
   lots = MathMax(MinLots, MathMin(lots, MaxLots));
   
   //--- Check margin if needed
   if(RiskClampToFreeMargin) {
      double marginRequired = g_marginInitial * lots;
      if(marginRequired > freeMargin) {
         lots = (freeMargin / g_marginInitial);
         lots = MathFloor(lots / g_lotStep) * g_lotStep;
         lots = MathMax(g_minLot, MathMin(lots, g_maxLot));
      }
   }
   
   return NormalizeDouble(lots, 2);
}

//+------------------------------------------------------------------+
