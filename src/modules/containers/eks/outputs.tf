output "cluster_id" {
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready"
  value       = element(concat(aws_eks_cluster.this.*.id, list("")), 0)
   #So that calling plans wait for the cluster to be available before attempting
   #to use it. They will not need to duplicate this null_resource
# depends_on = [null_resource.wait_for_cluster]
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
