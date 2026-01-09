//+------------------------------------------------------------------+
//| SMC_TrendBreakout_MTF_EA.mq5                                     |
//| EA: SMC (BOS/CHoCH) + Donchian breakout + MTF confirmation       |
//| Alerts / Push notifications + optional auto-trading              |
//+------------------------------------------------------------------+
#property strict

#include <Trade/Trade.mqh>

enum ENUM_SL_MODE
{
  SL_ATR = 0,          // ATR * multiplier
  SL_SWING = 1,        // last confirmed swing (fractal) + buffer
  SL_FIXED_POINTS = 2  // fixed points
};

enum ENUM_TP_MODE
{
  TP_RR = 0,               // RR * SL distance
  TP_FIXED_POINTS = 1,     // fixed points
  TP_DONCHIAN_WIDTH = 2    // Donchian channel width * multiplier
};

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
input ENUM_SL_MODE SLMode                = SL_ATR;
input ENUM_TP_MODE TPMode                = TP_RR;

input double FixedLots             = 0.10; // used when RiskPercent=0
input double RiskPercent           = 0.0;  // if >0: position size from SL distance
input bool   RiskUseEquity         = true; // recommended
input bool   RiskClampToFreeMargin = true; // reduce lots if not enough margin

input int    ATRPeriod             = 14;
input double ATR_SL_Mult           = 2.0;

input int    SwingSLBufferPoints   = 20;   // extra points beyond swing (SL_SWING)
input int    FixedSLPoints         = 500;  // SL_FIXED_POINTS

input double RR                    = 2.0;
input int    FixedTPPoints         = 1000; // TP_FIXED_POINTS
input double DonchianTP_Mult       = 1.0;  // TP_DONCHIAN_WIDTH

input int    SlippagePoints        = 30;

input group "Notifications"
input bool   PopupAlerts           = true;
input bool   PushNotifications     = true;
input bool   EnableWebRequest      = false; // enable custom web request
// IMPORTANT: URL must be added to MT5 terminal's allowed list:
// Tools -> Options -> Expert Advisors -> Allow WebRequest for listed URL
// Integrated with: https://github.com/Mouy-leng/-LengKundee-mql5.github.io.git
// Plugin: ZOLO-A6-9V-NUNA-
input string WebRequestURL         = "https://soloist.ai/a6-9v";

// --- Web request (for external integrations)
static void SendWebRequest(const string msg)
{
  if(!EnableWebRequest || WebRequestURL == "") return;

  char data[], result[];
  string headers;
  int timeout = 5000; // 5 seconds

  // Simple JSON payload
  string json = "{ \"event\": \"signal\", \"message\": \"" + msg + "\" }";
  StringToCharArray(json, data, 0, StringLen(json), CP_UTF8);

  ResetLastError();
  int res = WebRequest("POST", WebRequestURL, "Content-Type: application/json", timeout, data, result, headers);

  if(res == -1)
  {
    Print("WebRequest error: ", GetLastError());
  }
}

CTrade gTrade;

int gFractalsHandle = INVALID_HANDLE;
int gAtrHandle      = INVALID_HANDLE;
int gEmaFastHandle  = INVALID_HANDLE;
int gEmaSlowHandle  = INVALID_HANDLE;

datetime gLastSignalBarTime = 0;
int gTrendDir = 0; // 1 bullish, -1 bearish, 0 unknown (for CHoCH labelling)

// --- MTF Caching (performance)
datetime gLastMtfBarTime = 0;
int      gCachedMtfDir   = 0;

// --- Cached symbol properties (performance)
// Initialized once in OnInit to avoid repeated calls in OnTick.
static double G_POINT = 0.0;
static double G_TICK_SIZE = 0.0;
static double G_TICK_VALUE = 0.0;
static double G_VOL_MIN = 0.0;
static double G_VOL_MAX = 0.0;
static double G_VOL_STEP = 0.0;
static int    G_DIGITS = 2;
static int    G_STOPS_LEVEL = 0;

// PERF: This function is cached. It only recalculates when a new bar appears on the LowerTF.
// This prevents expensive, redundant CopyBuffer calls on every tick of the primary chart.
static int GetMTFDir()
{
  if(!RequireMTFConfirm) return 0;

  // Check if a new COMPLETED bar has formed on the lower timeframe
  datetime mtfTime[1]; // Array to hold one timestamp
  ArraySetAsSeries(mtfTime, true);
  // Read the timestamp of the last completed bar (index 1)
  if(CopyTime(_Symbol, LowerTF, 1, 1, mtfTime) != 1) return 0; // On error, return safe default, not stale cache
  if(mtfTime[0] == gLastMtfBarTime) return gCachedMtfDir; // No new bar, return cached

  // --- New bar detected, recalculate ---
  gLastMtfBarTime = mtfTime[0];

  if(gEmaFastHandle==INVALID_HANDLE || gEmaSlowHandle==INVALID_HANDLE)
  {
    gCachedMtfDir = 0; // Ensure cache is clean if handles are bad
    return 0;
  }

  double fast[1], slow[1];
  ArraySetAsSeries(fast, true);
  ArraySetAsSeries(slow, true);
  // Read from the last completed bar (index 1), consistent with the time check
  if(CopyBuffer(gEmaFastHandle, 0, 1, 1, fast) != 1)
  {
      gCachedMtfDir = 0; // On error, reset cache to safe default
      return 0;
  }
  if(CopyBuffer(gEmaSlowHandle, 0, 1, 1, slow) != 1)
  {
      gCachedMtfDir = 0; // On error, reset cache to safe default
      return 0;
  }

  if(fast[0] > slow[0]) gCachedMtfDir = 1;
  else if(fast[0] < slow[0]) gCachedMtfDir = -1;
  else gCachedMtfDir = 0;

  return gCachedMtfDir;
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
  // Use cached properties
  lots = MathMax(G_VOL_MIN, MathMin(G_VOL_MAX, lots));
  lots = MathFloor(lots/G_VOL_STEP) * G_VOL_STEP;
  int volDigits = (int)MathRound(-MathLog10(G_VOL_STEP));
  if(volDigits < 0) volDigits = 2;
  if(volDigits > 8) volDigits = 8;
  return NormalizeDouble(lots, volDigits);
}

static double LotsFromRisk(const string sym, const double riskPct, const double slPoints, const bool useEquity)
{
  if(riskPct <= 0.0) return 0.0;
  if(slPoints <= 0.0) return 0.0;

  double base = (useEquity ? AccountInfoDouble(ACCOUNT_EQUITY) : AccountInfoDouble(ACCOUNT_BALANCE));
  double riskMoney = base * (riskPct/100.0);

  if(G_TICK_VALUE <= 0 || G_TICK_SIZE <= 0) return 0.0;
  double valuePerPointPerLot = G_TICK_VALUE * (G_POINT / G_TICK_SIZE);
  if(valuePerPointPerLot <= 0) return 0.0;

  double lots = riskMoney / (slPoints * valuePerPointPerLot);
  return lots;
}

static double NormalizePriceToTick(const string sym, double price)
{
  // Use cached properties
  double tick = (G_TICK_SIZE > 0.0 ? G_TICK_SIZE : G_POINT);
  if(tick > 0.0) price = MathRound(price / tick) * tick;
  return NormalizeDouble(price, G_DIGITS);
}

static double MinStopDistancePrice(const string sym)
{
  // Use cached properties
  return (G_STOPS_LEVEL > 0 ? G_STOPS_LEVEL * G_POINT : 0.0);
}

static double ClampLotsToMargin(const string sym, const ENUM_ORDER_TYPE type, double lots, const double price)
{
  if(lots <= 0.0) return 0.0;
  if(!RiskClampToFreeMargin) return lots;

  double freeMargin = AccountInfoDouble(ACCOUNT_FREEMARGIN);
  if(freeMargin <= 0.0) return 0.0;

  double margin=0.0;
  if(!OrderCalcMargin(type, sym, lots, price, margin)) return lots; // if broker doesn't provide calc, don't block
  if(margin <= freeMargin) return lots;

  // Estimate from 1-lot margin, then clamp down.
  double margin1=0.0;
  if(!OrderCalcMargin(type, sym, 1.0, price, margin1)) return lots;
  if(margin1 <= 0.0) return lots;

  double maxLots = (freeMargin / margin1) * 0.95; // small cushion
  return MathMin(lots, maxLots);
}

static void Notify(const string msg)
{
  if(PopupAlerts) Alert(msg);
  if(PushNotifications) SendNotification(msg);
  SendWebRequest(msg);
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

  // --- Cache symbol properties for performance
  G_POINT = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  G_TICK_SIZE = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
  G_TICK_VALUE = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
  if(G_TICK_VALUE <= 0.0) G_TICK_VALUE = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
  G_VOL_MIN = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
  G_VOL_MAX = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
  G_VOL_STEP = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
  if(G_VOL_STEP <= 0) G_VOL_STEP = 0.01;
  G_DIGITS = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

  int stopsLevel  = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
  int freezeLevel = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
  G_STOPS_LEVEL = MathMax(stopsLevel, freezeLevel);

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
  const int sigBar = (FireOnClose ? 1 : 0);

  // --- New bar check (performance optimization) ---
  // Exit early if a new bar hasn't formed on the signal timeframe.
  // This avoids the expensive CopyRates call on every tick for the same bar.
  datetime sigTime = (datetime)iTime(_Symbol, tf, sigBar);
  if(sigTime > 0 && sigTime == gLastSignalBarTime)
  {
    return;
  }
  gLastSignalBarTime = sigTime;

  // Pull recent bars from SignalTF
  MqlRates rates[400];
  ArraySetAsSeries(rates, true);
  int needBars = MathMin(400, Bars(_Symbol, tf));
  if(needBars < 100) return;
  if(CopyRates(_Symbol, tf, 0, needBars, rates) < 100) return;

  if(sigBar >= needBars-1) return;

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

  // Donchian bounds (optimized)
  // Using built-in iHighest/iLowest is faster than manual loops in MQL.
  int donLookback = (DonchianLookback < 2 ? 2 : DonchianLookback);
  int donStart = sigBar + 1;
  int donCount = donLookback;
  if(donStart + donCount >= needBars) return;
  int highIndex = iHighest(_Symbol, tf, MODE_HIGH, donCount, donStart);
  int lowIndex  = iLowest(_Symbol, tf, MODE_LOW, donCount, donStart);
  if(highIndex < 0 || lowIndex < 0) return; // Error case, data not ready
  // PERF: Access price data directly from the copied 'rates' array.
  // This avoids the function call overhead of iHigh/iLow, as the data is already in memory.
  double donHigh = rates[highIndex].high;
  double donLow  = rates[lowIndex].low;

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

  // ATR (always calculated; used for SL_ATR and fallbacks)
  double atr[3];
  ArraySetAsSeries(atr, true);
  if(CopyBuffer(gAtrHandle, 0, sigBar, 1, atr) != 1) return;
  double atrVal = atr[0];
  if(atrVal <= 0) return;

  // Cached point size (fallback to terminal-provided _Point)
  double point = (G_POINT > 0.0 ? G_POINT : _Point);
  // PERF: Use pre-defined Ask/Bid globals in OnTick to avoid function call overhead.
  double ask = Ask;
  double bid = Bid;

  double entry = (finalLong ? ask : bid);
  double sl = 0.0, tp = 0.0;

  // --- Build SL
  if(SLMode == SL_SWING)
  {
    // For a long breakout, protective SL typically goes below the last confirmed swing low.
    // For a short breakout, SL goes above the last confirmed swing high.
    double buf = SwingSLBufferPoints * G_POINT;
    if(finalLong && lastSwingLowT != 0 && lastSwingLow > 0.0) sl = lastSwingLow - buf;
    if(finalShort && lastSwingHighT != 0 && lastSwingHigh > 0.0) sl = lastSwingHigh + buf;

    // Fallback if swing is missing/invalid for current entry.
    if(finalLong && (sl <= 0.0 || sl >= entry)) sl = entry - (ATR_SL_Mult * atrVal);
    if(finalShort && (sl <= 0.0 || sl <= entry)) sl = entry + (ATR_SL_Mult * atrVal);
  }
  else if(SLMode == SL_FIXED_POINTS)
  {
    double dist = MathMax(1, FixedSLPoints) * point;
    sl = (finalLong ? entry - dist : entry + dist);
  }
  else // SL_ATR
  {
    sl = (finalLong ? entry - (ATR_SL_Mult * atrVal) : entry + (ATR_SL_Mult * atrVal));
  }

  // --- Build TP
  if(TPMode == TP_FIXED_POINTS)
  {
    double dist = MathMax(1, FixedTPPoints) * point;
    tp = (finalLong ? entry + dist : entry - dist);
  }
  else if(TPMode == TP_DONCHIAN_WIDTH)
  {
    double width = MathAbs(donHigh - donLow);
    if(width <= 0.0) width = ATR_SL_Mult * atrVal; // fallback
    double dist = DonchianTP_Mult * width;
    tp = (finalLong ? entry + dist : entry - dist);
  }
  else // TP_RR
  {
    double slDist = MathAbs(entry - sl);
    tp = (finalLong ? entry + (RR * slDist) : entry - (RR * slDist));
  }

  // Respect broker minimum stop distance (in points)
  double minStop = MinStopDistancePrice(_Symbol);
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
  sl = NormalizePriceToTick(_Symbol, sl);
  tp = NormalizePriceToTick(_Symbol, tp);

  // Size
  double slPoints = MathAbs(entry - sl) / point;
  double lots = FixedLots;
  if(RiskPercent > 0.0)
  {
    double riskLots = LotsFromRisk(_Symbol, RiskPercent, slPoints, RiskUseEquity);
    if(riskLots > 0.0) lots = riskLots;
  }
  lots = NormalizeLots(_Symbol, ClampLotsToMargin(_Symbol, (finalLong ? ORDER_TYPE_BUY : ORDER_TYPE_SELL), lots, entry));
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

