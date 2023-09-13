variable "cluster_name" {
}

variable "k8s_host" {
}

variable "k8s_cluster_ca_certificate" {
}

variable "k8s_client_token" {
}

variable "oidc_provider_arn" {
}

variable "cluster_oidc_issuer_url" {
  default = ""
}

variable "cluster_oidc_id" {
  default = ""
}

variable "service_account_namespace" {
    type = string
    default = "istio-system"
    description = "Kubernetes name space where the service account shall be created"
}

variable "service_account_name" {
    type = string
    default = "route53-controller"
    description = "Name of Service Account in kubernetes cluster."
}
