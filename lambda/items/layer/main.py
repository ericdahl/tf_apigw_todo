import json
import boto3

dynamodb = boto3.resource('dynamodb')
items = dynamodb.Table("items")


def handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    # return event

    response = items.scan(Limit=10)
    return response['Items']

    # response = items.query(KeyConditionExpression=Key('id').eq('1'))
    # return response['Items']


if __name__ == '__main__':
    print(handler(0, 0))