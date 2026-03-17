resource "aws_launch_template" "nach-hi" {
  name_prefix   = var.node_tag
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = var.userdata_content

  # 1. Network Security
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name

  # 2. Identity (Zero-Trust)
  iam_instance_profile {
    name = var.instance_profile_name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      env  = var.node_tag
      Name = var.global_tag
      type = var.node_tag
      DoNotDelete  = true
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      env = var.global_tag
    }
  }

  # 3. Tags for the Template itself (NOT the instances)

    
}


resource "aws_autoscaling_group" "k8s-nodes" {
  name                = "asg-${var.node_tag}"
  vpc_zone_identifier = data.aws_subnets.all_subnets.ids

  target_group_arns = var.tg_arns

  # Scaling Boundaries
  min_size         = var.min_amount
  max_size         = var.max_amount
  desired_capacity = var.min_amount

  # Health Tracking
  health_check_type         = "ELB"
  health_check_grace_period = 1200

  # Linking the Blueprint
  launch_template {
    id      = aws_launch_template.nach-hi.id
    version = "$Latest"
  }

  # The Rolling Update Strategy
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}