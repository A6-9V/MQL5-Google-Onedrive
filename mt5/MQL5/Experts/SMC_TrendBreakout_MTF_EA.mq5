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
   
   //--- Check if AutoTrading is enabled
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      Print("AutoTrading is disabled in terminal settings");
      return;
   }
   
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) {
      Print("AutoTrading is disabled in EA settings");
      return;
   }
   
   //--- ⚡ Bolt: Consolidate CopyRates calls for performance.
   //--- Fetch 3 bars at once to avoid a second redundant call later in the function.
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, _Period, 0, 3, rates) <= 0) return; // Fetch 3 bars
   
   //--- New bar check
   datetime currentBarTime = rates[0].time;
   if(currentBarTime == lastBarTime) return; // Exit if not a new bar
   lastBarTime = currentBarTime;
   
   //--- Check if position already open
   if(PositionSelect(_Symbol)) {
      if(PositionGetInteger(POSITION_MAGIC) == MagicNumber) {
         positionOpen = true;
         return; // Already have position
      }
   }
   positionOpen = false;
   
   //--- Get indicator values
   double upperBand[];
   double lowerBand[];
   double emaFast[];
   double emaSlow[];
   
   ArraySetAsSeries(upperBand, true);
   ArraySetAsSeries(lowerBand, true);
   ArraySetAsSeries(emaFast, true);
   ArraySetAsSeries(emaSlow, true);
   
   // iBands buffers: 1=upper, 2=lower
   if(CopyBuffer(donchianBandsHandle, 1, 0, 3, upperBand) <= 0) return;
   if(CopyBuffer(donchianBandsHandle, 2, 0, 3, lowerBand) <= 0) return;
   if(CopyBuffer(emaFastHandle, 0, 0, 3, emaFast) <= 0) return;
   if(CopyBuffer(emaSlowHandle, 0, 0, 3, emaSlow) <= 0) return;
   
   //--- Extract latest indicator values for calculations
   double latestUpperBand = upperBand[0];
   double latestLowerBand = lowerBand[0];

   //--- Get current prices
   double ask = Ask;
   double bid = Bid;
   
   double close[3];
   close[0] = rates[0].close;
   close[1] = rates[1].close;
   close[2] = rates[2].close;
   
   //--- Lower TF Confirmation: Check EMA direction
   bool bullishConfirmation = (emaFast[0] > emaSlow[0] && emaFast[1] > emaSlow[1]);
   bool bearishConfirmation = (emaFast[0] < emaSlow[0] && emaFast[1] < emaSlow[1]);
   
   //--- Donchian Breakout Detection
   bool buySignal = (close[1] > upperBand[1] && close[0] > close[1] && bullishConfirmation);
   bool sellSignal = (close[1] < lowerBand[1] && close[0] < close[1] && bearishConfirmation);
   
   //--- BOLT Optimization: Pass pre-fetched indicator values to trade functions to avoid redundant CopyBuffer() calls in a hot path.
   //--- Execute trades
   if(buySignal || sellSignal)
   {
     //--- ⚡ Bolt: Defer ATR calculation until a signal is confirmed to avoid unnecessary calls.
     double atr[];
     ArraySetAsSeries(atr, true);
     if(CopyBuffer(atrHandle, 0, 0, 1, atr) <= 0) return;

     if(buySignal) {
       OpenBuyTrade(ask, atr[0], latestUpperBand, latestLowerBand);
     }
     else { // sellSignal must be true
       OpenSellTrade(bid, atr[0], latestUpperBand, latestLowerBand);
     }
   }
}

//+------------------------------------------------------------------+
//| Open Buy Trade                                                     |
//+------------------------------------------------------------------+
void OpenBuyTrade(double ask, double latestAtr, double latestUpperBand, double latestLowerBand)
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
   double lots = CalculateLots(ask - sl);
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
void OpenSellTrade(double bid, double latestAtr, double latestUpperBand, double latestLowerBand)
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
   double lots = CalculateLots(sl - bid);
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
   
   if(SLMode == SL_ATR) {
      if(latestAtr <= 0) return 0; // Basic validation
      if(isSell) {
         sl = price + (latestAtr * ATR_SL_Mult);
      } else {
         sl = price - (latestAtr * ATR_SL_Mult);
      }
   }
   else if(SLMode == SL_FIXED_POINTS) {
      if(isSell) {
         sl = price + (FixedSLPoints * g_point);
      } else {
         sl = price - (FixedSLPoints * g_point);
      }
   }
   else if(SLMode == SL_SWING) {
      // Simplified swing - use ATR as fallback
      if(latestAtr <= 0) return 0; // Basic validation
      if(isSell) {
         sl = price + (latestAtr * ATR_SL_Mult) + (SwingSLBufferPoints * g_point);
      } else {
         sl = price - (latestAtr * ATR_SL_Mult) - (SwingSLBufferPoints * g_point);
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
double CalculateLots(double slDistance)
{
   if(slDistance <= 0) return 0;
   if(RiskPercent <= 0) return 0;
   
   //--- Get account balance/equity
   double accountBalance = RiskUseEquity ? AccountInfoDouble(ACCOUNT_EQUITY) : AccountInfoDouble(ACCOUNT_BALANCE);
   
   //--- Calculate risk amount
   double riskAmount = accountBalance * (RiskPercent / 100.0);
   
   //--- Calculate lots
   double lots = (riskAmount / (slDistance / g_point * g_tickSize / g_point * g_tickValue));
   
   //--- Normalize lot size
   lots = MathFloor(lots / g_lotStep) * g_lotStep;
   lots = MathMax(g_minLot, MathMin(lots, g_maxLot));
   
   //--- Apply user limits
   lots = MathMax(MinLots, MathMin(lots, MaxLots));
   
   //--- Check margin if needed
   if(RiskClampToFreeMargin) {
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
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
