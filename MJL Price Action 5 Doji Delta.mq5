﻿//+------------------------------------------------------------------+
//|                                           MJL_Price_Action_2.mq5 |
//+------------------------------------------------------------------+
#property version   "1.00"
#property description "MJL Price Action indicator"
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   12
//-----------------------------------------
//--- plot DivUP
#property indicator_label1  "MJL PA Buy Pin"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot DivUP
#property indicator_label2  "MJL PA Buy Minor Pin"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot DivUP
#property indicator_label3  "MJL PA Buy Traintrack"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrAqua
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot DivUP
#property indicator_label4  "MJL PA Buy Outside Bar"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrAqua
#property indicator_style4  STYLE_SOLID
#property indicator_width4  4

//-----------------------------------------
//--- plot DivDN
#property indicator_label5  "MJL PA Sell Pin"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2
//--- plot DivDN
#property indicator_label6  "MJL PA Sell Minor Pin"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrMaroon
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot DivDN
#property indicator_label7  "MJL PA Sell Traintrack"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrMagenta
#property indicator_style7  STYLE_SOLID
#property indicator_width7  2
//--- plot DivDN
#property indicator_label8  "MJL PA Sell Outside Bar"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrRed
#property indicator_style8  STYLE_SOLID
#property indicator_width8  4
//-----------------------------------------
//--- plot Target
#property indicator_label9  "MJL TP Target"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrNavy
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1

//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0, // No
  };
//--- input parameters
input ENUM_INPUT_YES_NO    InpUseAlerts      =  INPUT_YES;     // Use alerts
input ENUM_INPUT_YES_NO    InpSendMail       =  INPUT_NO;      // Send mail
input ENUM_INPUT_YES_NO    InpSendPush       =  INPUT_YES;     // Send push-notifications


input ENUM_TIMEFRAMES Timeframe = PERIOD_H4;
input ENUM_TIMEFRAMES Timeframe_Refresh = PERIOD_M1;

input double   ATR_Mult      =  1;
input bool     DeltaFilter  = true;
input bool     Pinbars       =  true;  
input double   Candle_To_D1_ATR_Ratio = 0.25;
input double   D1RangeMult=1;
input double   Pin_To_ATR_Ratio = 0.5;
input double   Pin_To_Body_Ratio = 1;
input double   Head_To_Tail_Ratio = 2;

input bool     BullishMinorPinbars  =  true;
input bool     BearishMinorPinbars  =  true;
input bool     MinorPin_Boll  =  false;
input double   MinorPinBodyRatio_Mult = 1;
input double   MinorPinTailRatio_Mult = 2;

input bool     Traintracks       =  true;
input double   Traintrack_ATR_Ratio = 3;
input double   Proximity_To_Previous_Open = 0.66;
     
input bool     OutsideBar        =  true; 
input bool     OutsideBar_Boll   =  true; 
input double   Outside_To_D1_ATR_Ratio = 0.33;
input double   Outside_To_Prev_Ratio = 1;

input bool     BullishDoji        =  true; 
input bool     BearishDoji        =  true; 
input double   Doji_Ratio = 0.1;


input bool     Custom_Rejection = false;
input int      Rejection_Period = 400;
input ENUM_MA_METHOD      Rejection_Method = 1;
input bool     EMA200_Rejection = true;
input bool     EMA100_Rejection = true;
input bool     EMA50_Rejection = true;
input double   Tail_To_ATR_Ratio = 0.4;

input bool     ShowTargets = false;
input double   RiskRewardRatio = 3;
input int      BarsLookback = 4;//BarsLookback (must be >= 1)

input int      BollingerPeriod  = 12;
input bool     Bullish_Bollinger_2_Filter = false;
input bool     Bearish_Bollinger_2_Filter = true;

input int      Bollinger_2_Period  = 50;
input double   Bollinger_2_Deviation = 1.8;

input int      DailyATR_Period = 22;
input double   Risk  =50;//Risk Percent
input bool     Delete_TL      =  false;

//--- indicator buffers
double         BufferDivUP[];
double         BufferDivDN[];

double         BufferDivUP2[];
double         BufferDivDN2[];

double         BufferDivUP3[];
double         BufferDivDN3[];

double         BufferDivUP4[];
double         BufferDivDN4[];

double         Bollinger_High[];
double         Bollinger_Low[];

double         Bollinger_2_High[];
double         Bollinger_2_Low[];
double         SMA200[];
double         SMA100[];
double         SMA50[];
double         SMA400[];
double         Delta50[];
double         Delta200[];


double         Target[];

double         DailyATR20,
               ATR20;
               
static datetime last_time;   

int            Bollinger_handle;
int            Bollinger_2_handle;
int            SMA200_handle;
int            SMA100_handle;
int            SMA50_handle;
int            SMA400_handle;
int            Delta50_handle;
int            Delta200_handle;
bool           DeleteScreenshot;

MqlDateTime tm;
            
//--- global variables
ENUM_CHART_VOLUME_MODE  prev_volume;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {


//--- Section A.2: Find out whether trading using EAs is allowed on this account.
      if(Period()!=Timeframe)
        {
         if(ChartSetSymbolPeriod(0,Symbol(),Timeframe)<=0)
            {
            Print(_Symbol+" Chart Refresh failed");
            }
        }



//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDivUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDivUP2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDivUP3,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDivUP4,INDICATOR_DATA);
   SetIndexBuffer(4,BufferDivDN,INDICATOR_DATA);
   SetIndexBuffer(5,BufferDivDN2,INDICATOR_DATA);
   SetIndexBuffer(6,BufferDivDN3,INDICATOR_DATA);
   SetIndexBuffer(7,BufferDivDN4,INDICATOR_DATA);
   SetIndexBuffer(8,Target,INDICATOR_DATA);
   
   //SetIndexBuffer(2,BufferVolume,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,225);
   PlotIndexSetInteger(1,PLOT_ARROW,225);
   PlotIndexSetInteger(2,PLOT_ARROW,221);
   PlotIndexSetInteger(3,PLOT_ARROW,241);
   PlotIndexSetInteger(4,PLOT_ARROW,226);
   PlotIndexSetInteger(5,PLOT_ARROW,226);
   PlotIndexSetInteger(6,PLOT_ARROW,222);
   PlotIndexSetInteger(7,PLOT_ARROW,242);
   PlotIndexSetInteger(8,PLOT_ARROW,159);
   
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MJL Price Action");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDivUP,true);
   ArraySetAsSeries(BufferDivUP2,true);
   ArraySetAsSeries(BufferDivUP3,true);
   ArraySetAsSeries(BufferDivUP4,true);
   //===
   ArraySetAsSeries(BufferDivDN,true);
   ArraySetAsSeries(BufferDivDN2,true);
   ArraySetAsSeries(BufferDivDN3,true);
   ArraySetAsSeries(BufferDivDN4,true);
   ArraySetAsSeries(Bollinger_High,true);
   ArraySetAsSeries(Bollinger_Low,true);
   ArraySetAsSeries(Bollinger_2_High,true);
   ArraySetAsSeries(Bollinger_2_Low,true);
   ArraySetAsSeries(SMA200,true);
   ArraySetAsSeries(SMA100,true);
   ArraySetAsSeries(SMA50,true);
   ArraySetAsSeries(SMA400,true);
   ArraySetAsSeries(Delta50,true);
   ArraySetAsSeries(Delta200,true);
   //===
   ArraySetAsSeries(Target,true);
   
   //ArraySetAsSeries(BufferVolume,true);
   last_time=0;
   
   
//--- indicator buffers mapping
   SetIndexBuffer(9,Bollinger_High,INDICATOR_DATA);
   SetIndexBuffer(10,Bollinger_Low,INDICATOR_DATA);
   Bollinger_handle=iBands(NULL,0,BollingerPeriod,0,2,PRICE_WEIGHTED);
   
//--- indicator buffers mapping
   SetIndexBuffer(11,Bollinger_High,INDICATOR_DATA);
   SetIndexBuffer(12,Bollinger_Low,INDICATOR_DATA);
   Bollinger_2_handle=iBands(NULL,0,Bollinger_2_Period,0,Bollinger_2_Deviation,PRICE_CLOSE);
   
   SetIndexBuffer(13,SMA200,INDICATOR_DATA);
   SMA200_handle=iMA(NULL,PERIOD_CURRENT,200,0,1,PRICE_CLOSE);
   SetIndexBuffer(14,SMA100,INDICATOR_DATA);
   SMA100_handle=iMA(NULL,PERIOD_CURRENT,100,0,1,PRICE_CLOSE);
   SetIndexBuffer(15,SMA50,INDICATOR_DATA);
   SMA50_handle=iMA(NULL,PERIOD_CURRENT,50,0,1,PRICE_CLOSE);
   SetIndexBuffer(16,SMA400,INDICATOR_DATA);
   SMA400_handle=iMA(NULL,PERIOD_CURRENT,Rejection_Period,0,Rejection_Method,PRICE_CLOSE);
   
   SetIndexBuffer(16,Delta50,INDICATOR_DATA);
   Delta50_handle=iCustom(NULL,PERIOD_CURRENT,"Delta MA");
   SetIndexBuffer(16,Delta200,INDICATOR_DATA);
   Delta200_handle=iCustom(NULL,PERIOD_CURRENT,"Delta MA");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //ChartSetInteger(0,CHART_SHOW_VOLUMES,prev_volume);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(tick_volume,true);
   ArraySetAsSeries(volume,true);
   
//--- Проверка количества доступных баров
   if(rates_total<10) return 0;
   
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   

      limit=rates_total-10;
      ArrayInitialize(BufferDivUP,EMPTY_VALUE);
      ArrayInitialize(BufferDivDN,EMPTY_VALUE);
      ArrayInitialize(BufferDivUP2,EMPTY_VALUE);
      ArrayInitialize(BufferDivDN2,EMPTY_VALUE);
      ArrayInitialize(BufferDivUP3,EMPTY_VALUE);
      ArrayInitialize(BufferDivDN3,EMPTY_VALUE);
      ArrayInitialize(BufferDivUP4,EMPTY_VALUE);
      ArrayInitialize(BufferDivDN4,EMPTY_VALUE);
      ArrayInitialize(Target,EMPTY_VALUE);


      TimeCurrent(tm);
      
   //--- Расчёт индикатора
    if(last_time!=time[0])
      {
      
      DeleteScreenshot = true;
      if(tm.hour==23 && tm.min==59 && tm.sec >45){ObjectDelete(0,"stoploss");}
      if(Delete_TL){ObjectDelete(0,"stoploss");}
      //Sleep(1000);
      

      DailyATR20  = 0;
      MqlRates _rates[]; 
      int _ratesCopied = CopyRates(_Symbol,PERIOD_D1,0,DailyATR_Period+1,_rates);
      if (_ratesCopied>0)
          for (int i=1; i<_ratesCopied; i++)
            DailyATR20 += MathMax(_rates[i].high,_rates[i-1].close)-MathMin(_rates[i].low,_rates[i-1].close);
            DailyATR20 /= MathMax(_ratesCopied,1);
            DailyATR20 = DailyATR20*ATR_Mult;
            DailyATR20 = NormalizeDouble(DailyATR20,_Digits);
            

      ATR20  = 0;
      MqlRates _rates2[]; 
      int _ratesCopied2 = CopyRates(_Symbol,PERIOD_CURRENT,0,101,_rates2);
      if (_ratesCopied2>0)
          for (int j=1; j<_ratesCopied2; j++)
            ATR20 += MathMax(_rates2[j].high,_rates2[j-1].close)-MathMin(_rates2[j].low,_rates2[j-1].close);
            ATR20 /= MathMax(_ratesCopied2,1);
            ATR20 = ATR20*ATR_Mult;
            ATR20 = NormalizeDouble(ATR20,_Digits);
     
     
       ArrayInitialize(Bollinger_High,EMPTY_VALUE);
       ArrayInitialize(Bollinger_Low,EMPTY_VALUE);
       
       ArrayInitialize(Bollinger_2_High,EMPTY_VALUE);
       ArrayInitialize(Bollinger_2_Low,EMPTY_VALUE);
       
          int copy=CopyBuffer(Bollinger_handle,1,0,rates_total,Bollinger_High);
          if(copy<=0){
             Sleep(1000);
             if(ChartSetSymbolPeriod(0,_Symbol,Timeframe_Refresh)>0)
                           {
                           GlobalVariableSet(_Symbol+"_OncePerHour",tm.hour);
                           Print(_Symbol," Chart Refreshed ",tm.hour);   
                           Print("An attempt to get the Bollinger_High has failed");  
                           return(0);    
                           }
             }//if
       
          copy=CopyBuffer(Bollinger_handle,2,0,rates_total,Bollinger_Low);
          if(copy<=0){
             Sleep(1000);
             if(ChartSetSymbolPeriod(0,_Symbol,Timeframe_Refresh)>0)
                           {
                           GlobalVariableSet(_Symbol+"_OncePerHour",tm.hour);
                           Print(_Symbol," Chart Refreshed ",tm.hour);   
                           Print("An attempt to get the Bollinger_Low has failed");    
                           return(0);    
                           }
             }//if
       

          copy=CopyBuffer(Bollinger_2_handle,1,0,rates_total,Bollinger_2_High);
          if(copy<=0){
             Sleep(1000);
             if(ChartSetSymbolPeriod(0,_Symbol,Timeframe_Refresh)>0)
                           {
                           GlobalVariableSet(_Symbol+"_OncePerHour",tm.hour);
                           Print(_Symbol," Chart Refreshed ",tm.hour);   
                           Print("An attempt to get the Bollinger_2_High has failed"); 
                           return(0);    
                           }
             }//if


          copy=CopyBuffer(Bollinger_2_handle,2,0,rates_total,Bollinger_2_Low);
          if(copy<=0){
             Sleep(1000);
             if(ChartSetSymbolPeriod(0,_Symbol,Timeframe_Refresh)>0)
                           {
                           GlobalVariableSet(_Symbol+"_OncePerHour",tm.hour);
                           Print(_Symbol," Chart Refreshed ",tm.hour);   
                           Print("An attempt to get the Bollinger_2_Low has failed"); 
                           return(0);    
                           }
             }//if
             
          copy=CopyBuffer(Delta50_handle,2,0,rates_total,Delta50);
          if(copy<=0){
             //Sleep(1000);
               Print("An attempt to get the Delta50_handle has failed"); 
             }//if
             
          copy=CopyBuffer(Delta200_handle,3,0,rates_total,Delta200);
          if(copy<=0){
             //Sleep(1000);
               Print("An attempt to get the Delta200_handle has failed"); 
             }//if

          copy=CopyBuffer(SMA200_handle,0,0,rates_total,SMA200);
          if(copy<=0){
             //Sleep(1000);
             Print("An attempt to get the SMA200 has failed");    
             }
          copy=CopyBuffer(SMA100_handle,0,0,rates_total,SMA100);
          if(copy<=0){
             //Sleep(1000);
             Print("An attempt to get the SMA100 has failed");    
             }
          copy=CopyBuffer(SMA50_handle,0,0,rates_total,SMA50);
          if(copy<=0){
             //Sleep(1000);
             Print("An attempt to get the SMA50 has failed");    
             }
          copy=CopyBuffer(SMA400_handle,0,0,rates_total,SMA400);
          if(copy<=0){
             //Sleep(1000);
             Print("An attempt to get the SMA400 has failed");    
             }

              //--- force chart redraw by changing timeframe if indicators lose sync with charts
          if((Period()==Timeframe)&&(GlobalVariableGet(_Symbol+"_OncePerHour")!=tm.hour))
                  {
                  if(ChartSetSymbolPeriod(0,_Symbol,Timeframe_Refresh)>0)
                     {
                     GlobalVariableSet(_Symbol+"_OncePerHour",tm.hour);
                     Print(_Symbol," Chart Refreshed ",tm.hour);         
                     //Sleep(1000);
                     //return(0);
                     }
                  }
         //Print(_Symbol+"_OncePerHour ",GlobalVariableGet(_Symbol+"_OncePerHour"));         
     
      }//if
     


//use this to hide indicators when not maximised 
//ChartGetInteger(0,CHART_IS_MAXIMIZED);


/*
if(_Symbol=="EURUSD"){Print("Capslock Int"+IntegerToString(TerminalInfoInteger(TERMINAL_KEYSTATE_CAPSLOCK)));
Sleep(1000);}
*/
/*

double High[10],
       Highest=0;
for(int j=0;j<6;j++){
   High[j]=NormalizeDouble(high[j]+ATR20/20,_Digits);
   if (NormalizeDouble(high[j]+ATR20/20,_Digits)>Highest){Highest=NormalizeDouble(high[j]+ATR20/20,_Digits);}
   }
   ObjectCreate(0,"stoploss",OBJ_TREND,0,time[10],Highest,time[0],Highest);
   
   
   

   //==SELL SIZE===================================================================================== Calculate the trade volume based on the desired stoploss & risk
   int Digit_Factor   = 1;  
   double increment = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_SIZE);  //m_symbol.TickSize()
   double  AccountEquity  = AccountInfoDouble(ACCOUNT_EQUITY);
               double stoploss = MathAbs(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK)-Highest,_Digits));
   if (_Digits == 3 || _Digits == 5)Digit_Factor = 10;
   double   One_Tick = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_VALUE) * Digit_Factor;
   double   MaxLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MAX);
   double   MinLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MIN);
   double   LotDigits = 2;//SymbolInfoDouble(NULL,SYMBOL_VOLUME_STEP);
   double Risk_In_Money = (stoploss/increment/Digit_Factor) * One_Tick;
   double tradesize = NormalizeDouble(((AccountEquity * 50/100)/Risk_In_Money),(int)LotDigits); // %risk = $ loss >>> SL = allowed volume
   if (tradesize > MaxLot)tradesize = MaxLot;
   if (tradesize < MinLot)tradesize = MinLot;
   Print(_Symbol+"  "+DoubleToString(tradesize,2));
   //========================================================================================= Convert the pips for EA use using point & 4 or 5 digit conversion


double Low[10],
       Lowest=9999999;
for(int j=0;j<6;j++){
   Low[j]=NormalizeDouble(low[j]-ATR20/20,_Digits);
   if (NormalizeDouble(low[j]-ATR20/20,_Digits)<Lowest){Lowest=NormalizeDouble(low[j]-ATR20/20,_Digits);}
   }
   ObjectCreate(0,"stoploss",OBJ_TREND,0,time[10],Lowest,time[0],Lowest);


//==BUY SIZE===================================================================================== Calculate the trade volume based on the desired stoploss & risk
int Digit_Factor   = 1;  
double increment = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_SIZE);  //m_symbol.TickSize()
double  AccountEquity  = AccountInfoDouble(ACCOUNT_EQUITY);
double stoploss = MathAbs(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK)-Lowest,_Digits));
if (_Digits == 3 || _Digits == 5)Digit_Factor = 10;
double   One_Tick = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_VALUE) * Digit_Factor;
double   MaxLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MAX);
double   MinLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MIN);
double   LotDigits = 2;//SymbolInfoDouble(NULL,SYMBOL_VOLUME_STEP);
double Risk_In_Money = (stoploss/increment/Digit_Factor) * One_Tick;
double tradesize = NormalizeDouble(((AccountEquity * Risk/100)/Risk_In_Money),(int)LotDigits); // %risk = $ loss >>> SL = allowed volume
if (tradesize > MaxLot)tradesize = MaxLot;
if (tradesize < MinLot)tradesize = MinLot;
Print(_Symbol+"  "+DoubleToString(tradesize,2));
//========================================================================================= Convert the pips for EA use using point & 4 or 5 digit conversion

*/  


 

//--- Расчёт индикатора
   for(int i=limit-10; i>=0 && !IsStopped(); i--)
     {
     
     
      double Range0=high[i]-low[i];
      double Range1=high[i+1]-low[i+1];
      double Range2=high[i+2]-low[i+2];
      double bullbody=close[i+1]-open[i+1];
      double bearbody=open[i+1]-close[i+1];
      double bulltails=(high[i+1]-close[i+1])+(open[i+1]-low[i+1]);
      double beartails=(high[i+1]-open[i+1])+(close[i+1]-low[i+1]);
      double bullbody2=close[i+2]-open[i+2];
      double bearbody2=open[i+2]-close[i+2];
      double bulltails2=(high[i+2]-close[i+2])+(open[i+2]-low[i+2]);
      double beartails2=(high[i+2]-open[i+2])+(close[i+2]-low[i+2]);
      double Candle_To_D1_ATR_Ratio_temp;

      if(Range0==0)continue;
      if(Range1==0)continue;

      if(Period()==PERIOD_D1)
         {Candle_To_D1_ATR_Ratio_temp=(Candle_To_D1_ATR_Ratio*D1RangeMult);}
      else
         {Candle_To_D1_ATR_Ratio_temp=Candle_To_D1_ATR_Ratio;}
    
      
          //Print("Bollinger_Low = ",_Symbol,"   ",Bollinger_Low[0]);
          //Print("Bollinger_High = ",_Symbol,"   ",Bollinger_High[0]);
          //Print("high[1] = ",_Symbol,"   ",high[1]);
          //Print("low[1] = ",_Symbol,"   ",low[1]);
      //-----------------------------------------------------------------------------------------------
      // Bearish:
      //-----------------------------------------------------------------------------------------------
      
      
      if(
            (  (close[i+1]>open[i+1])                                              //up bear candle
            && (Range1>(ATR20*Candle_To_D1_ATR_Ratio_temp))                        //range not small
            && ((high[i+1]-close[i+1])>(ATR20*Pin_To_ATR_Ratio))                   //pin head is large
            && ((high[i+1]-close[i+1])>((close[i+1]-open[i+1])*Pin_To_Body_Ratio)) //pin head is large
            && ((high[i+1]-close[i+1])>((open[i+1]-low[i+1])*Head_To_Tail_Ratio))  //pin head is large
            && ((close[i+2]>open[i+2])||(Range2<(ATR20*1.5)))                      //not right after a big move in our direction
            //&&RSI(20)>30
            && (high[i+1]>=Bollinger_High[i+1])
            && ((high[i+1]>=Bollinger_2_High[i+1])||(!Bearish_Bollinger_2_Filter)||(high[i+1]<SMA200[i+1]))
            &&(Pinbars)
            &&((!DeltaFilter)||(Delta50[i]<=Delta200[i]) ||((Delta50[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
            //&&((!DeltaFilter)||(Delta50[i]<=Delta200[i]) ||((Delta200[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
           )
           ||
           (   (close[i+1]<=open[i+1])                                              //down bear candle
            && (Range1>(ATR20*Candle_To_D1_ATR_Ratio_temp))                        //range not small
            && ((high[i+1]-open[i+1])>(ATR20*Pin_To_ATR_Ratio))                   //pin head is large
            && ((high[i+1]-open[i+1])>((open[i+1]-close[i+1])*Pin_To_Body_Ratio)) //pin head is large
            && ((high[i+1]-open[i+1])>((close[i+1]-low[i+1])*Head_To_Tail_Ratio))  //pin head is large
            && ((close[i+2]>open[i+2])||(Range2<(ATR20*1.5)))                        //not right after a big move in our direction
            //&&RSI(20)>30
            && (high[i+1]>=Bollinger_High[i+1])
            && ((high[i+1]>=Bollinger_2_High[i+1])||(!Bearish_Bollinger_2_Filter)||(high[i+1]<SMA200[i+1]))
            &&(Pinbars)
            &&((!DeltaFilter)||(Delta50[i]<=Delta200[i]) ||((Delta50[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
            //&&((!DeltaFilter)||(Delta50[i]<=Delta200[i]) ||((Delta200[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
           )
        )//if
           {
            BufferDivDN[i+1]=high[i+1]+(ATR20/2);
            if(ShowTargets){Target[i+1]=NormalizeDouble(close[i+1]-(RiskRewardRatio*(high[i+1]-close[i+1])),_Digits);}
            if(i==0)
              {
               if(last_time!=time[0])
                 {
                  last_time=time[0];
                     double High[10],
                            Highest=0;
                     for(int j=0;j<BarsLookback;j++){
                        High[j]=NormalizeDouble(high[j]+ATR20/20,_Digits);
                        if (NormalizeDouble(high[j]+ATR20/20,_Digits)>Highest){Highest=NormalizeDouble(high[j]+ATR20/20,_Digits);}
                        }                       
                        if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){
                        ObjectCreate(0,"stoploss",OBJ_TREND,0,time[10],Highest,time[0],Highest);
                        ObjectSetInteger(0,"stoploss",OBJPROP_RAY_RIGHT,true);
                        ObjectSetInteger(0,"stoploss",OBJPROP_SELECTABLE,true);
                        ObjectSetInteger(0,"stoploss",OBJPROP_SELECTED,true);
                        }
                  ChartRedraw();
                  //==SELL SIZE===================================================================================== Calculate the trade volume based on the desired stoploss & risk
                  int Digit_Factor   = 1;  
                  double increment = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_SIZE);  //m_symbol.TickSize()
                  double  AccountEquity  = AccountInfoDouble(ACCOUNT_EQUITY);
                  double stoploss = MathAbs(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID)-Highest,_Digits));
                  if (_Digits == 3 || _Digits == 5)Digit_Factor = 10;
                  double   One_Tick = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_VALUE) * Digit_Factor;
                  double   MaxLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MAX);
                  double   MinLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MIN);
                  double   LotDigits = 2;//SymbolInfoDouble(NULL,SYMBOL_VOLUME_STEP);
                  double Risk_In_Money = (stoploss/increment/Digit_Factor) * One_Tick;
                  double tradesize = NormalizeDouble(((AccountEquity * Risk/100)/Risk_In_Money),(int)LotDigits); // %risk = $ loss >>> SL = allowed volume
                  if (tradesize > MaxLot)tradesize = MaxLot;
                  if (tradesize < MinLot)tradesize = MinLot;
                  //Print(_Symbol+"  "+DoubleToString(tradesize,2));
                  //========================================================================================= Convert the pips for EA use using point & 4 or 5 digit conversion
                  string message=Symbol()+", "+TimeframeToString(Period())+": Bear Pin   [Range = "+(string)NormalizeDouble(((high[i+1]-low[i+1])/ATR20),2)+"ATR | SL = "+DoubleToString(Highest,_Digits)+" | "+DoubleToString(tradesize,2)+" lots short]";
                  if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){if(InpUseAlerts) Alert(message);
                  //if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Price volume divergence Signal",message);
                  if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);}
                 }
              }
           }
         else
            BufferDivDN[i+1]=EMPTY_VALUE;

      if(
           (   (close[i+1]>open[i+1])                                              //up bear candle
            && ((high[i+1]-close[i+1])>(ATR20*0.5*Pin_To_ATR_Ratio))                   //pin head is large
            && ((high[i+1]-close[i+1])>((close[i+1]-open[i+1])*MinorPinBodyRatio_Mult*Pin_To_Body_Ratio)) //pin head is large
            && ((high[i+1]-close[i+1])>((open[i+1]-low[i+1])*MinorPinTailRatio_Mult*Head_To_Tail_Ratio))  //pin head is large
            && (high[i+1]>high[i+2])
            && (high[i+1]>high[i+3])
            //&& ((close[i+2]>open[i+2])||(Range2<(ATR20*1.5)))                        //not right after a big move in our direction
            //&&RSI(20)>30
            && ((high[i+1]>=Bollinger_High[i+1])||(!MinorPin_Boll))
            && (((high[i+1]>=Bollinger_2_High[i+1])||(!Bearish_Bollinger_2_Filter)||(!MinorPin_Boll))||(high[i+1]<SMA200[i+1]))
            &&(BearishMinorPinbars)
            &&((!DeltaFilter)||(Delta50[i]<=Delta200[i]) ||((Delta50[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
            //&&((!DeltaFilter)||(Delta50[i]<=Delta200[i]) ||((Delta200[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
           )
           ||
           (   (close[i+1]<=open[i+1])                                              //down bear candle
            && ((high[i+1]-open[i+1])>(ATR20*0.5*Pin_To_ATR_Ratio))                   //pin head is large
            && ((high[i+1]-open[i+1])>((open[i+1]-close[i+1])*MinorPinBodyRatio_Mult*Pin_To_Body_Ratio)) //pin head is large
            && ((high[i+1]-open[i+1])>((close[i+1]-low[i+1])*MinorPinTailRatio_Mult*Head_To_Tail_Ratio))  //pin head is large
            && (high[i+1]>high[i+2])
            && (high[i+1]>high[i+3])
            //&& ((close[i+2]>open[i+2])||(Range2<(ATR20*1.5)))                        //not right after a big move in our direction
            //&&RSI(20)>30
            && ((high[i+1]>=Bollinger_High[i+1])||(!MinorPin_Boll))
            && (((high[i+1]>=Bollinger_2_High[i+1])||(!Bearish_Bollinger_2_Filter)||(!MinorPin_Boll))||(high[i+1]<SMA200[i+1]))
            &&(BearishMinorPinbars)
            &&((!DeltaFilter)||(Delta50[i]<=Delta200[i]) ||((Delta50[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
            //&&((!DeltaFilter)||(Delta50[i]<=Delta200[i]) ||((Delta200[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
           )
           ||
           (
               ((MathAbs((open[i+1]-close[i+1]))/Range1)<Doji_Ratio)                                             //down bull candle
            && ((low[i+1]>=Bollinger_High[i+1]))
            && ((((high[i+1]-close[i+1]+0.000000001)/(open[i+1]-low[i+1]+0.000000001))>(1-Doji_Ratio))||(close[i+1]<open[i+1]))
            && ((((high[i+1]-open[i+1]+0.000000001)/(close[i+1]-low[i+1]+0.000000001))>(1-Doji_Ratio))||(close[i+1]>open[i+1]))
            &&(BearishDoji)
            &&((!DeltaFilter)||(Delta50[i]<=Delta200[i])  ||((Delta50[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
            //&&((!DeltaFilter)||(Delta50[i]<=Delta200[i])  ||((Delta200[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
           )
           ||
           (
               ((high[i+1]>=SMA200[i+1]))
            && ((close[i+1]<SMA200[i+1]))
            && ((high[i+1]>=(Bollinger_High[i+1]-((Bollinger_High[i+1]-Bollinger_Low[i+1])/8))))
            && ((((high[i+1]-close[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]<=open[i+1]))
            && ((((high[i+1]-open[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]>open[i+1]))
            && (EMA200_Rejection)
            &&((!DeltaFilter)||(Delta50[i]<=Delta200[i])  ||((Delta50[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
            //&&((!DeltaFilter)||(Delta50[i]<=Delta200[i])  ||((Delta200[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
           )  
           ||
           (
               ((high[i+1]>=SMA100[i+1]))
            && ((close[i+1]<SMA100[i+1]))
            && ((high[i+1]>=(Bollinger_High[i+1]-((Bollinger_High[i+1]-Bollinger_Low[i+1])/8))))
            && ((((high[i+1]-close[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]<=open[i+1]))
            && ((((high[i+1]-open[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]>open[i+1]))
            && (EMA100_Rejection)
            &&((!DeltaFilter)||(Delta50[i]<=Delta200[i])  ||((Delta50[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
            //&&((!DeltaFilter)||(Delta50[i]<=Delta200[i])  ||((Delta200[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
           )   
           ||
           (
               ((high[i+1]>=SMA50[i+1]))
            && ((close[i+1]<SMA50[i+1]))
            && ((high[i+1]>=(Bollinger_High[i+1]-((Bollinger_High[i+1]-Bollinger_Low[i+1])/8))))
            && ((((high[i+1]-close[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]<=open[i+1]))
            && ((((high[i+1]-open[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]>open[i+1]))
            && (EMA50_Rejection)
            &&((!DeltaFilter)||(Delta50[i]<=Delta200[i])  ||((Delta50[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
            //&&((!DeltaFilter)||(Delta50[i]<=Delta200[i])  ||((Delta200[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
           )        
           ||
           (
               ((high[i+1]>=SMA400[i+1]))
            && ((close[i+1]<SMA400[i+1]))
            && ((high[i+1]>=(Bollinger_High[i+1]-((Bollinger_High[i+1]-Bollinger_Low[i+1])/8))))
            && ((((high[i+1]-close[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]<=open[i+1]))
            && ((((high[i+1]-open[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]>open[i+1]))
            && (Custom_Rejection)
            &&((!DeltaFilter)||(Delta50[i]<=Delta200[i])  ||((Delta50[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
            //&&((!DeltaFilter)||(Delta50[i]<=Delta200[i])  ||((Delta200[i]<0)&&((SMA100[i+1]<=SMA200[i+1])))  )
           )        
           )//if
           {
            BufferDivDN2[i+1]=high[i+1]+(ATR20/3);
            if(ShowTargets){Target[i+1]=NormalizeDouble(close[i+1]-(RiskRewardRatio*(high[i+1]-close[i+1])),_Digits);}
            if(i==0)
              {
               if(last_time!=time[0])
                 {
                  last_time=time[0];
                     double High[10],
                            Highest=0;
                     for(int j=0;j<BarsLookback;j++){
                        High[j]=NormalizeDouble(high[j]+ATR20/20,_Digits);
                        if (NormalizeDouble(high[j]+ATR20/20,_Digits)>Highest){Highest=NormalizeDouble(high[j]+ATR20/20,_Digits);}
                        }
                        if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){
                        ObjectCreate(0,"stoploss",OBJ_TREND,0,time[10],Highest,time[0],Highest);
                        ObjectSetInteger(0,"stoploss",OBJPROP_RAY_RIGHT,true);
                        ObjectSetInteger(0,"stoploss",OBJPROP_SELECTABLE,true);
                        ObjectSetInteger(0,"stoploss",OBJPROP_SELECTED,true);
                        }
                  ChartRedraw();
                  //==SELL SIZE===================================================================================== Calculate the trade volume based on the desired stoploss & risk
                  int Digit_Factor   = 1;  
                  double increment = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_SIZE);  //m_symbol.TickSize()
                  double  AccountEquity  = AccountInfoDouble(ACCOUNT_EQUITY);
                  double stoploss = MathAbs(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID)-Highest,_Digits));
                  if (_Digits == 3 || _Digits == 5)Digit_Factor = 10;
                  double   One_Tick = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_VALUE) * Digit_Factor;
                  double   MaxLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MAX);
                  double   MinLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MIN);
                  double   LotDigits = 2;//SymbolInfoDouble(NULL,SYMBOL_VOLUME_STEP);
                  double Risk_In_Money = (stoploss/increment/Digit_Factor) * One_Tick;
                  double tradesize = NormalizeDouble(((AccountEquity * Risk/100)/Risk_In_Money),(int)LotDigits); // %risk = $ loss >>> SL = allowed volume
                  if (tradesize > MaxLot)tradesize = MaxLot;
                  if (tradesize < MinLot)tradesize = MinLot;
                  //Print(_Symbol+"  "+DoubleToString(tradesize,2));
                  //========================================================================================= Convert the pips for EA use using point & 4 or 5 digit conversion
                  string message=Symbol()+", "+TimeframeToString(Period())+": Minor Bear Pin   [Range = "+(string)NormalizeDouble(((high[i+1]-low[i+1])/ATR20),2)+"ATR | SL = "+DoubleToString(Highest,_Digits)+" | "+DoubleToString(tradesize,2)+" lots short]";
                  if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){if(InpUseAlerts) Alert(message);
                  //if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Price volume divergence Signal",message);
                  if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);}
                 }
              }
           }
         else
            BufferDivDN2[i+1]=EMPTY_VALUE;
   


      if(   (close[i+1]<=open[i+1]) 
         && (close[i+2]>open[i+2])                                              //bear traintrack
         && (Range1>(ATR20*Traintrack_ATR_Ratio*Candle_To_D1_ATR_Ratio_temp))                        //range not small
         && (Range2>(ATR20*Traintrack_ATR_Ratio*Candle_To_D1_ATR_Ratio_temp))                        //range not small
         && (MathAbs((open[i+2]-close[i+1]))<ATR20*Proximity_To_Previous_Open)                           //previous open near last close
         && (bearbody>beartails)
         //&& (bullbody2>bulltails2)
         && (high[i+1]-open[i+1])<(ATR20/3)
         && ((high[i+1]>=Bollinger_High[i+1])||(high[i+2]>=Bollinger_High[i+2]))
         && (((high[i+1]>=Bollinger_2_High[i+1])||(high[i+2]>=Bollinger_2_High[i+2]))||(!Bearish_Bollinger_2_Filter)||(high[i+1]<SMA200[i+1]))
         && (Traintracks)
         &&((!DeltaFilter)||(Delta50[i]<=Delta200[i])  ||((Delta50[i]>0)&&((SMA100[i+1]>SMA200[i+1])))  )
         //&&((!DeltaFilter)||(Delta50[i]<=Delta200[i])  ||((Delta200[i]>0)&&((SMA100[i+1]>SMA200[i+1])))  )
        )
        
        
        {
         BufferDivDN3[i+1]=high[i+1]+(ATR20/2);
         if(ShowTargets){Target[i+1]=NormalizeDouble(close[i+1]-(RiskRewardRatio*(high[i+1]-close[i+1])),_Digits);}
         if(i==0)
           {
            if(last_time!=time[0])
                 {
                  last_time=time[0];
                     double High[10],
                            Highest=0;
                     for(int j=0;j<BarsLookback;j++){
                        High[j]=NormalizeDouble(high[j]+ATR20/20,_Digits);
                        if (NormalizeDouble(high[j]+ATR20/20,_Digits)>Highest){Highest=NormalizeDouble(high[j]+ATR20/20,_Digits);}
                        }
                        if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){
                        ObjectCreate(0,"stoploss",OBJ_TREND,0,time[10],Highest,time[0],Highest);
                        ObjectSetInteger(0,"stoploss",OBJPROP_RAY_RIGHT,true);
                        ObjectSetInteger(0,"stoploss",OBJPROP_SELECTABLE,true);
                        ObjectSetInteger(0,"stoploss",OBJPROP_SELECTED,true);
                        }
                  ChartRedraw();
                  //==SELL SIZE===================================================================================== Calculate the trade volume based on the desired stoploss & risk
                  int Digit_Factor   = 1;  
                  double increment = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_SIZE);  //m_symbol.TickSize()
                  double  AccountEquity  = AccountInfoDouble(ACCOUNT_EQUITY);
                  double stoploss = MathAbs(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID)-Highest,_Digits));
                  if (_Digits == 3 || _Digits == 5)Digit_Factor = 10;
                  double   One_Tick = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_VALUE) * Digit_Factor;
                  double   MaxLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MAX);
                  double   MinLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MIN);
                  double   LotDigits = 2;//SymbolInfoDouble(NULL,SYMBOL_VOLUME_STEP);
                  double Risk_In_Money = (stoploss/increment/Digit_Factor) * One_Tick;
                  double tradesize = NormalizeDouble(((AccountEquity * Risk/100)/Risk_In_Money),(int)LotDigits); // %risk = $ loss >>> SL = allowed volume
                  if (tradesize > MaxLot)tradesize = MaxLot;
                  if (tradesize < MinLot)tradesize = MinLot;
                  //Print(_Symbol+"  "+DoubleToString(tradesize,2));
                  //========================================================================================= Convert the pips for EA use using point & 4 or 5 digit conversion
                  string message=Symbol()+", "+TimeframeToString(Period())+": Bearish Traintracks   [Range = "+(string)NormalizeDouble(((high[i+1]-low[i+1])/ATR20),2)+"ATR | SL = "+DoubleToString(Highest,_Digits)+" | "+DoubleToString(tradesize,2)+" lots short]";
                  if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){if(InpUseAlerts) Alert(message);
                  //if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Price volume divergence Signal",message);
                  if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);}
                 }           }
        }
      else
         BufferDivDN3[i+1]=EMPTY_VALUE;

      //-----------------------------------------------------------------------------------------------


      if(   (close[i+1]<=open[i+1]) 
         && (Range1>(ATR20*Outside_To_D1_ATR_Ratio))                        //range not small
         && (Range2>(ATR20*0.5*Outside_To_D1_ATR_Ratio))                        //range not small
         && (high[i+1]>high[i+2])
         && (low[i+1]<low[i+2])
         && (Range1>(Outside_To_Prev_Ratio*Range2))
         && (bearbody>4*(close[i+1]-low[i+1]))
         && ((high[i+1]>=Bollinger_High[i+1])||(!OutsideBar_Boll))
         && ((high[i+1]>=Bollinger_2_High[i+1])||(!OutsideBar_Boll)||(!Bearish_Bollinger_2_Filter)||(high[i+1]<SMA200[i+1]))
         && (OutsideBar)
         &&((!DeltaFilter)||(Delta50[i]<=Delta200[i])||((Delta50[i]>0)&&((SMA100[i+1]>SMA200[i+1])))  )
         //&&((!DeltaFilter)||(Delta50[i]<=Delta200[i])||((Delta200[i]>0)&&((SMA100[i+1]>SMA200[i+1])))  )
        )
        {
         BufferDivDN4[i+1]=high[i+1]+(ATR20/2);
         if(ShowTargets){Target[i+1]=NormalizeDouble(close[i+1]-(RiskRewardRatio*(high[i+1]-close[i+1])),_Digits);}
         if(i==0)
           {
            if(last_time!=time[0])
                 {
                  last_time=time[0];
                     double High[10],
                            Highest=0;
                     for(int j=0;j<BarsLookback;j++){
                        High[j]=NormalizeDouble(high[j]+ATR20/20,_Digits);
                        if (NormalizeDouble(high[j]+ATR20/20,_Digits)>Highest){Highest=NormalizeDouble(high[j]+ATR20/20,_Digits);}
                        }
                        if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){
                        ObjectCreate(0,"stoploss",OBJ_TREND,0,time[10],Highest,time[0],Highest);
                        ObjectSetInteger(0,"stoploss",OBJPROP_RAY_RIGHT,true);
                        ObjectSetInteger(0,"stoploss",OBJPROP_SELECTABLE,true);
                        ObjectSetInteger(0,"stoploss",OBJPROP_SELECTED,true);
                        }
                  ChartRedraw();
                  //==SELL SIZE===================================================================================== Calculate the trade volume based on the desired stoploss & risk
                  int Digit_Factor   = 1;  
                  double increment = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_SIZE);  //m_symbol.TickSize()
                  double  AccountEquity  = AccountInfoDouble(ACCOUNT_EQUITY);
                  double stoploss = MathAbs(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID)-Highest,_Digits));
                  if (_Digits == 3 || _Digits == 5)Digit_Factor = 10;
                  double   One_Tick = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_VALUE) * Digit_Factor;
                  double   MaxLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MAX);
                  double   MinLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MIN);
                  double   LotDigits = 2;//SymbolInfoDouble(NULL,SYMBOL_VOLUME_STEP);
                  double Risk_In_Money = (stoploss/increment/Digit_Factor) * One_Tick;
                  double tradesize = NormalizeDouble(((AccountEquity * Risk/100)/Risk_In_Money),(int)LotDigits); // %risk = $ loss >>> SL = allowed volume
                  if (tradesize > MaxLot)tradesize = MaxLot;
                  if (tradesize < MinLot)tradesize = MinLot;
                  //Print(_Symbol+"  "+DoubleToString(tradesize,2));
                  //========================================================================================= Convert the pips for EA use using point & 4 or 5 digit conversion
                  string message=Symbol()+", "+TimeframeToString(Period())+": Bearish Outside Bar   [Range = "+(string)NormalizeDouble(((high[i+1]-low[i+1])/ATR20),2)+"ATR | SL = "+DoubleToString(Highest,_Digits)+" | "+DoubleToString(tradesize,2)+" lots short]";
                  if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){if(InpUseAlerts) Alert(message);
                  //if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Price volume divergence Signal",message);
                  if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);}
                 }           }
        }
      else
         BufferDivDN4[i+1]=EMPTY_VALUE;


   //-----------------------------------------------------------------------------------------------
   // Bullish:
   //-----------------------------------------------------------------------------------------------


    if(
        (
            (close[i+1]>open[i+1])                                              //up bull candle
         && (Range1>(ATR20*Candle_To_D1_ATR_Ratio_temp))                        //range not small
         && ((open[i+1]-low[i+1])>(ATR20*Pin_To_ATR_Ratio))                     //pin head is large
         && ((open[i+1]-low[i+1])>((close[i+1]-open[i+1])*Pin_To_Body_Ratio))   //pin tail is large
         && ((open[i+1]-low[i+1])>((high[i+1]-close[i+1])*Head_To_Tail_Ratio))  //pin is larger than tail
         && ((close[i+2]<open[i+2])||(Range2<(ATR20*1.5)))                        //not right after a big move in our direction
         //&&RSI(20)<70
         && (low[i+1]<=Bollinger_Low[i+1])
         && ((low[i+1]<=Bollinger_2_Low[i+1])||(!Bullish_Bollinger_2_Filter)||(low[i+1]>SMA200[i+1]))
         &&(Pinbars)
         &&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta50[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
         //&&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta200[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
        )
        ||
        (
            (close[i+1]<=open[i+1])                                             //down bull candle
         && (Range1>(ATR20*Candle_To_D1_ATR_Ratio_temp))                        //range not small
         && ((close[i+1]-low[i+1])>(ATR20*Pin_To_ATR_Ratio))                    //pin head is large
         && ((close[i+1]-low[i+1])>((open[i+1]-close[i+1])*Pin_To_Body_Ratio))  //pin head is large
         && ((close[i+1]-low[i+1])>((high[i+1]-open[i+1])*Head_To_Tail_Ratio))  //pin is larger than tail
         && ((close[i+2]<open[i+2])||(Range2<(ATR20*1.5)))                        //not right after a big move in our direction
         //&&RSI(20)<70
         && (low[i+1]<=Bollinger_Low[i+1])
         && ((low[i+1]<=Bollinger_2_Low[i+1])||(!Bullish_Bollinger_2_Filter)||(low[i+1]>SMA200[i+1]))
         &&(Pinbars)
         &&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta50[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
         //&&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta200[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
        )
       )//if
        {
         BufferDivUP[i+1]=low[i+1]-(ATR20/2);
         if(ShowTargets){Target[i+1]=NormalizeDouble(close[i+1]+(RiskRewardRatio*(close[i+1]-low[i+1])),_Digits);}
         if(i==0)
           {
            if(last_time!=time[0])
              {
               last_time=time[0];
               double Low[10],
                      Lowest=9999999;
               for(int j=0;j<BarsLookback;j++){
                  Low[j]=NormalizeDouble(low[j]-ATR20/20,_Digits);
                  if (NormalizeDouble(low[j]-ATR20/20,_Digits)<Lowest){Lowest=NormalizeDouble(low[j]-ATR20/20,_Digits);}
                  }
                  if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){
                  ObjectCreate(0,"stoploss",OBJ_TREND,0,time[10],Lowest,time[0],Lowest);
                  ObjectSetInteger(0,"stoploss",OBJPROP_RAY_RIGHT,true);
                  ObjectSetInteger(0,"stoploss",OBJPROP_SELECTABLE,true);
                  ObjectSetInteger(0,"stoploss",OBJPROP_SELECTED,true);
                  }
               ChartRedraw(0);
               //==BUY SIZE===================================================================================== Calculate the trade volume based on the desired stoploss & risk
               int Digit_Factor   = 1;  
               double increment = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_SIZE);  //m_symbol.TickSize()
               double  AccountEquity  = AccountInfoDouble(ACCOUNT_EQUITY);
               double stoploss = MathAbs(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK)-Lowest,_Digits));
               if (_Digits == 3 || _Digits == 5)Digit_Factor = 10;
               double   One_Tick = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_VALUE) * Digit_Factor;
               double   MaxLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MAX);
               double   MinLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MIN);
               double   LotDigits = 2;//SymbolInfoDouble(NULL,SYMBOL_VOLUME_STEP);
               double Risk_In_Money = (stoploss/increment/Digit_Factor) * One_Tick;
               double tradesize = NormalizeDouble(((AccountEquity * Risk/100)/Risk_In_Money),(int)LotDigits); // %risk = $ loss >>> SL = allowed volume
               if (tradesize > MaxLot)tradesize = MaxLot;
               if (tradesize < MinLot)tradesize = MinLot;
               //Print(_Symbol+"  "+DoubleToString(tradesize,2));
               //========================================================================================= Convert the pips for EA use using point & 4 or 5 digit conversion
               string message=Symbol()+", "+TimeframeToString(Period())+": Bull Pin   [Range = "+(string)NormalizeDouble(((high[i+1]-low[i+1])/ATR20),2)+"ATR | SL = "+DoubleToString(Lowest,_Digits)+" | "+DoubleToString(tradesize,2)+" lots long]";
               if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){if(InpUseAlerts) Alert(message);
               //if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Price volume divergence Signal",message);
               if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);}
              }
           }
        }
      else

         BufferDivUP[i+1]=EMPTY_VALUE;
       
       
    if(
        (
            (close[i+1]>open[i+1])                                              //up bull candle
         && ((open[i+1]-low[i+1])>(ATR20*Pin_To_ATR_Ratio))                     //pin head is large
         && ((open[i+1]-low[i+1])>((close[i+1]-open[i+1])*MinorPinBodyRatio_Mult*Pin_To_Body_Ratio))   //pin tail is large
         && ((open[i+1]-low[i+1])>((high[i+1]-close[i+1])*MinorPinTailRatio_Mult*Head_To_Tail_Ratio))  //pin is larger than tail
         && (low[i+1]<low[i+2])
         && (low[i+1]<low[i+3])
         //&& ((close[i+2]<open[i+2])||(Range2<(ATR20*1.5)))                        //not right after a big move in our direction
         //&&RSI(20)<70
         && ((low[i+1]<=Bollinger_Low[i+1])||(!MinorPin_Boll))
         && ((low[i+1]<=Bollinger_2_Low[i+1])||(!Bullish_Bollinger_2_Filter)||(!MinorPin_Boll)||(low[i+1]>SMA200[i+1]))
         &&(BullishMinorPinbars)
         &&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta50[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
         //&&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta200[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
        )
        ||
        (
            (close[i+1]<=open[i+1])                                             //down bull candle
         && ((close[i+1]-low[i+1])>(ATR20*Pin_To_ATR_Ratio))                    //pin head is large
         && ((close[i+1]-low[i+1])>((open[i+1]-close[i+1])*MinorPinBodyRatio_Mult*Pin_To_Body_Ratio))  //pin head is large
         && ((close[i+1]-low[i+1])>((high[i+1]-open[i+1])*MinorPinTailRatio_Mult*Head_To_Tail_Ratio))  //pin is larger than tail
         && (low[i+1]<low[i+2])
         && (low[i+1]<low[i+3])
         //&& ((close[i+2]<open[i+2])||(Range2<(ATR20*1.5)))                        //not right after a big move in our direction
         //&&RSI(20)<70
         && ((low[i+1]<=Bollinger_Low[i+1])||(!MinorPin_Boll))
         && ((low[i+1]<=Bollinger_2_Low[i+1])||(!Bullish_Bollinger_2_Filter)||(!MinorPin_Boll)||(low[i+1]>SMA200[i+1]))
         &&(BullishMinorPinbars)
         &&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta50[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
         //&&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta200[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
        )
        ||
        (
            ((MathAbs((open[i+1]-close[i+1]))/Range1)<Doji_Ratio)                                             //down bull candle
         && ((low[i+1]<=Bollinger_Low[i+1]))
         && ((((high[i+1]-close[i+1]+0.000000001)/(open[i+1]-low[i+1]+0.000000001))>(1-Doji_Ratio))||(close[i+1]<open[i+1]))
         && ((((high[i+1]-open[i+1]+0.000000001)/(close[i+1]-low[i+1]+0.000000001))>(1-Doji_Ratio))||(close[i+1]>open[i+1]))
         &&(BullishDoji)
         &&((!DeltaFilter)||(Delta50[i]>Delta200[i])||(Delta50[i]>=0))
         //&&((!DeltaFilter)||(Delta50[i]>Delta200[i])||(Delta200[i]>=0))
        )
        ||
        (
            ((low[i+1]<=SMA200[i+1]))
         && ((close[i+1]>SMA200[i+1]))
         && ((low[i+1]<=    (((Bollinger_High[i+1]-Bollinger_Low[i+1])/8)+Bollinger_Low[i+1])     )        )
         && ((((close[i+1]-low[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]>=open[i+1]))
         && ((((open[i+1]-low[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]<open[i+1]))
         && (EMA200_Rejection)
         &&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta50[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
         //&&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta200[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
        )     
        ||
        (
            ((low[i+1]<=SMA100[i+1]))
         && ((close[i+1]>SMA100[i+1]))
         && ((low[i+1]<=    (((Bollinger_High[i+1]-Bollinger_Low[i+1])/8)+Bollinger_Low[i+1])     )        )
         && ((((close[i+1]-low[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]>=open[i+1]))
         && ((((open[i+1]-low[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]<open[i+1]))
         && (EMA100_Rejection)
         &&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta50[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
         //&&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta200[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
        )    
        ||
        (
            ((low[i+1]<=SMA50[i+1]))
         && ((close[i+1]>SMA50[i+1]))
         && ((low[i+1]<=    (((Bollinger_High[i+1]-Bollinger_Low[i+1])/8)+Bollinger_Low[i+1])     )        )
         && ((((close[i+1]-low[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]>=open[i+1]))
         && ((((open[i+1]-low[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]<open[i+1]))
         && (EMA50_Rejection)
         &&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta50[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
         //&&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta200[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
        )     
        ||
        (
            ((low[i+1]<=SMA400[i+1]))
         && ((close[i+1]>SMA400[i+1]))
         && ((low[i+1]<=    (((Bollinger_High[i+1]-Bollinger_Low[i+1])/8)+Bollinger_Low[i+1])     )        )
         && ((((close[i+1]-low[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]>=open[i+1]))
         && ((((open[i+1]-low[i+1]))>(ATR20*Tail_To_ATR_Ratio))||(close[i+1]<open[i+1]))
         && (Custom_Rejection)
         &&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta50[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
         //&&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta200[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
        )        
       )//if
        {
         BufferDivUP2[i+1]=low[i+1]-(ATR20/3);
         if(ShowTargets){Target[i+1]=NormalizeDouble(close[i+1]+(RiskRewardRatio*(close[i+1]-low[i+1])),_Digits);}
         if(i==0)
           {
            if(last_time!=time[0])
              {
               last_time=time[0];
               double Low[10],
                      Lowest=9999999;
               for(int j=0;j<BarsLookback;j++){
                  Low[j]=NormalizeDouble(low[j]-ATR20/20,_Digits);
                  if (NormalizeDouble(low[j]-ATR20/20,_Digits)<Lowest){Lowest=NormalizeDouble(low[j]-ATR20/20,_Digits);}
                  }
                  if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){
                  ObjectCreate(0,"stoploss",OBJ_TREND,0,time[10],Lowest,time[0],Lowest);
                  ObjectSetInteger(0,"stoploss",OBJPROP_RAY_RIGHT,true);
                  ObjectSetInteger(0,"stoploss",OBJPROP_SELECTABLE,true);
                  ObjectSetInteger(0,"stoploss",OBJPROP_SELECTED,true);
                  }
               ChartRedraw(0);
               //==BUY SIZE===================================================================================== Calculate the trade volume based on the desired stoploss & risk
               int Digit_Factor   = 1;  
               double increment = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_SIZE);  //m_symbol.TickSize()
               double  AccountEquity  = AccountInfoDouble(ACCOUNT_EQUITY);
               double stoploss = MathAbs(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK)-Lowest,_Digits));
               if (_Digits == 3 || _Digits == 5)Digit_Factor = 10;
               double   One_Tick = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_VALUE) * Digit_Factor;
               double   MaxLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MAX);
               double   MinLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MIN);
               double   LotDigits = 2;//SymbolInfoDouble(NULL,SYMBOL_VOLUME_STEP);
               double Risk_In_Money = (stoploss/increment/Digit_Factor) * One_Tick;
               double tradesize = NormalizeDouble(((AccountEquity * Risk/100)/Risk_In_Money),(int)LotDigits); // %risk = $ loss >>> SL = allowed volume
               if (tradesize > MaxLot)tradesize = MaxLot;
               if (tradesize < MinLot)tradesize = MinLot;
               //Print(_Symbol+"  "+DoubleToString(tradesize,2));
               //========================================================================================= Convert the pips for EA use using point & 4 or 5 digit conversion
               string message=Symbol()+", "+TimeframeToString(Period())+": Minor Bull Pin   [Range = "+(string)NormalizeDouble(((high[i+1]-low[i+1])/ATR20),2)+"ATR | SL = "+DoubleToString(Lowest,_Digits)+" | "+DoubleToString(tradesize,2)+" lots long]";
               if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){if(InpUseAlerts) Alert(message);
               //if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Price volume divergence Signal",message);
               if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);}
              }              
           }
        }
      else
         BufferDivUP2[i+1]=EMPTY_VALUE;

        //-----------------------------------------------------------------------------------------------
    if(
        (   
            (close[i+1]>open[i+1]) 
         && (close[i+2]<=open[i+2])                                              //bull traintrack
         && (Range1>(ATR20*Traintrack_ATR_Ratio*Candle_To_D1_ATR_Ratio_temp))                        //range not small
         && (Range2>(ATR20*Traintrack_ATR_Ratio*Candle_To_D1_ATR_Ratio_temp))                        //range not small
         && (MathAbs(Range1-Range2)<ATR20*Proximity_To_Previous_Open)
         && (bullbody>bulltails)
         //&& (bearbody2>beartails2)
         && (high[i+1]-close[i+1])<(ATR20/3)
         && ((low[i+1]<=Bollinger_Low[i+1])||(low[i+2]<=Bollinger_Low[i+2]))
         && (((low[i+1]<=Bollinger_2_Low[i+1])||(low[i+2]<=Bollinger_2_Low[i+2]))||(!Bullish_Bollinger_2_Filter)||(low[i+1]>SMA200[i+1]))
         && (Traintracks)
         &&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta50[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
         //&&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta200[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
        )
       )//if
        {
         BufferDivUP3[i+1]=low[i+1]-(ATR20/2);
         if(ShowTargets){Target[i+1]=NormalizeDouble(close[i+1]+(RiskRewardRatio*(close[i+1]-low[i+1])),_Digits);}
         if(i==0)
           {
            if(last_time!=time[0])
              {
               last_time=time[0];
               double Low[10],
                      Lowest=9999999;
               for(int j=0;j<BarsLookback;j++){
                  Low[j]=NormalizeDouble(low[j]-ATR20/20,_Digits);
                  if (NormalizeDouble(low[j]-ATR20/20,_Digits)<Lowest){Lowest=NormalizeDouble(low[j]-ATR20/20,_Digits);}
                  }
                  if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){
                  ObjectCreate(0,"stoploss",OBJ_TREND,0,time[10],Lowest,time[0],Lowest);
                  ObjectSetInteger(0,"stoploss",OBJPROP_RAY_RIGHT,true);
                  ObjectSetInteger(0,"stoploss",OBJPROP_SELECTABLE,true);
                  ObjectSetInteger(0,"stoploss",OBJPROP_SELECTED,true);
                  }
               ChartRedraw(0);
               //==BUY SIZE===================================================================================== Calculate the trade volume based on the desired stoploss & risk
               int Digit_Factor   = 1;  
               double increment = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_SIZE);  //m_symbol.TickSize()
               double  AccountEquity  = AccountInfoDouble(ACCOUNT_EQUITY);
               double stoploss = MathAbs(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK)-Lowest,_Digits));
               if (_Digits == 3 || _Digits == 5)Digit_Factor = 10;
               double   One_Tick = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_VALUE) * Digit_Factor;
               double   MaxLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MAX);
               double   MinLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MIN);
               double   LotDigits = 2;//SymbolInfoDouble(NULL,SYMBOL_VOLUME_STEP);
               double Risk_In_Money = (stoploss/increment/Digit_Factor) * One_Tick;
               double tradesize = NormalizeDouble(((AccountEquity * Risk/100)/Risk_In_Money),(int)LotDigits); // %risk = $ loss >>> SL = allowed volume
               if (tradesize > MaxLot)tradesize = MaxLot;
               if (tradesize < MinLot)tradesize = MinLot;
               //Print(_Symbol+"  "+DoubleToString(tradesize,2));
               //========================================================================================= Convert the pips for EA use using point & 4 or 5 digit conversion
               string message=Symbol()+", "+TimeframeToString(Period())+": Bullish Traintacks   [Range = "+(string)NormalizeDouble(((high[i+1]-low[i+1])/ATR20),2)+"ATR | SL = "+DoubleToString(Lowest,_Digits)+" | "+DoubleToString(tradesize,2)+" lots long]";
               if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){if(InpUseAlerts) Alert(message);
               //if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Price volume divergence Signal",message);
               if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);}
              }              

              
           }
        }
      else

         BufferDivUP3[i+1]=EMPTY_VALUE;
//   */        
        //-----------------------------------------------------------------------------------------------
    
    if(
        (   
            (close[i+1]>open[i+1]) 
         && (Range1>(ATR20*Outside_To_D1_ATR_Ratio))                        //range not small
         && (Range2>(ATR20*0.5*Outside_To_D1_ATR_Ratio))                        //range not small
         && (high[i+1]>high[i+2])
         && (low[i+1]<low[i+2])
         && (Range1>(Outside_To_Prev_Ratio*Range2))
         && (bullbody>4*(high[i+1]-close[i+1]))
         && ((low[i+1]<=Bollinger_Low[i+1])||(!OutsideBar_Boll))
         && ((low[i+1]<=Bollinger_2_Low[i+1])||(!OutsideBar_Boll)||(!Bullish_Bollinger_2_Filter)||(low[i+1]>SMA200[i+1]))
         && (OutsideBar)
         &&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta50[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
         //&&((!DeltaFilter)||(Delta50[i]>Delta200[i])||((Delta200[i]>0)&&((SMA100[i+1]>SMA200[i+1]))))
        )
       )//if
        {
         BufferDivUP4[i+1]=low[i+1]-(ATR20/2);
         if(ShowTargets){Target[i+1]=NormalizeDouble(close[i+1]+(RiskRewardRatio*(close[i+1]-low[i+1])),_Digits);}
         if(i==0)
           {
            if(last_time!=time[0])
              {
               last_time=time[0];
               double Low[10],
                      Lowest=9999999;
               for(int j=0;j<BarsLookback;j++){
                  Low[j]=NormalizeDouble(low[j]-ATR20/20,_Digits);
                  if (NormalizeDouble(low[j]-ATR20/20,_Digits)<Lowest){Lowest=NormalizeDouble(low[j]-ATR20/20,_Digits);}
                  }
                  if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){
                  ObjectCreate(0,"stoploss",OBJ_TREND,0,time[10],Lowest,time[0],Lowest);
                  ObjectSetInteger(0,"stoploss",OBJPROP_RAY_RIGHT,true);
                  ObjectSetInteger(0,"stoploss",OBJPROP_SELECTABLE,true);
                  ObjectSetInteger(0,"stoploss",OBJPROP_SELECTED,true);
                  }
               ChartRedraw(0);
               //==BUY SIZE===================================================================================== Calculate the trade volume based on the desired stoploss & risk
               int Digit_Factor   = 1;  
               double increment = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_SIZE);  //m_symbol.TickSize()
               double  AccountEquity  = AccountInfoDouble(ACCOUNT_EQUITY);
               double stoploss = MathAbs(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK)-Lowest,_Digits));
               if (_Digits == 3 || _Digits == 5)Digit_Factor = 10;
               double   One_Tick = SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_VALUE) * Digit_Factor;
               double   MaxLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MAX);
               double   MinLot = SymbolInfoDouble(NULL,SYMBOL_VOLUME_MIN);
               double   LotDigits = 2;//SymbolInfoDouble(NULL,SYMBOL_VOLUME_STEP);
               double Risk_In_Money = (stoploss/increment/Digit_Factor) * One_Tick;
               double tradesize = NormalizeDouble(((AccountEquity * Risk/100)/Risk_In_Money),(int)LotDigits); // %risk = $ loss >>> SL = allowed volume
               if (tradesize > MaxLot)tradesize = MaxLot;
               if (tradesize < MinLot)tradesize = MinLot;
               //Print(_Symbol+"  "+DoubleToString(tradesize,2));
               //========================================================================================= Convert the pips for EA use using point & 4 or 5 digit conversion
               string message=Symbol()+", "+TimeframeToString(Period())+": Bullish Outside Bar   [Range = "+(string)NormalizeDouble(((high[i+1]-low[i+1])/ATR20),2)+"ATR | SL = "+DoubleToString(Lowest,_Digits)+" | "+DoubleToString(tradesize,2)+" lots long]";
               if(_Period==PERIOD_H4 || _Period==PERIOD_H1 || _Period==PERIOD_M30 || _Period==PERIOD_M15){if(InpUseAlerts) Alert(message);
               //if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Price volume divergence Signal",message);
               if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);}
              }              
              
           }
        }
      else

         BufferDivUP4[i+1]=EMPTY_VALUE;

  
  
  
         //BufferDivUP[i+1]=EMPTY_VALUE;
         //BufferDivUP2[i+1]=EMPTY_VALUE;
         //BufferDivUP3[i+1]=EMPTY_VALUE;
         //BufferDivUP4[i+1]=EMPTY_VALUE;
         //BufferDivDN[i+1]=EMPTY_VALUE;
         //BufferDivDN2[i+1]=EMPTY_VALUE;
         //BufferDivDN3[i+1]=EMPTY_VALUE;
         //BufferDivDN4[i+1]=EMPTY_VALUE;
  
     }
     
     
     
     
     

if(last_time!=time[0])
   {
   ChartRedraw(0);
   last_time=time[0];
   //if(GetLastError()==;
   
   //if(ChartScreenShot(0,_Symbol+"_Screenshot.jpg",1335,750,ALIGN_LEFT))  Print("We've saved the screenshot ",_Symbol+"_Screenshot.jpg");    
   }


//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timeframe to string                                              |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  {
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+
double ObjectGetValueByShiftMQL4(string name,int shift)
  {
   MqlRates mql4[];
   CopyRates(NULL,PERIOD_CURRENT,shift,1,mql4);
   return(ObjectGetValueByTime(0,name,mql4[0].time,0));
  }   
//-------------------------------------------------------

