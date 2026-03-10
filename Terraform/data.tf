data "aws_subnets" "all_subnets" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

data "aws_route53_zone" "primary" {
  name         = local.zone_name
  private_zone = false
}