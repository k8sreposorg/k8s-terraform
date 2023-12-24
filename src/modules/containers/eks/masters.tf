resource "aws_eks_cluster" "this" {
  name                      = var.cluster_name
  role_arn                  = var.iam-role-arn-for-cluster
  version                   = var.cluster_version
  vpc_config {
    security_group_ids      = [var.masters-sg]
    subnet_ids              = var.private_subnets
  }
  timeouts {
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
  }
#  depends_on = [
#    aws_security_group_rule.cluster_egress_internet,
#    aws_security_group_rule.cluster_https_worker_ingress,
#   aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
#    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
#    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceControllerPolicy,
#  ]
}


