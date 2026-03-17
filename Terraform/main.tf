module "temp-init-master-node" {
  source                = "./modules/ec2-instances-k8s"
  instance_config       = local.master_init_node
  key_pair_name         = local.key_pair_name
  image_id              = local.image_id
  global_tag            = local.global_tag
  userdata_content      = file(local.userdata_path)
  instance_profile_name = module.instance_profile.control_plane_profile_name
  security_group_id     = module.sg-k8s.security_group_id
  tg_arn                = module.nlb.target_groups["api_server_tg_nach_hi"].arn
}



module "launch_template_ASG" {
  source = "./modules/launch_template_ASG"

  for_each         = local.nodes
  instance_type    = each.value["instance_type"]
  ami_id           = each.value["ami_id"]
  node_tag         = each.value["node_tag"]
  key_pair_name    = each.value["key_pair_name"]
  min_amount       = each.value["min_amount"]
  max_amount       = each.value["max_amount"]
  tg_arns          = each.value["tg_arns"]
  userdata_content = filebase64(each.value["userdata_path"])

  global_tag = local.global_tag
  vpc_name   = local.vpc_name

  security_group_id     = module.sg-k8s.security_group_id

  instance_profile_name = each.value["instance_profile"]
  

}


module "sg-k8s" {
  source     = "./modules/sg-k8s"
  vpc_name   = local.vpc_name
  global_tag = local.global_tag
}



module "instance_profile" {
  source    = "./modules/instance_profile"
  role_name = local.role_name
}


# NLB + ALB using the same module
module "nlb" {
  source             = "./modules/terraform-aws-alb"
  load_balancer_type = "network"
  name               = local.nlb_name
  vpc_id             = local.vpc_id
  subnets            = data.aws_subnets.all_subnets.ids

  create_security_group = false
  security_groups       = [module.sg-k8s.security_group_id]

  # Enable Cross-Zone Routing
  enable_cross_zone_load_balancing = true
  
  route53_records = {
    "master-nlb.nach-hi.click" = {
      zone_id                = data.aws_route53_zone.primary.id
      type                   = "A"
      evaluate_target_health = true
      allow_overwrite        = true
    }
  }

  target_groups = {
    api_server_tg_nach_hi = {
      name_prefix = "api-"
      protocol    = "TCP"
      port        = 6443
      target_type = "instance"

      create_attachment = false
    }
  }

  listeners = {
    tcp_6443 = {
      port     = 6443
      protocol = "TCP"
      forward = {
        target_group_key = "api_server_tg_nach_hi"
      }
    }
  }
}


module "alb" {
  source             = "./modules/terraform-aws-alb"
  load_balancer_type = "application"
  name               = local.alb_name
  vpc_id             = local.vpc_id
  subnets            = data.aws_subnets.all_subnets.ids

  create_security_group = false
  security_groups       = [module.sg-k8s.security_group_id_alb]

  route53_records = {
    "sp.nach-hi.click" = {
      zone_id                = data.aws_route53_zone.primary.id
      type                   = "A"
      evaluate_target_health = true
      allow_overwrite        = true
    }
  }

  target_groups = {
    nach_hi_worker_nodes = {
      name_prefix = "api-"
      protocol    = "HTTP"
      port        = 30007
      target      = "instance"

      create_attachment = false
    }
  }

  listeners = {
    tcp_6443 = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "nach_hi_worker_nodes"
      }
    }
  }
}



