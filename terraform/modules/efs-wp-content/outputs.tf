output "file_system_id" {
  description = "EFS File System ID"
  value       = aws_efs_file_system.this.id
}

output "dns_name" {
  description = "EFS DNS name"
  value       = aws_efs_file_system.this.dns_name
}

output "security_group_id" {
  description = "EFS security group ID"
  value       = aws_security_group.efs.id
}
