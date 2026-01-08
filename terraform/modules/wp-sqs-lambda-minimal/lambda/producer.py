import json
import os
import boto3

sqs = boto3.client("sqs")

QUEUE_URL = os.environ.get("QUEUE_URL", "")
TOKEN = os.environ.get("TOKEN", "")
HEADER_NAME = os.environ.get("HEADER_NAME", "X-Token")


def _resp(code: int, body: dict):
    return {
        "statusCode": code,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(body),
    }


def handler(event, context):
    # Function URL event structure: headers + body
    headers = event.get("headers") or {}

    # Header lookup should be case-insensitive
    token = None
    for k, v in headers.items():
        if k.lower() == HEADER_NAME.lower():
            token = v
            break

    if not TOKEN:
        return _resp(500, {"ok": False, "error": "TOKEN env var is not set"})

    if token != TOKEN:
        return _resp(401, {"ok": False, "error": "unauthorized"})

    if not QUEUE_URL:
        return _resp(500, {"ok": False, "error": "QUEUE_URL env var is not set"})

    raw_body = event.get("body") or "{}"
    if event.get("isBase64Encoded"):
        # keep it minimal; if you ever send base64, handle it here
        return _resp(400, {"ok": False, "error": "base64 body not supported in this demo"})

    try:
        payload = json.loads(raw_body) if raw_body else {}
    except Exception:
        return _resp(400, {"ok": False, "error": "invalid json"})

    message = {
        "source": "wordpress",
        "requestId": getattr(context, "aws_request_id", None),
        "payload": payload,
    }

    try:
        r = sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(message),
        )
        return _resp(200, {"ok": True, "messageId": r.get("MessageId")})
    except Exception as e:
        return _resp(500, {"ok": False, "error": str(e)})
