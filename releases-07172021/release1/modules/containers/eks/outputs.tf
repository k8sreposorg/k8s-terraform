output "cluster_id" {
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready"
  value       = element(concat(aws_eks_cluster.this.*.id, list("")), 0)
  # So that calling plans wait for the cluster to be available before attempting
  # to use it. They will not need to duplicate this null_resource
  depends_on = [null_resource.wait_for_cluster]
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = element(concat(aws_eks_cluster.this.*.arn, list("")), 0)
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = element(concat(aws_eks_cluster.this[*].certificate_authority[0].data, list("")), 0)
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = element(concat(aws_eks_cluster.this.*.endpoint, list("")), 0)
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = element(concat(aws_eks_cluster.this[*].version, list("")), 0)
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster. On 1.14 or later, this is the 'Additional security groups' in the EKS console."
  value       = local.cluster_security_group_id
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = kubernetes_config_map.aws_auth.*
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = local.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = local.cluster_iam_role_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = flatten(concat(aws_eks_cluster.this[*].identity[*].oidc.0.issuer, [""]))[0]
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console."
  value       = local.cluster_primary_security_group_id
}

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = element(concat(aws_cloudwatch_log_group.this[*].name, list("")), 0)
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = element(concat(aws_cloudwatch_log_group.this[*].arn, list("")), 0)
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = local.kubeconfig
}

output "kubeconfig_filename" {
  description = "The filename of the generated kubectl config."
  value       = concat(local_file.kubeconfig.*.filename, [""])[0]
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = var.enable_irsa ? concat(aws_iam_openid_connect_provider.oidc_provider[*].arn, [""])[0] : null
}

output "workers_asg_arns" {
  description = "IDs of the autoscaling groups containing workers."
  value = concat(
    aws_autoscaling_group.workers.*.arn,
  )
}

output "workers_asg_names" {
  description = "Names of the autoscaling groups containing workers."
  value = concat(
    aws_autoscaling_group.workers.*.id,
  )
}

#output "workers_user_data" {
#  description = "User data of worker groups"
#  value = concat(
#    data.template_file.userdata.*.rendered,
#    data.template_file.launch_template_userdata.*.rendered,
#  )
#}

#output "workers_default_ami_id" {
#  description = "ID of the default worker group AMI"
#  value       = data.aws_ami.eks_worker.id
#}




output "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers."
  value       = local.worker_security_group_id
}

output "worker_iam_instance_profile_arns" {
  description = "default IAM instance profile ARN for EKS worker groups"
  value = concat(
    aws_iam_instance_profile.workers.*.arn,
  )
}

output "worker_iam_instance_profile_names" {
  description = "default IAM instance profile name for EKS worker groups"
  value = concat(
    aws_iam_instance_profile.workers.*.name,
  )
}


output "security_group_rule_cluster_https_worker_ingress" {
  description = "Security group rule responsible for allowing pods to communicate with the EKS cluster API."
  value       = aws_security_group_rule.cluster_https_worker_ingress
}
