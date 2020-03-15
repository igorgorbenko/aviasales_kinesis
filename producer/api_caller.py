#!/usr/bin/python3
"""Example Code of API calling to receive the prices of the tickets."""
import sys
import time
import logging
import json
import asyncio
from aiohttp import ClientSession, FormData

TARGET_FILE = time.strftime(r'/var/log/aviatickets/%Y%m%d-%H%M%S.log')

BASE_URL = 'http://api.travelpayouts.com/v2/prices/month-matrix'
CURRENCY = 'rub'
ORIGIN = 'LED'
DESTINATION = 'KZN'
SHOW_TO_AFFILIATES = 'false'
TRIP_DURATION = '1'

LOGGER = logging.getLogger('StatsCreator')
if not LOGGER.handlers:
    LOGGER.setLevel(logging.INFO)
    FORMATTER = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s',
                                  '%Y-%m-%d %H:%M:%S')
    CONSOLE_HANDLER = logging.StreamHandler(sys.stdout)
    CONSOLE_HANDLER.setFormatter(FORMATTER)
    LOGGER.addHandler(CONSOLE_HANDLER)


class TicketsApi:
    """Api caller class."""

    def __init__(self, headers):
        """Init method."""
        self.base_url = BASE_URL
        self.headers = headers

    async def get_data(self, data):
        """Get the data from API query."""
        async with ClientSession(headers=self.headers) as session:
            async with session.get(self.base_url, data=data) as response:
                return await response.json()


async def main():
    """Get run the code."""
    if len(sys.argv) > 1:
        api_token = sys.argv[1]

    headers = {'X-Access-Token': api_token,
               'Accept-Encoding': 'gzip'}

    data = FormData()
    data.add_field('currency', CURRENCY)
    data.add_field('origin', ORIGIN)
    data.add_field('destination', DESTINATION)
    data.add_field('show_to_affiliates', SHOW_TO_AFFILIATES)
    data.add_field('trip_duration', TRIP_DURATION)

    api = TicketsApi(headers)
    response = await api.get_data(data)

    if response['success']:
        LOGGER.info('API has returned %s items', len(response['data']))
        try:
            with open(TARGET_FILE, 'w') as log_file:
                json.dump(response['data'], log_file)
            LOGGER.info('A log file %s has been filled', TARGET_FILE)
        except Exception as e:
            LOGGER.error('Oops! Request result was not saved to file. %s',
                         str(e))
    else:
        LOGGER.error('Oops! API request was unsuccessful %s!', response)

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
