//+------------------------------------------------------------------+
//|                                                   ZoloBridge.mqh |
//|                                  Copyright 2024, GenX Solutions  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, GenX Solutions"
#property strict

//+------------------------------------------------------------------+
//| Helper: Sanitize JSON String                                     |
//+------------------------------------------------------------------+
string Zolo_SanitizeJSON(string text)
{
   string res = text;
   // Replace backslash first to avoid double escaping
   StringReplace(res, "\\", "\\\\");
   StringReplace(res, "\"", "\\\"");
   StringReplace(res, "\n", " ");
   StringReplace(res, "\r", " ");
   StringReplace(res, "\t", " ");
   return res;
}

//+------------------------------------------------------------------+
//| ZOLO Bridge Function                                             |
//+------------------------------------------------------------------+
void SendSignalToBridge(string msg, bool enable, string url)
{
   if (!enable || url == "") return;

   string sanitized_msg = Zolo_SanitizeJSON(msg);
   string body = "{\"event\":\"signal\",\"message\":\"" + sanitized_msg + "\"}";

   char data[];
   int len = StringToCharArray(body, data, 0, WHOLE_ARRAY, CP_UTF8);
   if (len > 0) ArrayResize(data, len - 1); // Remove null terminator

   char result[];
   string result_headers;
   string headers = "Content-Type: application/json";

   int res = WebRequest("POST", url, headers, 5000, data, result, result_headers);

   if (res != 200)
   {
      // Only print on failure to reduce log noise
      PrintFormat("ZOLO WebRequest failed. Code: %d. URL: %s", res, url);
      if(res == -1) Print("Error: ", GetLastError());
   }
}
