# Crypto-Analytics-Dashboard

##  Executive Summary

This project analyses price trends, volatility, and trading volume anomalies across the top 10 cryptocurrencies by market cap over a 12-month period (May 2025 – May 2026).
Using a full end-to-end pipeline, CoinGecko API extraction in Python, SQL Server analytical views, and a two-page Power BI dashboard, the project surfaces actionable insights about which assets carry the most risk, when unusual market activity occurred, and how the broader crypto market trended over the period.

**_Key findings at a glance:_**

- ADA was the most volatile coin at 6.22% avg daily move — not Bitcoin (3.07%)
- July 2025 saw the highest concentration of volume spikes, with DOGE trading at 9.87× its average volume
- The market peaked in October–November 2025 before declining through early 2026
- TRX delivered the best average monthly return (+2.5%) despite being one of the lowest-volume coins


## Business Problem
Crypto markets generate enormous volumes of data, but raw price feeds alone don't tell you where the risk is, when the market is behaving abnormally, or how individual assets compare over time.
This project addresses three specific business questions:

*Market performance*
How did crypto prices trend over the past year, and which coins delivered the best and worst monthly returns?

*Risk profiling*
Which coins carry the most price risk based on day-to-day volatility, and what is the relationship between a coin's maximum gain and maximum loss?

*Anomaly detection*
On which days did trading volume spike unusually high — and for which coins? What does this tell us about market activity?


## Methodology
**Data extraction**: Python 
OHLCV data (open, high, low, close, volume) pulled from the CoinGecko public API for 10 coins over 365 days. Two endpoints called per coin, one for price and the other for volume merged on date and coin. A retry mechanism handles free tier rate limits automatically.

See: python/extract.py

**Feature engineering**: Python / pandas
Two features engineered before loading:
FeatureLogicdaily_return_pctpct_change() on close price, grouped by coinvolume_change_pctpct_change() on volume, grouped by coin
Grouping by coin before calculating ensures returns don't bleed across coins.

**Storage & analysis**: SQL Server
Data loaded into SQL Server. Four analytical views built using T-SQL window functions:
  *vw_rolling_avg -*  How does price trend when smoothed over 7 days?
  *vw_volume_spikes -* Which days had abnormally high trading volume?
  *vw_volatility_ranking -* Which coins are most volatile on a daily basis?
  *vw_monthly_performance -* How did each coin perform month by month?

See: sql/

**Visualisation**: Power BI
Two-page dashboard connected directly to SQL Server views. Star schema data model with vw_volatility_ranking serving as the coin dimension. Eight DAX measures created for KPI cards.

See: powerbi/crypto_analytics.pbix

## Skills Demonstrated
**_Python:_** (requests, pandas) API extraction, retry logic, feature engineering
**_SQL:_** window functions AVG() OVER, RANK() OVER, PARTITION BY, SQL Server views 
Reusable analytical layer between storage and BI tool
**_Power BI:_** data modelling Star schema, cross-table relationships DAXFORMAT, CALCULATE, TOPN, SELECTEDVALUE Data quality validation


## Results & Business Recommendations
**Result 1:**  Altcoins carry significantly more risk than Bitcoin
ADA (6.22%), DOGE (5.90%), and SOL (5.58%) recorded the highest average daily moves. Bitcoin ranked 7th at 3.07%.
**Recommendation:** Portfolios benchmarked against Bitcoin volatility may be significantly underestimating risk if they hold high-weight positions in ADA, DOGE, or SOL.

**Result 2:** July 2025 was a high-risk period across multiple coins
DOGE spiked at 9.87× average volume on July 19, TRX at 8.11× on the same date, and SOL at 5.61× on July 23. The cross-coin concentration of spikes on the same dates points to a macro market event rather than coin-specific news.
**Recommendation::** Volume spike monitoring across multiple coins simultaneously — rather than per-coin alerts in isolation — would give earlier warning of broad market stress events.

**Result 3:** The market inflection point was October–November 2025
The 7-day rolling average shows a clear peak and sustained decline from this period through early 2026, with early recovery signals in May 2026.
**Recommendation:** Any strategy that entered positions after October 2025 without downside protection would have faced sustained losses through Q1 2026. Rolling average trend monitoring provides a cleaner signal than raw price for identifying regime changes.

**Result 4:** Volume is not a reliable predictor of returns
TRX had the best average monthly return (+2.5%) with one of the lowest trading volumes (0.01T). USDT had the highest volume (1.08T) with near-zero returns by design.
**Recommendation:** Volume-weighted return metrics should be used with caution — high-volume coins do not necessarily outperform, and low-volume coins can generate significant returns over a given period.


## Next Steps
If this project were extended in a production environment:

- Replace free tier API with paid feed or WebSocket to get true daily (or intraday) OHLCV data rather than 4-day intervals
- Add dbt for transformation layer with documented lineage and column-level tests (e.g. stablecoin close price within $0.01 of $1.00, no negative volume)
- Build a scheduled refresh pipeline using Azure Data Factory or Airflow rather than a one-time CSV import
- Extend anomaly detection with statistical thresholds (e.g. z-score > 2) rather than a fixed 2× multiplier, to make spike detection adaptive to each coin's volatility profile
- Add correlation analysis to quantify how closely altcoin prices move with Bitcoin 



