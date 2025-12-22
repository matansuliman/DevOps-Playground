import json
import os
import boto3
from datetime import datetime, timezone

dynamodb = boto3.resource("dynamodb")

def lambda_handler(event, context):
    table_name = os.environ.get("TABLE_NAME", "")
    visits = None

    if table_name:
        table = dynamodb.Table(table_name)
        resp = table.update_item(
            Key={"pk": "visits"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":inc": 1},
            ReturnValues="UPDATED_NEW",
        )
        visits = int(resp["Attributes"]["count"])

    body = {
        "message": "Hello from Lambda 👋",
        "time": datetime.now(timezone.utc).isoformat(),
        "visits": visits
    }

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }
