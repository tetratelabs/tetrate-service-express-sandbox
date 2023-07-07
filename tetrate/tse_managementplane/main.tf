data "terraform_remote_state" "infra" {
  backend = "local"
  config = {
    path = "../../infra/${var.k8s_cluster["cloud"]}/terraform.tfstate.d/${var.k8s_cluster["cloud"]}-${var.k8s_cluster["cluster_id"]}-${var.region}/terraform.tfstate"
  }
}

data "terraform_remote_state" "k8s_auth" {
  backend = "local"
  config = {
    path = "../../infra/${var.k8s_cluster["cloud"]}/k8s_auth/terraform.tfstate.d/${var.k8s_cluster["cloud"]}-${var.k8s_cluster["cluster_id"]}-${var.region}/terraform.tfstate"
  }
}

module "tse_managementplane" {
  source                           = "../../modules/tetrate/tse_managementplane"
  tetrate_version                  = local.tetrate.version
  tetrate_helm_repository          = local.tetrate.helm_repository
  tetrate_helm_repository_username = local.tetrate.image_sync_username
  tetrate_helm_repository_password = local.tetrate.image_sync_apikey
  tetrate_password                 = local.tetrate.password
  registry                         = data.terraform_remote_state.infra.outputs.registry
  k8s_host                         = data.terraform_remote_state.infra.outputs.host
  k8s_cluster_ca_certificate       = data.terraform_remote_state.infra.outputs.cluster_ca_certificate
  k8s_client_token                 = data.terraform_remote_state.k8s_auth.outputs.token
}
