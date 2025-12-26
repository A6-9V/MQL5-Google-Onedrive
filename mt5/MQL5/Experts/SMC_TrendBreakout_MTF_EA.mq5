//+------------------------------------------------------------------+
//| SMC_TrendBreakout_MTF_EA.mq5                                     |
//| EA: SMC (BOS/CHoCH) + Donchian breakout + MTF confirmation       |
//| Alerts / Push notifications + optional auto-trading              |
//+------------------------------------------------------------------+
#property strict

#include <Trade/Trade.mqh>

input group "Core"
input bool   EnableTrading         = false; // if false: alerts only
input long   MagicNumber           = 26012025;
input bool   OnePositionPerSymbol  = true;

input group "Main timeframe logic"
input ENUM_TIMEFRAMES SignalTF     = PERIOD_CURRENT;
input bool   FireOnClose           = true;  // use last closed bar on SignalTF

input group "SMC (structure)"
input bool   UseSMC                = true;
input bool   UseCHoCH              = true;

input group "Trend Breakout"
input bool   UseDonchianBreakout   = true;
input int    DonchianLookback      = 20;

input group "Lower timeframe confirmation"
input bool            RequireMTFConfirm = true;
input ENUM_TIMEFRAMES LowerTF           = PERIOD_M5;
input int             EMAFast           = 20;
input int             EMASlow           = 50;

input group "Risk / Orders"
input double FixedLots             = 0.10; // used when RiskPercent=0
input double RiskPercent           = 0.0;  // if >0: position size from SL distance
input int    ATRPeriod             = 14;
input double ATR_SL_Mult           = 2.0;
input double RR                    = 2.0;
input int    SlippagePoints        = 30;

input group "Notifications"
input bool   PopupAlerts           = true;
input bool   PushNotifications     = true;

CTrade gTrade;

int gFractalsHandle = INVALID_HANDLE;
int gAtrHandle      = INVALID_HANDLE;
int gEmaFastHandle  = INVALID_HANDLE;
int gEmaSlowHandle  = INVALID_HANDLE;

datetime gLastSignalBarTime = 0;
int gTrendDir = 0; // 1 bullish, -1 bearish, 0 unknown (for CHoCH labelling)

static double HighestHighMql(const MqlRates &rates[], const int start, const int count)
{
  double hh = -DBL_MAX;
  for(int i=start;i<start+count;i++) if(rates[i].high > hh) hh = rates[i].high;
  return hh;
}

static double LowestLowMql(const MqlRates &rates[], const int start, const int count)
{
  double ll = DBL_MAX;
  for(int i=start;i<start+count;i++) if(rates[i].low < ll) ll = rates[i].low;
  return ll;
}

static int GetMTFDir()
{
  if(!RequireMTFConfirm) return 0;
  if(gEmaFastHandle==INVALID_HANDLE || gEmaSlowHandle==INVALID_HANDLE) return 0;

  double fast[2], slow[2];
  ArraySetAsSeries(fast, true);
  ArraySetAsSeries(slow, true);
  if(CopyBuffer(gEmaFastHandle, 0, 1, 1, fast) != 1) return 0;
  if(CopyBuffer(gEmaSlowHandle, 0, 1, 1, slow) != 1) return 0;
  if(fast[0] > slow[0]) return 1;
  if(fast[0] < slow[0]) return -1;
  return 0;
}

static bool HasOpenPosition(const string sym, const long magic)
{
  for(int i=PositionsTotal()-1;i>=0;i--)
  {
    if(!PositionSelectByIndex(i)) continue;
    string ps = PositionGetString(POSITION_SYMBOL);
    if(ps != sym) continue;
    if((long)PositionGetInteger(POSITION_MAGIC) != magic) continue;
    return true;
  }
  return false;
}

static double NormalizeLots(const string sym, double lots)
{
  double minLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
  double maxLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
  double step   = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
  if(step <= 0) step = 0.01;
  lots = MathMax(minLot, MathMin(maxLot, lots));
  lots = MathFloor(lots/step) * step;
  int volDigits = (int)MathRound(-MathLog10(step));
  if(volDigits < 0) volDigits = 2;
  if(volDigits > 8) volDigits = 8;
  return NormalizeDouble(lots, volDigits);
}

static double LotsFromRisk(const string sym, const double riskPct, const double slPoints)
{
  if(riskPct <= 0.0) return 0.0;
  if(slPoints <= 0.0) return 0.0;

  double bal = AccountInfoDouble(ACCOUNT_BALANCE);
  double riskMoney = bal * (riskPct/100.0);

  double tickVal = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
  double tickSz  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
  if(tickVal <= 0 || tickSz <= 0) return 0.0;

  double point = SymbolInfoDouble(sym, SYMBOL_POINT);
  double valuePerPointPerLot = tickVal * (point / tickSz);
  if(valuePerPointPerLot <= 0) return 0.0;

  double lots = riskMoney / (slPoints * valuePerPointPerLot);
  return lots;
}

static void Notify(const string msg)
{
  if(PopupAlerts) Alert(msg);
  if(PushNotifications) SendNotification(msg);
}

int OnInit()
{
  ENUM_TIMEFRAMES tf = (SignalTF==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)_Period : SignalTF);

  gFractalsHandle = iFractals(_Symbol, tf);
  if(gFractalsHandle == INVALID_HANDLE) return INIT_FAILED;

  gAtrHandle = iATR(_Symbol, tf, ATRPeriod);
  if(gAtrHandle == INVALID_HANDLE) return INIT_FAILED;

  gEmaFastHandle = iMA(_Symbol, LowerTF, EMAFast, 0, MODE_EMA, PRICE_CLOSE);
  gEmaSlowHandle = iMA(_Symbol, LowerTF, EMASlow, 0, MODE_EMA, PRICE_CLOSE);

  gTrade.SetExpertMagicNumber(MagicNumber);
  gTrade.SetDeviationInPoints(SlippagePoints);
  return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
  if(gFractalsHandle != INVALID_HANDLE) IndicatorRelease(gFractalsHandle);
  if(gAtrHandle != INVALID_HANDLE) IndicatorRelease(gAtrHandle);
  if(gEmaFastHandle != INVALID_HANDLE) IndicatorRelease(gEmaFastHandle);
  if(gEmaSlowHandle != INVALID_HANDLE) IndicatorRelease(gEmaSlowHandle);
}

void OnTick()
{
  ENUM_TIMEFRAMES tf = (SignalTF==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)_Period : SignalTF);

  // Pull recent bars from SignalTF
  MqlRates rates[400];
  ArraySetAsSeries(rates, true);
  int needBars = MathMin(400, Bars(_Symbol, tf));
  if(needBars < 100) return;
  if(CopyRates(_Symbol, tf, 0, needBars, rates) < 100) return;

  const int sigBar = (FireOnClose ? 1 : 0);
  if(sigBar >= needBars-1) return;

  // Run once per signal bar
  datetime sigTime = rates[sigBar].time;
  if(sigTime == gLastSignalBarTime) return;
  gLastSignalBarTime = sigTime;

  // Get fractals (for structure break)
  int frNeed = MathMin(300, needBars);
  double upFr[300], dnFr[300];
  ArraySetAsSeries(upFr, true);
  ArraySetAsSeries(dnFr, true);
  if(CopyBuffer(gFractalsHandle, 0, 0, frNeed, upFr) <= 0) return;
  if(CopyBuffer(gFractalsHandle, 1, 0, frNeed, dnFr) <= 0) return;

  double lastSwingHigh = 0.0; datetime lastSwingHighT = 0;
  double lastSwingLow  = 0.0; datetime lastSwingLowT  = 0;
  for(int i=sigBar+2; i<frNeed; i++)
  {
    if(lastSwingHighT==0 && upFr[i] != 0.0) { lastSwingHigh = upFr[i]; lastSwingHighT = rates[i].time; }
    if(lastSwingLowT==0  && dnFr[i] != 0.0) { lastSwingLow  = dnFr[i]; lastSwingLowT  = rates[i].time; }
    if(lastSwingHighT!=0 && lastSwingLowT!=0) break;
  }

  // Donchian bounds
  if(DonchianLookback < 2) DonchianLookback = 2;
  int donStart = sigBar + 1;
  int donCount = DonchianLookback;
  if(donStart + donCount >= needBars) return;
  double donHigh = HighestHighMql(rates, donStart, donCount);
  double donLow  = LowestLowMql(rates, donStart, donCount);

  // Lower TF confirmation
  int mtfDir = GetMTFDir();
  bool mtfOkLong  = (!RequireMTFConfirm) || (mtfDir == 1);
  bool mtfOkShort = (!RequireMTFConfirm) || (mtfDir == -1);

  // Signals
  bool smcLong=false, smcShort=false, donLong=false, donShort=false;
  double closeSig = rates[sigBar].close;
  if(UseSMC)
  {
    if(lastSwingHighT!=0 && closeSig > lastSwingHigh) smcLong = true;
    if(lastSwingLowT!=0  && closeSig < lastSwingLow)  smcShort = true;
  }
  if(UseDonchianBreakout)
  {
    if(closeSig > donHigh) donLong = true;
    if(closeSig < donLow)  donShort = true;
  }

  bool finalLong  = (smcLong || donLong) && mtfOkLong;
  bool finalShort = (smcShort || donShort) && mtfOkShort;

  if(!finalLong && !finalShort) return;

  // CHoCH / BOS label (informational)
  string kind = "";
  if(finalLong)
  {
    int breakDir = 1;
    bool choch = (UseCHoCH && gTrendDir!=0 && breakDir != gTrendDir);
    kind = (choch ? "CHoCH↑" : "BOS↑");
    gTrendDir = breakDir;
  }
  if(finalShort)
  {
    int breakDir = -1;
    bool choch = (UseCHoCH && gTrendDir!=0 && breakDir != gTrendDir);
    kind = (choch ? "CHoCH↓" : "BOS↓");
    gTrendDir = breakDir;
  }

  string msg = StringFormat("%s %s %s | TF=%s | MTF=%s | SMC=%s DON=%s",
                            _Symbol,
                            (finalLong ? "LONG" : "SHORT"),
                            kind,
                            EnumToString(tf),
                            EnumToString(LowerTF),
                            (smcLong||smcShort ? "Y" : "N"),
                            (donLong||donShort ? "Y" : "N"));
  Notify(msg);

  if(!EnableTrading) return;
  if(OnePositionPerSymbol && HasOpenPosition(_Symbol, MagicNumber)) return;

  // ATR for SL distance
  double atr[3];
  ArraySetAsSeries(atr, true);
  if(CopyBuffer(gAtrHandle, 0, sigBar, 1, atr) != 1) return;
  double atrVal = atr[0];
  if(atrVal <= 0) return;

  double point = _Point;
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  double entry = (finalLong ? ask : bid);
  double slDist = ATR_SL_Mult * atrVal;
  double sl = (finalLong ? entry - slDist : entry + slDist);
  double tp = (finalLong ? entry + RR * slDist : entry - RR * slDist);

  // Respect broker minimum stop distance (in points)
  int stopsLevel = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
  double minStop = stopsLevel * point;
  if(minStop > 0)
  {
    if(finalLong)
    {
      if(entry - sl < minStop) sl = entry - minStop;
      if(tp - entry < minStop) tp = entry + minStop;
    }
    else
    {
      if(sl - entry < minStop) sl = entry + minStop;
      if(entry - tp < minStop) tp = entry - minStop;
    }
  }

  // Respect tick size / digits
  int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
  sl = NormalizeDouble(sl, digits);
  tp = NormalizeDouble(tp, digits);

  // Size
  double slPoints = MathAbs(entry - sl) / point;
  double lots = FixedLots;
  if(RiskPercent > 0.0)
  {
    double riskLots = LotsFromRisk(_Symbol, RiskPercent, slPoints);
    if(riskLots > 0.0) lots = riskLots;
  }
  lots = NormalizeLots(_Symbol, lots);
  if(lots <= 0.0) return;

  bool ok = false;
  if(finalLong)
    ok = gTrade.Buy(lots, _Symbol, 0.0, sl, tp, "SMC_TB_MTF");
  else
    ok = gTrade.Sell(lots, _Symbol, 0.0, sl, tp, "SMC_TB_MTF");

  if(!ok)
  {
    int err = GetLastError();
    Notify(StringFormat("Order failed: %d", err));
  }
}

