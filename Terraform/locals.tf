locals {

  image_path    = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  processor     = "x86_64"
  key_pair_name = "nachman-home-nitzanim"
  region        = "us-east-1"
  global_tag    = "k8s-terraform-sandbox-sp"
  vpc_name      = "Default VPC"


  instances_config = {
    master_node_sp = {
      amount        = 3
      instance_type = "t3.large"
      tag           = "tf-sp-master-node"
    }
    worker_node_sp = {
      amount        = 2
      instance_type = "t3.medium"
      tag           = "tf-sp-working-node"
    }
  }

  # 1. Iterate over each role (master/worker).
  # 2. Iterate 'amount' times using range().
  # 3. Create a distinct object for every single instance needed.
  instances_list = flatten([
    for role, config in local.instances_config : [
      for i in range(config.amount) : {
        # Create a unique identifier for the map key later
        key           = "${role}-${i}"
        instance_type = config.instance_type
        tag           = config.tag
        role          = role
      }
    ]
  ])

}