variable "name" {
  type        = string
  description = "Base name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for ASG instances"
}

variable "alb_sg_id" {
  type        = string
  description = "ALB security group ID (allowed to reach instances on 80)"
}

variable "target_group_arn" {
  type        = string
  description = "Target group ARN to attach ASG to"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "min_size" {
  type    = number
  default = 1
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "key_name" {
  type        = string
  default     = null
  description = "Optional key pair name"
}

# WordPress + DB
variable "wp_db_host" {
  type        = string
  description = "RDS endpoint (host:port or host)"
}

variable "wp_db_name" {
  type        = string
  description = "DB name"
}

variable "wp_db_user" {
  type        = string
  description = "DB username"
}

variable "wp_db_password" {
  type        = string
  description = "DB password"
  sensitive   = true
}

# EFS
variable "efs_dns_name" {
  type        = string
  description = "EFS DNS name"
}

variable "wp_container_image" {
  type    = string
  default = "wordpress:latest"
}

variable "attach_ssm" {
  type    = bool
  default = true
}
