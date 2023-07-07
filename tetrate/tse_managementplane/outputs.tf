output "registry" {
  value = data.terraform_remote_state.infra.outputs.registry
}

output "tetrate_managementplane_hostname" {
  value = module.tse_managementplane.ingress_hostname
}

output "tetrate_managementplane_username" {
  value = "tse"
}

output "tetrate_managementplane_password" {
  value     = module.tse_managementplane.password
  sensitive = false
}
