//+------------------------------------------------------------------+
//|                                                   MoneyFixed.mqh |
//|                                                       Jules      |
//+------------------------------------------------------------------+
#property copyright "Jules"
#property strict

#include <Expert\Money\MoneySizeOptimized.mqh>

//+------------------------------------------------------------------+
//| Class CMoneyFixed                                                |
//| Extends CMoneySizeOptimized to ensure robust volume normalization|
//+------------------------------------------------------------------+
class CMoneyFixed : public CMoneySizeOptimized
{
public:
   //+------------------------------------------------------------------+
   //| Check volume for Long position                                   |
   //+------------------------------------------------------------------+
   virtual double CheckOpenLong(double price, double sl)
   {
      double lots = CMoneySizeOptimized::CheckOpenLong(price, sl);
      return NormalizeVolume(lots);
   }

   //+------------------------------------------------------------------+
   //| Check volume for Short position                                  |
   //+------------------------------------------------------------------+
   virtual double CheckOpenShort(double price, double sl)
   {
      double lots = CMoneySizeOptimized::CheckOpenShort(price, sl);
      return NormalizeVolume(lots);
   }

protected:
   //+------------------------------------------------------------------+
   //| Normalize volume to symbol limits                                |
   //+------------------------------------------------------------------+
   double NormalizeVolume(double lots)
   {
      if(m_symbol == NULL) return 0.0;

      double min_vol = m_symbol.LotsMin();
      double max_vol = m_symbol.LotsMax();
      double step_vol = m_symbol.LotsStep();

      // If calculation returned 0 or negative, we might want to return min_vol
      // if we are aggressive, or 0 to skip.
      // However, 10014 often happens when we try to send 0.0 or a non-step value.
      // If the parent class returned 0.0, it likely means "no trade".
      if(lots <= 0.000001) return 0.0;

      // Clamp to limits
      if(lots < min_vol) lots = min_vol;
      if(lots > max_vol) lots = max_vol;

      // Normalize to step
      if(step_vol > 0.0)
      {
         lots = MathFloor(lots / step_vol) * step_vol;
         // Round to avoid floating point issues (e.g. 0.300000004 -> 0.3)
         lots = NormalizeDouble(lots, 8); // 8 decimals is safe for lots
      }

      // Final sanity check against min_vol again (in case floor dropped it below)
      if(lots < min_vol) lots = min_vol;

      return lots;
   }
};
