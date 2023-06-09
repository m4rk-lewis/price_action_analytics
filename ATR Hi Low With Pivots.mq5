//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- input parameters
input double          RewardRatio            =2;
//---
input int             GMT_Offset             =3;
input int             NY_CUT_GMT_TIME        =14;
input double          ManualRoundNumber      =0;
input double          ManualRoundNumberPips  =0;
//---
input int             DailyAtrPeriod         = 21;             // ATR period
input bool            WeeklyATR              =false;
input int             WeeklyAtrPeriod        = 13;             // ATR period
input bool            MonthlyATR             =false;
input int             MonthlyAtrPeriod       = 12;             // ATR period
//---
input bool            Show_ATR_HighLow       = true;
input bool            Show_Weekly_MA         = true;
input bool            Show_Daily_MA          = true;
input bool            Show_hourly_MA         = true;
input bool            Show_Weekly_Pivots     = true;
input bool            Show_Weekly_Pivot_SR   = false;
input bool            Show_Monthly_Pivots    = true;
input bool            Show_Monthly_Pivot_SR  = false;
input bool            Show_Round_Numbers     = true;
input bool            Show_Round_Number_MP   = false;
input bool            TradesBreakEven        =false;
input bool            OrdersBreakEven        =false;
//---
input int             OrdersDayOfMonth       =0;
input double          Sell_Orders_1          =0.0;//Sell Orders
input double          Sell_Orders_2          =0.0;//Sell Orders
input double          Sell_Orders_3          =0.0;//Sell Orders
input double          Sell_Orders_4          =0.0;//Sell Orders
input double          Buy_Orders_1           =0.0;//Buy Orders
input double          Buy_Orders_2           =0.0;//Buy Orders
input double          Buy_Orders_3           =0.0;//Buy Orders
input double          Buy_Orders_4           =0.0;//Buy Orders
//---
input double          OptionExpire1          =0.0;
input string          OptionExpire1Size      ="";
input double          OptionExpire2          =0.0;
input string          OptionExpire2Size      ="";
input double          OptionExpire3          =0.0;
input string          OptionExpire3Size      ="";
input double          OptionExpire4          =0.0;
input string          OptionExpire4Size      ="";
input double          OptionExpire5          =0.0;
input string          OptionExpire5Size      ="";
input double          OptionExpire6          =0.0;
input string          OptionExpire6Size      ="";
input double          OptionExpire7          =0.0;
input string          OptionExpire7Size      ="";
input double          OptionExpire8          =0.0;
input string          OptionExpire8Size      ="";
//---
input string          inpUniqueID            = "AtrLevel";     // Unique ID for objects
input int             LabelsShift            = 5;             // Labels End
input int             LabelStartShift        = 3;             // Labels Start


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,inpUniqueID+":"); return;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   MqlDateTime tm;
   TimeCurrent(tm);
      
   datetime _time_daystart = iTimeMQL4(_Symbol,PERIOD_D1,0);//time point for first candle plus label shift
   datetime _time_weekstart = iTimeMQL4(_Symbol,PERIOD_W1,0);//time point for first candle plus label shift
   datetime _time_monthstart = iTimeMQL4(_Symbol,PERIOD_MN1,0);//time point for first candle plus label shift
   datetime _time_time_time = time[rates_total-1]+(8*PeriodSeconds(_Period)*LabelsShift);//time point for first candle plus label shift
   datetime _time_time = time[rates_total-1]+(4*PeriodSeconds(_Period)*LabelsShift);//time point for first candle plus label shift
   datetime _time = time[rates_total-1]+PeriodSeconds(_Period)*LabelsShift;//time point for first candle plus label shift
   datetime _time_trend = time[rates_total-1]+(LabelStartShift*PeriodSeconds(_Period));//time point for first candle
   datetime _time_minus = time[rates_total-1]-PeriodSeconds(_Period)*LabelsShift;//time point for first candle plus label shift
   datetime _time_minusminus = time[rates_total-1]-(2*PeriodSeconds(_Period)*LabelsShift);//time point for first candle plus label shift
   datetime _time_zero_candle= time[rates_total-1];//time point for first candle plus label shift

   //----------------------------     
   MqlRates daily_rates[]; int daily_ratesCopied=CopyRates(_Symbol,PERIOD_D1,1,DailyAtrPeriod+1,daily_rates);
   if(daily_ratesCopied != DailyAtrPeriod+1) return(prev_calculated);
   double daily_atr    = 0; for(int k=0;k<DailyAtrPeriod; k++) daily_atr += MathMax(daily_rates[k+1].high,daily_rates[k].close)-MathMin(daily_rates[k+1].low,daily_rates[k].close); daily_atr /= DailyAtrPeriod;

   if(Show_ATR_HighLow){
      if((iHighMQL4(Symbol(),PERIOD_D1,0)-(iLowMQL4(Symbol(),PERIOD_D1,0))>daily_atr))
         {//Range Exceded
         if(iCloseMQL4(Symbol(),PERIOD_D1,0)>iOpenMQL4(Symbol(),PERIOD_D1,0))
            {//bullish
            _createLineDMA("DailyResistance",iLowMQL4(Symbol(),PERIOD_D1,0)+daily_atr,_time_daystart,_time,Red,Red,"D1 ATR("+(string)DailyAtrPeriod+") High ("+DoubleToString(iLowMQL4(Symbol(),PERIOD_D1,0)+daily_atr,_Digits)+")");//bullish
            _createLineDMA("DailySupport",iLowMQL4(Symbol(),PERIOD_D1,0),_time_daystart,_time,Red,Red,"D1 ATR("+(string)DailyAtrPeriod+") Low ("+DoubleToString(iLowMQL4(Symbol(),PERIOD_D1,0),_Digits)+")");//bullish
            }else{//bearish
            _createLineDMA("DailyResistance",iHighMQL4(Symbol(),PERIOD_D1,0),_time_daystart,_time,Red,Red,"D1 ATR("+(string)DailyAtrPeriod+") High ("+DoubleToString(iHighMQL4(Symbol(),PERIOD_D1,0),_Digits));//bearish
            _createLineDMA("DailySupport",iHighMQL4(Symbol(),PERIOD_D1,0)-daily_atr,_time_daystart,_time,Red,Red,"D1 ATR("+(string)DailyAtrPeriod+") Low ("+DoubleToString(iHighMQL4(Symbol(),PERIOD_D1,0)-daily_atr,_Digits)+")");//bearish
            }
         }else{//Range Not Exceded
            {
            _createLineDMA("DailyResistance",iLowMQL4(Symbol(),PERIOD_D1,0)+daily_atr,_time_daystart,_time,Aqua,Aqua,"D1 ATR("+(string)DailyAtrPeriod+") High ("+DoubleToString(iLowMQL4(Symbol(),PERIOD_D1,0)+daily_atr,_Digits)+")");//bullish
            _createLineDMA("DailySupport",iHighMQL4(Symbol(),PERIOD_D1,0)-daily_atr,_time_daystart,_time,Aqua,Aqua,"D1 ATR("+(string)DailyAtrPeriod+") Low ("+DoubleToString(iHighMQL4(Symbol(),PERIOD_D1,0)-daily_atr,_Digits)+")");//bearish
            }
         } 
      }
      
      double DailyLastClose = daily_rates[DailyAtrPeriod].close;
      double First00Lower = NormalizeDouble(DailyLastClose,_Digits-3);
      double RoundNumberPips = (1/MathPow(10,_Digits-3));
      //---
      if(Symbol()=="US500") {
         First00Lower = NormalizeDouble(DailyLastClose/100,0)*100;
         RoundNumberPips = (MathPow(10,2));
         }
      if(Symbol()=="USTEC") {
         First00Lower = NormalizeDouble(DailyLastClose/100,0)*100;
         RoundNumberPips = (MathPow(10,3)/2);
         }
      if((Symbol()=="US30")||(Symbol()=="DE30")||(Symbol()=="JP225")) {
         First00Lower = NormalizeDouble(DailyLastClose/1000,0)*1000;
         RoundNumberPips = (MathPow(10,3));
         }
      if(Symbol()=="US2000") {
         First00Lower = NormalizeDouble(DailyLastClose/100,0)*100;
         RoundNumberPips = (MathPow(10,2));
         }
      if(Symbol()=="XAUUSD") {
         First00Lower = NormalizeDouble(DailyLastClose/100,0)*100;
         RoundNumberPips = (MathPow(10,2));
         }
      if(StringSubstr(Symbol(),0,3)=="VIX") {
         First00Lower = 30;
         RoundNumberPips = 10;
         }      
      if(Symbol()=="CHINA50") {
         First00Lower = NormalizeDouble(DailyLastClose/1000,0)*1000;
         RoundNumberPips = (MathPow(10,3));
         }
      if(Symbol()=="UK100") {
         First00Lower = NormalizeDouble(DailyLastClose/100,0)*100;
         RoundNumberPips = (MathPow(10,2));
         }
      if(Symbol()=="STOXX50") {
         First00Lower = NormalizeDouble(DailyLastClose/100,0)*100;
         RoundNumberPips = (MathPow(10,2));
         }
         
         //---
      if(ManualRoundNumber!=0){
      First00Lower = ManualRoundNumber;
      RoundNumberPips = ManualRoundNumberPips;
      }
      
      if(Show_Round_Numbers){
      
               //if(SymbolInfoInteger(_Symbol,SYMBOL_TRADE_CALC_MODE)==SYMBOL_CALC_MODE_CFD)First00Lower = NormalizeDouble(DailyLastClose,0);
               //if(_Symbol=="US500"){First00Lower = NormalizeDouble(DailyLastClose,0);Print("US500");}
               
               double Second00Lower = NormalizeDouble(First00Lower-RoundNumberPips,_Digits);
               double Third00Lower = NormalizeDouble(First00Lower-(2*RoundNumberPips),_Digits);
               double Fourth00Lower = NormalizeDouble(First00Lower-(3*RoundNumberPips),_Digits);
               double Fifth00Lower = NormalizeDouble(First00Lower-(4*RoundNumberPips),_Digits);
               double Sixth00Lower = NormalizeDouble(First00Lower-(5*RoundNumberPips),_Digits);
               double Seventh00Lower = NormalizeDouble(First00Lower-(6*RoundNumberPips),_Digits);
               double Eighth00Lower = NormalizeDouble(First00Lower-(7*RoundNumberPips),_Digits);
               double Ninth00Lower = NormalizeDouble(First00Lower-(8*RoundNumberPips),_Digits);
               double Tenth00Lower = NormalizeDouble(First00Lower-(9*RoundNumberPips),_Digits);

               double First00Higher = NormalizeDouble(First00Lower+RoundNumberPips,_Digits);
               double Second00Higher = NormalizeDouble(First00Lower+(2*RoundNumberPips),_Digits);
               double Third00Higher = NormalizeDouble(First00Lower+(3*RoundNumberPips),_Digits);
               double Fourth00Higher = NormalizeDouble(First00Lower+(4*RoundNumberPips),_Digits);
               double Fifth00Higher = NormalizeDouble(First00Lower+(5*RoundNumberPips),_Digits);
               double Sixth00Higher = NormalizeDouble(First00Lower+(6*RoundNumberPips),_Digits);
               double Seventh00Higher = NormalizeDouble(First00Lower+(7*RoundNumberPips),_Digits);
               double Eighth00Higher = NormalizeDouble(First00Lower+(8*RoundNumberPips),_Digits);
               double Ninth00Higher = NormalizeDouble(First00Lower+(9*RoundNumberPips),_Digits);
               double Tenth00Higher = NormalizeDouble(First00Lower+(10*RoundNumberPips),_Digits);

                  _createHLine("First00Lower",First00Lower,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(First00Lower,_Digits-1));
                  _createHLine("Second00Lower",Second00Lower,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Second00Lower,_Digits-1));
                  _createHLine("Third00Lower",Third00Lower,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Third00Lower,_Digits-1));
                  _createHLine("Fourth00Lower",Fourth00Lower,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Fourth00Lower,_Digits-1));
                  _createHLine("Fifth00Lower",Fifth00Lower,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Fifth00Lower,_Digits-1));
                  _createHLine("Sixth00Lower",Sixth00Lower,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Sixth00Lower,_Digits-1));
                  _createHLine("Seventh00Lower",Seventh00Lower,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Seventh00Lower,_Digits-1));
                  _createHLine("Eighth00Lower",Eighth00Lower,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Eighth00Lower,_Digits-1));
                  _createHLine("Ninth00Lower",Ninth00Lower,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Ninth00Lower,_Digits-1));
                  _createHLine("Tenth00Lower",Tenth00Lower,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Tenth00Lower,_Digits-1));



                  _createHLine("First00Higher",First00Higher,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(First00Higher,_Digits-1));
                  _createHLine("Second00Higher",Second00Higher,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Second00Higher,_Digits-1));
                  _createHLine("Third00Higher",Third00Higher,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Third00Higher,_Digits-1));
                  _createHLine("Fourth00Higher",Fourth00Higher,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Fourth00Higher,_Digits-1));
                  _createHLine("Fifth00Higher",Fifth00Higher,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Fifth00Higher,_Digits-1));
                  _createHLine("Sixth00Higher",Sixth00Higher,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Sixth00Higher,_Digits-1));
                  _createHLine("Seventh00Higher",Seventh00Higher,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Seventh00Higher,_Digits-1));
                  _createHLine("Eighth00Higher",Eighth00Higher,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Eighth00Higher,_Digits-1));
                  _createHLine("Ninth00Higher",Ninth00Higher,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Ninth00Higher,_Digits-1));
                  _createHLine("Tenth00Higher",Tenth00Higher,_time_minusminus,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Tenth00Higher,_Digits-1));


               double First50Lower = First00Lower+(RoundNumberPips/2);
               double Second50Lower = First00Lower+(RoundNumberPips/2)-RoundNumberPips;
               double Third50Lower = First00Lower+(RoundNumberPips/2)-(2*RoundNumberPips);
               double Fourth50Lower = First00Lower+(RoundNumberPips/2)-(3*RoundNumberPips);
               double First50Higher = First00Lower+(RoundNumberPips/2)+RoundNumberPips;
               double Second50Higher = First00Lower+(RoundNumberPips/2)+(2*RoundNumberPips);
               double Third50Higher = First00Lower+(RoundNumberPips/2)+(3*RoundNumberPips);
               double Fourth50Higher = First00Lower+(RoundNumberPips/2)+(4*RoundNumberPips);
               
               
      if(Show_Round_Number_MP){
                  _createLine("First50Lower",First50Lower,_time_trend,_time_time,C'50,50,50',C'50,50,50',DoubleToString(First50Lower,_Digits-1));
                  _createLine("Second50Lower",Second50Lower,_time_trend,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Second50Lower,_Digits-1));
                  _createLine("Third50Lower",Third50Lower,_time_trend,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Third50Lower,_Digits-1));
                  _createLine("Fourth50Lower",Fourth50Lower,_time_trend,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Fourth50Lower,_Digits-1));
                  _createLine("First50Higher",First50Higher,_time_trend,_time_time,C'50,50,50',C'50,50,50',DoubleToString(First50Higher,_Digits-1));
                  _createLine("Second50Higher",Second50Higher,_time_trend,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Second50Higher,_Digits-1));
                  _createLine("Third50Higher",Third50Higher,_time_trend,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Third50Higher,_Digits-1));
                  _createLine("Fourth50Higher",Fourth50Higher,_time_trend,_time_time,C'50,50,50',C'50,50,50',DoubleToString(Fourth50Higher,_Digits-1));
             }
    
      }//if(Show_Round_Numbers){ 
        
      //--- Market Orders - deletes when hit   
      double todaylow = iLowMQL4(_Symbol,PERIOD_CURRENT,0);
      double todayhigh = iHighMQL4(_Symbol,PERIOD_CURRENT,0);
      TimeCurrent(tm);
      
      if((tm.day==OrdersDayOfMonth)&&(Sell_Orders_1!=0)&&(Sell_Orders_1>todayhigh)&&(GlobalVariableGet("Sell_Orders_1")!=tm.day)){_createLine("Sell_Orders_1",Sell_Orders_1,_time,_time_time,Red,Red,DoubleToString(Sell_Orders_1,_Digits-1)+" Sell Orders");}
      if((tm.day==OrdersDayOfMonth)&&(Sell_Orders_2!=0)&&(Sell_Orders_2>todayhigh)&&(GlobalVariableGet("Sell_Orders_2")!=tm.day)){_createLine("Sell_Orders_2",Sell_Orders_2,_time,_time_time,Red,Red,DoubleToString(Sell_Orders_2,_Digits-1)+" Sell Orders");}
      if((tm.day==OrdersDayOfMonth)&&(Sell_Orders_3!=0)&&(Sell_Orders_3>todayhigh)&&(GlobalVariableGet("Sell_Orders_3")!=tm.day)){_createLine("Sell_Orders_3",Sell_Orders_3,_time,_time_time,Red,Red,DoubleToString(Sell_Orders_3,_Digits-1)+" Sell Orders");}
      if((tm.day==OrdersDayOfMonth)&&(Sell_Orders_4!=0)&&(Sell_Orders_4>todayhigh)&&(GlobalVariableGet("Sell_Orders_4")!=tm.day)){_createLine("Sell_Orders_4",Sell_Orders_4,_time,_time_time,Red,Red,DoubleToString(Sell_Orders_4,_Digits-1)+" Sell Orders");}
      
      
      if((tm.day==OrdersDayOfMonth)&&(Buy_Orders_1!=0)&&(Buy_Orders_1<todaylow)&&(GlobalVariableGet("Buy_Orders_1")!=tm.day)){_createLine("Buy_Orders_1",Buy_Orders_1,_time,_time_time,Lime,Lime,DoubleToString(Buy_Orders_1,_Digits-1)+" Buy Orders");}
      if((tm.day==OrdersDayOfMonth)&&(Buy_Orders_2!=0)&&(Buy_Orders_2<todaylow)&&(GlobalVariableGet("Buy_Orders_2")!=tm.day)){_createLine("Buy_Orders_2",Buy_Orders_2,_time,_time_time,Lime,Lime,DoubleToString(Buy_Orders_2,_Digits-1)+" Buy Orders");}
      if((tm.day==OrdersDayOfMonth)&&(Buy_Orders_3!=0)&&(Buy_Orders_3<todaylow)&&(GlobalVariableGet("Buy_Orders_3")!=tm.day)){_createLine("Buy_Orders_3",Buy_Orders_3,_time,_time_time,Lime,Lime,DoubleToString(Buy_Orders_3,_Digits-1)+" Buy Orders");}
      if((tm.day==OrdersDayOfMonth)&&(Buy_Orders_4!=0)&&(Buy_Orders_4<todaylow)&&(GlobalVariableGet("Buy_Orders_4")!=tm.day)){_createLine("Buy_Orders_4",Buy_Orders_4,_time,_time_time,Lime,Lime,DoubleToString(Buy_Orders_4,_Digits-1)+" Buy Orders");}
         
      if((ObjectFind(0,inpUniqueID+":Sell_Orders_1")>=0)&&((Sell_Orders_1<=todayhigh)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":Sell_Orders_1"); GlobalVariableSet("Sell_Orders_1",OrdersDayOfMonth);}
      if((ObjectFind(0,inpUniqueID+":Sell_Orders_2")>=0)&&((Sell_Orders_2<=todayhigh)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":Sell_Orders_2"); GlobalVariableSet("Sell_Orders_2",OrdersDayOfMonth);}  
      if((ObjectFind(0,inpUniqueID+":Sell_Orders_3")>=0)&&((Sell_Orders_3<=todayhigh)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":Sell_Orders_3"); GlobalVariableSet("Sell_Orders_3",OrdersDayOfMonth);}
      if((ObjectFind(0,inpUniqueID+":Sell_Orders_4")>=0)&&((Sell_Orders_4<=todayhigh)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":Sell_Orders_4"); GlobalVariableSet("Sell_Orders_4",OrdersDayOfMonth);}
      
      if((ObjectFind(0,inpUniqueID+":label:Sell_Orders_1")>=0)&&((Sell_Orders_1<=todayhigh)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:Sell_Orders_1");}
      if((ObjectFind(0,inpUniqueID+":label:Sell_Orders_2")>=0)&&((Sell_Orders_2<=todayhigh)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:Sell_Orders_2");}   
      if((ObjectFind(0,inpUniqueID+":label:Sell_Orders_3")>=0)&&((Sell_Orders_3<=todayhigh)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:Sell_Orders_3");}
      if((ObjectFind(0,inpUniqueID+":label:Sell_Orders_4")>=0)&&((Sell_Orders_4<=todayhigh)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:Sell_Orders_4");}

      if((ObjectFind(0,inpUniqueID+":Buy_Orders_1")>=0)&&((Buy_Orders_1>=todaylow)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":Buy_Orders_1"); GlobalVariableSet("Buy_Orders_1",OrdersDayOfMonth);}
      if((ObjectFind(0,inpUniqueID+":Buy_Orders_2")>=0)&&((Buy_Orders_2>=todaylow)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":Buy_Orders_2"); GlobalVariableSet("Buy_Orders_2",OrdersDayOfMonth);}
      if((ObjectFind(0,inpUniqueID+":Buy_Orders_3")>=0)&&((Buy_Orders_3>=todaylow)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":Buy_Orders_3"); GlobalVariableSet("Buy_Orders_3",OrdersDayOfMonth);}
      if((ObjectFind(0,inpUniqueID+":Buy_Orders_4")>=0)&&((Buy_Orders_4>=todaylow)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":Buy_Orders_4"); GlobalVariableSet("Buy_Orders_4",OrdersDayOfMonth);}
      
      if((ObjectFind(0,inpUniqueID+":label:Buy_Orders_1")>=0)&&((Buy_Orders_1>=todaylow)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:Buy_Orders_1");}
      if((ObjectFind(0,inpUniqueID+":label:Buy_Orders_2")>=0)&&((Buy_Orders_2>=todaylow)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:Buy_Orders_2");}
      if((ObjectFind(0,inpUniqueID+":label:Buy_Orders_3")>=0)&&((Buy_Orders_3>=todaylow)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:Buy_Orders_3");}
      if((ObjectFind(0,inpUniqueID+":label:Buy_Orders_4")>=0)&&((Buy_Orders_4>=todaylow)||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:Buy_Orders_4");}


      //--- Option Expiries - deletes after the NY cut  
      if((tm.day==OrdersDayOfMonth)&&(OptionExpire1!=0)&&(tm.hour<(NY_CUT_GMT_TIME+GMT_Offset))){_createLineDMA("OptionExpire1",OptionExpire1,_time,_time_time_time,Blue,Blue,"Option Expiry @ "+DoubleToString(OptionExpire1,_Digits-1)+" ($"+OptionExpire1Size+")");}
      if((tm.day==OrdersDayOfMonth)&&(OptionExpire2!=0)&&(tm.hour<(NY_CUT_GMT_TIME+GMT_Offset))){_createLineDMA("OptionExpire2",OptionExpire2,_time,_time_time_time,Blue,Blue,"Option Expiry @ "+DoubleToString(OptionExpire2,_Digits-1)+" ($"+OptionExpire2Size+")");}
      if((tm.day==OrdersDayOfMonth)&&(OptionExpire3!=0)&&(tm.hour<(NY_CUT_GMT_TIME+GMT_Offset))){_createLineDMA("OptionExpire3",OptionExpire3,_time,_time_time_time,Blue,Blue,"Option Expiry @ "+DoubleToString(OptionExpire3,_Digits-1)+" ($"+OptionExpire3Size+")");}
      if((tm.day==OrdersDayOfMonth)&&(OptionExpire4!=0)&&(tm.hour<(NY_CUT_GMT_TIME+GMT_Offset))){_createLineDMA("OptionExpire4",OptionExpire4,_time,_time_time_time,Blue,Blue,"Option Expiry @ "+DoubleToString(OptionExpire4,_Digits-1)+" ($"+OptionExpire4Size+")");}
      if((tm.day==OrdersDayOfMonth)&&(OptionExpire5!=0)&&(tm.hour<(NY_CUT_GMT_TIME+GMT_Offset))){_createLineDMA("OptionExpire5",OptionExpire5,_time,_time_time_time,Blue,Blue,"Option Expiry @ "+DoubleToString(OptionExpire5,_Digits-1)+" ($"+OptionExpire5Size+")");}
      if((tm.day==OrdersDayOfMonth)&&(OptionExpire6!=0)&&(tm.hour<(NY_CUT_GMT_TIME+GMT_Offset))){_createLineDMA("OptionExpire6",OptionExpire6,_time,_time_time_time,Blue,Blue,"Option Expiry @ "+DoubleToString(OptionExpire6,_Digits-1)+" ($"+OptionExpire6Size+")");}
      if((tm.day==OrdersDayOfMonth)&&(OptionExpire7!=0)&&(tm.hour<(NY_CUT_GMT_TIME+GMT_Offset))){_createLineDMA("OptionExpire7",OptionExpire7,_time,_time_time_time,Blue,Blue,"Option Expiry @ "+DoubleToString(OptionExpire7,_Digits-1)+" ($"+OptionExpire7Size+")");}
      if((tm.day==OrdersDayOfMonth)&&(OptionExpire8!=0)&&(tm.hour<(NY_CUT_GMT_TIME+GMT_Offset))){_createLineDMA("OptionExpire8",OptionExpire8,_time,_time_time_time,Blue,Blue,"Option Expiry @ "+DoubleToString(OptionExpire8,_Digits-1)+" ($"+OptionExpire8Size+")");}
         
      if((ObjectFind(0,inpUniqueID+":OptionExpire1")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":OptionExpire1");}
      if((ObjectFind(0,inpUniqueID+":OptionExpire2")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":OptionExpire2");}   
      if((ObjectFind(0,inpUniqueID+":OptionExpire3")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":OptionExpire3");}
      if((ObjectFind(0,inpUniqueID+":OptionExpire4")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":OptionExpire4");}
      if((ObjectFind(0,inpUniqueID+":OptionExpire5")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":OptionExpire5");}
      if((ObjectFind(0,inpUniqueID+":OptionExpire6")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":OptionExpire6");}
      if((ObjectFind(0,inpUniqueID+":OptionExpire7")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":OptionExpire7");}
      if((ObjectFind(0,inpUniqueID+":OptionExpire8")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":OptionExpire8");}
      
      if((ObjectFind(0,inpUniqueID+":label:OptionExpire1")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:OptionExpire1");}
      if((ObjectFind(0,inpUniqueID+":label:OptionExpire2")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:OptionExpire2");}   
      if((ObjectFind(0,inpUniqueID+":label:OptionExpire3")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:OptionExpire3");}
      if((ObjectFind(0,inpUniqueID+":label:OptionExpire4")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:OptionExpire4");}
      if((ObjectFind(0,inpUniqueID+":label:OptionExpire5")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:OptionExpire5");}
      if((ObjectFind(0,inpUniqueID+":label:OptionExpire6")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:OptionExpire6");}
      if((ObjectFind(0,inpUniqueID+":label:OptionExpire7")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:OptionExpire7");}
      if((ObjectFind(0,inpUniqueID+":label:OptionExpire8")>=0)&&((tm.hour>=(NY_CUT_GMT_TIME+GMT_Offset))||(tm.day!=OrdersDayOfMonth))){ObjectDelete(0,inpUniqueID+":label:OptionExpire8");}
      
      
      
      //--- Scripts Buy Sell Markers---------------------------------------------------------------------------------------------------------------------------------------------------
      ObjectDelete(0,inpUniqueID+":label:stoplossText");
      ObjectDelete(0,inpUniqueID+":label:buy");
      ObjectDelete(0,inpUniqueID+":label:sell");
      ObjectDelete(0,inpUniqueID+":buy");
      ObjectDelete(0,inpUniqueID+":sell");
      ObjectDelete(0,inpUniqueID+":label:takeprofitText_1");
      ObjectDelete(0,inpUniqueID+":label:takeprofitText_2");
      ObjectDelete(0,inpUniqueID+":label:takeprofitText_3");
      ObjectDelete(0,inpUniqueID+":takeprofitText_1");
      ObjectDelete(0,inpUniqueID+":takeprofitText_2");
      ObjectDelete(0,inpUniqueID+":takeprofitText_3");
      ObjectDelete(0,inpUniqueID+":stoplossText");
      
      
      if(ObjectFind(0,"stoploss")>=0)ObjectSetInteger(0,"stoploss",OBJPROP_COLOR,Red);
      if(ObjectFind(0,"buy")>=0)ObjectSetInteger(0,"buy",OBJPROP_COLOR,Lime);
      if(ObjectFind(0,"sell")>=0)ObjectSetInteger(0,"sell",OBJPROP_COLOR,Magenta);
      if(ObjectFind(0,"tp")>=0)ObjectSetInteger(0,"tp",OBJPROP_COLOR,Orange);
      //--
      if(ObjectFind(0,"stoploss")>=0)ObjectSetInteger(0,"stoploss",OBJPROP_WIDTH,1);
      if(ObjectFind(0,"buy")>=0)ObjectSetInteger(0,"buy",OBJPROP_WIDTH,1);
      if(ObjectFind(0,"sell")>=0)ObjectSetInteger(0,"sell",OBJPROP_WIDTH,1);
      if(ObjectFind(0,"tp")>=0)ObjectSetInteger(0,"tp",OBJPROP_WIDTH,1);
      //--
      if(ObjectFind(0,"stoploss")>=0)ObjectSetInteger(0,"stoploss",OBJPROP_STYLE,STYLE_SOLID);
      if(ObjectFind(0,"buy")>=0)ObjectSetInteger(0,"buy",OBJPROP_STYLE,STYLE_SOLID);
      if(ObjectFind(0,"sell")>=0)ObjectSetInteger(0,"sell",OBJPROP_STYLE,STYLE_SOLID);
      if(ObjectFind(0,"tp")>=0)ObjectSetInteger(0,"tp",OBJPROP_STYLE,STYLE_SOLID);

      //--- shows price for stop loss market order script line
      if((ObjectFind(0,"stoploss")>=0)&&(ObjectFind(0,"buy")<0)&&(ObjectFind(0,"sell")<0)){
      
      _createLine("stoplossText",ObjectGetValueByTime(0,"stoploss",_time,0),_time_trend,_time,Red,Red,"Stoploss ("+DoubleToString(ObjectGetValueByTime(0,"stoploss",_time,0),_Digits)+")");
         double tp_pips_1 = iCloseMQL4(Symbol(),PERIOD_CURRENT,0)-(NormalizeDouble(ObjectGetValueByTime(0,"stoploss",_time,0)-iCloseMQL4(Symbol(),PERIOD_CURRENT,0),_Digits)*1);
         _createLine("takeprofitText_1",tp_pips_1,_time_trend,_time,DarkOrange,DarkOrange," 1:1 TakeProfit ("+DoubleToString(tp_pips_1,_Digits)+")");
         
         double tp_pips_2 = iCloseMQL4(Symbol(),PERIOD_CURRENT,0)-(NormalizeDouble(ObjectGetValueByTime(0,"stoploss",_time,0)-iCloseMQL4(Symbol(),PERIOD_CURRENT,0),_Digits)*2);
         _createLine("takeprofitText_2",tp_pips_2,_time_trend,_time,DarkOrange,DarkOrange," 2:1 TakeProfit ("+DoubleToString(tp_pips_2,_Digits)+")");
         
         double tp_pips_3 = iCloseMQL4(Symbol(),PERIOD_CURRENT,0)-(NormalizeDouble(ObjectGetValueByTime(0,"stoploss",_time,0)-iCloseMQL4(Symbol(),PERIOD_CURRENT,0),_Digits)*3);
         _createLine("takeprofitText_3",tp_pips_3,_time_trend,_time,DarkOrange,DarkOrange," 3:1 TakeProfit ("+DoubleToString(tp_pips_3,_Digits)+")");
        
         }
   //=======================   
      //--- shows price for stop loss buy limit order script line (RR)
      if(
           (ObjectFind(0,"stoploss")>=0)
         &&(ObjectFind(0,"buy")>=0)
         &&(ObjectFind(0,"tp")<0)
         &&(ObjectGetValueByTime(0,"stoploss",_time,0)<ObjectGetValueByTime(0,"buy",_time,0))
         &&(ObjectGetValueByTime(0,"buy",_time,0)<iCloseMQL4(Symbol(),PERIOD_CURRENT,0))
         ){
         _createLine("stoplossText",ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_time_trend,_time,Red,Red,"Stoploss ("+DoubleToString(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_Digits)+")");
         _createLine("buy",ObjectGetValueByTime(0,"buy",_time_zero_candle,0),_time_trend,_time,Lime,Lime,"Buy Limit ("+DoubleToString(ObjectGetValueByTime(0,"buy",_time_zero_candle,0),_Digits)+")");
         double tp_pips = ObjectGetValueByTime(0,"buy",_time_zero_candle,0)+(1*(ObjectGetValueByTime(0,"buy",_time_zero_candle,0)-ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0)));
         _createLine("takeprofitText_1",tp_pips,_time_trend,_time,DarkOrange,DarkOrange," 1:1 TakeProfit ("+DoubleToString(tp_pips,_Digits)+")");
         }
      //--- shows price for stop loss sell limit order script line (RR)
      if(
           (ObjectFind(0,"stoploss")>=0)
         &&(ObjectFind(0,"sell")>=0)
         &&(ObjectFind(0,"tp")<0)
         &&(ObjectGetValueByTime(0,"stoploss",_time,0)>ObjectGetValueByTime(0,"sell",_time,0))
         &&(ObjectGetValueByTime(0,"sell",_time,0)>iCloseMQL4(Symbol(),PERIOD_CURRENT,0))
         ){
         _createLine("stoplossText",ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_time_trend,_time,Red,Red,"Stoploss ("+DoubleToString(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_Digits)+")");
         _createLine("sell",ObjectGetValueByTime(0,"sell",_time_zero_candle,0),_time_trend,_time,Magenta,Magenta,"Sell limit ("+DoubleToString(ObjectGetValueByTime(0,"sell",_time_zero_candle,0),_Digits)+")");
         double tp_pips = ObjectGetValueByTime(0,"sell",_time_zero_candle,0)-(1*(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0)-ObjectGetValueByTime(0,"sell",_time_zero_candle,0)));
         _createLine("takeprofitText_1",tp_pips,_time_trend,_time,DarkOrange,DarkOrange," 1:1 Take Profit ("+DoubleToString(tp_pips,_Digits)+")");
         }
   //=======================   
      //--- shows price for stop loss buy limit order script line (RR)  2:1
      if(
           (ObjectFind(0,"stoploss")>=0)
         &&(ObjectFind(0,"buy")>=0)
         &&(ObjectFind(0,"tp")<0)
         &&(ObjectGetValueByTime(0,"stoploss",_time,0)<ObjectGetValueByTime(0,"buy",_time,0))
         &&(ObjectGetValueByTime(0,"buy",_time,0)<iCloseMQL4(Symbol(),PERIOD_CURRENT,0))
         ){
         _createLine("stoplossText",ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_time_trend,_time,Red,Red,"Stoploss ("+DoubleToString(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_Digits)+")");
         _createLine("buy",ObjectGetValueByTime(0,"buy",_time_zero_candle,0),_time_trend,_time,Lime,Lime,"Buy Limit ("+DoubleToString(ObjectGetValueByTime(0,"buy",_time_zero_candle,0),_Digits)+")");
         double tp_pips = ObjectGetValueByTime(0,"buy",_time_zero_candle,0)+(2*(ObjectGetValueByTime(0,"buy",_time_zero_candle,0)-ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0)));
         _createLine("takeprofitText_2",tp_pips,_time_trend,_time,DarkOrange,DarkOrange," 2:1 TakeProfit ("+DoubleToString(tp_pips,_Digits)+")");
         }
      //--- shows price for stop loss sell limit order script line (RR) 2:1
      if(
           (ObjectFind(0,"stoploss")>=0)
         &&(ObjectFind(0,"sell")>=0)
         &&(ObjectFind(0,"tp")<0)
         &&(ObjectGetValueByTime(0,"stoploss",_time,0)>ObjectGetValueByTime(0,"sell",_time,0))
         &&(ObjectGetValueByTime(0,"sell",_time,0)>iCloseMQL4(Symbol(),PERIOD_CURRENT,0))
         ){
         _createLine("stoplossText",ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_time_trend,_time,Red,Red,"Stoploss ("+DoubleToString(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_Digits)+")");
         _createLine("sell",ObjectGetValueByTime(0,"sell",_time_zero_candle,0),_time_trend,_time,Magenta,Magenta,"Sell limit ("+DoubleToString(ObjectGetValueByTime(0,"sell",_time_zero_candle,0),_Digits)+")");
         double tp_pips = ObjectGetValueByTime(0,"sell",_time_zero_candle,0)-(2*(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0)-ObjectGetValueByTime(0,"sell",_time_zero_candle,0)));
         _createLine("takeprofitText_2",tp_pips,_time_trend,_time,DarkOrange,DarkOrange," 2:1 Take Profit ("+DoubleToString(tp_pips,_Digits)+")");
         }
   //=======================   
      //--- shows price for stop loss buy limit order script line (RR)  3:1
      if(
           (ObjectFind(0,"stoploss")>=0)
         &&(ObjectFind(0,"buy")>=0)
         &&(ObjectFind(0,"tp")<0)
         &&(ObjectGetValueByTime(0,"stoploss",_time,0)<ObjectGetValueByTime(0,"buy",_time,0))
         &&(ObjectGetValueByTime(0,"buy",_time,0)<iCloseMQL4(Symbol(),PERIOD_CURRENT,0))
         ){
         _createLine("stoplossText",ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_time_trend,_time,Red,Red,"Stoploss ("+DoubleToString(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_Digits)+")");
         _createLine("buy",ObjectGetValueByTime(0,"buy",_time_zero_candle,0),_time_trend,_time,Lime,Lime,"Buy Limit ("+DoubleToString(ObjectGetValueByTime(0,"buy",_time_zero_candle,0),_Digits)+")");
         double tp_pips = ObjectGetValueByTime(0,"buy",_time_zero_candle,0)+(3*(ObjectGetValueByTime(0,"buy",_time_zero_candle,0)-ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0)));
         _createLine("takeprofitText_3",tp_pips,_time_trend,_time,DarkOrange,DarkOrange," 3:1 TakeProfit ("+DoubleToString(tp_pips,_Digits)+")");
         }
      //--- shows price for stop loss sell limit order script line (RR) 3:1
      if(
           (ObjectFind(0,"stoploss")>=0)
         &&(ObjectFind(0,"sell")>=0)
         &&(ObjectFind(0,"tp")<0)
         &&(ObjectGetValueByTime(0,"stoploss",_time,0)>ObjectGetValueByTime(0,"sell",_time,0))
         &&(ObjectGetValueByTime(0,"sell",_time,0)>iCloseMQL4(Symbol(),PERIOD_CURRENT,0))
         ){
         _createLine("stoplossText",ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_time_trend,_time,Red,Red,"Stoploss ("+DoubleToString(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_Digits)+")");
         _createLine("sell",ObjectGetValueByTime(0,"sell",_time_zero_candle,0),_time_trend,_time,Magenta,Magenta,"Sell limit ("+DoubleToString(ObjectGetValueByTime(0,"sell",_time_zero_candle,0),_Digits)+")");
         double tp_pips = ObjectGetValueByTime(0,"sell",_time_zero_candle,0)-(3*(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0)-ObjectGetValueByTime(0,"sell",_time_zero_candle,0)));
         _createLine("takeprofitText_3",tp_pips,_time_trend,_time,DarkOrange,DarkOrange," 3:1 Take Profit ("+DoubleToString(tp_pips,_Digits)+")");
         }
   //=======================   
      //--- shows price for stop loss buy limit order script line (RR)  4:1
      if(
           (ObjectFind(0,"stoploss")>=0)
         &&(ObjectFind(0,"buy")>=0)
         &&(ObjectFind(0,"tp")<0)
         &&(ObjectGetValueByTime(0,"stoploss",_time,0)<ObjectGetValueByTime(0,"buy",_time,0))
         &&(ObjectGetValueByTime(0,"buy",_time,0)<iCloseMQL4(Symbol(),PERIOD_CURRENT,0))
         ){
         _createLine("stoplossText",ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_time_trend,_time,Red,Red,"Stoploss ("+DoubleToString(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_Digits)+")");
         _createLine("buy",ObjectGetValueByTime(0,"buy",_time_zero_candle,0),_time_trend,_time,Lime,Lime,"Buy Limit ("+DoubleToString(ObjectGetValueByTime(0,"buy",_time_zero_candle,0),_Digits)+")");
         double tp_pips = ObjectGetValueByTime(0,"buy",_time_zero_candle,0)+(4*(ObjectGetValueByTime(0,"buy",_time_zero_candle,0)-ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0)));
         _createLine("takeprofitText_4",tp_pips,_time_trend,_time,DarkOrange,DarkOrange," 4:1 TakeProfit ("+DoubleToString(tp_pips,_Digits)+")");
         }
      //--- shows price for stop loss sell limit order script line (RR) 3:1
      if(
           (ObjectFind(0,"stoploss")>=0)
         &&(ObjectFind(0,"sell")>=0)
         &&(ObjectFind(0,"tp")<0)
         &&(ObjectGetValueByTime(0,"stoploss",_time,0)>ObjectGetValueByTime(0,"sell",_time,0))
         &&(ObjectGetValueByTime(0,"sell",_time,0)>iCloseMQL4(Symbol(),PERIOD_CURRENT,0))
         ){
         _createLine("stoplossText",ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_time_trend,_time,Red,Red,"Stoploss ("+DoubleToString(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_Digits)+")");
         _createLine("sell",ObjectGetValueByTime(0,"sell",_time_zero_candle,0),_time_trend,_time,Magenta,Magenta,"Sell limit ("+DoubleToString(ObjectGetValueByTime(0,"sell",_time_zero_candle,0),_Digits)+")");
         double tp_pips = ObjectGetValueByTime(0,"sell",_time_zero_candle,0)-(4*(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0)-ObjectGetValueByTime(0,"sell",_time_zero_candle,0)));
         _createLine("takeprofitText_4",tp_pips,_time_trend,_time,DarkOrange,DarkOrange," 4:1 Take Profit ("+DoubleToString(tp_pips,_Digits)+")");
         }
   //=======================    
      //--- shows price for stop loss buy limit order script line (RR)
      if(
           (ObjectFind(0,"stoploss")>=0)
         &&(ObjectFind(0,"buy")>=0)
         &&(ObjectFind(0,"tp")>=0)
         &&(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0)<ObjectGetValueByTime(0,"buy",_time_zero_candle,0))
         &&(ObjectGetValueByTime(0,"buy",_time_zero_candle,0)<ObjectGetValueByTime(0,"tp",_time_zero_candle,0))
         &&(ObjectGetValueByTime(0,"buy",_time_zero_candle,0)<iCloseMQL4(Symbol(),PERIOD_CURRENT,0))
         ){
         _createLine("stoplossText",ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_time_trend,_time,Red,Red,"Stoploss ("+DoubleToString(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_Digits)+")");
         _createLine("buy",ObjectGetValueByTime(0,"buy",_time_zero_candle,0),_time_trend,_time,Lime,Lime,"Buy Limit ("+DoubleToString(ObjectGetValueByTime(0,"buy",_time_zero_candle,0),_Digits)+")");
         _createLine("takeprofitText",ObjectGetValueByTime(0,"tp",_time_zero_candle,0),_time_trend,_time,DarkOrange,DarkOrange,"Take Profit ("+DoubleToString(ObjectGetValueByTime(0,"tp",_time_zero_candle,0),_Digits)+")");
         }
      //--- shows price for stop loss sell limit order script line (RR)
      if(
           (ObjectFind(0,"stoploss")>=0)
         &&(ObjectFind(0,"sell")>=0)
         &&(ObjectFind(0,"tp")>=0)
         &&(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0)>ObjectGetValueByTime(0,"sell",_time_zero_candle,0))
         &&(ObjectGetValueByTime(0,"sell",_time_zero_candle,0)>ObjectGetValueByTime(0,"tp",_time_zero_candle,0))
         &&(ObjectGetValueByTime(0,"sell",_time_zero_candle,0)>iCloseMQL4(Symbol(),PERIOD_CURRENT,0))
         ){
         _createLine("stoplossText",ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_time_trend,_time,Red,Red,"Stoploss ("+DoubleToString(ObjectGetValueByTime(0,"stoploss",_time_zero_candle,0),_Digits)+")");
         _createLine("sell",ObjectGetValueByTime(0,"sell",_time_zero_candle,0),_time_trend,_time,Magenta,Magenta,"Sell Limit ("+DoubleToString(ObjectGetValueByTime(0,"sell",_time_zero_candle,0),_Digits)+")");
         _createLine("takeprofitText",ObjectGetValueByTime(0,"tp",_time_zero_candle,0),_time_trend,_time,DarkOrange,DarkOrange,"Take Profit ("+DoubleToString(ObjectGetValueByTime(0,"tp",_time_zero_candle,0),_Digits)+")");
         }
      //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // */    
         
         
      
      
   //----------------------------     
   MqlRates weekly_rates[]; int weekly_ratesCopied=CopyRates(_Symbol,PERIOD_W1,1,WeeklyAtrPeriod+1,weekly_rates);
   if(weekly_ratesCopied != WeeklyAtrPeriod+1) return(prev_calculated);
   double weekly_atr    = 0; for(int k=0;k<WeeklyAtrPeriod; k++) weekly_atr += MathMax(weekly_rates[k+1].high,weekly_rates[k].close)-MathMin(weekly_rates[k+1].low,weekly_rates[k].close); weekly_atr /= WeeklyAtrPeriod;

if(WeeklyATR){
   if((iHighMQL4(Symbol(),PERIOD_W1,0)-(iLowMQL4(Symbol(),PERIOD_W1,0))>weekly_atr))
      {//Range Exceded
      if(iCloseMQL4(Symbol(),PERIOD_W1,0)>iOpenMQL4(Symbol(),PERIOD_W1,0))
         {//bullish
         _createLine("WeeklyResistance",iLowMQL4(Symbol(),PERIOD_W1,0)+weekly_atr,_time_weekstart,_time,Red,Red,"W1 ATR("+(string)WeeklyAtrPeriod+") High ("+DoubleToString(iLowMQL4(Symbol(),PERIOD_W1,0)+weekly_atr,_Digits)+")");//bullish
         _createLine("WeeklySupport",iLowMQL4(Symbol(),PERIOD_W1,0),_time_weekstart,_time,Red,Red,"W1 ATR("+(string)WeeklyAtrPeriod+") Low ("+DoubleToString(iLowMQL4(Symbol(),PERIOD_W1,0),_Digits)+")");//bullish
         }else{//bearish
         _createLine("WeeklyResistance",iHighMQL4(Symbol(),PERIOD_W1,0),_time_weekstart,_time,Red,Red,"W1 ATR("+(string)WeeklyAtrPeriod+") High ("+DoubleToString(iHighMQL4(Symbol(),PERIOD_W1,0),_Digits)+")");//bearish
         _createLine("WeeklySupport",iHighMQL4(Symbol(),PERIOD_W1,0)-weekly_atr,_time_weekstart,_time,Red,Red,"W1 ATR("+(string)WeeklyAtrPeriod+") Low ("+DoubleToString(iHighMQL4(Symbol(),PERIOD_W1,0)-weekly_atr,_Digits)+")");//bearish
         }
      }else{//Range Not Exceded
         {
         _createLine("WeeklyResistance",iLowMQL4(Symbol(),PERIOD_W1,0)+weekly_atr,_time_weekstart,_time,DodgerBlue,DodgerBlue,"W1 ATR("+(string)WeeklyAtrPeriod+") High ("+DoubleToString(iLowMQL4(Symbol(),PERIOD_W1,0)+weekly_atr,_Digits)+")");//bullish
         _createLine("WeeklySupport",iHighMQL4(Symbol(),PERIOD_W1,0)-weekly_atr,_time_weekstart,_time,DodgerBlue,DodgerBlue,"W1 ATR("+(string)WeeklyAtrPeriod+") Low ("+DoubleToString(iHighMQL4(Symbol(),PERIOD_W1,0)-weekly_atr,_Digits)+")");//bearish
         }
      }
}//if(WeeklyATR){
      
      if(Show_Weekly_Pivots){
 
            double WeeklyLastHigh = weekly_rates[WeeklyAtrPeriod].high;
            double WeeklyLastLow  = weekly_rates[WeeklyAtrPeriod].low;
            double WeeklyLastClose= weekly_rates[WeeklyAtrPeriod].close;
            double WeeklyPivotR3=0;
            double WeeklyPivotR2=0;
            double WeeklyPivotR1=0;
            double WeeklyPivot=0;
            double WeeklyPivotS1=0;
            double WeeklyPivotS2=0;
            double WeeklyPivotS3=0;
            
            WeeklyPivot = (WeeklyLastHigh + WeeklyLastLow + WeeklyLastClose)/3.0; 
            WeeklyPivotR1 = (2*WeeklyPivot)-WeeklyLastLow; 
            WeeklyPivotR2 = WeeklyPivot+(WeeklyLastHigh-WeeklyLastLow);
            WeeklyPivotR3 = WeeklyLastHigh+(2*(WeeklyPivot-WeeklyLastLow)); 
            WeeklyPivotS1 = (2*WeeklyPivot)-WeeklyLastHigh; 
            WeeklyPivotS2 = WeeklyPivot-(WeeklyLastHigh-WeeklyLastLow); 
            WeeklyPivotS3 = WeeklyLastLow-(2*(WeeklyLastHigh-WeeklyPivot)); 
            
            
            _createLine("WeeklyPivot",WeeklyPivot,_time_weekstart,_time,Yellow,Yellow,"Wk Pivot ("+DoubleToString(WeeklyPivot,_Digits)+")");//bearish
            
      if(Show_Weekly_Pivot_SR){
            _createLine("WeeklyPivotR3",WeeklyPivotR3,_time_weekstart,_time,DimGray,DimGray,"Wk R3 ("+DoubleToString(WeeklyPivotR3,_Digits)+")");//bearish
            _createLine("WeeklyPivotR2",WeeklyPivotR2,_time_weekstart,_time,DimGray,DimGray,"Wk R2 ("+DoubleToString(WeeklyPivotR2,_Digits)+")");//bearish
            _createLine("WeeklyPivotR1",WeeklyPivotR1,_time_weekstart,_time,DimGray,DimGray,"Wk R1 ("+DoubleToString(WeeklyPivotR1,_Digits)+")");//bearish
            _createLine("WeeklyPivotS1",WeeklyPivotS1,_time_weekstart,_time,DimGray,DimGray,"Wk S1 ("+DoubleToString(WeeklyPivotS1,_Digits)+")");//bearish
            _createLine("WeeklyPivotS2",WeeklyPivotS2,_time_weekstart,_time,DimGray,DimGray,"Wk S2 ("+DoubleToString(WeeklyPivotS2,_Digits)+")");//bearish
            _createLine("WeeklyPivotS3",WeeklyPivotS3,_time_weekstart,_time,DimGray,DimGray,"Wk S3 ("+DoubleToString(WeeklyPivotS3,_Digits)+")");//bearish
            }
      }//if(Show_Weekly_Pivots){
      
   //----------------------------     
   MqlRates monthly_rates[]; int monthly_ratesCopied=CopyRates(_Symbol,PERIOD_MN1,1,MonthlyAtrPeriod+1,monthly_rates);
   if(monthly_ratesCopied != MonthlyAtrPeriod+1) return(prev_calculated);
   double monthly_atr    = 0; for(int k=0;k<MonthlyAtrPeriod; k++) monthly_atr += MathMax(monthly_rates[k+1].high,monthly_rates[k].close)-MathMin(monthly_rates[k+1].low,monthly_rates[k].close); monthly_atr /= MonthlyAtrPeriod;


      if(MonthlyATR){
         if((iHighMQL4(Symbol(),PERIOD_MN1,0)-(iLowMQL4(Symbol(),PERIOD_MN1,0))>monthly_atr))
            {//Range Exceded
            if(iCloseMQL4(Symbol(),PERIOD_MN1,0)>iOpenMQL4(Symbol(),PERIOD_MN1,0))
               {//bullish
               _createLine("MonthlyResistance",iLowMQL4(Symbol(),PERIOD_MN1,0)+monthly_atr,_time_monthstart,_time,Red,Red,"MN ATR("+(string)MonthlyAtrPeriod+") High ("+DoubleToString(iLowMQL4(Symbol(),PERIOD_MN1,0)+monthly_atr,_Digits)+")");//bullish
               _createLine("MonthlySupport",iLowMQL4(Symbol(),PERIOD_MN1,0),_time_monthstart,_time,Red,Red,"MN ATR("+(string)MonthlyAtrPeriod+") Low ("+DoubleToString(iLowMQL4(Symbol(),PERIOD_MN1,0),_Digits)+")");//bullish
               }else{//bearish
               _createLine("MonthlyResistance",iHighMQL4(Symbol(),PERIOD_MN1,0),_time_monthstart,_time,Red,Red,"M1 ATR("+(string)MonthlyAtrPeriod+") High ("+DoubleToString(iHighMQL4(Symbol(),PERIOD_MN1,0),_Digits)+")");//bearish
               _createLine("MonthlySupport",iHighMQL4(Symbol(),PERIOD_MN1,0)-monthly_atr,_time_monthstart,_time,Red,Red,"MN ATR("+(string)MonthlyAtrPeriod+") Low ("+DoubleToString(iHighMQL4(Symbol(),PERIOD_MN1,0)-monthly_atr,_Digits)+")");//bearish
               }
            }else{//Range Not Exceded
               {
               _createLine("MonthlyResistance",iLowMQL4(Symbol(),PERIOD_MN1,0)+monthly_atr,_time_monthstart,_time,Blue,Blue,"MN ATR("+(string)MonthlyAtrPeriod+") High ("+DoubleToString(iLowMQL4(Symbol(),PERIOD_MN1,0)+monthly_atr,_Digits)+")");//bullish
               _createLine("MonthlySupport",iHighMQL4(Symbol(),PERIOD_MN1,0)-monthly_atr,_time_monthstart,_time,Blue,Blue,"MN ATR("+(string)MonthlyAtrPeriod+") Low ("+DoubleToString(iHighMQL4(Symbol(),PERIOD_MN1,0)-monthly_atr,_Digits)+")");//bearish
               }
            } 
      }//if(MonthlyATR){
      


      if(Show_Monthly_Pivots){

            double MonthlyLastHigh = monthly_rates[MonthlyAtrPeriod].high;
            double MonthlyLastLow  = monthly_rates[MonthlyAtrPeriod].low;
            double MonthlyLastClose= monthly_rates[MonthlyAtrPeriod].close;
            double MonthlyPivotR3=0;
            double MonthlyPivotR2=0;
            double MonthlyPivotR1=0;
            double MonthlyPivot=0;
            double MonthlyPivotS1=0;
            double MonthlyPivotS2=0;
            double MonthlyPivotS3=0;
            
            MonthlyPivot = (MonthlyLastHigh + MonthlyLastLow + MonthlyLastClose)/3.0; 
            MonthlyPivotR1 = (2*MonthlyPivot)-MonthlyLastLow; 
            MonthlyPivotR2 = MonthlyPivot+(MonthlyLastHigh-MonthlyLastLow);
            MonthlyPivotR3 = MonthlyLastHigh+(2*(MonthlyPivot-MonthlyLastLow)); 
            MonthlyPivotS1 = (2*MonthlyPivot)-MonthlyLastHigh; 
            MonthlyPivotS2 = MonthlyPivot-(MonthlyLastHigh-MonthlyLastLow); 
            MonthlyPivotS3 = MonthlyLastLow-(2*(MonthlyLastHigh-MonthlyPivot)); 
      
            _createLine("MonthlyPivot",MonthlyPivot,_time_monthstart,_time,Magenta,Magenta,"MN Pivot ("+DoubleToString(MonthlyPivot,_Digits)+")");//bearish
         
            if(Show_Monthly_Pivot_SR){
            _createLine("MonthlyPivotS1",MonthlyPivotS1,_time_monthstart,_time,Maroon,Maroon,"MN S1 ("+DoubleToString(MonthlyPivotS1,_Digits)+")");//bearish
            _createLine("MonthlyPivotS2",MonthlyPivotS2,_time_monthstart,_time,Maroon,Maroon,"MN S2 ("+DoubleToString(MonthlyPivotS2,_Digits)+")");//bearish
            _createLine("MonthlyPivotS3",MonthlyPivotS3,_time_monthstart,_time,Maroon,Maroon,"MN S3 ("+DoubleToString(MonthlyPivotS3,_Digits)+")");//bearish
            _createLine("MonthlyPivotR3",MonthlyPivotR3,_time_monthstart,_time,Maroon,Maroon,"MN R3 ("+DoubleToString(MonthlyPivotR3,_Digits)+")");//bearish
            _createLine("MonthlyPivotR2",MonthlyPivotR2,_time_monthstart,_time,Maroon,Maroon,"MN R2 ("+DoubleToString(MonthlyPivotR2,_Digits)+")");//bearish
            _createLine("MonthlyPivotR1",MonthlyPivotR1,_time_monthstart,_time,Maroon,Maroon,"MN R1 ("+DoubleToString(MonthlyPivotR1,_Digits)+")");//bearish
            }
      }//if(Show_Monthly_Pivots){

   //----------------------------
   if(Show_Weekly_MA){
      //----weekly MA------
      weekly_ratesCopied=CopyRates(_Symbol,PERIOD_W1,0,53,weekly_rates);
      if(weekly_ratesCopied != 53) return(prev_calculated);
      double W1_52MA    = 0;
      for(int k=1;k<53; k++)  W1_52MA += weekly_rates[k].close/52; 
      _createLineDMA("W1_52MA",W1_52MA,_time_trend,_time_time,Magenta,Magenta,"52 Week MA ("+DoubleToString(W1_52MA,_Digits)+")");//bearish

      weekly_ratesCopied=CopyRates(_Symbol,PERIOD_W1,0,101,weekly_rates);
      if(weekly_ratesCopied != 101) return(prev_calculated);
      double W1_100MA    = 0; 
      for(int k=1;k<101; k++)  W1_100MA += weekly_rates[k].close/100;
      _createLineDMA("W1_100MA",W1_100MA,_time_trend,_time_time,clrLime,clrLime,"100 Week MA ("+DoubleToString(W1_100MA,_Digits)+")");//bearish
      
      weekly_ratesCopied=CopyRates(_Symbol,PERIOD_W1,0,201,weekly_rates);
      if(weekly_ratesCopied != 201) return(prev_calculated);
      double W1_200MA    = 0; 
      for(int k=1;k<201; k++)  W1_100MA += weekly_rates[k].close/200;
      _createLineDMA("W1_200MA",W1_100MA,_time_trend,_time_time,clrDodgerBlue,clrDodgerBlue,"200 Week MA ("+DoubleToString(W1_200MA,_Digits)+")");//bearish
      }     
        
        
   if(Show_Daily_MA){
      //----daily MA------
      daily_ratesCopied=CopyRates(_Symbol,PERIOD_D1,0,201,daily_rates);
      if(daily_ratesCopied != 201) return(prev_calculated);
      double D1_200MA    = 0;
      for(int k=1;k<201; k++)  D1_200MA += daily_rates[k].close/200; 
      _createLineDMA("D1_200MA",D1_200MA,_time_trend,_time_time,clrDodgerBlue,clrDodgerBlue,"200 Day MA ("+DoubleToString(D1_200MA,_Digits)+")");//bearish
   
      daily_ratesCopied=CopyRates(_Symbol,PERIOD_D1,0,101,daily_rates);
      if(daily_ratesCopied != 101) return(prev_calculated);
      double D1_100MA    = 0; 
      for(int k=1;k<101; k++)  D1_100MA += daily_rates[k].close/100;
      _createLineDMA("D1_100MA",D1_100MA,_time_trend,_time_time,clrLime,clrLime,"100 Day MA ("+DoubleToString(D1_100MA,_Digits)+")");//bearish
   
      daily_ratesCopied=CopyRates(_Symbol,PERIOD_D1,0,51,daily_rates);
      if(daily_ratesCopied != 51) return(prev_calculated);
      double D1_50MA    = 0; 
      for(int k=1;k<51; k++)  D1_50MA += daily_rates[k].close/50;
      _createLineDMA("D1_50MA",D1_50MA,_time_trend,_time_time,clrDarkGray,clrDarkGray,"50 Day MA ("+DoubleToString(D1_50MA,_Digits)+")");//bearish
   
      daily_ratesCopied=CopyRates(_Symbol,PERIOD_D1,0,22,daily_rates);
      if(daily_ratesCopied != 22) return(prev_calculated);
      double D1_21MA    = 0; 
      for(int k=1;k<22; k++)  D1_21MA += daily_rates[k].close/21;
      _createLineDMA("D1_21MA",D1_21MA,_time_trend,_time_time,Orange,Orange,"21 Day MA ("+DoubleToString(D1_21MA,_Digits)+")");//bearish
      }
   
   if(Show_hourly_MA){
      //----hourly MA------
      MqlRates hourly_rates[]; 
      int hourly_ratesCopied=CopyRates(_Symbol,PERIOD_H1,0,201,hourly_rates);
      if(hourly_ratesCopied != 201) return(prev_calculated);
      double H1_200MA    = 0;
      for(int k=1;k<201; k++)  H1_200MA += hourly_rates[k].close/200; 
      _createLineMA("H1_200MA",H1_200MA,_time_trend,_time_time,Yellow,Yellow,"200 Hour MA ("+DoubleToString(H1_200MA,_Digits)+")");//bearish
   
      hourly_ratesCopied=CopyRates(_Symbol,PERIOD_H1,0,101,hourly_rates);
      if(hourly_ratesCopied != 101) return(prev_calculated);
      double H1_100MA    = 0; 
      for(int k=1;k<101; k++)  H1_100MA += hourly_rates[k].close/100;
      _createLineMA("H1_100MA",H1_100MA,_time_trend,_time_time,White,White,"100 Hour MA ("+DoubleToString(H1_100MA,_Digits)+")");//bearish
      }
   /*
   
         //--- variables for returning values from order properties 
         uint     total=PositionsTotal(); 
         int DealNumberArr=0;
         double BreakevenLong=999999999;
         double BreakevenShort=0;
         double SumOfLotPriceLong=0;
         double SumOfLotPriceShort=0;
         double LongLots=0;
         double ShortLots=0;
         
         //--- go through orders in a loop 
         for(uint i=0;i<total;i++) 
           { 
            //--- return order ticket by its position in the list 
            if((ticket=PositionGetTicket(i))>0) 
              { 
                if((PositionGetString(POSITION_SYMBOL)==_Symbol))//&&(PositionGetInteger(POSITION_MAGIC)==MagicNumber)
                  {
                     
                     DealNumberArr=DealNumberArr+1;

                     //-----   
                     if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                        {
                           SumOfLotPriceLong = SumOfLotPriceLong+((PositionGetDouble(POSITION_PRICE_OPEN)+((Ask-Bid)*2))*PositionGetDouble(POSITION_VOLUME));
                           LongLots = LongLots+PositionGetDouble(POSITION_VOLUME);
                        }
                     //-----   
                     if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                        {
                           SumOfLotPriceShort = SumOfLotPriceShort+((PositionGetDouble(POSITION_PRICE_OPEN)-((Ask-Bid)*2))*PositionGetDouble(POSITION_VOLUME));
                           ShortLots = ShortLots+PositionGetDouble(POSITION_VOLUME);
                        }
                  }//SymbolArr[N]
              }//PositionGetTicket
           }//for        
   
   
*/   
   
   
   
   ChartRedraw();
   //Sleep(1000);
   return (rates_total);
  }
//+------------------------------------------------------------------+
//| Custom function(s)                                               |
//+------------------------------------------------------------------+
void _createLine(string _add,double _price,datetime _time_trend,datetime _time,color _color,color _textColor,string _text,int _style=STYLE_DOT)
  {
   string _name=inpUniqueID+":"+_add;
   //ObjectCreate(0,_name,OBJ_HLINE,0,0,0);
   ObjectCreate(0,_name, OBJ_TREND, 0, _time_trend, _price, _time, _price, 0, 0);
   ObjectSetInteger(0,_name,OBJPROP_COLOR,_color);
   ObjectSetInteger(0,_name,OBJPROP_STYLE,_style);
   ObjectSetDouble(0,_name,OBJPROP_PRICE,0,_price);
   //ObjectSetInteger(0,_name,OBJPROP_RAY_RIGHT,1);
   
   _name=inpUniqueID+":label:"+_add;
   ObjectCreate(0,_name,OBJ_TEXT,0,0,0);
   ObjectSetInteger(0,_name,OBJPROP_COLOR,_textColor);
   ObjectSetInteger(0,_name,OBJPROP_TIME,0,_time);
   ObjectSetInteger(0,_name,OBJPROP_FONTSIZE,8);
   ObjectSetDouble(0,_name,OBJPROP_PRICE,0,_price);
   ObjectSetString(0,_name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,_name,OBJPROP_TEXT,_text);
  }
void _createHLine(string _add,double _price,datetime _time_trend,datetime _time,color _color,color _textColor,string _text,int _style=STYLE_DOT)
  {
   string _name=inpUniqueID+":"+_add;
   ObjectCreate(0,_name,OBJ_HLINE,0,0,0);
   //ObjectCreate(0,_name, OBJ_TREND, 0, _time_trend, _price, _time, _price, 0, 0);
   ObjectSetInteger(0,_name,OBJPROP_COLOR,_color);
   ObjectSetInteger(0,_name,OBJPROP_STYLE,_style);
   ObjectSetDouble(0,_name,OBJPROP_PRICE,0,_price);
   //ObjectSetInteger(0,_name,OBJPROP_RAY_RIGHT,1);
  }
void _createLineMA(string _add,double _price,datetime _time_trend,datetime _time,color _color,color _textColor,string _text,int _style=STYLE_SOLID)
  {
   string _name=inpUniqueID+":"+_add;
   //ObjectCreate(0,_name,OBJ_HLINE,0,0,0);
   ObjectCreate(0,_name, OBJ_TREND, 0, _time_trend, _price, _time, _price, 0, 0);
   ObjectSetInteger(0,_name,OBJPROP_COLOR,_color);
   ObjectSetInteger(0,_name,OBJPROP_STYLE,_style);
   ObjectSetDouble(0,_name,OBJPROP_PRICE,0,_price);
   //ObjectSetInteger(0,_name,OBJPROP_RAY_RIGHT,1);
   
   _name=inpUniqueID+":label:"+_add;
   ObjectCreate(0,_name,OBJ_TEXT,0,0,0);
   ObjectSetInteger(0,_name,OBJPROP_COLOR,_textColor);
   ObjectSetInteger(0,_name,OBJPROP_TIME,0,_time);
   ObjectSetInteger(0,_name,OBJPROP_FONTSIZE,8);
   ObjectSetDouble(0,_name,OBJPROP_PRICE,0,_price);
   ObjectSetString(0,_name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,_name,OBJPROP_TEXT,_text);
  }
void _createLineDMA(string _add,double _price,datetime _time_trend,datetime _time,color _color,color _textColor,string _text,int _style=STYLE_SOLID)
  {
   string _name=inpUniqueID+":"+_add;
   //ObjectCreate(0,_name,OBJ_HLINE,0,0,0);
   ObjectCreate(0,_name, OBJ_TREND, 0, _time_trend, _price, _time, _price, 0, 0);
   ObjectSetInteger(0,_name,OBJPROP_COLOR,_color);
   ObjectSetInteger(0,_name,OBJPROP_STYLE,_style);
   ObjectSetDouble(0,_name,OBJPROP_PRICE,0,_price);
   ObjectSetInteger(0,_name,OBJPROP_WIDTH,3);
   //ObjectSetInteger(0,_name,OBJPROP_RAY_RIGHT,1);
   
   _name=inpUniqueID+":label:"+_add;
   ObjectCreate(0,_name,OBJ_TEXT,0,0,0);
   ObjectSetInteger(0,_name,OBJPROP_COLOR,_textColor);
   ObjectSetInteger(0,_name,OBJPROP_TIME,0,_time);
   ObjectSetInteger(0,_name,OBJPROP_FONTSIZE,8);
   ObjectSetDouble(0,_name,OBJPROP_PRICE,0,_price);
   ObjectSetString(0,_name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,_name,OBJPROP_TEXT,_text);
  }//------------------  
int    _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int period)
  {
   if(period==PERIOD_CURRENT)
      period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);
  }
//+------------------------------------------------------------------+
double iHighMQL4(string symbol,ENUM_TIMEFRAMES timeframe,int index)

{
   if(index < 0) return(-1);
   double Arr[];
   //ENUM_TIMEFRAMES timeframe=PERIOD_D1;
   if(CopyHigh(symbol,timeframe, index, 1, Arr)>0) 
        return(Arr[0]);
   else return(-1);
}//+------------------------------------------------------------------+
double iLowMQL4(string symbol,ENUM_TIMEFRAMES timeframe,int index)

{
   if(index < 0) return(-1);
   double Arr[];
   //ENUM_TIMEFRAMES timeframe=PERIOD_D1;
   if(CopyLow(symbol,timeframe, index, 1, Arr)>0)
        return(Arr[0]);
   else return(-1);
}//+------------------------------------------------------------------+
double iCloseMQL4(string symbol,ENUM_TIMEFRAMES timeframe,int index)

{
   if(index < 0) return(-1);
   double Arr[];
   //ENUM_TIMEFRAMES timeframe=PERIOD_D1;
   if(CopyClose(symbol,timeframe, index, 1, Arr)>0)
        return(Arr[0]);
   else return(-1);
}//+------------------------------------------------------------------+
double iOpenMQL4(string symbol,ENUM_TIMEFRAMES timeframe,int index)

{
   if(index < 0) return(-1);
   double Arr[];
   //ENUM_TIMEFRAMES timeframe=PERIOD_D1;
   if(CopyOpen(symbol,timeframe, index, 1, Arr)>0)
        return(Arr[0]);
   else return(-1);
}//+------------------------------------------------------------------+
datetime iTimeMQL4(string symbol,ENUM_TIMEFRAMES timeframe,int index)
{
   if(index < 0) return(-1);
   datetime Arr[];
   if(CopyTime(symbol, timeframe, index, 1, Arr)>0)
        return(Arr[0]);
   else return(-1);
}
//+------------------------------------------------------------------+ 
