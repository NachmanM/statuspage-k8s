resource "aws_security_group" "allow_http_ssh" {
  name        = "nach-hi-sg-nodes"
  description = "Allow SSH and all local traffic, and open nodeport ports"
  vpc_id      = data.aws_vpc.selected.id

  # All inline ingress and egress blocks have been removed
  # to prevent authoritative state conflicts.

  tags = {
    Name = "sg-${var.global_tag}"
    env  = var.global_tag
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_http_ssh.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_http_ssh.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_custom_ports" {
  security_group_id = aws_security_group.allow_http_ssh.id
  from_port         = 30000
  to_port           = 32000
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.allow_http_ssh.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "self_referencing_ingress" {
  for_each                     = toset(["tcp", "udp"])
  security_group_id            = aws_security_group.allow_http_ssh.id
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = each.key
  referenced_security_group_id = aws_security_group.allow_http_ssh.id
}