locals {
  common_tags = merge(var.tags, {
    "ManagedBy" = "Terraform"
  })

  derived_visibility_timeout = max(30, var.consumer_timeout_seconds + 10)
  sqs_visibility_timeout     = coalesce(var.visibility_timeout_seconds, local.derived_visibility_timeout)
}

# ----------------------
# SQS (Main + DLQ)
# ----------------------
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.name}-dlq"
  message_retention_seconds = var.dlq_message_retention_seconds

  tags = merge(local.common_tags, {
    Name = "${var.name}-dlq"
  })
}

resource "aws_sqs_queue" "main" {
  name                       = "${var.name}-q"
  message_retention_seconds  = var.queue_message_retention_seconds
  visibility_timeout_seconds = local.sqs_visibility_timeout

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(local.common_tags, {
    Name = "${var.name}-q"
  })
}

# ----------------------
# IAM for Lambdas
# ----------------------
data "aws_iam_policy_document" "assume_lambda" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Producer role
resource "aws_iam_role" "producer" {
  name               = "${var.name}-producer-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json

  tags = merge(local.common_tags, {
    Name = "${var.name}-producer-role"
  })
}

data "aws_iam_policy_document" "producer_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [aws_sqs_queue.main.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "producer" {
  name   = "${var.name}-producer-inline"
  role   = aws_iam_role.producer.id
  policy = data.aws_iam_policy_document.producer_policy.json
}

# Consumer role
resource "aws_iam_role" "consumer" {
  name               = "${var.name}-consumer-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json

  tags = merge(local.common_tags, {
    Name = "${var.name}-consumer-role"
  })
}

data "aws_iam_policy_document" "consumer_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility"
    ]
    resources = [aws_sqs_queue.main.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "consumer" {
  name   = "${var.name}-consumer-inline"
  role   = aws_iam_role.consumer.id
  policy = data.aws_iam_policy_document.consumer_policy.json
}

# ----------------------
# Lambda Code Packages
# ----------------------
data "archive_file" "producer_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/producer.py"
  output_path = "${path.module}/lambda_producer.zip"
}

data "archive_file" "consumer_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/consumer.py"
  output_path = "${path.module}/lambda_consumer.zip"
}

# ----------------------
# Lambda Functions
# ----------------------
resource "aws_cloudwatch_log_group" "producer" {
  name              = "/aws/lambda/${var.name}-producer"
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "consumer" {
  name              = "/aws/lambda/${var.name}-consumer"
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}

resource "aws_lambda_function" "producer" {
  function_name = "${var.name}-producer"
  role          = aws_iam_role.producer.arn
  handler       = "producer.handler"
  runtime       = "python3.12"
  timeout       = var.producer_timeout_seconds

  filename         = data.archive_file.producer_zip.output_path
  source_code_hash = data.archive_file.producer_zip.output_base64sha256

  environment {
    variables = {
      QUEUE_URL   = aws_sqs_queue.main.url
      TOKEN       = var.producer_token
      HEADER_NAME = var.producer_header_name
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-producer"
  })

  depends_on = [aws_cloudwatch_log_group.producer]
}

resource "aws_lambda_function" "consumer" {
  function_name = "${var.name}-consumer"
  role          = aws_iam_role.consumer.arn
  handler       = "consumer.handler"
  runtime       = "python3.12"
  timeout       = var.consumer_timeout_seconds

  filename         = data.archive_file.consumer_zip.output_path
  source_code_hash = data.archive_file.consumer_zip.output_base64sha256

  environment {
    variables = {
      ENV = "${var.name}"
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-consumer"
  })

  depends_on = [aws_cloudwatch_log_group.consumer]
}

# Function URL (public) for Producer
resource "aws_lambda_function_url" "producer" {
  function_name      = aws_lambda_function.producer.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["*"]
  }
}

# Allow public invoke for Function URL
resource "aws_lambda_permission" "producer_url_public" {
  statement_id           = "AllowPublicInvokeFunctionUrl"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.producer.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

# Event source mapping: SQS -> Consumer
resource "aws_lambda_event_source_mapping" "consumer" {
  event_source_arn = aws_sqs_queue.main.arn
  function_name    = aws_lambda_function.consumer.arn
  batch_size       = var.consumer_batch_size
  enabled          = true
}
