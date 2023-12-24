locals{
userdata = <<USERDATA
#!/bin/bash
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.this[0].endpoint}'   --b64-cluster-ca '${aws_eks_cluster.this[0].certificate_authority[0].data}'     '${aws_eks_cluster.this[0].name}'

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
   

#  force_delete = lookup(
#    var.worker_groups[count.index],
#    "asg_force_delete",
#    local.workers_group_defaults["asg_force_delete"],
#  )
  target_group_arns = lookup(
    var.worker_groups[count.index],
    "target_group_arns",
    local.workers_group_defaults["target_group_arns"]
  )
#  load_balancers = lookup(
#    var.worker_groups[count.index],
#    "load_balancers",
#    local.workers_group_defaults["load_balancers"]
#  )
#  service_linked_role_arn = lookup(
#    var.worker_groups[count.index],
#    "service_linked_role_arn",
#    local.workers_group_defaults["service_linked_role_arn"],
  #)
  launch_configuration = aws_launch_configuration.workers.*.id[count.index]
  vpc_zone_identifier = lookup(
    var.worker_groups[count.index],
    "subnets",
    local.workers_group_defaults["subnets"]
  )
#  protect_from_scale_in = lookup(
#    var.worker_groups[count.index],
#    "protect_from_scale_in",
#    local.workers_group_defaults["protect_from_scale_in"],
#  )
#  suspended_processes = lookup(
#    var.worker_groups[count.index],
#    "suspended_processes",
#    local.workers_group_defaults["suspended_processes"]
#  )
#  enabled_metrics = lookup(
#    var.worker_groups[count.index],
#    "enabled_metrics",
#    local.workers_group_defaults["enabled_metrics"]
#  )
#  placement_group = lookup(
#    var.worker_groups[count.index],
#    "placement_group",
#    local.workers_group_defaults["placement_group"],
#  )
#  termination_policies = lookup(
#    var.worker_groups[count.index],
#    "termination_policies",
#    local.workers_group_defaults["termination_policies"]
#  )
#  max_instance_lifetime = lookup(
#    var.worker_groups[count.index],
#    "max_instance_lifetime",
#    local.workers_group_defaults["max_instance_lifetime"],
#  )
#  default_cooldown = lookup(
#    var.worker_groups[count.index],
#    "default_cooldown",
#    local.workers_group_defaults["default_cooldown"]
#  )
#  health_check_type = lookup(
#    var.worker_groups[count.index],
#    "health_check_type",
#    local.workers_group_defaults["health_check_type"]
#  )
#  health_check_grace_period = lookup(
#    var.worker_groups[count.index],
#    "health_check_grace_period",
#    local.workers_group_defaults["health_check_grace_period"]
#  )

#  dynamic "initial_lifecycle_hook" {
#    for_each = var.worker_create_initial_lifecycle_hooks ? lookup(var.worker_groups[count.index], "asg_initial_lifecycle_hooks", local.workers_group_defaults["asg_initial_lifecycle_hooks"]) : []
#    content {
#      name                    = initial_lifecycle_hook.value["name"]
#      lifecycle_transition    = initial_lifecycle_hook.value["lifecycle_transition"]
#      notification_metadata   = lookup(initial_lifecycle_hook.value, "notification_metadata", null)
#      heartbeat_timeout       = lookup(initial_lifecycle_hook.value, "heartbeat_timeout", null)
#      notification_target_arn = lookup(initial_lifecycle_hook.value, "notification_target_arn", null)
#      role_arn                = lookup(initial_lifecycle_hook.value, "role_arn", null)
#      default_result          = lookup(initial_lifecycle_hook.value, "default_result", null)
#    }
#  }

  dynamic "tag" {
    for_each = concat(
      [
        {
          "key"                 = "Name"
          "value"               = "${coalescelist(aws_eks_cluster.this[*].name, [""])[0]}-${lookup(var.worker_groups[count.index], "name", count.index)}-eks_asg"
          "propagate_at_launch" = true
        },
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
      ],
      [
        for tag_key, tag_value in var.tags :
        map(
          "key", tag_key,
          "value", tag_value,
          "propagate_at_launch", "true"
        )
        if tag_key != "Name" && !contains([for tag in lookup(var.worker_groups[count.index], "tags", local.workers_group_defaults["tags"]) : tag["key"]], tag_key)
      ],
      lookup(
        var.worker_groups[count.index],
        "tags",
        local.workers_group_defaults["tags"]
      )
    )
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

#  lifecycle {
#    create_before_destroy = true
#    ignore_changes        = [desired_capacity]
#  }
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
ebs_optimized = lookup(
    var.worker_groups[count.index],
    "ebs_optimized",
    !contains(
      local.ebs_optimized_not_supported,
      lookup(
        var.worker_groups[count.index],
        "instance_type",
        local.workers_group_defaults["instance_type"]
      )
    )
  )

  #ebs_optimized = "true"
  enable_monitoring = lookup(
    var.worker_groups[count.index],
    "enable_monitoring",
    local.workers_group_defaults["enable_monitoring"],
  )
  spot_price = lookup(
    var.worker_groups[count.index],
    "spot_price",
    local.workers_group_defaults["spot_price"],
  )
  placement_tenancy = lookup(
    var.worker_groups[count.index],
    "placement_tenancy",
    local.workers_group_defaults["placement_tenancy"],
  )

  root_block_device {
    encrypted = lookup(
      var.worker_groups[count.index],
      "root_encrypted",
      local.workers_group_defaults["root_encrypted"],
    )
    volume_size = lookup(
      var.worker_groups[count.index],
      "root_volume_size",
      local.workers_group_defaults["root_volume_size"],
    )
    volume_type = lookup(
      var.worker_groups[count.index],
      "root_volume_type",
      local.workers_group_defaults["root_volume_type"],
    )
    iops = lookup(
      var.worker_groups[count.index],
      "root_iops",
      local.workers_group_defaults["root_iops"],
    )
    delete_on_termination = true
  }

  dynamic "ebs_block_device" {
    for_each = lookup(var.worker_groups[count.index], "additional_ebs_volumes", local.workers_group_defaults["additional_ebs_volumes"])

    content {
      device_name = ebs_block_device.value.block_device_name
      volume_size = lookup(
        ebs_block_device.value,
        "volume_size",
        local.workers_group_defaults["root_volume_size"],
      )
      volume_type = lookup(
        ebs_block_device.value,
        "volume_type",
        local.workers_group_defaults["root_volume_type"],
      )
      iops = lookup(
        ebs_block_device.value,
        "iops",
        local.workers_group_defaults["root_iops"],
      )
      encrypted = lookup(
        ebs_block_device.value,
        "encrypted",
        local.workers_group_defaults["root_encrypted"],
      )
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  # Prevent premature access of security group roles and policies by pods that
  # require permissions on create/destroy that depend on workers.
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

