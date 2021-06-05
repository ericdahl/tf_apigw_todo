import json
import boto3
import base64
import uuid
import datetime

dynamodb = boto3.resource('dynamodb')
items = dynamodb.Table('items')


def handler(event, context):
    print('Received event: ' + json.dumps(event, indent=2))

    try:
        body = parse(event)
    except Exception as e:
        return {
            'statusCode': 401,
            "body": "invalid input",
            "headers": {"Content-Type": "application/json"}
        }

    item = {
        "id": str(uuid.uuid4()),
        "item": body["item"],
        "created": datetime.datetime.now(datetime.timezone.utc).isoformat()
    }

    items.put_item(Item=item)

    return {
        "statusCode": 201
    }


def parse(event):
    body = event['body']
    if bool(event['isBase64Encoded']):
        body = base64.b64decode(body)
    body_json = json.loads(body)

    return {
        "item": body_json["item"]
    }


if __name__ == '__main__':
    event = {
        "body": "eyJpdGVtIjogImZvb2JhciJ9zz",
        "isBase64Encoded": True
    }

    print(handler(event, 0))
