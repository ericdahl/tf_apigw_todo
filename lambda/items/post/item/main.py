import json
import boto3
import base64
import uuid
import datetime
from boto3_type_annotations.dynamodb import ServiceResource

dynamodb: ServiceResource = boto3.resource('dynamodb')
items = dynamodb.Table('items')


def handler(event, context):
    print('Received event: ' + json.dumps(event, indent=2))

    body = event['body']
    if bool(event['isBase64Encoded']):
        body = base64.b64decode(body)
    body = json.loads(body)

    item = {
        "id": str(uuid.uuid4()),
        "item": body["item"],
        "created": datetime.datetime.now(datetime.timezone.utc).isoformat()
    }

    items.put_item(Item=item)

    return body

if __name__ == '__main__':
    event = {
          "body": "eyJpdGVtIjogImZvb2JhciJ9",
          "isBase64Encoded": True
    }

    print(handler(event, 0))