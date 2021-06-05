import json
import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
items = dynamodb.Table('items')


def handler(event, context):
    print('Received event: ' + json.dumps(event, indent=2))

    key = event['pathParameters']['item']
    response = items.query(KeyConditionExpression=Key('id').eq(key))
    return response['Items']


if __name__ == '__main__':
    print(handler({'pathParameters': {'item': '1'}}, 0))