module "temp-init-master-node" {
  source                = "./modules/ec2-instances-k8s"
  instance_config       = local.master_init_node
  key_pair_name         = local.key_pair_name
  image_id              = local.image_id
  global_tag            = local.global_tag
  userdata_content      = file(local.userdata_path)
  instance_profile_name = module.instance_profile.control_plane_profile_name
  security_group_id     = module.sg-k8s.security_group_id
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
  userdata_content = filebase64(each.value["userdata_path"])

  global_tag = local.global_tag
  vpc_name   = local.vpc_name

  security_group_id     = module.sg-k8s.security_group_id

  instance_profile_name = each.value["instance_profile"]
  

}

module "nlb" {
  source             = "./modules/terraform-aws-alb"
  load_balancer_type = "network"
  name               = local.nlb_name
  vpc_id             = local.vpc_id
  subnets            = data.aws_subnets.all_subnets.ids

  create_security_group = false
  security_groups       = [module.sg-k8s.security_group_id]

  route53_records = {
    "master-nlb.nach-hi.click" = {
      zone_id = data.aws_route53_zone.primary.id
      type = "A"
      evaluate_target_health = true
      allow_overwrite = true
    }
  }
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