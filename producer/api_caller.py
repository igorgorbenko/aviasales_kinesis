#!/usr/bin/python3
"""Example Code of API calling to receive the prices of the tickets."""
import sys
import time
import logging
import csv
import asyncio
from aiohttp import ClientSession, FormData
from urllib.error import HTTPError
import json
import uuid


TARGET_FILE = time.strftime(r'/var/log/airline_tickets/%Y%m%d-%H%M%S.log')

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
        response_json = {}
        async with ClientSession(headers=self.headers) as session:
            try:
                response = await session.get(self.base_url, data=data)
                response.raise_for_status()
                LOGGER.info('Response status %s: %s',
                            self.base_url, response.status)
                response_json = await response.json()
            except HTTPError as http_err:
                LOGGER.error('Oops! HTTP error occurred: %s', str(http_err))
            except Exception as err:
                LOGGER.error('Oops! An error ocurred: %s', str(err))
            return response_json


def get_guid():
    """Return the random UID."""
    return str(uuid.uuid4())


def log_maker(response_json):
    """Save the response into a csv file."""
    with open(TARGET_FILE, 'w+') as csv_file:
        csv_writer = csv.writer(csv_file)
        count = 0
        new_row = []
        for resp in response_json['data']:
            new_row = list(resp.values())
            new_row.append(get_guid())
            csv_writer.writerow(new_row)
            count += 1

        return count


def prepare_request(api_token):
    """Return the headers and query fot the API request."""
    headers = {'X-Access-Token': api_token,
               'Accept-Encoding': 'gzip'}

    data = FormData()
    data.add_field('currency', CURRENCY)
    data.add_field('origin', ORIGIN)
    data.add_field('destination', DESTINATION)
    data.add_field('show_to_affiliates', SHOW_TO_AFFILIATES)
    data.add_field('trip_duration', TRIP_DURATION)
    return headers, data


async def main():
    """Get run the code."""
    if len(sys.argv) != 2:
        print('Usage: api_caller.py <your_api_token>')
        sys.exit(1)
        return
    api_token = sys.argv[1]
    headers, data = prepare_request(api_token)

    api = TicketsApi(headers)
    response = await api.get_data(data)
    print(json.dumps(response, indent=4))
    if response.get('success', None):
        LOGGER.info('API has returned %s items', len(response['data']))
        try:
            count_rows = log_maker(response)
            LOGGER.info('%s rows have been saved into %s',
                        count_rows,
                        TARGET_FILE)
        except Exception as e:
            LOGGER.error('Oops! Request result was not saved to file. %s',
                         str(e))
    else:
        LOGGER.error('Oops! API request was unsuccessful %s!', response)

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
