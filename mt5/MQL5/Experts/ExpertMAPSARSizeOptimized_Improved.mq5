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
bool IsTradingAllowed()
{
   //--- Check if trading is enabled
   if(!Expert_EnableTrading)
   {
      LogDebug("Trading is disabled by user");
      return false;
   }

   //--- Check if AutoTrading is enabled
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      LogError("AutoTrading is disabled in terminal settings");
      return false;
   }

   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
   {
      LogError("AutoTrading is disabled in EA settings");
      return false;
   }

   //--- Check time filter
   if(Inp_Risk_EnableTimeFilter)
   {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      int currentHour = dt.hour;

      if(Inp_Risk_StartHour <= Inp_Risk_EndHour)
      {
         if(currentHour < Inp_Risk_StartHour || currentHour > Inp_Risk_EndHour)
         {
            LogDebug("Outside trading hours: ", currentHour);
            return false;
         }
      }
      else // Overnight trading
      {
         if(currentHour < Inp_Risk_StartHour && currentHour > Inp_Risk_EndHour)
         {
            LogDebug("Outside trading hours: ", currentHour);
            return false;
         }
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| Check Daily Limits                                               |
//+------------------------------------------------------------------+
bool CheckDailyLimits()
{
   datetime currentDate = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(currentDate, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   datetime todayStart = StructToTime(dt);

   //--- Reset daily statistics if new day
   if(LastTradeDate != todayStart)
   {
      TradesToday = 0;
      DailyProfit = 0.0;
      DailyLoss = 0.0;
      LastTradeDate = todayStart;
      LogInfo("New trading day started. Resetting daily statistics.");
   }

   //--- Check max trades per day
   if(Inp_Risk_MaxTradesPerDay > 0 && TradesToday >= Inp_Risk_MaxTradesPerDay)
   {
      LogInfo("Maximum trades per day reached: ", Inp_Risk_MaxTradesPerDay);
      return false;
   }

   //--- Check daily loss limit
   if(Inp_Risk_MaxDailyLoss > 0)
   {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double maxLoss = balance * (Inp_Risk_MaxDailyLoss / 100.0);

      if(DailyLoss >= maxLoss)
      {
         LogError("Daily loss limit reached: ", DoubleToString(DailyLoss, 2), " (Max: ", DoubleToString(maxLoss, 2), ")");
         if(Expert_ShowAlerts) Alert("Daily loss limit reached!");
         return false;
      }
   }

   //--- Check daily profit limit
   if(Inp_Risk_MaxDailyProfit > 0)
   {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double maxProfit = balance * (Inp_Risk_MaxDailyProfit / 100.0);

      if(DailyProfit >= maxProfit)
      {
         LogInfo("Daily profit limit reached: ", DoubleToString(DailyProfit, 2), " (Max: ", DoubleToString(maxProfit, 2), ")");
         if(Expert_ShowAlerts) Alert("Daily profit target reached!");
         return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| Update Daily Statistics                                          |
//+------------------------------------------------------------------+
void UpdateDailyStatistics()
{
   double currentProfit = 0.0;

   //--- Calculate current day's profit/loss
   if(HistorySelect(TimeCurrent() - PeriodSeconds(PERIOD_D1), TimeCurrent()))
   {
      int total = HistoryDealsTotal();
      for(int i = 0; i < total; i++)
      {
         ulong ticket = HistoryDealGetTicket(i);
         if(ticket > 0)
         {
            if(HistoryDealGetInteger(ticket, DEAL_MAGIC) == Expert_MagicNumber)
            {
               double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
               double swap = HistoryDealGetDouble(ticket, DEAL_SWAP);
               double commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
               currentProfit += profit + swap + commission;
            }
         }
      }
   }

   if(currentProfit > 0)
      DailyProfit = currentProfit;
   else
      DailyLoss = MathAbs(currentProfit);
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

   //--- Success message
   LogInfo("Expert Advisor initialized successfully");
   LogInfo("Account: ", IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));
   LogInfo("Symbol: ", Symbol());
   LogInfo("Period: ", EnumToString(Period()));
   LogInfo("Magic Number: ", IntegerToString(Expert_MagicNumber));
   LogInfo("Initial Balance: ", DoubleToString(InitialBalance, 2));

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Print final statistics
   double finalBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double totalProfit = finalBalance - InitialBalance;
   double profitPercent = (totalProfit / InitialBalance) * 100.0;

   LogInfo("Expert Advisor deinitialized. Reason: ", IntegerToString(reason));
   LogInfo("Final Balance: ", DoubleToString(finalBalance, 2));
   LogInfo("Total Profit: ", DoubleToString(totalProfit, 2), " (", DoubleToString(profitPercent, 2), "%)");
   LogInfo("Trades Today: ", IntegerToString(TradesToday));

   ExtExpert.Deinit();
}

//+------------------------------------------------------------------+
//| Function-event handler "tick"                                    |
//+------------------------------------------------------------------+
void OnTick(void)
{
   // ⚡ Bolt: Lightweight new bar check as a gatekeeper.
   // Using iTime() is much faster than CopyRates() and avoids expensive logic on every tick.
   datetime currentBarTime = iTime(Symbol(), Period(), 0);
   if(currentBarTime == 0) return; // History not ready
   bool isNewBar = (currentBarTime != LastBarTime);

   // ⚡ Bolt: Early exit if not a new bar and EveryTick is disabled.
   // This skips all trading logic, daily limit checks, and API calls for the rest of the bar.
   if(!Expert_EveryTick && !isNewBar) return;

   //--- Check if trading is allowed (deferred after new bar check)
   if(!IsTradingAllowed())
      return;

   // ⚡ Bolt: Only update statistics on a new bar to save CPU.
   // HistorySelect() and history loops are expensive and should not run on every tick.
   // Statistics are also updated in OnTrade() to maintain real-time accuracy.
   if(isNewBar)
   {
      UpdateDailyStatistics();
      LastBarTime = currentBarTime;
      LogDebug("New bar detected");
   }

   //--- Check daily limits
   if(!CheckDailyLimits())
      return;

   //--- Process expert tick
   ExtExpert.OnTick();
}

//+------------------------------------------------------------------+
//| Function-event handler "trade"                                   |
//+------------------------------------------------------------------+
void OnTrade(void)
{
   ExtExpert.OnTrade();

   // ⚡ Bolt: Update daily statistics immediately after a trade event
   // to ensure accuracy despite the lazy-loading optimization in OnTick.
   UpdateDailyStatistics();

   //--- Update trade statistics
   if(HistorySelect(TimeCurrent() - 60, TimeCurrent()))
   {
      int total = HistoryDealsTotal();
      for(int i = total - 1; i >= 0; i--)
      {
         ulong ticket = HistoryDealGetTicket(i);
         if(ticket > 0)
         {
            if(HistoryDealGetInteger(ticket, DEAL_MAGIC) == Expert_MagicNumber)
            {
               datetime dealTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
               if(dealTime > LastTradeDate)
               {
                  TradesToday++;
                  LogInfo("Trade executed. Total trades today: ", IntegerToString(TradesToday));
                  break;
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Function-event handler "timer"                                   |
//+------------------------------------------------------------------+
void OnTimer(void)
{
   ExtExpert.OnTimer();

   //--- Update statistics periodically
   UpdateDailyStatistics();
}

//+------------------------------------------------------------------+
