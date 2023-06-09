//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3

#property indicator_label1  "Delta Ma"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  C'60,60,60'    // Gray
//,clrYellowGreen,clrOrange,clrGreen,clrRed
#property indicator_width1  2

#property indicator_label2  "Average"
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_SOLID
#property indicator_color2  clrDodgerBlue

#property indicator_label3  "Average2"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed

/*
#property indicator_label4  "Average3"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
*/
//---
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
//---
enum enVolumeType
  {
   vol_ticks, // Use ticks
   vol_volume, // Use real volume
  };
  
  
enum enVolumeWeighting
  {
   Delta, // Delta
   None, // Just Price
   Vol_weighted, // Vol Weighted Price
  };

//--- input parameters  
input enVolumeType inpVolumeType      = vol_ticks; // Volume type to use
input enVolumeWeighting inpVolumeWeighting      = Delta; // Volume delta calc

input int          inpAveragePeriod   = 50;        // Average period
input enMaTypes    inpAverageMethod   = ma_sma;    // Average method
input bool         average2_bool      = true;
input int          inpAverage2Period  = 200;        // Average 2 period
//input bool         average3_bool      = true;
//input enMaTypes    inpAverage2Method  = ma_ema;    // Average 2 method

 double       inpBreakoutPercent = 50;        // Breakout percentage
input double       ScaleMult          = 15;
//--- buffers
double  val[],valc[],average[],average2[],average3[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,average,INDICATOR_DATA);
   SetIndexBuffer(3,average2,INDICATOR_DATA);
//   SetIndexBuffer(4,average3,INDICATOR_DATA);
   //string _avgNames[]={"SMA","EMA","SMMA","LWMA"};
   IndicatorSetString(INDICATOR_SHORTNAME,"Delta MA         ");
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   
   int i=(int)MathMax(prev_calculated-1,0); 
   for(; i<rates_total && !_StopFlag; i++)
     {
      double _volume=double((inpVolumeType==vol_ticks) ? tick_volume[i]: volume[i]);
            
      if(inpVolumeWeighting==Delta){
         if((high[i]-low[i])!=0){
         val[i]     = (_volume/((high[i]-low[i])))*(close[i]-open[i]);}
         else{
         val[i]     = (_volume/0.00001)*(close[i]-open[i]);
         }
      }
      
      if(inpVolumeWeighting==None){
      val[i]     = (close[i]-open[i]);}
      
      if(inpVolumeWeighting==Vol_weighted){
      val[i]     = _volume*(close[i]-open[i]);}
      
      average[i]    = 0;
      average[i] = iCustomMa(inpAverageMethod,val[i],inpAveragePeriod,i,rates_total)*ScaleMult;
      
      if(i>0 && val[i]>0)  valc[i] = (MathAbs(val[i]) > average[i]*(1+inpBreakoutPercent)) ? 0 : 0;
      if(i>0 && val[i]<=0)  valc[i] = (MathAbs(val[i]) > average[i]*(1+inpBreakoutPercent)) ? 0 : 0;
     }
     



   i=(int)MathMax(prev_calculated-1,0); 
   for(i=1; i<(rates_total) && !_StopFlag; i++)
     {
      average2[i]    = 0;
      average2[i] = iCustomMa(inpAverageMethod,val[i],inpAverage2Period,i,rates_total)*ScaleMult;
     }
     

   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iCustomMa(int mode,double price,double length,int r,int bars,int instanceNo=0)
  {
   switch(mode)
     {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
     }
  }
double workSma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);
   workSma[r][instanceNo]=price;
   double avg=price;
   int k=1;
   for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double workEma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);
   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double workSmma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSmma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSmma,0)!=_bars) ArrayResize(workSmma,_bars);
   workSmma[r][instanceNo]=price;
   if(r>1 && period>1)
      workSmma[r][instanceNo]=workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double workLwma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<1) return(price);
   double sumw = period;
   double sum  = period*price;
   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight=period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//+------------------------------------------------------------------+
