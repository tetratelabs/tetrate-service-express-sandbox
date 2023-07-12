output "public_ip" {
  value = aws_instance.jumpbox.public_ip
}

output "jumpbox_iam_role_arn" {
  value = aws_iam_instance_profile.jumpbox_iam_profile.arn
}

output "pkey" {
  value = tls_private_key.generated.private_key_pem
}
