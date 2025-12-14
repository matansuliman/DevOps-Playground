variable "name" {
  description = "Base name for RDS resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for DB subnet group (for now can be public subnets if you don't have private yet)"
  type        = list(string)
}

variable "allowed_sg_id" {
  description = "Security Group ID that is allowed to connect to the DB (app/instances SG)"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Master username"
  type        = string
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class (e.g. db.t3.micro)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage (GiB)"
  type        = number
  default     = 20
}
