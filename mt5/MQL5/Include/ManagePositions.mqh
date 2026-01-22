//+------------------------------------------------------------------+
//|                                              ManagePositions.mqh |
//|                                                       Jules      |
//+------------------------------------------------------------------+
#property copyright "Jules"
#property strict

#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\Trade.mqh>

// Objects required by ManagePositions
// These should ideally be passed to the function or class members,
// but based on the snippet provided, they are expected to be global.
CPositionInfo posInfo;
CSymbolInfo   symInfo;
CTrade        trade;

// Configuration variables (External inputs expected from EA)
// You should define these in your EA inputs and remove 'extern' here if included there,
// or use this file as a base.
extern int       CFG_Magic_Number     = 0;
extern bool      CFG_Use_BreakEven    = false;
extern double    CFG_BE_Trigger_Pips  = 0;
extern double    CFG_BE_Plus_Pips     = 0;
extern bool      CFG_Use_Trailing     = false;
extern double    CFG_Trail_Start_Pips = 0;
extern double    CFG_Trail_Step_Pips  = 0;
extern bool      CFG_Enable_Logging   = true;

//+------------------------------------------------------------------+
//| Manage existing positions (trailing, break-even)                  |
//+------------------------------------------------------------------+
void ManagePositions()
{
   // Ensure Symbol Info is initialized for current symbol
   if(symInfo.Name(_Symbol))
      symInfo.RefreshRates();
   else
      return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!posInfo.SelectByIndex(i))
         continue;

      //--- Only manage our positions
      if(posInfo.Magic() != CFG_Magic_Number)
         continue;

      //--- Only manage positions on current symbol
      if(posInfo.Symbol() != _Symbol)
         continue;

      double openPrice = posInfo.PriceOpen();
      double currentSL = posInfo.StopLoss();
      double currentTP = posInfo.TakeProfit();
      double point = symInfo.Point();
      ulong ticket = posInfo.Ticket();

      //--- Calculate profit in pips
      double profitPips = 0;
      double newSL = currentSL;

      if(posInfo.PositionType() == POSITION_TYPE_BUY)
      {
         double bid = symInfo.Bid();
         profitPips = (bid - openPrice) / point / 10;

         //--- Break-even
         if(CFG_Use_BreakEven && profitPips >= CFG_BE_Trigger_Pips)
         {
            double beLevel = openPrice + (CFG_BE_Plus_Pips * point * 10);
            if(currentSL < beLevel)
            {
               newSL = beLevel;
            }
         }

         //--- Trailing stop
         if(CFG_Use_Trailing && profitPips >= CFG_Trail_Start_Pips)
         {
            double trailLevel = bid - (CFG_Trail_Step_Pips * point * 10);
            if(trailLevel > newSL)
            {
               newSL = trailLevel;
            }
         }
      }
      else if(posInfo.PositionType() == POSITION_TYPE_SELL)
      {
         double ask = symInfo.Ask();
         profitPips = (openPrice - ask) / point / 10;

         //--- Break-even
         if(CFG_Use_BreakEven && profitPips >= CFG_BE_Trigger_Pips)
         {
            double beLevel = openPrice - (CFG_BE_Plus_Pips * point * 10);
            // FIXED: Added missing || operator
            if(currentSL > beLevel || currentSL == 0)
            {
               newSL = beLevel;
            }
         }

         //--- Trailing stop
         if(CFG_Use_Trailing && profitPips >= CFG_Trail_Start_Pips)
         {
            double trailLevel = ask + (CFG_Trail_Step_Pips * point * 10);
            if(trailLevel < newSL || currentSL == 0)
            {
               newSL = trailLevel;
            }
         }
      }

      //--- Modify position if SL changed
      if(newSL != currentSL && newSL != 0)
      {
         newSL = NormalizeDouble(newSL, symInfo.Digits());

         if(trade.PositionModify(ticket, newSL, currentTP))
         {
            if(CFG_Enable_Logging)
               Print("✓ Position #", ticket, " SL moved to ", newSL, " (profit: ", DoubleToString(profitPips, 1), " pips)");
         }
      }
   }
}
