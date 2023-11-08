data "terraform_remote_state" "infra" {
  backend = "local"
  config = {
    path = "../../infra/${var.k8s_cluster["cloud"]}/terraform.tfstate.d/${var.k8s_cluster["cloud"]}-${var.cluster_id}-${var.region}/terraform.tfstate"
  }
}

data "terraform_remote_state" "k8s_auth" {
  backend = "local"
  config = {
    path = "../../infra/${var.k8s_cluster["cloud"]}/k8s_auth/terraform.tfstate.d/${var.k8s_cluster["cloud"]}-${var.cluster_id}-${var.region}/terraform.tfstate"
  }
}

data "terraform_remote_state" "tse_managementplane" {
  backend = "local"
  config = {
    path = "../tse_managementplane/terraform.tfstate"
  }
}

module "tse_controlplane" {
  source                           = "../../modules/tetrate/tse_controlplane"
  name_prefix                      = "${var.name_prefix}-${var.cluster_id}"
  cloud                            = var.k8s_cluster["cloud"]
  tetrate_version                  = local.tetrate.version
  tetrate_helm_repository          = local.tetrate.helm_repository
  tetrate_password                 = local.tetrate.password
  tetrate_managementplane_hostname = data.terraform_remote_state.tse_managementplane.outputs.tetrate_managementplane_hostname
  jumpbox_host                     = data.terraform_remote_state.infra.outputs.public_ip
  jumpbox_username                 = var.jumpbox_username
  jumpbox_pkey                     = data.terraform_remote_state.infra.outputs.pkey
  registry                         = data.terraform_remote_state.infra.outputs.registry
  cluster_name                     = data.terraform_remote_state.infra.outputs.cluster_name
  k8s_host                         = data.terraform_remote_state.infra.outputs.host
  k8s_cluster_ca_certificate       = data.terraform_remote_state.infra.outputs.cluster_ca_certificate
  k8s_client_token                 = data.terraform_remote_state.k8s_auth.outputs.token
  output_path                      = var.output_path
}