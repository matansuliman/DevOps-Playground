resource "aws_security_group" "efs" {
  name        = "${var.name}-efs-sg"
  description = "EFS SG: allow NFS from app/instances SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from app/instances SG"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.allowed_sg_id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-efs-sg"
  }
}

resource "aws_efs_file_system" "this" {
  creation_token   = "${var.name}-efs"
  encrypted        = var.encrypted
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode

  tags = {
    Name = "${var.name}-efs-wp-content"
  }
}

resource "aws_efs_mount_target" "this" {
  for_each = { for idx, sid in var.subnet_ids : tostring(idx) => sid }

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}
