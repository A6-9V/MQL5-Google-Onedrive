//+------------------------------------------------------------------+
//|                                        ExpertMACD_Enhanced.mq5   |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2025, MetaQuotes Ltd."
#property link      "https://forge.mql5.io/LengKundee/mql5.git"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
#include <Expert\Signal\SignalMACD.mqh>
#include <Expert\Trailing\TrailingFixedPips.mqh>
#include <Expert\Money\MoneySizeOptimized.mqh>
#include <ZoloBridge.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Inp_Expert_Title                      ="ExpertMACD Enhanced";
int                      Expert_MagicNumber                    =27897;
bool                     Expert_EveryTick                      =false;
//--- inputs for signal
input int                Inp_Signal_MACD_PeriodFast            =12;          // MACD Fast Period
input int                Inp_Signal_MACD_PeriodSlow            =26;          // MACD Slow Period
input int                Inp_Signal_MACD_PeriodSignal          =9;           // MACD Signal Period
input ENUM_APPLIED_PRICE Inp_Signal_MACD_Applied               =PRICE_CLOSE; // MACD Applied Price
//--- inputs for trailing
input int                Inp_Trailing_FixedPips_StopLevel      =50;          // Stop Level (points)
input int                Inp_Trailing_FixedPips_ProfitLevel    =50;          // Profit Level (points)
//--- inputs for money
input double             Inp_Money_SizeOptimized_DecreaseFactor=3.0;         // Money Decrease Factor
input double             Inp_Money_SizeOptimized_Percent       =3.0;         // Money Percent
//--- inputs for ZOLO Integration
input group              "ZOLO Integration"
input bool               EnableWebRequest                      =true;
input string             WebRequestURL                         = "https://genx-fx.com/api/signal"; // ZOLO Bridge URL (Secure)

//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;

//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(-1);
     }
//--- Creation of signal object
   CSignalMACD *signal=new CSignalMACD;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(-2);
     }
//--- Add signal to expert (will be deleted automatically))
   if(!ExtExpert.InitSignal(signal))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing signal");
      ExtExpert.Deinit();
      return(-3);
     }
//--- Set signal parameters
   signal->PeriodFast(Inp_Signal_MACD_PeriodFast);
   signal->PeriodSlow(Inp_Signal_MACD_PeriodSlow);
   signal->PeriodSignal(Inp_Signal_MACD_PeriodSignal);
   signal->Applied(Inp_Signal_MACD_Applied);
//--- Check signal parameters
   if(!signal->ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error signal parameters");
      ExtExpert.Deinit();
      return(-4);
     }
//--- Creation of trailing object
   CTrailingFixedPips *trailing=new CTrailingFixedPips;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(-5);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(-6);
     }
//--- Set trailing parameters
   trailing->StopLevel(Inp_Trailing_FixedPips_StopLevel);
   trailing->ProfitLevel(Inp_Trailing_FixedPips_ProfitLevel);
//--- Check trailing parameters
   if(!trailing->ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error trailing parameters");
      ExtExpert.Deinit();
      return(-7);
     }
//--- Creation of money object
   CMoneySizeOptimized *money=new CMoneySizeOptimized;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(-8);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(-9);
     }
//--- Set money parameters
   money->DecreaseFactor(Inp_Money_SizeOptimized_DecreaseFactor);
   money->Percent(Inp_Money_SizeOptimized_Percent);
//--- Check money parameters
   if(!money->ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error money parameters");
      ExtExpert.Deinit();
      return(-10);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(-11);
     }

   // Send initial heartbeat
   SendSignalToBridge("ExpertMACD Enhanced Initialized on " + Symbol(), EnableWebRequest, WebRequestURL);
   EventSetTimer(3600);

//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| Function-event handler "tick"                                    |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| Function-event handler "trade"                                   |
//+------------------------------------------------------------------+
void OnTrade(void)
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| Function-event handler "timer"                                   |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   ExtExpert.OnTimer();

   string timeStr = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
   string msg = "ExpertMACD Enhanced Heartbeat: " + timeStr;
   SendSignalToBridge(msg, EnableWebRequest, WebRequestURL);
  }
//+------------------------------------------------------------------+
