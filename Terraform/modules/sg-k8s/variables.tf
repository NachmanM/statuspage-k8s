variable "vpc_name" {
  type        = string
  description = "The name of the VPC to deploy the infra, eg EC2 instance, SG"
  default     = "Default VPC"
}

variable "global_tag" {
  type        = string
  description = "Global AWS tag, to all resources created by this Terraform code"
  default     = "k8s-terraform-sandbox-nachman"
}