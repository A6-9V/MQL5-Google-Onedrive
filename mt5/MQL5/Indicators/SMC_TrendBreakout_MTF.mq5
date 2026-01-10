//+------------------------------------------------------------------+
//| SMC_TrendBreakout_MTF.mq5                                        |
//| Visual indicator: BOS/CHoCH + Donchian breakout + MTF filter     |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

// --- plot 0: buy arrows
#property indicator_label1  "Long"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
// --- plot 1: sell arrows
#property indicator_label2  "Short"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrTomato
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

input group "SMC (structure)"
input bool   UseSMC                 = true;
input bool   UseCHoCH               = true;      // label opposite break as CHoCH

input group "Trend Breakout"
input bool   UseDonchianBreakout    = true;
input int    DonchianLookback       = 20;        // bars (completed bars)

input group "Lower timeframe confirmation"
input bool            RequireMTFConfirm = true;
input ENUM_TIMEFRAMES LowerTF           = PERIOD_M5;
input int             EMAFast           = 20;
input int             EMASlow           = 50;

input group "Signals"
input bool   FireOnClose           = true;  // use last closed bar (recommended)
input int    ArrowCodeLong         = 233;   // wingdings: up arrow
input int    ArrowCodeShort        = 234;   // wingdings: down arrow
input int    ArrowOffsetPoints     = 10;    // vertical offset in points

input group "Drawing"
input bool   DrawStructureLines    = true;
input bool   DrawBreakoutLines     = false;
input int    MaxObjects            = 200;   // prevent clutter

input group "Notifications"
input bool   PopupAlerts           = false;
input bool   PushNotifications     = false;

double gLongBuf[];
double gShortBuf[];

int gFractalsHandle = INVALID_HANDLE;
int gEmaFastHandle  = INVALID_HANDLE;
int gEmaSlowHandle  = INVALID_HANDLE;

// Tracks last trend direction on main TF: 1 bullish, -1 bearish, 0 unknown
int gTrendDir = 0;

string gObjPrefix;

datetime gLastBarTime = 0;

static int   ClampInt(const int v, const int lo, const int hi) { return (v<lo?lo:(v>hi?hi:v)); }
static bool  IsNewBar(const datetime t0) { if(t0==gLastBarTime) return false; gLastBarTime=t0; return true; }

static void Notify(const string msg)
{
  if(PopupAlerts) Alert(msg);
  if(PushNotifications) SendNotification(msg);
}

static void  SafeDeleteOldObjects()
{
  // keep last MaxObjects objects with prefix, delete oldest (by time suffix)
  // simple cap: if too many, delete all (fast & safe for indicator)
  int total = ObjectsTotal(0, 0, -1);
  int cnt = 0;
  for(int i=total-1;i>=0;i--)
  {
    string name = ObjectName(0, i, 0, -1);
    if(StringFind(name, gObjPrefix) == 0) cnt++;
  }
  if(cnt <= MaxObjects) return;
  for(int i=total-1;i>=0;i--)
  {
    string name = ObjectName(0, i, 0, -1);
    if(StringFind(name, gObjPrefix) == 0) ObjectDelete(0, name);
  }
}

static void DrawHLine(const string name, const double price, const color c, const ENUM_LINE_STYLE st, const int w)
{
  if(!DrawStructureLines && !DrawBreakoutLines) return;
  if(ObjectFind(0, name) >= 0) return;
  ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
  ObjectSetInteger(0, name, OBJPROP_COLOR, c);
  ObjectSetInteger(0, name, OBJPROP_STYLE, st);
  ObjectSetInteger(0, name, OBJPROP_WIDTH, w);
  ObjectSetInteger(0, name, OBJPROP_BACK, true);
}

static void DrawText(const string name, const datetime t, const double price, const string txt, const color c)
{
  if(ObjectFind(0, name) >= 0) return;
  ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
  ObjectSetString(0, name, OBJPROP_TEXT, txt);
  ObjectSetInteger(0, name, OBJPROP_COLOR, c);
  ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
  ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
  ObjectSetInteger(0, name, OBJPROP_BACK, true);
}

static double HighestHigh(const double &high[], const int start, const int count)
{
  double hh = -DBL_MAX;
  for(int i=start;i<start+count;i++) hh = (high[i] > hh ? high[i] : hh);
  return hh;
}

static double LowestLow(const double &low[], const int start, const int count)
{
  double ll = DBL_MAX;
  for(int i=start;i<start+count;i++) ll = (low[i] < ll ? low[i] : ll);
  return ll;
}

// --- Cached MTF direction (performance)
static datetime g_mtfDir_lastCheckTime = 0;
static int      g_mtfDir_cachedValue = 0;

static int GetMTFDir()
{
  if(!RequireMTFConfirm) return 0;
  if(gEmaFastHandle==INVALID_HANDLE || gEmaSlowHandle==INVALID_HANDLE) return 0;

  // PERF: Only check for new MTF direction on a new bar of the LowerTF.
  datetime mtf_time[1];
  if(CopyTime(_Symbol, LowerTF, 0, 1, mtf_time) != 1) return 0;
  if(mtf_time[0] == g_mtfDir_lastCheckTime) return g_mtfDir_cachedValue;
  g_mtfDir_lastCheckTime = mtf_time[0];

  double fast[2], slow[2];
  ArraySetAsSeries(fast, true);
  ArraySetAsSeries(slow, true);

  if(CopyBuffer(gEmaFastHandle, 0, 1, 1, fast) != 1) { g_mtfDir_cachedValue=0; return 0; }
  if(CopyBuffer(gEmaSlowHandle, 0, 1, 1, slow) != 1) { g_mtfDir_cachedValue=0; return 0; }

  if(fast[0] > slow[0]) g_mtfDir_cachedValue = 1;
  else if(fast[0] < slow[0]) g_mtfDir_cachedValue = -1;
  else g_mtfDir_cachedValue = 0;

  return g_mtfDir_cachedValue;
}

int OnInit()
{
  SetIndexBuffer(0, gLongBuf, INDICATOR_DATA);
  SetIndexBuffer(1, gShortBuf, INDICATOR_DATA);
  ArraySetAsSeries(gLongBuf, true);
  ArraySetAsSeries(gShortBuf, true);

  PlotIndexSetInteger(0, PLOT_ARROW, ArrowCodeLong);
  PlotIndexSetInteger(1, PLOT_ARROW, ArrowCodeShort);

  gObjPrefix = StringFormat("SMC_TB_MTF_%I64u_", (long)ChartID());

  // fractals on main TF
  gFractalsHandle = iFractals(_Symbol, _Period);
  if(gFractalsHandle == INVALID_HANDLE) return INIT_FAILED;

  // EMA handles on lower TF (for confirmation)
  gEmaFastHandle = iMA(_Symbol, LowerTF, EMAFast, 0, MODE_EMA, PRICE_CLOSE);
  gEmaSlowHandle = iMA(_Symbol, LowerTF, EMASlow, 0, MODE_EMA, PRICE_CLOSE);

  return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
  if(gFractalsHandle != INVALID_HANDLE) IndicatorRelease(gFractalsHandle);
  if(gEmaFastHandle != INVALID_HANDLE) IndicatorRelease(gEmaFastHandle);
  if(gEmaSlowHandle != INVALID_HANDLE) IndicatorRelease(gEmaSlowHandle);
}

int OnCalculate(
  const int rates_total,
  const int prev_calculated,
  const datetime &time[],
  const double &open[],
  const double &high[],
  const double &low[],
  const double &close[],
  const long &tick_volume[],
  const long &volume[],
  const int &spread[])
{
  if(rates_total < 100) return 0;
  int donLookback = (DonchianLookback < 2 ? 2 : DonchianLookback);

  ArraySetAsSeries(time, true);
  ArraySetAsSeries(open, true);
  ArraySetAsSeries(high, true);
  ArraySetAsSeries(low, true);
  ArraySetAsSeries(close, true);

  // Clear only newly calculated area; indicator buffers are series arrays (0 = current bar)
  int start = (prev_calculated==0 ? rates_total-1 : rates_total - prev_calculated);
  start = ClampInt(start, 0, rates_total-1);
  for(int i=start;i>=0;i--)
  {
    gLongBuf[i]  = EMPTY_VALUE;
    gShortBuf[i] = EMPTY_VALUE;
  }

  // Only emit signals once per new bar (less spam); use bar 1 when FireOnClose.
  if(!IsNewBar(time[0])) return rates_total;

  SafeDeleteOldObjects();

  const int sigBar = (FireOnClose ? 1 : 0);
  if(sigBar >= rates_total-1) return rates_total;

  // --- Pull fractal buffers for last ~500 bars for swing detection
  int need = MathMin(600, rates_total);
  double upFr[600], dnFr[600];
  ArraySetAsSeries(upFr, true);
  ArraySetAsSeries(dnFr, true);

  int gotUp = CopyBuffer(gFractalsHandle, 0, 0, need, upFr);
  int gotDn = CopyBuffer(gFractalsHandle, 1, 0, need, dnFr);
  if(gotUp <= 0 || gotDn <= 0) return rates_total;

  // Find most recent confirmed swing high/low (fractal appears 2 bars after formation)
  double lastSwingHigh = 0.0; datetime lastSwingHighT = 0;
  double lastSwingLow  = 0.0; datetime lastSwingLowT  = 0;
  for(int i=sigBar+2; i<need; i++)
  {
    if(lastSwingHighT==0 && upFr[i] != 0.0) { lastSwingHigh = upFr[i]; lastSwingHighT = time[i]; }
    if(lastSwingLowT==0  && dnFr[i] != 0.0) { lastSwingLow  = dnFr[i]; lastSwingLowT  = time[i]; }
    if(lastSwingHighT!=0 && lastSwingLowT!=0) break;
  }

  // --- Determine Donchian breakout bounds (exclude current forming bar and signal bar)
  int donStart = sigBar + 1;
  int donCount = donLookback;
  if(donStart + donCount >= rates_total) return rates_total;

  double donHigh = HighestHigh(high, donStart, donCount);
  double donLow  = LowestLow(low, donStart, donCount);

  // --- Lower TF confirmation
  int mtfDir = GetMTFDir(); // 1 up, -1 down, 0 neutral/unknown

  bool mtfOkLong  = (!RequireMTFConfirm) || (mtfDir == 1);
  bool mtfOkShort = (!RequireMTFConfirm) || (mtfDir == -1);

  // --- Signals
  bool smcLong=false, smcShort=false, donLong=false, donShort=false;

  if(UseSMC)
  {
    if(lastSwingHighT!=0 && close[sigBar] > lastSwingHigh) smcLong = true;
    if(lastSwingLowT!=0  && close[sigBar] < lastSwingLow)  smcShort = true;
  }
  if(UseDonchianBreakout)
  {
    if(close[sigBar] > donHigh) donLong = true;
    if(close[sigBar] < donLow)  donShort = true;
  }

  bool finalLong  = (smcLong || donLong) && mtfOkLong;
  bool finalShort = (smcShort || donShort) && mtfOkShort;

  // --- Plot & draw
  double pnt = _Point;
  if(finalLong)
  {
    gLongBuf[sigBar] = low[sigBar] - ArrowOffsetPoints * pnt;

    color c = clrLimeGreen;
    if(smcLong && lastSwingHighT!=0 && DrawStructureLines)
    {
      int breakDir = 1;
      bool choch = (UseCHoCH && gTrendDir!=0 && breakDir != gTrendDir);
      string kind = (choch ? "CHoCH↑" : "BOS↑");
      string n1 = gObjPrefix + StringFormat("SMC_%s_%I64d", kind, (long)time[sigBar]);
      DrawHLine(n1+"_L", lastSwingHigh, c, STYLE_DOT, 1);
      DrawText(n1+"_T", time[sigBar], lastSwingHigh, kind, c);
      gTrendDir = breakDir;
    }
    if(donLong && DrawBreakoutLines)
    {
      string n2 = gObjPrefix + StringFormat("DON_H_%I64d", (long)time[sigBar]);
      DrawHLine(n2, donHigh, clrDeepSkyBlue, STYLE_DASH, 1);
    }

    Notify(StringFormat("%s LONG | TF=%s | MTF=%s", _Symbol, EnumToString(_Period), EnumToString(LowerTF)));
  }
  if(finalShort)
  {
    gShortBuf[sigBar] = high[sigBar] + ArrowOffsetPoints * pnt;

    color c = clrTomato;
    if(smcShort && lastSwingLowT!=0 && DrawStructureLines)
    {
      int breakDir = -1;
      bool choch = (UseCHoCH && gTrendDir!=0 && breakDir != gTrendDir);
      string kind = (choch ? "CHoCH↓" : "BOS↓");
      string n1 = gObjPrefix + StringFormat("SMC_%s_%I64d", kind, (long)time[sigBar]);
      DrawHLine(n1+"_L", lastSwingLow, c, STYLE_DOT, 1);
      DrawText(n1+"_T", time[sigBar], lastSwingLow, kind, c);
      gTrendDir = breakDir;
    }
    if(donShort && DrawBreakoutLines)
    {
      string n2 = gObjPrefix + StringFormat("DON_L_%I64d", (long)time[sigBar]);
      DrawHLine(n2, donLow, clrDeepSkyBlue, STYLE_DASH, 1);
    }

    Notify(StringFormat("%s SHORT | TF=%s | MTF=%s", _Symbol, EnumToString(_Period), EnumToString(LowerTF)));
  }

  return rates_total;
}

