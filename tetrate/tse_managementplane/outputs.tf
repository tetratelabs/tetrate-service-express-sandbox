output "ingress_ip" {
  value = module.tse_managementplane.ingress_ip
}

output "ingress_hostname" {
  value = module.tse_managementplane.ingress_hostname
}

output "registry" {
  value = data.terraform_remote_state.infra.outputs.registry
}

output "tsb_password" {
  value     = module.tse_managementplane.password
  sensitive = true
}
