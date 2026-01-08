output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs"
}

output "availability_zones" {
  value       = local.azs
  description = "AZs in use"
}

/*
output "ec2_instance_ids_by_az" {
  value       = { for az, m in module.ec2 : az => m.instance_id }
  description = "Instance IDs per AZ"
}

output "ec2_public_ips_by_az" {
  value       = { for az, m in module.ec2 : az => m.public_ip }
  description = "Public IPv4 per AZ"
}

output "ec2_public_dns_by_az" {
  value       = { for az, m in module.ec2 : az => m.public_dns }
  description = "Public DNS per AZ"
}
*/

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "rds_port" {
  value = module.rds.port
}

output "efs_id" {
  value = module.efs.file_system_id
}

output "efs_dns_name" {
  value = module.efs.dns_name
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_security_group_id" {
  value = module.alb.alb_security_group_id
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}

output "wp_events_producer_function_url" {
  value = module.wp_events.producer_function_url
}

output "wp_events_queue_url" {
  value = module.wp_events.queue_url
}
