variable "instance_config" {
  type        = map(string)
  description = "EC2 instance config, has the keys: key, type, tag, role"
}

variable "image_id" {
  type        = string
  description = "Image id for the EC2 AMI"
}

variable "key_pair_name" {
  type        = string
  default     = "nachman-home-nitzanim"
  description = "The name of the key pair to apply to the EC2 instances"
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

variable "userdata_content" {
  type        = string
  description = "The path for the user data script"
}

# variable "region" {
#     type = string
#     description = "AWS region"
#     default = "us-east-1"
# }