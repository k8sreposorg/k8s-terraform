locals {

  cluster_security_group_id         = var.cluster_create_security_group ? join("", aws_security_group.cluster.*.id) : var.cluster_security_group_id
  cluster_primary_security_group_id = var.cluster_version >= 1.14 ? element(concat(aws_eks_cluster.this[*].vpc_config[0].cluster_security_group_id, list("")), 0) : null
  cluster_iam_role_name             = var.manage_cluster_iam_resources ? join("", aws_iam_role.cluster.*.name) : var.cluster_iam_role_name
  cluster_iam_role_arn              = var.manage_cluster_iam_resources ? join("", aws_iam_role.cluster.*.arn) : join("", data.aws_iam_role.custom_cluster_iam_role.*.arn)
  worker_security_group_id          = var.worker_create_security_group ? join("", aws_security_group.workers.*.id) : var.worker_security_group_id
  default_iam_role_id    = concat(aws_iam_role.workers.*.id, [""])[0]
  worker_group_count                 = length(var.worker_groups)
  ec2_principal = "ec2.${data.aws_partition.current.dns_suffix}"
  sts_principal = "sts.${data.aws_partition.current.dns_suffix}"
  policy_arn_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  workers_group_defaults_defaults = {
    name                          = "count.index"               # Name of the worker group. Literal count.index will never be used but if name is not set, the count.index interpolation will be used.
    tags                          = []                          # A list of map defining extra tags to be applied to the worker group autoscaling group.
    subnets                       = var.private_subnets                 # A list of subnets to place the worker nodes in. i.e. ["subnet-123", "subnet-456", "subnet-789"]
    iam_instance_profile_name     = ""                          # A custom IAM instance profile name. Used when manage_worker_iam_resources is set to false. Incompatible with iam_role_id.
    iam_role_id                   = "local.default_iam_role_id" # A custom IAM role id. Incompatible with iam_instance_profile_name.  Literal local.default_iam_role_id will never be used but if iam_role_id is not set, the local.default_iam_role_id interpolation will be used.
    platform                      = "linux"                     # Platform of workers. either "linux" or "windows"
  }

  workers_group_defaults = merge(
    local.workers_group_defaults_defaults,
    var.workers_group_defaults,
  )


}
