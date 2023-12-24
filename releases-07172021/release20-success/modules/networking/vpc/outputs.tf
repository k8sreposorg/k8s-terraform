output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.myvpc.id
}
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = [aws_subnet.privatesubnet1.id,aws_subnet.privatesubnet2.id]
}


output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = [aws_subnet.publicsubnet1.id,aws_subnet.publicsubnet2.id]
}

