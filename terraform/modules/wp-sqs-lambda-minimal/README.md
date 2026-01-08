# wp-sqs-lambda-minimal (module)

Creates a minimal demo pipeline:

WordPress (HTTP POST) -> **Producer Lambda Function URL** -> **SQS** -> **Consumer Lambda** -> CloudWatch Logs

Also creates a **DLQ** for failed messages.

## Notes
- The producer Function URL is public (`authorization_type = NONE`). Protect it with a shared secret header.
- Terraform will generate `lambda_producer.zip` and `lambda_consumer.zip` inside this module folder. Add them to `.gitignore`.
