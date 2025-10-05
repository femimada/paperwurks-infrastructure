output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the VPC"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "CIDR block of the VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "IDs of public subnets"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "IDs of private subnets"
}

output "database_subnet_ids" {
  value       = aws_subnet.database[*].id
  description = "IDs of database subnets"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "Security group ID for ALB"
}

output "ecs_security_group_id" {
  value       = aws_security_group.ecs.id
  description = "Security group ID for ECS tasks"
}

output "rds_security_group_id" {
  value       = aws_security_group.rds.id
  description = "Security group ID for RDS"
}