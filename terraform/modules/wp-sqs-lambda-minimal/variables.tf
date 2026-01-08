variable "name" {
  description = "Base name prefix for resources (e.g., legibit-wp-dev-events)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "producer_token" {
  description = "Shared secret token that WordPress will send in a header to the Producer Lambda URL"
  type        = string
  sensitive   = true
}

variable "producer_header_name" {
  description = "Header name for the shared secret"
  type        = string
  default     = "X-Token"
}

variable "log_retention_days" {
  description = "CloudWatch log retention (days)"
  type        = number
  default     = 7
}

variable "consumer_timeout_seconds" {
  description = "Consumer Lambda timeout (seconds)"
  type        = number
  default     = 10
}

variable "producer_timeout_seconds" {
  description = "Producer Lambda timeout (seconds)"
  type        = number
  default     = 5
}

variable "consumer_batch_size" {
  description = "SQS batch size for the consumer"
  type        = number
  default     = 5
}

variable "max_receive_count" {
  description = "How many times a message can be received before moving to DLQ"
  type        = number
  default     = 5
}

variable "queue_message_retention_seconds" {
  description = "Main queue message retention"
  type        = number
  default     = 345600 # 4 days
}

variable "dlq_message_retention_seconds" {
  description = "DLQ message retention"
  type        = number
  default     = 1209600 # 14 days
}

variable "visibility_timeout_seconds" {
  description = "SQS visibility timeout. Must be > consumer timeout. If null, derived automatically."
  type        = number
  default     = null
}
