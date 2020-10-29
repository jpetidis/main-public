import json
import requests
import urllib3

urllib3.disable_warnings()

"""
Requirements - Strong understanding of JSON and python functions.

- To complete exercise the output will need to show the price, high, low and 
volume of a valid crypto currency on the TradeOgre Exchange 

- Current output is: ""Cannot find data for specified crypto, please try again"" 
"""


# Define required functions
#####################################################################################################################

# Get ALL market data from exchange (API call)
def get_markets():
    url = "https://tradeogre.com/api/v1/markets"
    response = requests.get(url, verify=False)
    market_prices = json.loads(response.text)
    return market_prices


# Output ALL market data prices
def output_market_prices(market_data):
    print(f"Market Prices Are {market_data}")


# Specify crypto currency (Nested Dictionary from API call) to retrieve price, high, low and volume (key/pairs)
def get_crypto_currency_data(market_prices, crypto_currency=None):

    # Explain from line 36 to 43
    for item in market_prices:
        if crypto_currency in item:
            dict_layout = {'price': item[crypto_currency]['price'], 'high': item[crypto_currency]['high'],
                           'low': item[crypto_currency]['low'], 'volume': item[crypto_currency]['volume']}
            return f"\n{crypto_currency} Price: {dict_layout['price']}\n{crypto_currency} " \
                   f"Volume: {dict_layout['volume']}" \
                   f"\n{crypto_currency} High: {dict_layout['high']}\n{crypto_currency} Low: {dict_layout['low']}"


def output_crypto_currency_data(crypto_data):
    if crypto_data:
        print(crypto_data)
    else:
        print("Cannot find data for specified crypto, please try again")


#####################################################################################################################

def main():
    # Step 1 - Get market prices from exchange
    market_data = get_markets()

    # Step 2 - Specify nested dictionary from market_data to retrieve crypto data
    crypto_currency_data = get_crypto_currency_data(market_data)

    # Step 3 - Print out to user
    output_crypto_currency_data(crypto_currency_data)


#####################################################################################################################

# Init Main function

if __name__ == '__main__':
    main()
