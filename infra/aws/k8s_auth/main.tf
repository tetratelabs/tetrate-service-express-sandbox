data "terraform_remote_state" "infra" {
  backend = "local"
  config = {
    path = "../terraform.tfstate.d/${var.cloud}-${var.cluster_id}-${var.region}/terraform.tfstate"
  }
}

module "aws_k8s_auth" {
  source       = "../../../modules/aws/k8s_auth"
  count        = var.region == null ? 0 : 1
  cluster_name = data.terraform_remote_state.infra.outputs.cluster_name
}
