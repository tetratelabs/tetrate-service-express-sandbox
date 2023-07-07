output "vpc_id" {
  value = aws_vpc.tetrate.id
}

output "vpc_subnets" {
  value = aws_subnet.tetrate.*.id
}

output "registry" {
  value = aws_ecr_repository.tetrate.repository_url
}

output "registry_name" {
  value = aws_ecr_repository.tetrate.name
}

output "registry_id" {
  value = aws_ecr_repository.tetrate.registry_id
}

output "registry_username" {
  value = data.aws_ecr_authorization_token.token.user_name
}

output "registry_password" {
  value = data.aws_ecr_authorization_token.token.password
}

output "cidr" {
  value = var.cidr
}

