output "iam-instance-profile-for-workers" {
  value       = aws_iam_instance_profile.workers.id
}
output "iam-role-name-for-workers" {
  value       = aws_iam_role.workers.name
}
output "iam-role-arn-for-cluster" {
  value       = aws_iam_role.cluster.arn
}
output "masters-sg" {
  value       = aws_security_group.cluster.id
}
output "workers-sg" {
  value       = aws_security_group.workers.id
}
