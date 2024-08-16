output "vpc_id" {
  description = "El ID de la VPC creada."
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  description = "El ID de la subnet pública."
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "El ID de la subnet privada."
  value       = aws_subnet.private_subnet.id
}

output "internet_gateway_id" {
  description = "El ID del Internet Gateway."
  value       = aws_internet_gateway.igw.id
}
