//+------------------------------------------------------------------+
//|                                                   ZoloBridge.mqh |
//|                                  Copyright 2024, GenX Solutions  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, GenX Solutions"
#property strict

#ifndef ZOLO_BRIDGE_MQH
#define ZOLO_BRIDGE_MQH

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
//| Helper: Encrypt String (AES-256 + Base64)                        |
//+------------------------------------------------------------------+
string Zolo_Encrypt(string text, string key)
{
   if (key == "") return text;

   uchar data[];
   StringToCharArray(text, data, 0, WHOLE_ARRAY, CP_UTF8);
   if(ArraySize(data) > 0) ArrayResize(data, ArraySize(data)-1); // Remove null

   uchar keyData[];
   StringToCharArray(key, keyData, 0, WHOLE_ARRAY, CP_UTF8);
   if(ArraySize(keyData) > 0) ArrayResize(keyData, ArraySize(keyData)-1);

   // Hash key to ensure 32 bytes for AES-256
   uchar keyHash[];
   uchar empty[];
   CryptEncode(CRYPT_HASH_SHA256, keyData, empty, keyHash);

   uchar result[];
   int res = CryptEncode(CRYPT_AES256, data, keyHash, result);

   if (res <= 0)
   {
      Print("ZoloBridge: Encryption failed. Error: ", GetLastError());
      return "";
   }

   // Base64 encode
   uchar b64Data[];
   CryptEncode(CRYPT_BASE64, result, empty, b64Data);
   string b64 = CharArrayToString(b64Data);

   return b64;
}

//+------------------------------------------------------------------+
//| ZOLO Bridge Function                                             |
//+------------------------------------------------------------------+
void SendSignalToBridge(string msg, bool enable, string url, string key="")
{
   if (!enable || url == "") return;

   string final_msg = msg;
   if(key != "")
   {
      final_msg = Zolo_Encrypt(msg, key);
      // If encryption fails (returns empty), we might want to abort or send plaintext.
      // For security, aborting is better.
      if(final_msg == "") return;
   }

   string sanitized_msg = Zolo_SanitizeJSON(final_msg);
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

#endif // ZOLO_BRIDGE_MQH
