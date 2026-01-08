# ---------- Environment Variables ----------
variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-north-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile name"
  default     = "default"
}

variable "env" {
  type        = string
  description = "Environment name"
  default     = "dev"
}


# ---------- Application Variables ----------

# WordPress RDS variables
variable "rds_db_name" {
  type        = string
  description = "WordPress DB name"
  default     = "wordpress"
}

variable "rds_db_username" {
  type        = string
  description = "WordPress DB username"
  default     = "wordpress"
}

variable "rds_db_password" {
  type        = string
  description = "WordPress DB password"
  sensitive   = true
}

variable "rds_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  type        = number
  description = "RDS allocated storage (GiB)"
  default     = 20
}

# EFS variables
variable "efs_performance_mode" {
  type        = string
  description = "EFS performance mode"
  default     = "generalPurpose"
}

variable "efs_throughput_mode" {
  type        = string
  description = "EFS throughput mode"
  default     = "bursting"
}

variable "efs_encrypted" {
  type        = bool
  description = "Enable EFS encryption at rest"
  default     = true
}

# ALB variables
variable "alb_health_check_path" {
  type        = string
  description = "ALB target group health check path"
  default     = "/"
}

# WP Events variables
variable "wp_events_producer_token" {
  description = "Shared secret token for WP -> Producer Function URL"
  type        = string
  sensitive   = true
}

# ASG variables
variable "asg_instance_type" {
  type    = string
  default = "t3.micro"
}


