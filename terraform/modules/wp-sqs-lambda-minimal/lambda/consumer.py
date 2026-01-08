import json


def handler(event, context):
    # SQS -> Lambda event: event["Records"]
    records = event.get("Records") or []

    for r in records:
        body = r.get("body")
        try:
            data = json.loads(body) if body else None
        except Exception:
            data = {"raw": body}

        print("SQS_MESSAGE:", json.dumps(data, ensure_ascii=False))

    # If we return normally, SQS considers the batch processed successfully.
    return {"ok": True, "processed": len(records)}
