variable "bucket_name" {
  type        = string
  description = "S3 bucket name for the static website"
}

variable "index_document" {
  type        = string
  description = "Index document"
  default     = "index.html"
}

variable "error_document" {
  type        = string
  description = "Error document"
  default     = "404.html"
}

variable "force_destroy" {
  type        = bool
  description = "Allow terraform destroy to delete non-empty bucket"
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
