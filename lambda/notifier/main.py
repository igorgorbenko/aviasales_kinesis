import boto3
import base64
import os

SNS_CLIENT = boto3.client('sns')
TOPIC_ARN = os.environ['TOPIC_ARN']


def lambda_handler(event, context):
    try:
        SNS_CLIENT.publish(TopicArn=TOPIC_ARN,
                           Message='Hi! I have found an interesting stuff!',
                           Subject='Airline tickets alarm')
        print('Alarm message has been successfully delivered')
    except Exception as err:
        print('Delivery failure', str(err))
