resource "aws_iam_instance_profile" "k8s_node_profile" {
  name = "nach_hi_k8s_node_profile"
  role = data.aws_iam_role.k8s_nodes.name
}