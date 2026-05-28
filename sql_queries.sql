
-- Query 1 ¡X 7-day rolling average price per coin
SELECT
    [date],
    [coin],
    [close],
    AVG([close]) OVER (
        PARTITION BY [coin]
        ORDER BY [date]
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7day_avg
FROM crypto_clean_v2
ORDER BY [coin], [date];


-- Query 2 ¡X Volume spike detection
-- Flags any day where volume is more than 2x the coin's average volume:
SELECT
    [date],
    [coin],
    [volume],
    AVG([volume]) OVER (PARTITION BY [coin]) AS avg_volume,
    ROUND([volume] / AVG([volume]) OVER (PARTITION BY [coin]), 2) AS volume_ratio,
    CASE 
        WHEN [volume] > 2 * AVG([volume]) OVER (PARTITION BY [coin]) 
        THEN 'Spike' 
        ELSE 'Normal' 
    END AS volume_flag
FROM crypto_clean_v2
ORDER BY volume_ratio DESC;


-- Query 3 ¡X Volatility ranking
-- Ranks coins by how volatile they were over the period:
SELECT
    [coin],
    ROUND(AVG(ABS([daily_return_pct])), 4) AS avg_daily_move,
    ROUND(MAX([daily_return_pct]), 4) AS max_gain,
    ROUND(MIN([daily_return_pct]), 4) AS max_loss,
    RANK() OVER (ORDER BY AVG(ABS([daily_return_pct])) DESC) AS volatility_rank
FROM crypto_clean_v2
GROUP BY [coin]
ORDER BY volatility_rank;


-- Query 4 ¡X Monthly performance summary
SELECT
    [coin],
    FORMAT([date], 'yyyy-MM') AS [month],
    ROUND(SUM([daily_return_pct]), 4) AS monthly_return_pct,
    ROUND(AVG([volume]), 2) AS avg_monthly_volume
FROM crypto_clean_v2
GROUP BY [coin], FORMAT([date], 'yyyy-MM')
ORDER BY [coin], [month];





-- View 1: Rolling average
CREATE VIEW vw_rolling_avg AS
SELECT
    [date], [coin], [close],
    AVG([close]) OVER (
        PARTITION BY [coin]
        ORDER BY [date]
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7day_avg
FROM crypto_clean_v2;

-- View 2: Volume spikes
CREATE VIEW vw_volume_spikes AS
SELECT
    [date], [coin], [volume],
    AVG([volume]) OVER (PARTITION BY [coin]) AS avg_volume,
    ROUND([volume] / AVG([volume]) OVER (PARTITION BY [coin]), 2) AS volume_ratio,
    CASE 
        WHEN [volume] > 2 * AVG([volume]) OVER (PARTITION BY [coin]) 
        THEN 'Spike' 
        ELSE 'Normal' 
    END AS volume_flag
FROM crypto_clean_v2;

-- View 3: Volatility ranking
CREATE VIEW vw_volatility_ranking AS
SELECT
    [coin],
    ROUND(AVG(ABS([daily_return_pct])), 4) AS avg_daily_move,
    ROUND(MAX([daily_return_pct]), 4) AS max_gain,
    ROUND(MIN([daily_return_pct]), 4) AS max_loss,
    RANK() OVER (ORDER BY AVG(ABS([daily_return_pct])) DESC) AS volatility_rank
FROM crypto_clean_v2
GROUP BY [coin];

-- View 4: Monthly performance
CREATE VIEW vw_monthly_performance AS
SELECT
    [coin],
    FORMAT([date], 'yyyy-MM') AS [month],
    ROUND(SUM([daily_return_pct]), 4) AS monthly_return_pct,
    ROUND(AVG([volume]), 2) AS avg_monthly_volume
FROM crypto_clean_v2
GROUP BY [coin], FORMAT([date], 'yyyy-MM');

