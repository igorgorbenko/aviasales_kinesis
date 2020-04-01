"""Parsing the stream and inserting into the DynamoDB table."""
import base64
import json
import boto3

DYNAMO_DB = boto3.resource('dynamodb')


class TicketsParser:
    """Parsing info from the Stream."""

    def __init__(self, table_name, records):
        """Init method."""
        self.table = DYNAMO_DB.Table(table_name)
        self.json_data = TicketsParser.get_json_data(records)

    @staticmethod
    def get_json_data(records):
        """Return deserialized data from the stream."""
        decoded_record_data = ([base64.b64decode(record['kinesis']['data'])
                                for record in records])
        json_data = ([json.loads(decoded_record)
                      for decoded_record in decoded_record_data])
        return json_data

    @staticmethod
    def get_item_from_json(json_item):
        """Pre-process the json data."""
        new_item = {
            'record_id': json_item.get('record_id'),
            'cost': float(json_item.get('cost')),
            'trip_class': json_item.get('trip_class'),
            'show_to_affiliates': json_item.get('show_to_affiliates'),
            'origin': json_item.get('origin'),
            'number_of_changes': int(json_item.get('number_of_changes')),
            'gate': json_item.get('gate'),
            'found_at': json_item.get('found_at'),
            'duration': int(json_item.get('duration')),
            'distance': int(json_item.get('distance')),
            'destination': json_item.get('destination'),
            'depart_date': json_item.get('depart_date'),
            'actual': json_item.get('actual')
        }
        return new_item

    def run(self):
        """Batch insert into the table."""
        with self.table.batch_writer() as batch_writer:
            for item in self.json_data:
                dynamodb_item = TicketsParser.get_item_from_json(item)
                batch_writer.put_item(dynamodb_item)

        print('Has been added ', len(self.json_data), 'items')

def lambda_handler(event, context):
    """Parse the stream and insert into the DynamoDB table."""
    print('Got event:', event)
    table_name = 'airline_tickets'
    parser = TicketsParser(table_name, event['Records'])
    parser.run()
