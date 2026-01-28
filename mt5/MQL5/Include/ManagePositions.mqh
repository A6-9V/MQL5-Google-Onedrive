//+------------------------------------------------------------------+
//|                                              ManagePositions.mqh |
//|                                                       Jules      |
//+------------------------------------------------------------------+
#property copyright "Jules"
#property strict

#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\Trade.mqh>

class CPositionManager
{
private:
   CPositionInfo  m_posInfo;
   CSymbolInfo    m_symInfo;
   CTrade*        m_trade; // Pointer to external CTrade

public:
   void Init(CTrade* tradeObj)
   {
      m_trade = tradeObj;
   }

   void Manage(long magic, string symbol,
               bool useBE, double beTriggerPips, double bePlusPips,
               bool useTrail, double trailStartPips, double trailStepPips)
   {
      if(m_trade == NULL) return;
      if(!m_symInfo.Name(symbol)) return;
      if(!m_symInfo.RefreshRates()) return;

      double point = m_symInfo.Point();
      int digits = m_symInfo.Digits();

      // Calculate point value for pips (assuming standard 1 pip = 10 points)
      // For JPY pairs or others, usually it's consistent if we use Point * 10 for "Pip"
      // But let's use the standard "10 points = 1 pip" convention.
      double pipSize = point * 10.0;

      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         if(!m_posInfo.SelectByIndex(i)) continue;
         if(m_posInfo.Magic() != magic) continue;
         if(m_posInfo.Symbol() != symbol) continue;

         double openPrice = m_posInfo.PriceOpen();
         double currentSL = m_posInfo.StopLoss();
         double currentTP = m_posInfo.TakeProfit();
         ulong ticket = m_posInfo.Ticket();

         double newSL = currentSL;
         double profitPips = 0.0;

         if(m_posInfo.PositionType() == POSITION_TYPE_BUY)
         {
            double bid = m_symInfo.Bid();
            profitPips = (bid - openPrice) / pipSize;

            // Break Even
            if(useBE && profitPips >= beTriggerPips)
            {
               double beLevel = openPrice + (bePlusPips * pipSize);
               // Move SL to BE if current SL is below BE
               if(currentSL < beLevel || currentSL == 0)
                  newSL = beLevel;
            }

            // Trailing
            if(useTrail && profitPips >= trailStartPips)
            {
               double trailLevel = bid - (trailStepPips * pipSize);
               // Move SL up if trail level is higher than current SL
               if(trailLevel > newSL || newSL == 0)
                  newSL = trailLevel;
            }
         }
         else if(m_posInfo.PositionType() == POSITION_TYPE_SELL)
         {
            double ask = m_symInfo.Ask();
            profitPips = (openPrice - ask) / pipSize;

            // Break Even
            if(useBE && profitPips >= beTriggerPips)
            {
               double beLevel = openPrice - (bePlusPips * pipSize);
               // Move SL to BE if current SL is above BE
               if(currentSL > beLevel || currentSL == 0)
                  newSL = beLevel;
            }

            // Trailing
            if(useTrail && profitPips >= trailStartPips)
            {
               double trailLevel = ask + (trailStepPips * pipSize);
               // Move SL down if trail level is lower than current SL
               if(trailLevel < newSL || newSL == 0)
                  newSL = trailLevel;
            }
         }

         if(MathAbs(newSL - currentSL) > point)
         {
            // Normalize
            newSL = NormalizeDouble(newSL, digits);

            // Check stops level
            double stopLevel = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
            bool valid = true;

            if(m_posInfo.PositionType() == POSITION_TYPE_BUY)
            {
               if(m_symInfo.Bid() - newSL < stopLevel) valid = false;
            }
            else
            {
               if(newSL - m_symInfo.Ask() < stopLevel) valid = false;
            }

            if(valid)
            {
               if(m_trade->PositionModify(ticket, newSL, currentTP))
               {
                  Print("ManagePositions: Position #", ticket, " SL moved to ", newSL);
               }
            }
         }
      }
   }
};
