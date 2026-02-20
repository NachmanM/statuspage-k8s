resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh_sp"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #   ingress {
  #     from_port   = 0
  #     to_port     = 655535
  #     protocol    = "-1"
  #     self     = true
  #   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-${var.global_tag}"
    env  = var.global_tag
  }
}

resource "aws_vpc_security_group_ingress_rule" "self_referencing_ingress" {
  security_group_id = aws_security_group.allow_http_ssh.id
  from_port         = 0
  to_port           = 65535    # Allows all ports, adjust as needed
  ip_protocol       = each.key # Protocol, e.g., "tcp", "udp", "-1" for all

  # Reference the security group itself as the source
  referenced_security_group_id = aws_security_group.allow_http_ssh.id
  for_each                     = toset(["tcp", "udp"])
}