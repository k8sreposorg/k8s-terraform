
resource "aws_autoscaling_group" "workers" {
  min_size = "1"
  desired_capacity = "1"
  max_size = "1"
 # target_group_arns = ""
  launch_configuration = aws_launch_configuration.workers.id
  vpc_zone_identifier = var.private_subnets

  dynamic "tag" {
    for_each = [
        {
          "key"                 = "kubernetes.io/cluster/${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}"
          "value"               = "owned"
          "propagate_at_launch" = true
        },
        {
          "key"                 = "k8s.io/cluster/${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}"
          "value"               = "owned"
          "propagate_at_launch" = true
        },
      ]
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

}

resource "aws_launch_configuration" "workers" {
  security_groups = [var.workers-sg]
  iam_instance_profile = var.iam-instance-profile-for-workers
  image_id = "ami-04a9624bc6addb65f"
  instance_type = "t2.medium"
  
  key_name = "ohio"
  user_data = base64encode(local.userdata)


  lifecycle {
    create_before_destroy = true
  }

#  depends_on = [
#    aws_security_group_rule.workers_egress_internet,
#    aws_security_group_rule.workers_ingress_self,
#    aws_security_group_rule.workers_ingress_cluster,
#    aws_security_group_rule.workers_ingress_cluster_kubelet,
#    aws_security_group_rule.workers_ingress_cluster_https,
#    aws_security_group_rule.workers_ingress_cluster_primary,
#    aws_security_group_rule.cluster_primary_ingress_workers,
#    aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy,
#    aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy,
#    aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly,
#    #aws_iam_role_policy_attachment.workers_additional_policies
#  ]
}


