data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "instance" {
  name        = "${var.name}-asg-sg"
  description = "ASG instances SG: allow HTTP only from ALB SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-asg-sg"
  }
}

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm" {
  count              = var.attach_ssm ? 1 : 0
  name               = "${var.name}-asg-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json

  tags = {
    Name = "${var.name}-asg-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  count      = var.attach_ssm ? 1 : 0
  role       = aws_iam_role.ssm[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  count = var.attach_ssm ? 1 : 0
  name  = "${var.name}-asg-ssm-instance-profile"
  role  = aws_iam_role.ssm[0].name

  tags = {
    Name = "${var.name}-asg-ssm-instance-profile"
  }
}

locals {
  user_data = templatefile("${path.module}/user_data_wordpress.sh.tftpl", {
    wp_db_host         = var.wp_db_host
    wp_db_name         = var.wp_db_name
    wp_db_user         = var.wp_db_user
    wp_db_password     = var.wp_db_password
    efs_dns_name       = var.efs_dns_name
    wp_container_image = var.wp_container_image

    wp_events_producer_url   = var.wp_events_producer_url
    wp_events_producer_token = var.wp_events_producer_token

    VER  = "v2.24.6"
    ARCH = "x86_64"
  })
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-wp-"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.instance.id]

  update_default_version = true

  dynamic "iam_instance_profile" {
    for_each = var.attach_ssm ? [1] : []
    content {
      name = aws_iam_instance_profile.ssm[0].name
    }
  }

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name}-asg-instance"
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name}-asg"
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  instance_refresh {
    strategy = "Rolling"
    triggers = ["launch_template"]

    preferences {
      instance_warmup        = 120
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-asg"
    propagate_at_launch = true
  }
}
