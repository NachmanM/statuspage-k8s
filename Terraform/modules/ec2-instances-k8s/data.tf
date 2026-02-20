data "aws_ami" "ami" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = [var.image_path] # image path eg ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
