provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
    token                  = var.k8s_client_token
  }
}

provider "kubectl" {
  host                   = var.k8s_host
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
  token                  = var.k8s_client_token
  load_config_file       = false
}

provider "kubernetes" {
  host                   = var.k8s_host
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
  token                  = var.k8s_client_token
}

resource "random_password" "tetrate" {
  length = 16
}

resource "helm_release" "managementplane" {
  name                = "managementplane"
  repository          = var.tetrate_helm_repository
  repository_username = var.tetrate_helm_repository_username
  repository_password = var.tetrate_helm_repository_password
  chart               = "managementplane"
  version             = var.tetrate_version
  namespace           = "tse"
  timeout             = 1200

  values = [templatefile("${path.module}/manifests/tetrate/managementplane-values.yaml.tmpl", {
    registry     = var.registry
    tetrate_password = coalesce(var.tetrate_password, random_password.tetrate.result)
  })]
}

resource "time_sleep" "wait_240_seconds" {
  depends_on      = [helm_release.managementplane]
  create_duration = "240s"
}

data "kubernetes_service" "tetrate" {
  metadata {
    name      = "envoy"
    namespace = "tetrate"
  }
  depends_on = [time_sleep.wait_240_seconds]
}
