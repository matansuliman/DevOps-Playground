variable "name" {
  description = "Base name for EFS resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets to create EFS mount targets in (one per subnet/AZ)"
  type        = list(string)
}

variable "allowed_sg_id" {
  description = "Security Group ID that is allowed to mount EFS (NFS 2049)"
  type        = string
}

variable "performance_mode" {
  description = "EFS performance mode"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "EFS throughput mode"
  type        = string
  default     = "bursting"
}

variable "encrypted" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}
