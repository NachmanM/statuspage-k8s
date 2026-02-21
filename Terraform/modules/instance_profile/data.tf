data "aws_iam_role" "k8s_nodes" {
  name = var.role_name
}
