//+------------------------------------------------------------------+
//|                                                  Trading-Bot.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int order;
bool engulfing;

double current_level_line;
double engulfing_line;
double stop_loss;

string logs[100];
int logIdx = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  
  }
  
void addToLogs(string item) {
   logs[logIdx] = item;
   logIdx = logIdx + 1;
}

void emptyLogs() {
   int indexTemp = 0;
   while (indexTemp < 100) {
      logs[indexTemp] = "";
      indexTemp = indexTemp + 1;
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
    double lotsize = 0.5;
    double sar_step = 0.01;
    double sar_maximum = 0.2;
    double adx_threshold = 20;
  
    if (OrderSelect(0, SELECT_BY_POS)) order = OrderTicket();
    
    emptyLogs();
    logIdx = 0;
    
    bool upper_ema_buy = false;
    bool upper_stars_buy = false;
    bool upper_adx_buy = false;
    bool upper_fractal_buy = false;
    
    bool lower_ema_buy = false;
    bool lower_stars_buy = false;
    bool lower_adx_buy = false;
    bool lower_fractal_buy = false;
    
    bool upper_ema_sell = false;
    bool upper_stars_sell = false;
    bool upper_adx_sell = false;
    bool upper_fractal_sell = false;
    
    bool lower_ema_sell = false;
    bool lower_stars_sell = false;
    bool lower_adx_sell = false;
    bool lower_fractal_sell = false;
    
    // ---------------------------------------------------------------------------------- //
  
    // LOWER - 1 Minute
    double lower_ema8 = iMA(NULL, PERIOD_M5, 8, 0, MODE_EMA, PRICE_CLOSE, 1);
    double lower_ema14 = iMA(NULL, PERIOD_M5, 14, 0, MODE_EMA, PRICE_CLOSE, 1);
    double lower_ema21 = iMA(NULL, PERIOD_M5, 21, 0, MODE_EMA, PRICE_CLOSE, 1);
    double lower_ema50 = iMA(NULL, PERIOD_M5, 50, 0, MODE_EMA, PRICE_CLOSE, 1);
    double lower_ema100 = iMA(NULL, PERIOD_M5, 100, 0, MODE_EMA, PRICE_CLOSE, 1);
    double lower_ema200 = iMA(NULL, PERIOD_M5, 200, 0, MODE_EMA, PRICE_CLOSE, 1);
    double lower_adx = iADX(NULL, PERIOD_M5, 14, PRICE_CLOSE, MODE_MAIN, 1);
    double lower_di_minus = iADX(NULL, PERIOD_M5, 14, PRICE_CLOSE, MODE_MINUSDI, 1);
    double lower_di_plus = iADX(NULL, PERIOD_M5, 14, PRICE_CLOSE, MODE_PLUSDI, 1);
    double lower_sar = iSAR(NULL, PERIOD_M5, sar_step, sar_maximum, 1);
    
    double   lower_heikinOpen  =  (iOpen(NULL, PERIOD_M5, 2) + iClose(NULL, PERIOD_M5, 2)) / 2;
    double   lower_heikinHigh  =  MathMax(MathMax(iOpen(NULL, PERIOD_M5, 1), iClose(NULL, PERIOD_M5, 1)), MathMax(iLow(NULL, PERIOD_M5, 1), iHigh(NULL, PERIOD_M5, 1)));
    double   lower_heikinLow = MathMin(MathMax(iOpen(NULL, PERIOD_M5, 1), iClose(NULL, PERIOD_M5, 1)), MathMax(iLow(NULL, PERIOD_M5, 1), iHigh(NULL, PERIOD_M5, 1)));
    double   lower_heikinClose = (iOpen(NULL, PERIOD_M5, 1) + iClose(NULL, PERIOD_M5, 1) + iLow(NULL, PERIOD_M5, 1) + iHigh(NULL, PERIOD_M5, 1)) / 4;
    
    double   lower_heikinHighSL = MathMax(MathMax(iOpen(NULL, PERIOD_M5, 2), iClose(NULL, PERIOD_M5, 2)), MathMax(iLow(NULL, PERIOD_M5, 2), iHigh(NULL, PERIOD_M5, 2)));
    double   lower_heikinLowSL   =  MathMin(MathMax(iOpen(NULL, PERIOD_M5, 2), iClose(NULL, PERIOD_M5, 2)), MathMax(iLow(NULL, PERIOD_M5, 2), iHigh(NULL, PERIOD_M5, 2)));
    
    double   lower_heikinCloseCURRENT =  (iOpen(NULL, PERIOD_M5, 0) + iClose(NULL, PERIOD_M5, 0) + iLow(NULL, PERIOD_M5, 0) + iHigh(NULL, PERIOD_M5, 0)) / 4;

    // GETTING LAST FRACTAL UP
    double lower_fractal_up = 0; 
    
    int lower_bars = iBars(NULL, 0);
    
    int lower_idx = 0;
    
    while (lower_fractal_up == 0) {
         
         double lower_fractal_up_temp = iFractals(NULL, PERIOD_M5, MODE_UPPER, lower_idx);
         lower_idx++;
         if (lower_fractal_up_temp != 0) {
               lower_fractal_up = lower_fractal_up_temp;
               lower_idx = 0;
         }
    }
    
    // GETTING LAST FRACTAL DOWN
    double lower_fractal_down = 0;
    
    while (lower_fractal_down == 0) {
    
         double lower_fractal_down_temp = iFractals(NULL, PERIOD_M5, MODE_LOWER, lower_idx);
         lower_idx++;
         if (lower_fractal_down_temp != 0) {
               lower_fractal_down = lower_fractal_down_temp;
         }
    }
    
    // -----------------------------------------------------------------------------------//
    
     // UPPER - 15 Minutes
    double upper_ema8 = iMA(NULL, PERIOD_M15, 8, 0, MODE_EMA, PRICE_CLOSE, 1);
    double upper_ema14 = iMA(NULL, PERIOD_M15, 14, 0, MODE_EMA, PRICE_CLOSE, 1);
    double upper_ema21 = iMA(NULL, PERIOD_M15, 21, 0, MODE_EMA, PRICE_CLOSE, 1);
    double upper_ema50 = iMA(NULL, PERIOD_M15, 50, 0, MODE_EMA, PRICE_CLOSE, 1);
    double upper_ema100 = iMA(NULL, PERIOD_M15, 100, 0, MODE_EMA, PRICE_CLOSE, 1);
    double upper_ema200 = iMA(NULL, PERIOD_M15, 200, 0, MODE_EMA, PRICE_CLOSE, 1);
    double upper_adx = iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, MODE_MAIN, 1);
    double upper_di_minus = iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, MODE_MINUSDI, 1);
    double upper_di_plus = iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, MODE_PLUSDI, 1);
    double upper_sar = iSAR(NULL, PERIOD_M15, sar_step, sar_maximum, 1);
    
    
    
    
    double   upper_heikinOpen  =  (iOpen(NULL, PERIOD_M15, 2) + iClose(NULL, PERIOD_M15, 2)) / 2;
    double   upper_heikinHigh  =  MathMax(MathMax(iOpen(NULL, PERIOD_M15, 1), iClose(NULL, PERIOD_M15, 1)), MathMax(iLow(NULL, PERIOD_M15, 1), iHigh(NULL, PERIOD_M15, 1)));
    double   upper_heikinLow = MathMin(MathMax(iOpen(NULL, PERIOD_M15, 1), iClose(NULL, PERIOD_M15, 1)), MathMax(iLow(NULL, PERIOD_M15, 1), iHigh(NULL, PERIOD_M15, 1)));
    double   upper_heikinClose = (iOpen(NULL, PERIOD_M15, 1) + iClose(NULL, PERIOD_M15, 1) + iLow(NULL, PERIOD_M15, 1) + iHigh(NULL, PERIOD_M15, 1)) / 4;
    
    double   upper_heikinHighSL = MathMax(MathMax(iOpen(NULL, PERIOD_M15, 2), iClose(NULL, PERIOD_M15, 2)), MathMax(iLow(NULL, PERIOD_M15, 2), iHigh(NULL, PERIOD_M15, 2)));
    double   upper_heikinLowSL   =  MathMin(MathMax(iOpen(NULL, PERIOD_M15, 2), iClose(NULL, PERIOD_M15, 2)), MathMax(iLow(NULL, PERIOD_M15, 2), iHigh(NULL, PERIOD_M15, 2)));
    
    // GETTING LAST FRACTAL UP
    double upper_fractal_up = 0; 
    
    int upper_bars = iBars(NULL, 0);
    
    int upper_idx = 0;
    
    while (upper_fractal_up == 0) {
         
         double upper_fractal_up_temp = iFractals(NULL, PERIOD_M15, MODE_UPPER, upper_idx);
         upper_idx++;
         if (upper_fractal_up_temp != 0) {
               upper_fractal_up = upper_fractal_up_temp;
               upper_idx = 0;
         }
    }
    
    // GETTING LAST FRACTAL DOWN
    double upper_fractal_down = 0;
    
    
    
    while (upper_fractal_down == 0) {
    
         double upper_fractal_down_temp = iFractals(NULL, PERIOD_M15, MODE_LOWER, upper_idx);
         upper_idx++;
         if (upper_fractal_down_temp != 0) {
               upper_fractal_down = upper_fractal_down_temp;
         }
    }
    
    
    // --------------------------------------------------------------------------------- //
    if (upper_ema8 > upper_ema14 && upper_ema14 > upper_ema21 && upper_ema21 > upper_ema200) upper_ema_buy = true;
    if (upper_heikinOpen > upper_sar) upper_stars_buy = true;
    if (upper_adx > adx_threshold && upper_di_minus < adx_threshold) upper_adx_buy = true;
    if (upper_heikinClose > upper_fractal_up) upper_fractal_buy = true;
    
    if (lower_ema8 > lower_ema14 && lower_ema14 > lower_ema21 && lower_ema21 > lower_ema200) lower_ema_buy = true;
    if (lower_heikinOpen > lower_sar) lower_stars_buy = true;
    if (lower_adx > adx_threshold && lower_di_minus < adx_threshold) lower_adx_buy = true;
    if (lower_heikinClose > lower_fractal_up) lower_fractal_buy = true;
    
    if (upper_ema8 < upper_ema14 && upper_ema14 < upper_ema21 && upper_ema21 < upper_ema200) upper_ema_sell = true;
    if (upper_heikinOpen < upper_sar) upper_stars_sell = true;
    if (upper_adx > adx_threshold && upper_di_plus < adx_threshold) upper_adx_sell = true;
    if (upper_heikinClose < upper_fractal_down) upper_fractal_sell = true;
    
    if (lower_ema8 < lower_ema14 && lower_ema14 < lower_ema21 && lower_ema21 < lower_ema200) lower_ema_sell = true;
    if (lower_heikinOpen < lower_sar) lower_stars_sell = true;
    if (lower_adx > adx_threshold && lower_di_plus < adx_threshold) lower_adx_sell = true;
    if (lower_heikinClose < lower_fractal_down) lower_fractal_sell = true;
    
    // -----------------------------------DEBUGGING------------------------------------- //
    
    //addToLogs(upper_heikinOpen + "\n" + upper_sar + "\n");
    //addToLogs(upper_heikinOpen + "\n" + upper_heikinClose + "\n" + upper_heikinHigh + "\n" + upper_heikinLow + "\n");
    //addToLogs(upper_ema8 + "\n" );
    
    // --------------------------------------------------------------------------------- //
    
     if (OrderSelect(0, SELECT_BY_POS)) {
      addToLogs("Order Found");
      if (OrderType() == 0) {
         if (lower_heikinClose < current_level_line || lower_heikinCloseCURRENT < stop_loss) {
            bool orderClosed = OrderClose(OrderTicket(), lotsize, Ask, 0, Yellow);
            order = 0;
            current_level_line = NULL;
            engulfing_line = NULL;
            stop_loss = NULL;
         } else if (lower_heikinClose > engulfing_line) {
            stop_loss = current_level_line;
            current_level_line = lower_heikinLow;
            engulfing_line = lower_heikinHigh;
         }
         
      } 
      if (OrderType() == 1) {
         if (lower_heikinClose > current_level_line || lower_heikinCloseCURRENT > stop_loss) {
            bool orderClosed = OrderClose(OrderTicket(), lotsize, Ask, 0, Green);
            order = 0;
            current_level_line = NULL;
            engulfing_line = NULL;
            stop_loss = NULL;
         } else if (lower_heikinClose < engulfing_line) {
            stop_loss = current_level_line;
            current_level_line = lower_heikinHigh;
            engulfing_line = lower_heikinLow;
         }
      }
    } else {
      addToLogs("Order Not Found");
    }
    
    if (upper_ema_buy && upper_stars_buy && upper_adx_buy && upper_fractal_buy)
    {
        // check if there is no existing buy order
            // check lower timeframe
            if (lower_ema_buy && lower_stars_buy && lower_adx_buy && lower_fractal_buy)
            {
               if (order == 0)
               {
                  current_level_line = lower_heikinLow;
                  engulfing_line = lower_heikinHigh;
                  order = OrderSend(Symbol(), OP_BUY, lotsize, Ask, 0, lower_heikinLowSL, 0, "Buy", 0, 0, Blue);
               }
            }
    }
    if (upper_ema_sell && upper_stars_sell && upper_adx_sell && upper_fractal_sell) {
         
         // check if there is no existing sell order
         if (order == 0)
        {
            // check lower timeframe
            if (lower_ema_sell && lower_stars_sell && lower_adx_sell && lower_fractal_sell)
            {
               current_level_line = lower_heikinHigh;
               engulfing_line = lower_heikinLow;
               order = OrderSend(Symbol(), OP_SELL, lotsize, Ask, 0, upper_heikinLowSL, 0, "Sell", 0, 0, Red);
            }
        }
    }
    
    // -------------------------------------------------------------------------------------- //
    if (upper_ema_buy) addToLogs("EMAs are in order - UPPER TIMEFRAME - BUY");
    if (upper_stars_buy) addToLogs("Price is above the stars - UPPER TIMEFRAME - BUY");
    if (upper_adx_buy) addToLogs("Upper ADX trending correctly - UPPER TIMEFRAME - BUY");
    if (upper_fractal_buy) addToLogs("Price broke the fractal up - UPPER TIMEFRAME - BUY");
    
    if (lower_ema_buy) addToLogs("EMAs are in order - LOWER TIMEFRAME - BUY");
    if (lower_stars_buy) addToLogs("Price is above the stars - LOWER TIMEFRAME - BUY");
    if (lower_adx_buy) addToLogs("ADX trending correctly - LOWER TIMEFRAME - BUY");
    if (lower_fractal_buy) addToLogs("Price broke the fractal up - LOWER TIMEFRAME - BUY");
    
    // -------------------------------------------------------------------------------------- //
    if (upper_ema_sell) addToLogs("EMAs are in order - UPPER TIMEFRAME - SELL");
    if (upper_stars_sell) addToLogs("Price is below the stars - UPPER TIMEFRAME - SELL");
    if (upper_adx_sell) addToLogs("Upper ADX trending correctly - UPPER TIMEFRAME - SELL");
    if (upper_fractal_sell) addToLogs("Price broke the fractal down - UPPER TIMEFRAME - SELL");
    
    if (lower_ema_sell) addToLogs("EMAs are in order - LOWER TIMEFRAME - SELL");
    if (lower_stars_sell) addToLogs("Price is below the stars - LOWER TIMEFRAME - SELL");
    if (lower_adx_sell) addToLogs("ADX trending correctly - LOWER TIMEFRAME - SELL");
    if (lower_fractal_sell) addToLogs("Price broke the fractal down - LOWER TIMEFRAME - SELL");
   
    
    // ------------------------------------------------------------------------------------//
    string finalLog = "STATUS TRACKER - " + Symbol() + "\n\n";
    
    int finalLogIdx = 0;
    while (finalLogIdx < ArraySize(logs)) {
      finalLog = finalLog + logs[finalLogIdx] + "\n\n";
      finalLogIdx++;
    }
    if (Symbol() == "AUDUSD") Alert(finalLog);
    //if (Symbol() == "EURUSD") Alert(finalLog);
    //if (Symbol() == "EURJPY") Alert(finalLog);
    //if (Symbol() == "USDJPY") Alert(finalLog);
    //if (Symbol() == "GBPUSD") Alert(finalLog);
    //if (Symbol() == "USDCHF") Alert(finalLog);
  }
//+------------------------------------------------------------------+
