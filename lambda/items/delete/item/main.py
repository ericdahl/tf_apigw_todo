import json
import boto3

dynamodb = boto3.resource('dynamodb')
items = dynamodb.Table('items')


def handler(event, context):
    print('Received event: ' + json.dumps(event, indent=2))

    key = event['pathParameters']['item']
    items.delete_item(Key={'id': key})

    return {
        "statusCode": 204
    }


if __name__ == '__main__':
    print(handler({'pathParameters': {'item': '1'}}, 0))
