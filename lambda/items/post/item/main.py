import json
import boto3
import base64
import uuid
from boto3_type_annotations.dynamodb import ServiceResource
from boto3.dynamodb.conditions import Key

dynamodb: ServiceResource = boto3.resource('dynamodb')
items = dynamodb.Table('items')


def handler(event, context):
    print('Received event: ' + json.dumps(event, indent=2))

    body = event['body']
    if bool(event['isBase64Encoded']):
        body = base64.b64decode(body)
    body = json.loads(body)

    body["id"] = str(uuid.uuid4())

    items.put_item(Item=body)

    return body

    # return event

    # key = event['pathParameters']['item']
    # response = items.query(KeyConditionExpression=Key('id').eq(key))
    # return response['Items']


if __name__ == '__main__':
    event = {
          "body": "eyJzb21ldGhpbmciOiB0cnVlfQ==",
          "isBase64Encoded": True
    }

    print(handler(event, 0))