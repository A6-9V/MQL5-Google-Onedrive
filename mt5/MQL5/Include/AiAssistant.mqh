//+------------------------------------------------------------------+
//|                                                  AiAssistant.mqh |
//|                                  Copyright 2025, GenX Solutions  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, GenX Solutions"
#property strict

#ifndef AI_ASSISTANT_MQH
#define AI_ASSISTANT_MQH

#include <ZoloBridge.mqh> // For Zolo_SanitizeJSON

//+------------------------------------------------------------------+
//| Enums                                                            |
//+------------------------------------------------------------------+
enum ENUM_AI_PROVIDER
{
   PROVIDER_GEMINI, // Google Gemini
   PROVIDER_JULES   // Jules API
};

//+------------------------------------------------------------------+
//| Helper: Construct Prompt                                         |
//+------------------------------------------------------------------+
string Ai_ConstructPrompt(string symbol, string type, double price, int trendDir, double rsi, double atr, string contextUrl)
{
   string trendStr = (trendDir > 0 ? "BULLISH" : (trendDir < 0 ? "BEARISH" : "NEUTRAL"));

   string prompt = StringFormat(
      "Analyze this trade setup:\n"
      "Symbol: %s\n"
      "Signal: %s at %f\n"
      "Trend: %s\n"
      "RSI(14): %.2f\n"
      "ATR(14): %.5f\n"
      "Context: %s\n"
      "Instructions: Review the technicals. Reply strictly with 'YES' to confirm or 'NO' to reject. Do not provide reasoning.",
      symbol, type, price, trendStr, rsi, atr, contextUrl
   );
   return prompt;
}

//+------------------------------------------------------------------+
//| Helper: Parse AI Response                                        |
//+------------------------------------------------------------------+
bool Ai_ParseResponse(string response)
{
   string upper = response;
   if(!StringToUpper(upper)) return false;

   // Check for explicit YES
   // We look for "YES" which might be surrounded by quotes or whitespace.
   if (StringFind(upper, "YES") >= 0)
   {
      // Simple validation: Ensure "NO" is not also present in a confusing way?
      // Since we asked for strictly YES/NO, presence of YES is a good indicator.
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Gemini API Call                                                  |
//+------------------------------------------------------------------+
bool Ai_AskGemini(string apiKey, string model, string prompt)
{
   if (apiKey == "")
   {
      Print("AiAssistant: Gemini API Key missing.");
      return false;
   }

   string url = "https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent?key=" + apiKey;

   // JSON Body: {"contents":[{"parts":[{"text":"prompt"}]}]}
   string body = "{\"contents\":[{\"parts\":[{\"text\":\"" + Zolo_SanitizeJSON(prompt) + "\"}]}]}";

   char data[];
   int len = StringToCharArray(body, data, 0, WHOLE_ARRAY, CP_UTF8);
   if (len > 0) ArrayResize(data, len - 1);

   char result[];
   string result_headers;
   string headers = "Content-Type: application/json";

   int res = WebRequest("POST", url, headers, 5000, data, result, result_headers);

   if (res == 200)
   {
      string resp = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
      // Print("AiAssistant Response: ", resp); // Debug
      return Ai_ParseResponse(resp);
   }
   else
   {
      PrintFormat("AiAssistant: Gemini Request failed. Code: %d. URL: %s", res, url);
      if(res == -1) Print("Error: ", GetLastError());
   }

   return false;
}

//+------------------------------------------------------------------+
//| Jules API Call                                                   |
//+------------------------------------------------------------------+
bool Ai_AskJules(string apiKey, string model, string prompt, string url)
{
   if (apiKey == "" || url == "")
   {
      Print("AiAssistant: Jules API Key or URL missing.");
      return false;
   }

   // Construct JSON body for Jules API
   // Assumes a generic structure or one compatible with common AI endpoints.
   // Structure: {"model": "model_name", "prompt": "..."}
   string body = "{\"model\":\"" + model + "\", \"prompt\":\"" + Zolo_SanitizeJSON(prompt) + "\"}";

   char data[];
   int len = StringToCharArray(body, data, 0, WHOLE_ARRAY, CP_UTF8);
   if (len > 0) ArrayResize(data, len - 1);

   char result[];
   string result_headers;
   // Use Bearer token authentication
   string headers = "Content-Type: application/json\r\nAuthorization: Bearer " + apiKey;

   int res = WebRequest("POST", url, headers, 5000, data, result, result_headers);

   if (res == 200)
   {
      string resp = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
      // Print("AiAssistant Jules Response: ", resp); // Debug
      return Ai_ParseResponse(resp);
   }
   else
   {
      PrintFormat("AiAssistant: Jules Request failed. Code: %d. URL: %s", res, url);
      if(res == -1) Print("Error: ", GetLastError());
   }

   return false;
}

#endif // AI_ASSISTANT_MQH
