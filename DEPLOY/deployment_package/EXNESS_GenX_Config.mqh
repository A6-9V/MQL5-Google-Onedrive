//+------------------------------------------------------------------+
//|                                         EXNESS_GenX_Config.mqh   |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Inp_Expert_Title                      ="EXNESS GenX Trader v2.0";
int                      Expert_MagicNumber                    =27895;
bool                     Expert_EveryTick                      =false;
input bool               EnableTrading                         =true; // Enable Trading
//--- inputs for signal
input int                Inp_Signal_MA_Period                  =30;          // MA Period
input int                Inp_Signal_MA_Shift                   =0;           // MA Shift
input ENUM_MA_METHOD     Inp_Signal_MA_Method                  =MODE_EMA;    // MA Method
input ENUM_APPLIED_PRICE Inp_Signal_MA_Applied                 =PRICE_CLOSE; // MA Applied Price
//--- inputs for RSI filter
input int                Inp_Signal_RSI_Period                 =14;          // RSI Period
input double             Inp_Signal_RSI_Weight                 =0.5;         // RSI Weight (0.0 to 1.0)
//--- inputs for trailing
input double             Inp_Trailing_ParabolicSAR_Step        =0.02;        // PSAR Step
input double             Inp_Trailing_ParabolicSAR_Maximum     =0.2;         // PSAR Maximum
//--- inputs for money
input double             Inp_Money_SizeOptimized_DecreaseFactor=3.0;         // Money Decrease Factor
input double             Inp_Money_SizeOptimized_Percent       =1.0;         // Risk Percent
//--- inputs for ZOLO Integration
input group              "ZOLO Integration"
input bool               EnableWebRequest                      =true;
input string             WebRequestURL                         = "http://203.147.134.90";
