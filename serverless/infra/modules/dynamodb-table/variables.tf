variable "name" {
  type        = string
  description = "DynamoDB table name"
}

variable "hash_key_name" {
  type        = string
  description = "Partition key name"
  default     = "pk"
}

variable "hash_key_type" {
  type        = string
  description = "Partition key type: S | N | B"
  default     = "S"
}

variable "billing_mode" {
  type        = string
  description = "PAY_PER_REQUEST or PROVISIONED"
  default     = "PAY_PER_REQUEST"
}

variable "tags" {
  type    = map(string)
  default = {}
}
