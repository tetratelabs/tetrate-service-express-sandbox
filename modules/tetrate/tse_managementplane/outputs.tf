
output "ingress_ip" {
  value = data.kubernetes_service.tetrate.status[0].load_balancer[0].ingress[0].ip
}

output "ingress_hostname" {
  value = data.kubernetes_service.tetrate.status[0].load_balancer[0].ingress[0].hostname
}

output "password" {
  value     = coalesce(var.tetrate_password, random_password.tetrate.result)
  sensitive = true
}
