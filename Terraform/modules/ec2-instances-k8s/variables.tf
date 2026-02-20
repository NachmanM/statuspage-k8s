variable "instance_config" {
  type        = map(string)
  description = "EC2 instance config, has the keys: key, type, tag, role"
}

variable "image_path" {
  type        = string
  description = "Image path for the EC2 AMI"
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "processor" {
  type        = string
  description = "The AMI processor eg x86_64"
  default     = "x86_64"
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

# variable "region" {
#     type = string
#     description = "AWS region"
#     default = "us-east-1"
# }