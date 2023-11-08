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

resource "helm_release" "managementplane" {
  name             = "managementplane"
  repository       = var.tetrate_helm_repository
  chart            = "managementplane"
  version          = var.tetrate_version
  namespace        = "tse"
  create_namespace = true
  timeout          = 1200

  values = [templatefile("${path.module}/manifests/tetrate/managementplane-values.yaml.tmpl", {
    registry = var.registry
  })]
}

resource "time_sleep" "wait_60_seconds" {
  depends_on      = [helm_release.managementplane]
  create_duration = "60s"
}

data "kubernetes_service" "tetrate" {
  metadata {
    name      = "envoy"
    namespace = "tse"
  }
  depends_on = [time_sleep.wait_60_seconds]
}
