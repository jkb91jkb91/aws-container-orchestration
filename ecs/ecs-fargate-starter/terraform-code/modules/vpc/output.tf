output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public1_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public1.id
}

output "public2_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public2.id
}


output "private1_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_1.id
}

output "private2_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_2.id
}


output "subnet1_id" {
  description = "subnet1_id"
  value       = aws_subnet.private_1.id
}

output "subnet2_id" {
  description = "subnet2_id"
  value       = aws_subnet.private_2.id
}
