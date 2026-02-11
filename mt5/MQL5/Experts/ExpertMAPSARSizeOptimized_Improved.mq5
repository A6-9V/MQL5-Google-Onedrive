//+------------------------------------------------------------------+
//|                                    ExpertMAPSARSizeOptimized.mq5 |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//|                                    Improved Version with Enhancements |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "2.00"
#property description "Improved Expert Advisor with MA Signal, Parabolic SAR Trailing, and Optimized Money Management"
#property description "Enhanced with better error handling, logging, and risk management"

//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Trailing\TrailingParabolicSAR.mqh>
#include <Expert\Money\MoneySizeOptimized.mqh>
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
//--- Expert Settings
input group "=== Expert Settings ==="
input string             Inp_Expert_Title                      ="ExpertMAPSARSizeOptimized";
input int                Expert_MagicNumber                    =27893;
input bool               Expert_EveryTick                      =false;
input bool               Expert_EnableTrading                  =true;  // Enable Trading
input bool               Expert_ShowAlerts                     =true;  // Show Alerts

//--- Signal Settings
input group "=== Moving Average Signal ==="
input int                Inp_Signal_MA_Period                  =12;
input int                Inp_Signal_MA_Shift                   =6;
input ENUM_MA_METHOD     Inp_Signal_MA_Method                  =MODE_SMA;
input ENUM_APPLIED_PRICE Inp_Signal_MA_Applied                 =PRICE_CLOSE;

//--- Trailing Settings
input group "=== Parabolic SAR Trailing ==="
input double             Inp_Trailing_ParabolicSAR_Step        =0.02;
input double             Inp_Trailing_ParabolicSAR_Maximum     =0.2;
input bool               Inp_Trailing_Enable                   =true;  // Enable Trailing Stop

//--- Money Management Settings
input group "=== Money Management ==="
input double             Inp_Money_SizeOptimized_DecreaseFactor=3.0;
input double             Inp_Money_SizeOptimized_Percent       =10.0;
input double             Inp_Money_MaxLotSize                  =10.0;  // Maximum Lot Size
input double             Inp_Money_MinLotSize                  =0.01;  // Minimum Lot Size
input bool               Inp_Money_UseEquity                  =true;  // Use Equity for Calculation

//--- Risk Management Settings
input group "=== Risk Management ==="
input double             Inp_Risk_MaxDailyLoss                 =0.0;   // Max Daily Loss (% of balance, 0=disabled)
input double             Inp_Risk_MaxDailyProfit               =0.0;   // Max Daily Profit (% of balance, 0=disabled)
input int                Inp_Risk_MaxTradesPerDay              =0;     // Max Trades Per Day (0=unlimited)
input bool               Inp_Risk_EnableTimeFilter             =false; // Enable Time Filter
input int                Inp_Risk_StartHour                    =0;     // Trading Start Hour (0-23)
input int                Inp_Risk_EndHour                      =23;    // Trading End Hour (0-23)

//--- Logging Settings
input group "=== Logging & Debug ==="
input bool               Inp_Log_EnableDetailedLog             =true;  // Enable Detailed Logging
input int                Inp_Log_Level                         =1;     // Log Level (0=Errors, 1=Info, 2=Debug)

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CExpert ExtExpert;
CTrade  ExtTrade;

//--- Trading statistics
datetime LastBarTime = 0;
int      TradesToday = 0;
double   DailyProfit = 0.0;
double   DailyLoss = 0.0;
double   InitialBalance = 0.0;
datetime LastTradeDate = 0;
datetime g_todayStart = 0; // ⚡ Bolt: Cached today's start time for efficient history selection
double   g_maxDailyLossCurrency = 0;   // ⚡ Bolt: Cached daily loss limit in currency
double   g_maxDailyProfitCurrency = 0; // ⚡ Bolt: Cached daily profit limit in currency
double   g_lossFactor = 0;             // ⚡ Bolt: Cached loss factor
double   g_profitFactor = 0;           // ⚡ Bolt: Cached profit factor

//+------------------------------------------------------------------+
//| Logging Functions                                                |
//+------------------------------------------------------------------+
void LogError(string message)
{
   Print("[ERROR] ", Inp_Expert_Title, ": ", message);
   if(Expert_ShowAlerts) Alert(Inp_Expert_Title, " - ERROR: ", message);
}

void LogInfo(string message)
{
   if(Inp_Log_Level >= 1)
      Print("[INFO] ", Inp_Expert_Title, ": ", message);
}

void LogDebug(string message)
{
   if(Inp_Log_Level >= 2)
      Print("[DEBUG] ", Inp_Expert_Title, ": ", message);
}

//+------------------------------------------------------------------+
//| Check Trading Allowed                                            |
//+------------------------------------------------------------------+
bool IsTradingAllowed(datetime now)
{
   //--- ⚡ Bolt: Use static variables for log throttling to avoid flooding the log on every tick.
   static datetime lastTerminalError = 0;
   static datetime lastMqlError = 0;

   //--- Check if trading is enabled
   if(!Expert_EnableTrading)
   {
      if(Inp_Log_Level >= 2) LogDebug("Trading is disabled by user");
      return false;
   }

   //--- ⚡ Bolt: Move time filter check (cheap math) before expensive terminal API calls.
   if(Inp_Risk_EnableTimeFilter)
   {
      //--- ⚡ Bolt: Use fast integer math for hour extraction instead of TimeToStruct.
      int currentHour = (int)((now / 3600) % 24);

      bool outsideHours = false;
      if(Inp_Risk_StartHour <= Inp_Risk_EndHour)
      {
         if(currentHour < Inp_Risk_StartHour || currentHour > Inp_Risk_EndHour)
            outsideHours = true;
      }
      else // Overnight trading
      {
         if(currentHour < Inp_Risk_StartHour && currentHour > Inp_Risk_EndHour)
            outsideHours = true;
      }

      if(outsideHours)
      {
         if(Inp_Log_Level >= 2) LogDebug("Outside trading hours: " + IntegerToString(currentHour));
         return false;
      }
   }

   //--- Check if AutoTrading is enabled
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      if(now - lastTerminalError > 3600) // Log once per hour
      {
         LogError("AutoTrading is disabled in terminal settings");
         lastTerminalError = now;
      }
      return false;
   }

   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
   {
      if(now - lastMqlError > 3600) // Log once per hour
      {
         LogError("AutoTrading is disabled in EA settings");
         lastMqlError = now;
      }
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Check Daily Limits                                               |
//+------------------------------------------------------------------+
bool CheckDailyLimits()
{
   //--- ⚡ Bolt: Use a static flag to throttle logs and alerts.
   //--- Once a limit is reached, we stop logging/alerting for the rest of the day.
   //--- This avoids redundant string formatting and API calls on every tick.
   static datetime lastLimitLogDay = 0;

   //--- If we already logged a limit reached today, exit silently.
   if(lastLimitLogDay == g_todayStart)
      return false;

   //--- ⚡ Bolt: Rollover reset logic moved to OnTick() for better performance and
   //--- to ensure it runs even when EveryTick is disabled.

   //--- Check max trades per day
   if(Inp_Risk_MaxTradesPerDay > 0 && TradesToday >= Inp_Risk_MaxTradesPerDay)
   {
      LogInfo("Maximum trades per day reached: " + IntegerToString(Inp_Risk_MaxTradesPerDay));
      lastLimitLogDay = g_todayStart;
      return false;
   }

   //--- Check daily loss limit
   if(Inp_Risk_MaxDailyLoss > 0 && DailyLoss >= g_maxDailyLossCurrency)
   {
      LogError("Daily loss limit reached: " + DoubleToString(DailyLoss, 2) + " (Max: " + DoubleToString(g_maxDailyLossCurrency, 2) + ")");
      if(Expert_ShowAlerts) Alert("Daily loss limit reached!");
      lastLimitLogDay = g_todayStart;
      return false;
   }

   //--- Check daily profit limit
   if(Inp_Risk_MaxDailyProfit > 0 && DailyProfit >= g_maxDailyProfitCurrency)
   {
      LogInfo("Daily profit limit reached: " + DoubleToString(DailyProfit, 2) + " (Max: " + DoubleToString(g_maxDailyProfitCurrency, 2) + ")");
      if(Expert_ShowAlerts) Alert("Daily profit target reached!");
      lastLimitLogDay = g_todayStart;
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Update Daily Statistics                                          |
//+------------------------------------------------------------------+
void UpdateDailyStatistics(datetime now = 0)
{
   double currentProfit = 0.0;
   TradesToday = 0; // ⚡ Bolt: Reset and recount from history for robustness

   //--- ⚡ Bolt: Performance optimization - use fast integer math for g_todayStart.
   //--- This avoids expensive TimeToStruct/StructToTime calls.
   if(now == 0) now = TimeCurrent();
   g_todayStart = (now / 86400) * 86400;

   //--- ⚡ Bolt: Consolidate history scan. Count trades and calculate profit in one pass.
   if(HistorySelect(g_todayStart, now))
   {
      int total = HistoryDealsTotal();
      for(int i = 0; i < total; i++)
      {
         //--- ⚡ Bolt: After selecting a deal, use retrieval variants without ticket parameter for speed.
         if(HistoryDealGetTicket(i) > 0)
         {
            if(HistoryDealGetInteger(DEAL_MAGIC) == Expert_MagicNumber)
            {
               //--- ⚡ Bolt: Increment trade count only for entry deals.
               if(HistoryDealGetInteger(DEAL_ENTRY) == DEAL_ENTRY_IN)
                  TradesToday++;

               double profit = HistoryDealGetDouble(DEAL_PROFIT);
               double swap = HistoryDealGetDouble(DEAL_SWAP);
               double commission = HistoryDealGetDouble(DEAL_COMMISSION);
               currentProfit += profit + swap + commission;
            }
         }
      }
   }

   if(currentProfit >= 0)
   {
      DailyProfit = currentProfit;
      DailyLoss = 0.0;
   }
   else
   {
      DailyProfit = 0.0;
      DailyLoss = MathAbs(currentProfit);
   }

   //--- ⚡ Bolt: Cache daily currency limits to avoid redundant calculations and API calls in OnTick.
   //--- Optimized to use pre-calculated factors to replace divisions with multiplications.
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   g_maxDailyLossCurrency = (g_lossFactor > 0) ? balance * g_lossFactor : 0;
   g_maxDailyProfitCurrency = (g_profitFactor > 0) ? balance * g_profitFactor : 0;
}

//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit(void)
{
   //--- Set trade parameters
   ExtTrade.SetExpertMagicNumber(Expert_MagicNumber);
   ExtTrade.SetDeviationInPoints(30);
   ExtTrade.SetTypeFilling(ORDER_FILLING_FOK);
   ExtTrade.SetAsyncMode(false);

   //--- Initialize expert
   if(!ExtExpert.Init(Symbol(), Period(), Expert_EveryTick, Expert_MagicNumber))
   {
      LogError("Error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }

   //--- Creation of signal object
   CSignalMA *signal = new CSignalMA;
   if(signal == NULL)
   {
      LogError("Error creating signal object");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }

   //--- Add signal to expert (will be deleted automatically)
   if(!ExtExpert.InitSignal(signal))
   {
      LogError("Error initializing signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }

   //--- Set signal parameters
   signal.PeriodMA(Inp_Signal_MA_Period);
   signal.Shift(Inp_Signal_MA_Shift);
   signal.Method(Inp_Signal_MA_Method);
   signal.Applied(Inp_Signal_MA_Applied);

   //--- Check signal parameters
   if(!signal.ValidationSettings())
   {
      LogError("Invalid signal parameters");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }

   //--- Creation of trailing object
   CTrailingPSAR *trailing = new CTrailingPSAR;
   if(trailing == NULL)
   {
      LogError("Error creating trailing object");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }

   //--- Add trailing to expert (will be deleted automatically)
   if(!ExtExpert.InitTrailing(trailing))
   {
      LogError("Error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }

   //--- Set trailing parameters
   trailing.Step(Inp_Trailing_ParabolicSAR_Step);
   trailing.Maximum(Inp_Trailing_ParabolicSAR_Maximum);

   //--- Check trailing parameters
   if(!trailing.ValidationSettings())
   {
      LogError("Invalid trailing parameters");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }

   //--- Creation of money object
   CMoneySizeOptimized *money = new CMoneySizeOptimized;
   if(money == NULL)
   {
      LogError("Error creating money management object");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }

   //--- Add money to expert (will be deleted automatically)
   if(!ExtExpert.InitMoney(money))
   {
      LogError("Error initializing money management");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }

   //--- Set money parameters
   money.DecreaseFactor(Inp_Money_SizeOptimized_DecreaseFactor);
   money.Percent(Inp_Money_SizeOptimized_Percent);

   //--- Check money parameters
   if(!money.ValidationSettings())
   {
      LogError("Invalid money management parameters");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }

   //--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
   {
      LogError("Error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
   }

   //--- Initialize statistics
   InitialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   LastTradeDate = 0;
   TradesToday = 0;
   DailyProfit = 0.0;
   DailyLoss = 0.0;

   //--- ⚡ Bolt: Pre-calculate daily risk factors for performance
   g_lossFactor = (Inp_Risk_MaxDailyLoss > 0) ? (Inp_Risk_MaxDailyLoss / 100.0) : 0;
   g_profitFactor = (Inp_Risk_MaxDailyProfit > 0) ? (Inp_Risk_MaxDailyProfit / 100.0) : 0;

   //--- ⚡ Bolt: Initialize daily statistics and set timer for periodic updates
   UpdateDailyStatistics();
   EventSetTimer(60);

   //--- Success message
   LogInfo("Expert Advisor initialized successfully");
   LogInfo("Account: " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));
   LogInfo("Symbol: " + Symbol());
   LogInfo("Period: " + EnumToString(Period()));
   LogInfo("Magic Number: " + IntegerToString(Expert_MagicNumber));
   LogInfo("Initial Balance: " + DoubleToString(InitialBalance, 2));

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- ⚡ Bolt: Kill timer on deinitialization
   EventKillTimer();

   //--- Print final statistics
   double finalBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double totalProfit = finalBalance - InitialBalance;
   double profitPercent = (totalProfit / InitialBalance) * 100.0;

   LogInfo("Expert Advisor deinitialized. Reason: " + IntegerToString(reason));
   LogInfo("Final Balance: " + DoubleToString(finalBalance, 2));
   LogInfo("Total Profit: " + DoubleToString(totalProfit, 2) + " (" + DoubleToString(profitPercent, 2) + "%)");
   LogInfo("Trades Today: " + IntegerToString(TradesToday));

   ExtExpert.Deinit();
}

//+------------------------------------------------------------------+
//| Function-event handler "tick"                                    |
//+------------------------------------------------------------------+
void OnTick(void)
{
   //--- ⚡ Bolt: Optimized Day-Rollover check.
   //--- This happens at the top to ensure daily stats are reset exactly at midnight.
   //--- Using integer division is extremely cheap and avoids expensive TimeToStruct/StructToTime calls on every tick.
   //--- Explicitly cast to long to ensure consistent behavior across MQL5 versions.
   datetime currentTickTime = TimeCurrent();
   long currentDay = (long)currentTickTime / 86400;
   if(currentDay != (long)LastTradeDate / 86400)
   {
      g_todayStart = (datetime)(currentDay * 86400);
      LastTradeDate = g_todayStart;
      UpdateDailyStatistics(currentTickTime);
      LogInfo("New trading day started. Resetting daily statistics.");
   }

   //--- ⚡ Bolt: Prioritize cheap, internal logic checks before expensive terminal API calls.
   //--- Check daily limits (fast) before IsTradingAllowed (contains multiple API calls).
   if(!CheckDailyLimits())
      return;

   //--- Check if trading is allowed (terminal/mql state)
   if(!IsTradingAllowed(currentTickTime))
      return;

   //--- ⚡ Bolt: Moved UpdateDailyStatistics() from OnTick to OnTrade and OnTimer
   //--- to avoid expensive history scanning on every price tick.

   //--- Process expert tick
   //--- We do NOT throttle this call with a "new bar" check here because ExtExpert
   //--- already manages its own EveryTick setting and needs to run for trailing stops.
   ExtExpert.OnTick();

   //--- ⚡ Bolt: Use lightweight iTime() to detect and log new bars instead of expensive CopyRates().
   //--- Guarded with log level check to avoid unnecessary API calls when debug logging is disabled.
   if(Inp_Log_Level >= 2)
   {
      datetime currentBarTime = iTime(_Symbol, _Period, 0);
      if(currentBarTime != 0 && currentBarTime != LastBarTime)
      {
         LastBarTime = currentBarTime;
         LogDebug("New bar detected");
      }
   }
}

//+------------------------------------------------------------------+
//| Function-event handler "trade"                                   |
//+------------------------------------------------------------------+
void OnTrade(void)
{
   ExtExpert.OnTrade();

   //--- ⚡ Bolt: Update daily statistics when a trade occurs.
   //--- UpdateDailyStatistics now consolidates all history-based checks into a single scan.
   int prevTrades = TradesToday;
   UpdateDailyStatistics();

   if(TradesToday > prevTrades)
   {
      LogInfo("Trade executed. Total trades today: " + IntegerToString(TradesToday));
   }
}

//+------------------------------------------------------------------+
//| Function-event handler "timer"                                   |
//+------------------------------------------------------------------+
void OnTimer(void)
{
   //--- ⚡ Bolt: Periodic background update of statistics.
   ExtExpert.OnTimer();
   UpdateDailyStatistics();
}

//+------------------------------------------------------------------+
