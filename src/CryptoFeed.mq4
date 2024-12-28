//+------------------------------------------------------------------+
//|                                                    CryptoFeed.mq4  |
//|                                              Crypto Market Data EA  |
//+------------------------------------------------------------------+
#property copyright "Your Name"
#property link      ""
#property version   "1.00"
#property strict

// Socket connection variables
int socket = -1;
string server = "127.0.0.1";
int port = 5555;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   EventSetMillisecondTimer(1000); // Timer for price updates
   socket = SocketCreate();
   
   if (socket != INVALID_HANDLE) {
      if (SocketConnect(socket, server, port, 1000)) {
         Print("Connected to price server");
         return(INIT_SUCCEEDED);
      }
   }
   
   Print("Failed to connect to price server");
   return(INIT_FAILED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if (socket != INVALID_HANDLE) {
      SocketClose(socket);
   }
   EventKillTimer();
}

//+------------------------------------------------------------------+
//| Timer function                                                     |
//+------------------------------------------------------------------+
void OnTimer()
{
   if (socket != INVALID_HANDLE) {
      string received = SocketReadString(socket);
      if (StringLen(received) > 0) {
         string pairs[];
         StringSplit(received, '|', pairs);
         
         for(int i=0; i<ArraySize(pairs); i++) {
            string components[];
            StringSplit(pairs[i], ',', components);
            
            if (ArraySize(components) == 3) {
               string symbol = components[0];
               double bid = StringToDouble(components[1]);
               double ask = StringToDouble(components[2]);
               
               // Update custom symbols or use for trading logic
               Comment("Latest price for ", symbol, ": Bid=", bid, " Ask=", ask);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   // Add your trading logic here
}