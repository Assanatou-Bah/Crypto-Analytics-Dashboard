import requests
import pandas as pd
from datetime import datetime
import time

COINS = {
    'bitcoin': 'BTC',
    'ethereum': 'ETH',
    'tether': 'USDT',
    'binancecoin': 'BNB',
    'ripple': 'XRP',
    'solana': 'SOL',
    'usd-coin': 'USDC',
    'dogecoin': 'DOGE',
    'cardano': 'ADA',
    'tron': 'TRX'
}

CURRENCY = 'usd'
DAYS = 365

def api_call_with_retry(url, params, retries=3, wait=60):
    """Call API with automatic retry on 429 error"""
    for attempt in range(retries):
        response = requests.get(url, params=params)
        if response.status_code == 200:
            return response
        elif response.status_code == 429:
            print(f"  Rate limited. Waiting {wait} seconds before retry {attempt + 1}/{retries}...")
            time.sleep(wait)
        else:
            print(f"  Failed with status code: {response.status_code}")
            return None
    print(f"  All {retries} retries failed.")
    return None

def get_coin_data(coin_id, coin_symbol):
    """Pull OHLC price data for a single coin"""
    url = f"https://api.coingecko.com/api/v3/coins/{coin_id}/ohlc"
    params = {'vs_currency': CURRENCY, 'days': DAYS}
    
    response = api_call_with_retry(url, params)
    
    if response:
        data = response.json()
        df = pd.DataFrame(data, columns=['timestamp', 'open', 'high', 'low', 'close'])
        df['date'] = pd.to_datetime(df['timestamp'], unit='ms').dt.date
        df['coin'] = coin_symbol
        df.drop(columns='timestamp', inplace=True)
        return df
    return None

def get_volume_data(coin_id, coin_symbol):
    """Pull volume data for a single coin"""
    url = f"https://api.coingecko.com/api/v3/coins/{coin_id}/market_chart"
    params = {'vs_currency': CURRENCY, 'days': DAYS, 'interval': 'daily'}
    
    response = api_call_with_retry(url, params)
    
    if response:
        data = response.json()
        volumes = data['total_volumes']
        df = pd.DataFrame(volumes, columns=['timestamp', 'volume'])
        df['date'] = pd.to_datetime(df['timestamp'], unit='ms').dt.date
        df['coin'] = coin_symbol
        df.drop(columns='timestamp', inplace=True)
        return df
    return None

# --- Main pull loop ---
all_ohlc = []
all_volumes = []

for coin_id, coin_symbol in COINS.items():
    print(f"Fetching {coin_symbol}...")
    
    ohlc = get_coin_data(coin_id, coin_symbol)
    volume = get_volume_data(coin_id, coin_symbol)
    
    if ohlc is not None:
        all_ohlc.append(ohlc)
    if volume is not None:
        all_volumes.append(volume)

    print(f"  {coin_symbol} done. Pausing 45 seconds...")
    time.sleep(45)  # longer pause between coins

# --- Combine ---
ohlc_df = pd.concat(all_ohlc, ignore_index=True)
volume_df = pd.concat(all_volumes, ignore_index=True)

master_df = pd.merge(ohlc_df, volume_df, on=['date', 'coin'], how='left')

# --- Feature engineering ---
master_df = master_df.sort_values(['coin', 'date'])

master_df['daily_return_pct'] = (
    master_df.groupby('coin')['close']
    .pct_change() * 100
).round(4)

master_df['volume_change_pct'] = (
    master_df.groupby('coin')['volume']
    .pct_change() * 100
).round(4)

# --- Export ---
master_df.to_csv('crypto_clean.csv', index=False)
print(f"\nDone. {len(master_df)} rows exported to crypto_clean.csv")
print(master_df.head(10))