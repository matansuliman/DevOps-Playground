variable "name_prefix" {
  type = string
}

variable "stage_name" {
  type    = string
  default = "prod"
}

variable "route_method" {
  type    = string
  default = "GET"
}

variable "route_path" {
  type    = string
  default = "/hello"
}

variable "cors_allow_origins" {
  type    = list(string)
  default = ["*"]
}

variable "lambda_source_dir" {
  type        = string
  description = "Path to directory containing the lambda code (the folder that has handeler.py)."
}

variable "lambda_handler" {
  type    = string
  default = "handeler.lambda_handler"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.12"
}

variable "lambda_timeout" {
  type    = number
  default = 5
}

variable "lambda_memory" {
  type    = number
  default = 128
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name for visitor counter (optional)"
  default     = ""
}

variable "dynamodb_table_arn" {
  type        = string
  description = "DynamoDB table ARN for IAM permissions (optional)"
  default     = ""
}
