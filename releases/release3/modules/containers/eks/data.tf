data "aws_iam_policy_document" "workers_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = [local.ec2_principal]
    }
  }
}


data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}


data "aws_iam_role" "custom_cluster_iam_role" {
  count = var.manage_cluster_iam_resources ? 0 : 1
  name  = var.cluster_iam_role_name
}

data "aws_iam_instance_profile" "custom_worker_group_iam_instance_profile" {
  count = var.manage_worker_iam_resources ? 0 : local.worker_group_count
  name = lookup(
    var.worker_groups[count.index],
    "iam_instance_profile_name",
    local.workers_group_defaults["iam_instance_profile_name"],
  )
}

data "aws_iam_instance_profile" "custom_worker_group_launch_template_iam_instance_profile" {
  count = var.manage_worker_iam_resources ? 0 : local.worker_group_launch_template_count
  name = lookup(
    var.worker_groups_launch_template[count.index],
    "iam_instance_profile_name",
    local.workers_group_defaults["iam_instance_profile_name"],
  )
}

data "aws_partition" "current" {}
