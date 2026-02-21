variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "description"
}

variable "ami_id" {
  type = string
}

variable "node_tag" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "userdata_content" {
  type = string
}

variable "global_tag" {
  type        = string
  description = "A tag to all objects created by terraform"
  default     = "k8s-terraform-sandbox"
}

variable "security_group_id" {
  type        = string
  description = "Security group id from the module sg-k8s, for the EC2 instance nodes"
}

variable "instance_profile_name" {
  type        = string
  description = "Instance profile name for the k8s nodes"
}

variable "min_amount" {
  type        = number
  description = "Amount of min ec2 nodes"
}

variable "max_amount" {
  type        = number
  description = "Amount of max ec2 nodes"
}

variable "vpc_name" {
  type = string
}