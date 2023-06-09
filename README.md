# price_action_analytics

- Candlestick price action model with cumulative delta trend filter and chart interactive risk management. 
- Delta Moving Average Oscilator 
- Z-Score cointegration indicator

<p align="center">
  <img src="https://github.com/m4rk-lewis/price_action_analytics/blob/main/pics/US500H4 6.png" width="1000" title="S&P 500">
</p>

We can use the cointegration indicator in combination with the other indicators to find equity index hedged pairs trades. Here we can see there is a z-score divergence of approximately 2 standard deviations between the S&P500 (red line) and EuroStoxx50 (white line), which is confirmed with the cumulative delta MA indicator showing an opposite trend positioning. The price-action indication of long S&P500 can be used to time the entry to the trade, shorting EuroStoxx50 at the same time, exiting on the convergence of the two instrument z-scores.

<p align="center">
  <img src="https://github.com/m4rk-lewis/price_action_analytics/blob/main/pics/STOXX50H4 2.png" width="1000" title="Euro Stoxx 50">
</p>

A long S&P500 (red line) and short Nasdaq (green line) pairs trade can be constructed (z-score divergence of almost 4 standard deviations) using the price action short signal on Nasdaq to time the entry, exiting at the convergence of the z-scores.

<p align="center">
  <img src="https://github.com/m4rk-lewis/price_action_analytics/blob/main/pics/USTECH4.png" width="1000" title="NASDAQ">
</p>
 
