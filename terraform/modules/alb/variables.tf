variable "name" {
  description = "Base name for ALB resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for ALB (public subnets)"
  type        = list(string)
}

variable "listener_port" {
  description = "HTTP listener port"
  type        = number
  default     = 80
}

variable "target_port" {
  description = "Target group port (instances listen on this port)"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}
