locals{
userdata = <<USERDATA
#!/bin/bash
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.this.endpoint}'   --b64-cluster-ca '${aws_eks_cluster.this.certificate_authority[0].data}'     '${aws_eks_cluster.this.name}'

USERDATA
}

resource "aws_autoscaling_group" "workers" {
  count = var.create_eks ? local.worker_group_count : 0
  name_prefix = join(
    "-",
    compact(
      [
        coalescelist(aws_eks_cluster.this[*].name, [""])[0],
        lookup(var.worker_groups[count.index], "name", count.index),
        lookup(var.worker_groups[count.index], "asg_recreate_on_change", local.workers_group_defaults["asg_recreate_on_change"]) ? random_pet.workers[count.index].id : ""
      ]
    )
  )
  min_size = "1"
  desired_capacity = "1"
  max_size = "1"
  target_group_arns = lookup(
    var.worker_groups[count.index],
    "target_group_arns",
    local.workers_group_defaults["target_group_arns"]
  )
  launch_configuration = aws_launch_configuration.workers.*.id[count.index]
  vpc_zone_identifier = lookup(
    var.worker_groups[count.index],
    "subnets",
    local.workers_group_defaults["subnets"]
  )

  dynamic "tag" {
    for_each = [
 #concat(
      
     #   {
     #     "key"                 = "Name"
     #     "value"               = "${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}-${lookup(var.worker_groups[count.index], "name", count.index)}-eks_asg"
      #    "propagate_at_launch" = true
      #  },
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
      #[
      #  for tag_key, tag_value in var.tags :
      #  map(
      #    "key", tag_key,
      #    "value", tag_value,
      #    "propagate_at_launch", "true"
      #  )
      #  if tag_key != "Name" && !contains([for tag in lookup(var.worker_groups[count.index], "tags", local.workers_group_defaults["tags"]) : tag["key"]], tag_key)
      #],
      #lookup(
      #  var.worker_groups[count.index],
      #  "tags",
      #  local.workers_group_defaults["tags"]
     # )
   # )
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

}

resource "aws_launch_configuration" "workers" {
  count       = var.create_eks ? local.worker_group_count : 0
  name_prefix = "${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}-${lookup(var.worker_groups[count.index], "name", count.index)}"
  associate_public_ip_address = lookup(
    var.worker_groups[count.index],
    "public_ip",
    local.workers_group_defaults["public_ip"],
  )
  security_groups = flatten([
    local.worker_security_group_id,
    var.worker_additional_security_group_ids,
    lookup(
      var.worker_groups[count.index],
      "additional_security_group_ids",
      local.workers_group_defaults["additional_security_group_ids"]
    )
  ])
  iam_instance_profile = coalescelist(
    aws_iam_instance_profile.workers.*.id,
    data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile.*.name,
  )[count.index]
  image_id = "ami-04a9624bc6addb65f"
  instance_type = "t2.medium"
  
  key_name = "ohio"
  user_data = base64encode(local.userdata)


  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_security_group_rule.workers_egress_internet,
    aws_security_group_rule.workers_ingress_self,
    aws_security_group_rule.workers_ingress_cluster,
    aws_security_group_rule.workers_ingress_cluster_kubelet,
    aws_security_group_rule.workers_ingress_cluster_https,
    aws_security_group_rule.workers_ingress_cluster_primary,
    aws_security_group_rule.cluster_primary_ingress_workers,
    aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.workers_additional_policies
  ]
}

resource "random_pet" "workers" {
  count = var.create_eks ? local.worker_group_count : 0

  separator = "-"
  length    = 2

  keepers = {
    lc_name = aws_launch_configuration.workers[count.index].name
  }

  lifecycle {
    create_before_destroy = true
  }
}

