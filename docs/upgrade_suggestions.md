# Upgrade Suggestions

Generated: 2026-01-26 19:40:30

## Gemini Suggestions

**Based on the Market Research Report, the bot needs significant adjustments to its risk and execution management to handle the current bifurcation between low-volatility trending assets (FX) and high-volatility aggressive assets (GC=F, BTC-USD).**

Here are 3 specific code upgrades or parameter adjustments:

---

1.  **SMC\_TrendBreakout\_MTF\_EA.mq5:** **Add `TimeBasedStopDurationHours` Input and Management Logic** - The Gemini analysis specifically mandates the use of **time-based stops** for high-momentum assets like GC=F: "If the trade does not confirm momentum within a defined period (e.g., 4 hours), exit immediately." The current EA only supports price-based stops (ATR, Swing, Fixed Points).

    *   **Upgrade Detail:** Introduce an input under the "Risk / Orders" group: `input int TimeBasedStopDurationHours = 0; // 0 disables`. The trade management function (`CheckAndManageTrades`) must be upgraded to check the duration of any open position. If the trade's elapsed time exceeds this duration (and the trade is not significantly in profit), the trade must be closed immediately.

2.  **SMC\_TrendBreakout\_MTF\_EA.mq5:** **Implement `VolAdaptiveRiskFactor` for Position Sizing Reduction** - The report stresses that for high-volatility assets (GC=F, BTC-USD), position size must be *significantly reduced* (e.g., 50-70% of standard size) *even if* the ATR stop calculation already reduces the lot size. This suggests a systemic reduction factor beyond standard risk-per-trade logic.

    *   **Upgrade Detail:** Introduce a new input: `input double VolAdaptiveRiskFactor = 1.0;`. This factor will be used as a final multiplier on the calculated lot size: `FinalLots = CalculatedLots * VolAdaptiveRiskFactor`. The bot operator can then manually set this factor to 0.5 (50% reduction) for high-volatility assets like Gold and Bitcoin, and 1.0 for low-vol assets like EURUSD, ensuring that the monetary risk (R) is truly controlled when faced with high-speed whipsaws, as recommended in section 3.1.

3.  **SMC\_TrendBreakout\_MTF\_EA.mq5:** **Add `MaxThemeExposureRiskPercent` for Portfolio Risk Control** - The report issued a direct warning regarding highly correlated pairs (EURUSD, GBPUSD): "The bot must ensure combined exposure to the 'Long USD Weakness' theme does not exceed the maximum single-theme risk tolerance." The current `OnePositionPerSymbol` only prevents multiple trades on *one* symbol, not correlated symbols.

    *   **Upgrade Detail:** Introduce an input: `input double MaxThemeExposureRiskPercent = 2.0; // Max risk allowed across correlated assets`. The EA must maintain an internal list or mapping of correlated assets (e.g., EURUSD and GBPUSD map to "Long USD Weakness"). Before calculating the lot size for a new trade, the bot must sum the theoretical risk exposure (SL distance * Lot Size) of all currently open trades belonging to that theme. If the new trade pushes the total monetary risk above `MaxThemeExposureRiskPercent` of the account equity, the new signal must be rejected.
