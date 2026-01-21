//+------------------------------------------------------------------+
//| SMC_TrendBreakout_MTF_EA.mq5                                     |
//| EA: SMC (BOS/CHoCH) + Donchian breakout + MTF confirmation       |
//| Alerts / Push notifications + optional auto-trading              |
//| AI Integration: Gemini API for signal confirmation               |
//| Updated by: Jules (AI Assistant) for LengKundee                  |
//+------------------------------------------------------------------+
#property strict
#property copyright "LengKundee"
#property link      "https://forge.mql5.io/LengKundee/mql5.git"
#property version   "1.20"

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
input bool   EnableTrading         = true; // if false: alerts only
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
input double RiskPercent           = 1.0;  // if >0: position size from SL distance
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

input group "Gemini AI"
input bool   UseGeminiFilter       = false; // Enable Gemini AI confirmation
input string GeminiApiKey          = "";    // Paste your Gemini API Key here
input string GeminiModel           = "gemini-1.5-flash"; // e.g., gemini-1.5-flash, gemini-1.5-pro, gemini-3.0-flash
input string PerplexityUrl         = "https://www.perplexity.ai/finance/EURZ"; // Bridge to Perplexity (Manual/Context)

input group "Notifications"
input bool   PopupAlerts           = true;
input bool   PushNotifications     = true;

input group "ZOLO Integration"
input bool   EnableWebRequest      = false;
input string WebRequestURL         = "http://203.147.134.90";

CTrade gTrade;

int gFractalsHandle = INVALID_HANDLE;
int gAtrHandle      = INVALID_HANDLE;
int gDonchianHandle = INVALID_HANDLE;
int gEmaFastHandle  = INVALID_HANDLE;
int gEmaSlowHandle  = INVALID_HANDLE;

datetime gLastSignalBarTime = 0;
int gTrendDir = 0; // 1 bullish, -1 bearish, 0 unknown (for CHoCH labelling)

// PERF: Cached signal timeframe.
ENUM_TIMEFRAMES gSignalTf = PERIOD_CURRENT;

// PERF: Cached validated Donchian lookback.
int gDonchianLookback = 20;

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
static double G_MIN_STOP_PRICE = 0.0;

// --- Cached MTF direction (performance)
// The lower-TF EMA direction only needs to be checked once per new bar on that TF.
static datetime g_mtfDir_lastCheckTime = 0;
static int      g_mtfDir_cachedValue = 0;

// --- Helper ---
string SanitizeJSON(string text)
{
  string res = text;
  StringReplace(res, "\\", "\\\\");
  StringReplace(res, "\"", "\\\"");
  StringReplace(res, "\n", " ");
  StringReplace(res, "\r", " ");
  return res;
}

// --- AI Helper ---
bool AskGemini(string symbol, string type, double price)
{
  if (GeminiApiKey == "")
  {
    Print("Gemini API Key missing. Please set 'GeminiApiKey' in inputs.");
    return false;
  }

  string url = "https://generativelanguage.googleapis.com/v1beta/models/" + GeminiModel + ":generateContent?key=" + GeminiApiKey;

  // Construct a simple prompt
  string prompt = StringFormat("I am a trading bot. I have a %s signal for %s at price %f. "
                               "Trend Direction: %s. "
                               "Reference Context: %s "
                               "Reply strictly with just 'YES' to confirm the trade, or 'NO' to reject it. "
                               "Do not provide any other text or JSON.",
                               type, symbol, price, (gTrendDir > 0 ? "BULLISH" : (gTrendDir < 0 ? "BEARISH" : "UNKNOWN")), PerplexityUrl);

  // JSON Body: {"contents":[{"parts":[{"text":"prompt"}]}]}
  string body = "{\"contents\":[{\"parts\":[{\"text\":\"" + SanitizeJSON(prompt) + "\"}]}]}";

  char data[];
  int len = StringToCharArray(body, data, 0, WHOLE_ARRAY, CP_UTF8);
  // Remove null terminator
  if (len > 0) ArrayResize(data, len - 1);

  char result[];
  string result_headers;
  string headers = "Content-Type: application/json";

  // 5 seconds timeout
  int res = WebRequest("POST", url, headers, 5000, data, result, result_headers);

  if (res == 200)
  {
    string resp = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
    // Print("Gemini Response: ", resp); // Debug

    // Naive parsing: check if "YES" is present in the text field
    // Ideally we parse JSON, but searching for "YES" (case insensitive or specific) is robust enough for this simple prompt.
    // The model might reply "YES" or "YES." or "decision: YES".
    if (StringFind(resp, "YES") >= 0) return true;
  }
  else
  {
    PrintFormat("Gemini Request failed. Code: %d. URL: %s", res, url);
    if(res == -1) Print("Error: ", GetLastError());
  }

  return false;
}

// --- ZOLO Bridge ---
void SendSignalToBridge(string msg)
{
  if (!EnableWebRequest || WebRequestURL == "") return;

  string body = "{\"event\":\"signal\",\"message\":\"" + SanitizeJSON(msg) + "\"}";

  char data[];
  int len = StringToCharArray(body, data, 0, WHOLE_ARRAY, CP_UTF8);
  if (len > 0) ArrayResize(data, len - 1); // Remove null terminator

  char result[];
  string result_headers;
  string headers = "Content-Type: application/json";

  int res = WebRequest("POST", WebRequestURL, headers, 5000, data, result, result_headers);

  if (res != 200)
  {
    PrintFormat("ZOLO WebRequest failed. Code: %d. URL: %s", res, WebRequestURL);
    if(res == -1) Print("Error: ", GetLastError());
  }
}

static int GetMTFDir()
{
  if(!RequireMTFConfirm) return 0;
  if(gEmaFastHandle==INVALID_HANDLE || gEmaSlowHandle==INVALID_HANDLE) return 0;

  // PERF: Only check for new MTF direction on a new bar of the LowerTF.
  datetime mtf_time[1];
  if(CopyTime(_Symbol, LowerTF, 0, 1, mtf_time) != 1) return 0; // if data not ready, return neutral
  if(mtf_time[0] == g_mtfDir_lastCheckTime) return g_mtfDir_cachedValue; // return cached value
  g_mtfDir_lastCheckTime = mtf_time[0];

  double fast[2], slow[2];
  ArraySetAsSeries(fast, true);
  ArraySetAsSeries(slow, true);
  // Using CopyBuffer on bar 1 (last completed bar) to avoid repainting.
  if(CopyBuffer(gEmaFastHandle, 0, 1, 1, fast) != 1) { g_mtfDir_cachedValue=0; return 0; }
  if(CopyBuffer(gEmaSlowHandle, 0, 1, 1, slow) != 1) { g_mtfDir_cachedValue=0; return 0; }

  if(fast[0] > slow[0]) g_mtfDir_cachedValue = 1;
  else if(fast[0] < slow[0]) g_mtfDir_cachedValue = -1;
  else g_mtfDir_cachedValue = 0;

  return g_mtfDir_cachedValue;
}

// --- Cached ATR value (performance)
// The ATR only needs to be calculated once per OnTick event, and only if needed.
static double   g_atr_cachedValue = 0.0;
static datetime g_atr_cacheTime = 0; // The bar time this cache is valid for.

// PERF: Lazy-loads the ATR value for the current signal bar.
// This avoids an expensive CopyBuffer call if the SL/TP modes do not require ATR.
static double GetATR(const int signalBar, const datetime signalBarTime)
{
  // If we already calculated ATR for this specific bar, return the cached value.
  if(g_atr_cacheTime == signalBarTime && g_atr_cachedValue > 0.0)
  {
    return g_atr_cachedValue;
  }

  // Reset cache if the bar time is different.
  if(g_atr_cacheTime != signalBarTime)
  {
    g_atr_cachedValue = 0.0;
    g_atr_cacheTime = signalBarTime;
  }

  if(gAtrHandle == INVALID_HANDLE) return 0.0;

  double atr[1];
  if(CopyBuffer(gAtrHandle, 0, signalBar, 1, atr) != 1) return 0.0;
  if(atr[0] <= 0.0) return 0.0;

  g_atr_cachedValue = atr[0]; // Cache the valid ATR.
  return g_atr_cachedValue;
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
}

int OnInit()
{
  // PERF: Calculate and cache the signal timeframe once.
  gSignalTf = (SignalTF==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)_Period : SignalTF);

  gFractalsHandle = iFractals(_Symbol, gSignalTf);
  if(gFractalsHandle == INVALID_HANDLE) return INIT_FAILED;

  gAtrHandle = iATR(_Symbol, gSignalTf, ATRPeriod);
  if(gAtrHandle == INVALID_HANDLE) return INIT_FAILED;

  // PERF: Validate and cache Donchian lookback once.
  gDonchianLookback = (DonchianLookback < 2 ? 2 : DonchianLookback);
  gDonchianHandle = iDonchian(_Symbol, gSignalTf, gDonchianLookback);
  if(gDonchianHandle == INVALID_HANDLE) return INIT_FAILED;

  gEmaFastHandle = iMA(_Symbol, LowerTF, EMAFast, 0, MODE_EMA, PRICE_CLOSE);
  gEmaSlowHandle = iMA(_Symbol, LowerTF, EMASlow, 0, MODE_EMA, PRICE_CLOSE);

  gTrade.SetExpertMagicNumber(MagicNumber);
  gTrade.SetDeviationInPoints(SlippagePoints);

  // --- Cache symbol properties for performance
  G_POINT = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  if(G_POINT <= 0.0) G_POINT = _Point; // Fallback
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
  G_MIN_STOP_PRICE = (G_STOPS_LEVEL > 0 ? G_STOPS_LEVEL * G_POINT : 0.0);

  // PERF: Validate and cache Donchian lookback once.
  gDonchianLookback = (DonchianLookback < 2 ? 2 : DonchianLookback);

  return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
  if(gFractalsHandle != INVALID_HANDLE) IndicatorRelease(gFractalsHandle);
  if(gAtrHandle != INVALID_HANDLE) IndicatorRelease(gAtrHandle);
  if(gDonchianHandle != INVALID_HANDLE) IndicatorRelease(gDonchianHandle);
  if(gEmaFastHandle != INVALID_HANDLE) IndicatorRelease(gEmaFastHandle);
  if(gEmaSlowHandle != INVALID_HANDLE) IndicatorRelease(gEmaSlowHandle);
}

void OnTick()
{
  // PERF: Early exit if a new bar hasn't formed on the signal timeframe.
  // This is a critical optimization that prevents expensive calls (like CopyRates)
  // from running on every single price tick within the same bar.
  const int sigBar = (FireOnClose ? 1 : 0);
  datetime time[2]; // Index 0 is current bar, 1 is last closed bar.
  ArraySetAsSeries(time, true);
  // Ensure we have enough bars to get the time for our signal bar.
  if(CopyTime(_Symbol, gSignalTf, 0, sigBar + 1, time) <= sigBar) return;

  datetime sigTime = time[sigBar];
  if(sigTime == gLastSignalBarTime) return; // Not a new signal bar, exit early.

  // Now that we've passed all checks, we can commit to this bar time.
  gLastSignalBarTime = sigTime;

  // --- Data Loading & Primary Signals ---
  // PERF: Defer expensive data loading. Only load full history if needed.
  double lastSwingHigh = 0.0; datetime lastSwingHighT = 0;
  double lastSwingLow  = 0.0; datetime lastSwingLowT  = 0;
  double closeSig = 0.0;

  // PERF: Lazy Calculation - only search for swings if needed for SMC or SL.
  if(UseSMC || SLMode == SL_SWING)
  {
    // PERF: Array allocation is deferred to this block to avoid overhead on the lighter path.
    MqlRates rates[400];
    ArraySetAsSeries(rates, true);

    // This path requires a deep history for fractal/swing analysis.
    int needBars = MathMin(400, Bars(_Symbol, gSignalTf));
    if(needBars < 100) return;
    if(CopyRates(_Symbol, gSignalTf, 0, needBars, rates) < 100) return;
    if(sigBar >= needBars-1) return;
    closeSig = rates[sigBar].close; // Get close from the full rates array.

    // Get fractals (for structure break)
    int frNeed = MathMin(300, needBars);
    double upFr[300], dnFr[300];
    ArraySetAsSeries(upFr, true);
    ArraySetAsSeries(dnFr, true);
    if(CopyBuffer(gFractalsHandle, 0, 0, frNeed, upFr) <= 0) return;
    if(CopyBuffer(gFractalsHandle, 1, 0, frNeed, dnFr) <= 0) return;

    for(int i=sigBar+2; i<frNeed; i++)
    {
      if(lastSwingHighT==0 && upFr[i] != 0.0) { lastSwingHigh = upFr[i]; lastSwingHighT = rates[i].time; }
      if(lastSwingLowT==0  && dnFr[i] != 0.0) { lastSwingLow  = dnFr[i]; lastSwingLowT  = rates[i].time; }
      if(lastSwingHighT!=0 && lastSwingLowT!=0) break;
    }
  }
  else
  {
    // This path is much lighter.
    // PERF: Use the lightweight iClose() instead of heavy CopyRates() just to get a single price.
    closeSig = iClose(_Symbol, gSignalTf, sigBar);
    if(closeSig <= 0.0) return; // Abort if price is invalid.
  }

  // --- Donchian Channel (using native indicator for performance) ---
  // The native iDonchian is faster as the terminal manages state and calculations.
  double donchianUp[1], donchianDn[1];
  // We need the Donchian value from the bar *preceding* the signal bar.
  int donStart = sigBar + 1;
  if(CopyBuffer(gDonchianHandle, 0, donStart, 1, donchianUp) != 1) return;
  if(CopyBuffer(gDonchianHandle, 1, donStart, 1, donchianDn) != 1) return;

  double donHigh = donchianUp[0];
  double donLow  = donchianDn[0];
  if(donHigh <= 0 || donLow <= 0) return; // Data not ready or invalid

  // --- Primary Signals (without MTF confirmation yet) ---
  bool smcLong=false, smcShort=false, donLong=false, donShort=false;
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

  // PERF: Early exit if no primary signal exists. This avoids the GetMTFDir()
  // call (which performs a CopyTime) on the vast majority of bars.
  if(!(smcLong || donLong || smcShort || donShort)) return;

  // --- Lower TF confirmation (only after a primary signal) ---
  int mtfDir = GetMTFDir();
  bool mtfOkLong  = (!RequireMTFConfirm) || (mtfDir == 1);
  bool mtfOkShort = (!RequireMTFConfirm) || (mtfDir == -1);

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
                            EnumToString(gSignalTf),
                            EnumToString(LowerTF),
                            (smcLong||smcShort ? "Y" : "N"),
                            (donLong||donShort ? "Y" : "N"));
  Notify(msg);

  if(EnableWebRequest) SendSignalToBridge(msg);

  if(!EnableTrading) return;
  if(OnePositionPerSymbol && HasOpenPosition(_Symbol, MagicNumber)) return;

  // PERF: G_POINT is now guaranteed to be valid from OnInit.
  double point = G_POINT;
  // PERF: Use pre-defined Ask/Bid globals in OnTick to avoid function call overhead.
  double ask = Ask;
  double bid = Bid;

  double entry = (finalLong ? ask : bid);
  double sl = 0.0, tp = 0.0;

  // --- Gemini AI Filter ---
  if(UseGeminiFilter)
  {
    bool aiConfirmed = AskGemini(_Symbol, (finalLong ? "BUY" : "SELL"), entry);
    if(!aiConfirmed)
    {
      Print("Gemini AI rejected the trade or request failed.");
      return;
    }
    Print("Gemini AI confirmed the trade.");
  }

  // --- Build SL
  if(SLMode == SL_SWING)
  {
    // For a long breakout, protective SL typically goes below the last confirmed swing low.
    // For a short breakout, SL goes above the last confirmed swing high.
    double buf = SwingSLBufferPoints * G_POINT;
    if(finalLong && lastSwingLowT != 0 && lastSwingLow > 0.0) sl = lastSwingLow - buf;
    if(finalShort && lastSwingHighT != 0 && lastSwingHigh > 0.0) sl = lastSwingHigh + buf;

    // Fallback if swing is missing/invalid for current entry.
    if((finalLong && (sl <= 0.0 || sl >= entry)) || (finalShort && (sl <= 0.0 || sl <= entry)))
    {
      // PERF: ATR is lazy-loaded only for this fallback case.
      double atrVal = GetATR(sigBar, sigTime);
      if(atrVal > 0.0)
      {
        if(finalLong) sl = entry - (ATR_SL_Mult * atrVal);
        else sl = entry + (ATR_SL_Mult * atrVal);
      }
    }
  }
  else if(SLMode == SL_FIXED_POINTS)
  {
    double dist = MathMax(1, FixedSLPoints) * point;
    sl = (finalLong ? entry - dist : entry + dist);
  }
  else // SL_ATR
  {
    // PERF: ATR is lazy-loaded only when this SL mode is active.
    double atrVal = GetATR(sigBar, sigTime);
    if(atrVal > 0.0)
    {
      sl = (finalLong ? entry - (ATR_SL_Mult * atrVal) : entry + (ATR_SL_Mult * atrVal));
    }
  }

  // CRITICAL: If SL is 0 after this block, it means a required calculation
  // (like GetATR) failed. Abort to prevent placing a trade with no stop loss.
  if(sl == 0.0)
  {
    // Optionally notify the user about the failure.
    // Notify(StringFormat("SL calculation failed for %s.", _Symbol));
    return;
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
    if(width <= 0.0)
    {
      // PERF: ATR is lazy-loaded only for this fallback case.
      double atrVal = GetATR(sigBar, sigTime);
      if(atrVal > 0.0) width = ATR_SL_Mult * atrVal; // fallback
    }
    double dist = DonchianTP_Mult * width;
    tp = (finalLong ? entry + dist : entry - dist);
  }
  else // TP_RR
  {
    double slDist = MathAbs(entry - sl);
    tp = (finalLong ? entry + (RR * slDist) : entry - (RR * slDist));
  }

  // CRITICAL: If TP is 0, it means a calculation failed. Abort.
  if(tp == 0.0) return;

  // Respect broker minimum stop distance (in points)
  if(G_MIN_STOP_PRICE > 0)
  {
    if(finalLong)
    {
      if(entry - sl < G_MIN_STOP_PRICE) sl = entry - G_MIN_STOP_PRICE;
      if(tp - entry < G_MIN_STOP_PRICE) tp = entry + G_MIN_STOP_PRICE;
    }
    else
    {
      if(sl - entry < G_MIN_STOP_PRICE) sl = entry + G_MIN_STOP_PRICE;
      if(entry - tp < G_MIN_STOP_PRICE) tp = entry - G_MIN_STOP_PRICE;
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
