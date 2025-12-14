variable "name" {
  type        = string
  description = "Base name for tags"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block (e.g., 10.0.0.0/16)"
}

variable "availability_zones" {
  type        = list(string)
  description = "AZs for public subnets (e.g., [\"eu-north-1a\",\"eu-north-1b\"])"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for the public subnets (same length as availability_zones)"
}
