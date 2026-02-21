output "instance_profile_name" {
  value       = aws_iam_instance_profile.k8s_node_profile.name
  sensitive   = false
  description = "Instance profile name for the k8s nodes"
}
