output "queue_url" {
  value       = aws_sqs_queue.main.url
  description = "Main SQS Queue URL"
}

output "queue_arn" {
  value       = aws_sqs_queue.main.arn
  description = "Main SQS Queue ARN"
}

output "dlq_url" {
  value       = aws_sqs_queue.dlq.url
  description = "Dead Letter Queue URL"
}

output "dlq_arn" {
  value       = aws_sqs_queue.dlq.arn
  description = "Dead Letter Queue ARN"
}

output "producer_function_url" {
  value       = aws_lambda_function_url.producer.function_url
  description = "Public Function URL for the Producer (WordPress will POST to this)"
}

output "producer_function_name" {
  value       = aws_lambda_function.producer.function_name
  description = "Producer Lambda function name"
}

output "consumer_function_name" {
  value       = aws_lambda_function.consumer.function_name
  description = "Consumer Lambda function name"
}
