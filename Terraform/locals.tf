locals {
  # Global config
  global_tag = "nach-hi-status-page"
  vpc_id     = module.sg-k8s.vpc_id
  zone_name  = "nach-hi.click"

  # NLB Config
  nlb_name = "nach-hi-master"

  # Init ec2 config
  master_init_node = {
    amount        = 1
    instance_type = "t3.small"
    tag           = "tf-nach-master-node"
  }
  userdata_path = "./scripts/userdata_init.sh.tftpl"
  image_id      = "ami-0970689b372f08997"
  key_pair_name = "nachman-home-nitzanim"


  # Security group config  
  vpc_name = "Default VPC"

  # Instance profile config
  role_name = "nach-ecr-download-token"

  # Launch template and ASG configs
  nodes = {
    master_node = {
      instance_type = "t3.small"
      ami_id        = "ami-0970689b372f08997"
      node_tag      = "nach-hi-master-node"
      key_pair_name = "nachman-home-nitzanim"
      userdata_path = "./scripts/userdata_master_join.sh"
      min_amount    = 3
      max_amount    = 5
      instance_profile = module.instance_profile.control_plane_profile_name
    },
    worker_node = {
      instance_type = "t3.small"
      ami_id        = "ami-027e099ec1ea5a1f9"
      node_tag      = "nach-hi-worker-node"
      key_pair_name = "nachman-home-nitzanim"
      userdata_path = "./scripts/userdata_worker_join.sh"
      min_amount    = 2
      max_amount    = 5
      instance_profile = module.instance_profile.worker_profile_name
    }
  }
}
