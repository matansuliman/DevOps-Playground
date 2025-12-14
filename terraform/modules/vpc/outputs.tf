output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = aws_vpc.this.cidr_block
  description = "VPC CIDR"
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "IGW ID"
}

output "route_table_public_id" {
  value       = aws_route_table.public.id
  description = "Public route table ID"
}
