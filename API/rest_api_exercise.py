import json
import requests
import urllib3

urllib3.disable_warnings()

"""
Requirements - Strong understanding of JSON and python functions.

- To complete exercise the output will need to show the price, high, low and 
volume of a valid crypto currency on the TradeOgre Exchange 

- Optional - use ticker and order book functions to retrieve crypto currency data

- Current output is: ""Cannot find data for specified crypto, please try again"" 
"""


# Define required functions
#####################################################################################################################

# Get ALL market data from exchange (API call)
def get_market_data():
    url = "https://tradeogre.com/api/v1/markets"
    response = requests.get(url, verify=False)
    market_prices = json.loads(response.text)
    return market_prices


# Print ALL market data from TradeOgre API
def print_all_market_data(market_data):
    print(f"Market Prices Are: {market_data}")


# Specify crypto currency (Nested Dictionary from API call) to retrieve price, high, low and volume (key/values)
def get_crypto_currency_data(market_prices, crypto_currency=None):
    for item in market_prices:
        if crypto_currency in item:
            output = f"\n{crypto_currency} Price: {item[crypto_currency]['price']}" \
                     f"\n{crypto_currency} Volume: {item[crypto_currency]['volume']}"\
                     f"\n{crypto_currency} High: {item[crypto_currency]['high']} " \
                     f"\n{crypto_currency} Low: {item[crypto_currency]['low']}"
            print(output)
            return

    print("Cannot find data for specified crypto, please try again")


# Optional Functions
# ###################################################################################################################

# Retrieve the ticker for specified crypto currency, volume, high, and low are in the last 24 hours, initialprice is
# the price from 24 hours ago
def get_crypto_currency_ticker(crypto_currency=None):
    url = f"https://tradeogre.com/api/v1/ticker/{crypto_currency}"
    response = requests.get(url, verify=False)
    ticker = json.loads(response.text)
    print(f"{crypto_currency}: {ticker}")


# Retrieve the current order book for specified crypto currency
def get_crypto_currency_order_book(crypto_currency=None):
    url = f"https://tradeogre.com/api/v1/orders/{crypto_currency}"
    response = requests.get(url, verify=False)
    order_book = json.loads(response.text)
    print(f"{crypto_currency}: {order_book}")


#####################################################################################################################

def main():
    # Step 1 - Get market prices from exchange
    market_data = get_market_data()

    # Step 2 - Specify nested dictionary from market_data and output result
    get_crypto_currency_data(market_data)

    # Optional - use ticker and order book functions
    # get_crypto_currency_ticker()
    # get_crypto_currency_order_book()


#####################################################################################################################

# Init Main function

if __name__ == '__main__':
    main()
