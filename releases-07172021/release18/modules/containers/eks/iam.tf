################################### IAM roles and policies for master nodes #####################################
resource "aws_iam_role" "cluster" {
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       =  aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       =  aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceControllerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       =  aws_iam_role.cluster.name
}

/*
 Adding a policy to cluster IAM role that allow permissions
 required to create AWSServiceRoleForElasticLoadBalancing service-linked role by EKS during ELB provisioning
*/

#data "aws_iam_policy_document" "cluster_elb_sl_role_creation" {
#  count = var.manage_cluster_iam_resources && var.create_eks ? 1 : 0

#  statement {
#    effect = "Allow"
#    actions = [
#      "ec2:DescribeAccountAttributes",
#      "ec2:DescribeInternetGateways"
#    ]
#    resources = ["*"]
#  }
#}

#resource "aws_iam_policy" "cluster_elb_sl_role_creation" {
#  count       = var.manage_cluster_iam_resources && var.create_eks ? 1 : 0
#  name_prefix = "${var.cluster_name}-elb-sl-role-creation"
#  description = "Permissions for EKS to create AWSServiceRoleForElasticLoadBalancing service-linked role"
#  policy      = data.aws_iam_policy_document.cluster_elb_sl_role_creation[0].json
# path        = var.iam_path
#}

#resource "aws_iam_role_policy_attachment" "cluster_elb_sl_role_creation" {
#  count      = var.manage_cluster_iam_resources && var.create_eks ? 1 : 0
#  policy_arn = aws_iam_policy.cluster_elb_sl_role_creation[0].arn
#  role       = local.cluster_iam_role_name
#}


################################### IAM roles and policies for worker nodes #####################################

resource "aws_iam_role" "workers" {
  name = "workerrole"
  
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true
  #tags                  = var.tags
}

resource "aws_iam_instance_profile" "workers" {
  role = aws_iam_role.workers.name
  path = var.iam_path
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers.name
}

#resource "aws_iam_role_policy_attachment" "workers_additional_policies" {
#  count      = var.manage_worker_iam_resources && var.create_eks ? length(var.workers_additional_policies) : 0
#  role       = aws_iam_role.workers.name
#  policy_arn = var.workers_additional_policies[count.index]
#}
