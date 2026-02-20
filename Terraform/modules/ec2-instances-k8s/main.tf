resource "aws_instance" "k8s-node" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_config["instance_type"]

  key_name               = var.key_pair_name
  vpc_security_group_ids = [var.security_group_id]
  tags = {
    Name = var.instance_config["key"]
    k8s  = var.instance_config["tag"]
    env  = var.global_tag

  }
}

resource "aws_ec2_instance_state" "start_instance" {
  instance_id = aws_instance.k8s-node.id
  state       = "running" 
}