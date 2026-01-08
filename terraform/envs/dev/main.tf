locals {
  azs                 = ["eu-north-1a", "eu-north-1b"]
  public_subnet_cidrs = ["10.0.0.0/20", "10.0.16.0/20"]

  az_to_subnet = zipmap(local.azs, module.vpc.public_subnet_ids)
}

module "vpc" {
  source = "../../modules/vpc"

  name       = "legi-bit"
  cidr_block = "10.0.0.0/16"

  availability_zones  = local.azs
  public_subnet_cidrs = local.public_subnet_cidrs
}

# ---------- RDS MySQL ----------
module "rds" {
  source = "../../modules/rds-mysql"

  name   = "legi-bit"
  vpc_id = module.vpc.vpc_id

  subnet_ids = module.vpc.public_subnet_ids

  allowed_sg_id = module.asg.instance_sg_id

  db_name     = var.rds_db_name
  db_username = var.rds_db_username
  db_password = var.rds_db_password

  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
}

# ---------- EFS for WP content ----------
module "efs" {
  source = "../../modules/efs-wp-content"

  name   = "legi-bit"
  vpc_id = module.vpc.vpc_id

  subnet_ids = module.vpc.public_subnet_ids

  allowed_sg_id = module.asg.instance_sg_id

  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode
  encrypted        = var.efs_encrypted
}

# ---------- ALB ----------
module "alb" {
  source = "../../modules/alb"

  name       = "legi-bit"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  health_check_path = var.alb_health_check_path
}

# ---------- WP -> (Lambda Producer URL) -> SQS -> Lambda Consumer ----------
module "wp_events" {
  source = "../../modules/wp-sqs-lambda-minimal"

  name = "legi-bit-wp-${var.env}-events"

  producer_token = var.wp_events_producer_token

  tags = {
    Project     = "legi-bit"
    Environment = var.env
  }
}

# ---------- ASG WordPress ----------
module "asg" {
  source = "../../modules/asg-wordpress"

  name   = "legi-bit"
  vpc_id = module.vpc.vpc_id

  subnet_ids = module.vpc.public_subnet_ids

  alb_sg_id        = module.alb.alb_security_group_id
  target_group_arn = module.alb.target_group_arn

  instance_type = var.asg_instance_type

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  wp_db_host     = module.rds.endpoint
  wp_db_name     = var.rds_db_name
  wp_db_user     = var.rds_db_username
  wp_db_password = var.rds_db_password

  efs_dns_name = module.efs.dns_name

  wp_events_producer_url   = module.wp_events.producer_function_url
  wp_events_producer_token = var.wp_events_producer_token
}


