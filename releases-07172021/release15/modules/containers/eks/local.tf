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
    root_volume_size              = "100"                       # root volume size of workers instances.
    root_volume_type              = "gp3"                       # root volume type of workers instances, can be "standard", "gp3", "gp2", or "io1"
    root_iops                     = "0"                         # The amount of provisioned IOPS. This must be set with a volume_type of "io1".
    root_volume_throughput        = null                        # The amount of throughput to provision for a gp3 volume.
    ebs_optimized                 = true                        # sets whether to use ebs optimization on supported types.
    enable_monitoring             = true                        # Enables/disables detailed monitoring.
    enclave_support               = false                       # Enables/disables enclave support
    public_ip                     = false                       # Associate a public ip address with a worker
    subnets                       = var.private_subnets                 # A list of subnets to place the worker nodes in. i.e. ["subnet-123", "subnet-456", "subnet-789"]
    additional_security_group_ids = []                          # A list of additional security group ids to include in worker launch config
    protect_from_scale_in         = false                       # Prevent AWS from scaling in, so that cluster-autoscaler is solely responsible.
    iam_instance_profile_name     = ""                          # A custom IAM instance profile name. Used when manage_worker_iam_resources is set to false. Incompatible with iam_role_id.
    iam_role_id                   = "local.default_iam_role_id" # A custom IAM role id. Incompatible with iam_instance_profile_name.  Literal local.default_iam_role_id will never be used but if iam_role_id is not set, the local.default_iam_role_id interpolation will be used.
    suspended_processes           = ["AZRebalance"]             # A list of processes to suspend. i.e. ["AZRebalance", "HealthCheck", "ReplaceUnhealthy"]
    target_group_arns             = null                        # A list of Application LoadBalancer (ALB) target group ARNs to be associated to the autoscaling group
    load_balancers                = null                        # A list of Classic LoadBalancer (CLB)'s name to be associated to the autoscaling group
    enabled_metrics               = []                          # A list of metrics to be collected i.e. ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity"]
    placement_group               = null                        # The name of the placement group into which to launch the instances, if any.
    service_linked_role_arn       = ""                          # Arn of custom service linked role that Auto Scaling group will use. Useful when you have encrypted EBS
    termination_policies          = []                          # A list of policies to decide how the instances in the auto scale group should be terminated.
    platform                      = "linux"                     # Platform of workers. either "linux" or "windows"
    additional_ebs_volumes        = []                          # A list of additional volumes to be attached to the instances on this Auto Scaling group. Each volume should be an object with the following: block_device_name (required), volume_size, volume_type, iops, encrypted, kms_key_id (only on launch-template), delete_on_termination. Optional values are grabbed from root volume or from defaults
  }

  workers_group_defaults = merge(
    local.workers_group_defaults_defaults,
    var.workers_group_defaults,
  )


}
