resource "aws_instance" "k8s-node" {
  ami                    = var.image_id
  instance_type          = var.instance_config["instance_type"]
  user_data              = var.userdata_content
  iam_instance_profile   = var.instance_profile_name
  key_name               = var.key_pair_name
  vpc_security_group_ids = [var.security_group_id]
  tags = {
    Name = "nach-hi-temp-init-mater-node"
    k8s  = var.instance_config["tag"]
    env  = var.global_tag
  }
}