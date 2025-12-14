resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-db-subnets"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.name}-rds-sg"
  description = "RDS MySQL SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from app/instances SG"
    from_port       = 3306
    to_port         = 3306
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
    Name = "${var.name}-rds-sg"
  }
}

resource "aws_db_instance" "this" {
  identifier = "${var.name}-mysql"

  engine = "mysql"

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible = false

  # DEV:
  deletion_protection     = false
  skip_final_snapshot     = true
  backup_retention_period = 0

  tags = {
    Name = "${var.name}-mysql"
  }
}
